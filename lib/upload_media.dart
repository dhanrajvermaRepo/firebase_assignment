import 'package:firebase_assignment/auth_service.dart';
import 'package:firebase_assignment/content_type.dart';
import 'package:firebase_assignment/modals/content.dart';
import 'package:firebase_assignment/repository/fire_base_storage_service.dart';
import 'package:firebase_assignment/repository/firestore_services.dart';
import 'package:firebase_assignment/widgets/my_video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';


class UploadMedia extends StatefulWidget {
  const UploadMedia({required this.mediaType});
  final int mediaType;
  @override
  _UploadMediaState createState() => _UploadMediaState();
}
class _UploadMediaState extends State<UploadMedia> {
  List<XFile>? _imageFileList;
  bool _uploadDone=false;
  UploadTask? _task;
  final FireStoreService _fireStoreService=FireStoreService();
  final FirebaseStorageService _firebaseStorageService=FirebaseStorageService();
  XFile? videoFile;

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : [value];
  }

  dynamic _pickImageError;
  bool isVideo = false;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    _uploadDone=false;
    if (isVideo) {
      final XFile? file = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      setState(() {
        videoFile=file;
      });
    } else if (isMultiImage) {
      await _displayPickImageDialog(context!,
              (double? maxWidth, double? maxHeight, int? quality) async {
            try {
              final pickedFileList = await _picker.pickMultiImage(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                imageQuality: quality,
              );
              setState(() {
                _imageFileList = pickedFileList;
              });
            } catch (e) {
              setState(() {
                _pickImageError = e;
              });
            }
          });
    } else {
      await _displayPickImageDialog(context!,
              (double? maxWidth, double? maxHeight, int? quality) async {
            try {
              final pickedFile = await _picker.pickImage(
                source: source,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                imageQuality: quality,
              );
              setState(() {
                _imageFile = pickedFile;
              });
            } catch (e) {
              setState(() {
                _pickImageError = e;
              });
            }
          });
    }
  }

  @override
  void dispose() {
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (videoFile == null||videoFile?.path==null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DefaultPlayer(fromNetwork: false,file: File(videoFile!.path),),
    );
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
          child: ListView.builder(
            key: UniqueKey(),
            itemBuilder: (context, index) {
              // Why network for web?
              // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
              return Semantics(
                label: 'image_picker_example_picked_image',
                child: kIsWeb
                    ? Image.network(_imageFileList![index].path)
                    : Image.file(File(_imageFileList![index].path)),
              );
            },
            itemCount: _imageFileList!.length,
          ),
          label: 'image_picker_example_picked_images');
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    if (isVideo) {
      return _previewVideo();
    } else {
      return _previewImages();
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      _uploadDone=false;
      if (response.type == RetrieveType.video) {
        isVideo = true;
        setState(() {
          videoFile=response.file;
        });
      } else {
        isVideo = false;
        setState(() {
          _imageFile = response.file;
          _imageFileList = response.files;
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  void _uploadMedia()async{
    if(_uploadDone)return;
    var path=widget.mediaType==0?'images/${_imageFileList![0].name}':'videos/${videoFile!.name}';
     setState(() {
       _task=_firebaseStorageService.uploadFile(widget.mediaType==0?_imageFileList![0].path:videoFile!.path, path);
     });
    try {
      TaskSnapshot snapshot = await _task!;
     var url = await _firebaseStorageService.downloadURL(path);
     var content=Content(type: widget.mediaType==0?ContentType.IMAGE:ContentType.VIDEO, uploadedBy: AuthService().currentUser!.uid, url: url);
     await _fireStoreService.uploadContent(content);
      _uploadDone=true;
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.mediaType==0?"Image uploaded":"Video uploaded ")));
    } on FirebaseException catch (e) {
      print(_task!.snapshot);
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    }
  }

  Widget _uploadButton(){
    if((videoFile!=null&&videoFile!.path!=null ||_imageFileList!=null && _imageFileList!.length>0 && _imageFileList![0].path!=null)&&_task!=null){
      return StreamBuilder(builder: (context,AsyncSnapshot<TaskSnapshot> snap){
        if(snap.hasData&& snap.data!=null){
          return CircularPercentIndicator(
            radius: 66.0,
            lineWidth: 10.0,
            percent: snap.data!.bytesTransferred/snap.data!.totalBytes,
            center: FloatingActionButton(onPressed: _uploadMedia,key: Key("upload"),child: Icon(Icons.cloud_upload),backgroundColor: Colors.red,),
            backgroundColor: Colors.grey,
            progressColor: Colors.blue,
          );
        }else{
          return FloatingActionButton(onPressed: _uploadMedia,key: Key("upload"),child: Icon(Icons.cloud_upload),backgroundColor: Colors.red,);
        }
      },stream: _task!.snapshotEvents,);
    }else if((videoFile!=null&&videoFile!.path!=null ||_imageFileList!=null && _imageFileList!.length>0 && _imageFileList![0].path!=null)){
      return FloatingActionButton(onPressed: _uploadMedia,key: Key("upload"),child: Icon(Icons.cloud_upload),backgroundColor: Colors.red,);
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Media"),),
      body: Center(
        child: SizedBox(
          height: 200,
          child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? FutureBuilder<void>(
            future: retrieveLostData(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Text(
                    'You have not yet picked any media.',
                    textAlign: TextAlign.center,
                  );
                case ConnectionState.done:
                  return _handlePreview();
                default:
                  if (snapshot.hasError) {
                    return Text(
                      'Pick image/video error: ${snapshot.error}}',
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return const Text(
                      'You have not yet picked an image.',
                      textAlign: TextAlign.center,
                    );
                  }
              }
            },
          )
              : _handlePreview(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _uploadButton(),
          if(widget.mediaType==0)
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 16.0),
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       isVideo = false;
          //       _onImageButtonPressed(
          //         ImageSource.gallery,
          //         context: context,
          //         isMultiImage: true,
          //       );
          //     },
          //     heroTag: 'image1',
          //     tooltip: 'Pick Multiple Image from gallery',
          //     child: const Icon(Icons.photo_library),
          //   ),
          // ),
          if(widget.mediaType==0)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'image2',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          if(widget.mediaType==1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
              heroTag: 'video0',
              tooltip: 'Pick Video from gallery',
              child: const Icon(Icons.video_library),
            ),
          ),
          if(widget.mediaType==1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'video1',
              tooltip: 'Take a Video',
              child: const Icon(Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                  InputDecoration(hintText: "Enter maxWidth if desired"),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                  InputDecoration(hintText: "Enter maxHeight if desired"),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration:
                  InputDecoration(hintText: "Enter quality if desired"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}
typedef void OnPickImageCallback(
    double? maxWidth, double? maxHeight, int? quality);

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
