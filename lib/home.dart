import 'package:firebase_assignment/auth_service.dart';
import 'package:firebase_assignment/modals/app_user.dart';
import 'package:firebase_assignment/repository/firestore_services.dart';
import 'package:firebase_assignment/repository/send_push_notification.dart';
import 'package:firebase_assignment/topics.dart';
import 'package:firebase_assignment/user_home/user_home.dart';
import 'package:firebase_assignment/widgets/loading.dart';
import 'package:firebase_assignment/widgets/something_went_wrong.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'admin/adminHome.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FireStoreService _fireStoreService = FireStoreService();
  @override
  void initState() {
    super.initState();
    _subscribeChannel();
  }
  _subscribeChannel()async{
    await FirebaseMessaging.instance.subscribeToTopic(Topics.ALL_USERS);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KCUser>(builder: (context,AsyncSnapshot<KCUser> snap){
      if(snap.hasData){
       if(snap.data!=null){
         if(snap.data!.isAdmin){
           return AdminHome();
         }
         return UserHome(user: snap.data!);
       }else{
         return SomethingWentWrong();
       }
      }else if(snap.hasError){
        return SomethingWentWrong();
      }else{
      return Loading();
      }
    },stream: _fireStoreService.kcUser,);
  }
  // @override
  // void dispose() {
  //   super.dispose();
  //   _fireStoreService.dispose();
  // }
}
