import 'package:firebase_assignment/upload_media.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../topics.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with SingleTickerProviderStateMixin{
  final AuthService _authService = AuthService();
  late final TabController _tabController;
  var _currentTap=0;
  Future<void> _unSubscribeChannel() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(Topics.ALL_USERS);
  }

  void _handleUploadMedia() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return UploadMedia(mediaType: _tabController.index);
    }));
  }
  @override
  void initState() {
    super.initState();
    _tabController=TabController(length: 3, vsync: this);
    _tabController.addListener(_updateTab);
  }
  _updateTab(){
    setState(() {
      _currentTap=_tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AdminHome"),
        actions: [
          TextButton(
              onPressed: () async {
                await _unSubscribeChannel();
                await _authService.logOut();
              },
              child: Text(
                "Sign-Out",
                style: TextStyle(color: Colors.white),
              ))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Text("Photos"),Text("Videos"),Text("PDFS")],
        ),
      ),
      body: TabBarView(children: [
        Container(key: Key("Photos"),child: Center(child: Text("Photos"),),),
        Container(key: Key("video"),child: Center(child: Text("video"),),),
        Container(key: Key("PDFS"),child: Center(child: Text("PDFS"),),),
      ],controller: _tabController,),
      floatingActionButton: _currentTap!=2?FloatingActionButton(
        onPressed: _handleUploadMedia,
        child: Icon(Icons.add),
      ):null,
    );
  }
}
