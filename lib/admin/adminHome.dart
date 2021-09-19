import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../topics.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final AuthService _authService = AuthService();
  Future<void> _unSubscribeChannel()async{
    await FirebaseMessaging.instance.unsubscribeFromTopic(Topics.ALL_USERS);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AdminHome"),actions: [TextButton(onPressed: ()async{

        await _unSubscribeChannel();
        await _authService.logOut();
      }, child: Text("Sign-Out",style: TextStyle(color: Colors.white),))]),
    );
  }
}
