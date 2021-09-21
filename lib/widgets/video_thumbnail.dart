
import 'package:firebase_assignment/widgets/video_view.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'my_video_player.dart';

class VideoItem extends StatefulWidget {
  VideoItem({required this.dataSource,Key? key}):super(key: key);
  final String dataSource;
  @override
  _VideoItemState createState() => _VideoItemState();
}


class _VideoItemState extends State<VideoItem> {
 late  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.dataSource)
      ..initialize().then((_) {
        setState(() {});  //when your thumbnail will show.
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VideoView(url: widget.dataSource,),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : CircularProgressIndicator(),
          ),
          Container(child: Icon(Icons.play_circle_outline,size: 50,color: Colors.white,),color: Colors.black.withOpacity(0.2),)
        ],
      ),
    );
  }
}