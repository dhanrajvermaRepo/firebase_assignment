import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

class DefaultPlayer extends StatefulWidget {
  DefaultPlayer({required this.fromNetwork,this.file,this.url,Key? key}) : super(key: key);
  final bool fromNetwork;
  final File? file;
  final String? url;
  @override
  _DefaultPlayerState createState() => _DefaultPlayerState();
}

class _DefaultPlayerState extends State<DefaultPlayer> {
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    if(widget.fromNetwork){
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(
          widget.url!,
          videoPlayerOptions: VideoPlayerOptions()
          // closedCaptionFile: _loadCaptions(),
        ),
      );
    }else{
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.file(widget.file!,videoPlayerOptions: VideoPlayerOptions()),
      );
    }

  }

  ///If you have subtitle assets
  // Future<ClosedCaptionFile> _loadCaptions() async {
  //   final String fileContents = await DefaultAssetBundle.of(context)
  //       .loadString('images/bumble_bee_captions.srt');
  //   return SubRipCaptionFile(fileContents);
  // }

  ///If you have subtitle urls
  // Future<ClosedCaptionFile> _loadCaptions() async {
  //   final url = Uri.parse('SUBTITLE URL LINK');
  //   try {
  //     final data = await http.get(url);
  //     final srtContent = data.body.toString();
  //     print(srtContent);
  //     return SubRipCaptionFile(srtContent);
  //   } catch (e) {
  //     print('Failed to get subtitles for ${e}');
  //     return SubRipCaptionFile('');
  //   }
  //}

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickManager.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager.flickControlManager?.autoResume();
        }
      },
      child: Container(
        child: FlickVideoPlayer(
          flickManager: flickManager,
          flickVideoWithControls: FlickVideoWithControls(
            controls: FlickPortraitControls(),
            videoFit: BoxFit.scaleDown,
          ),
          flickVideoWithControlsFullscreen: FlickVideoWithControls(
            controls: FlickLandscapeControls(),
          ),
        ),
      ),
    );
  }
}
