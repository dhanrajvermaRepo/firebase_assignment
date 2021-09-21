import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_assignment/modals/app_user.dart';
import 'package:firebase_assignment/modals/content.dart';
import 'package:firebase_assignment/repository/firestore_services.dart';
import 'package:firebase_assignment/upload_media.dart';
import 'package:firebase_assignment/widgets/loading.dart';
import 'package:firebase_assignment/widgets/video_thumbnail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'content_type.dart';
import 'topics.dart';

class UserHome extends StatefulWidget {
  UserHome({required this.user});
  final KCUser user;
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  final FireStoreService _fireStoreService = FireStoreService();
  late final TabController _tabController;
  var _currentTap = 0;
  Future<void> _unSubscribeChannel() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(Topics.ALL_USERS);
  }

  void _handleUploadMedia() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return UploadMedia(mediaType: _tabController.index);
    }));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_updateTab);
  }

  _updateTab() {
    setState(() {
      _currentTap = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.isAdmin ? "AdminHome" : "UserHome"),
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
          tabs: [
            Tab(
              key: Key("Photos"),
              text: "Photos",
            ),
            Tab(
              key: Key("Videos"),
              text: "Videos",
            ),
            Tab(
              key: Key("PDFS"),
              text: "PDFS",
            )
          ],
        ),
      ),
      body: StreamBuilder(
        builder:
            (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
          if (snap.hasData) {
            var content = <Content>[];
            var videos = <Content>[];
            var images = <Content>[];
            snap.data?.docs.forEach((element) {
              content.add(Content.fromJson(element.data()));
            });
            videos = content
                .where((element) => element.type == ContentType.VIDEO)
                .toList();
            images = content
                .where((element) => element.type == ContentType.IMAGE)
                .toList();
            return TabBarView(
              children: [
                GridView.builder(
                  padding: EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 100,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemBuilder: (conntext, index) {
                    return Container(
                      color: Colors.black,
                      child: CachedNetworkImage(
                        imageUrl: images[index].url,
                        placeholder: (_, __) =>
                            Center(child: CircularProgressIndicator()),
                      ),
                    );
                  },
                  itemCount: images.length,
                ),
                GridView.builder(
                  padding: EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 100,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemBuilder: (conntext, index) {
                    return Container(
                      color: Colors.black,
                      child: VideoItem(
                        dataSource: videos[index].url,
                      ),
                    );
                  },
                  itemCount: videos.length,
                ),
                Container(
                  key: Key("PDFS"),
                  child: Center(
                    child: Text("PDFS"),
                  ),
                ),
              ],
              controller: _tabController,
            );
          } else {
            return Loading();
          }
        },
        stream: _fireStoreService.getContentInRealTime(),
      ),
      floatingActionButton: _currentTap != 2 && widget.user.isAdmin
          ? FloatingActionButton(
              onPressed: _handleUploadMedia,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
