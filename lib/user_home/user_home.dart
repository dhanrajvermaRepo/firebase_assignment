import 'package:firebase_assignment/modals/app_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../topics.dart';

class UserHome extends StatefulWidget {
  const UserHome({required this.user});
  final KCUser user;
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final AuthService _authService = AuthService();
  Future<void> _unSubscribeChannel()async{
    await FirebaseMessaging.instance.unsubscribeFromTopic(Topics.ALL_USERS);
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text("UserHome"),actions: [TextButton(onPressed: ()async{

        await _unSubscribeChannel();
        await _authService.logOut();
      }, child: Text("Sign-Out",style: TextStyle(color: Colors.white),))],),
      // body: Center(
      //   child: ElevatedButton(onPressed: ()async{
      //     var resp=await SendPushNotification("test content").sendPush();
      //     if(resp){
      //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Broadcast successful")));
      //     }else{
      //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong")));
      //     }
      //   },child: Text("Send Push"),),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("UserId ${widget.user.uid}"),
          Text("IsAdmin ${widget.user.isAdmin}"),
        ],
      ),
    );
  }
}
