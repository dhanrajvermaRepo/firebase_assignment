
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_assignment/auth_service.dart';
import 'package:firebase_assignment/content_type.dart';
import 'package:firebase_assignment/modals/content.dart';
import 'package:firebase_assignment/repository/fire_base_storage_service.dart';
import 'package:firebase_assignment/repository/firestore_services.dart';
import 'package:flutter/material.dart';

class UploadPdf extends StatefulWidget {
  @override
  _UploadPdfState createState() => _UploadPdfState();
}

class _UploadPdfState extends State<UploadPdf> {
  FilePickerResult? result;
 final FirebaseStorageService _firebaseStorageService =FirebaseStorageService();
 final FireStoreService _fireStoreService =FireStoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("UploadPdf"),),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: ()async{
        result = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf']);
        // if(result!=null && result!.files[0].size>2*1024*1024){
        //   print("file size is greater that 2MB");
        //   return;
        // }
        _uploadMedia();
      },),
    );
  }
  void _uploadMedia()async{
    var path='pdfs/${result!.files[0].name}';

    try {
      print("123 ${result!.files[0].path!}");
        _firebaseStorageService.uploadFile(result!.files[0].path!, path);
      var url = await _firebaseStorageService.downloadURL(path);
      var content=Content(type: ContentType.PDF, uploadedBy: AuthService().currentUser!.uid, url: url);
      await _fireStoreService.uploadContent(content);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF uploaded")));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    }
  }
}
