import 'package:flutter/material.dart';

import 'my_video_player.dart';

class VideoView extends StatelessWidget {
 const VideoView({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video view"),),
      body: Center(
        child: SizedBox(height: 200,width: MediaQuery.of(context).size.width,child: DefaultPlayer(fromNetwork: true,url: url,),),
      ),
    );
  }
}
