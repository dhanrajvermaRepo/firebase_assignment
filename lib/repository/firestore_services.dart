import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_assignment/modals/app_user.dart';
import 'package:firebase_assignment/modals/content.dart';
import 'package:firebase_assignment/repository/collections.dart';
import 'package:firebase_assignment/repository/send_push_notification.dart';

class FireStoreService{
  static final FireStoreService _fireStoreService = FireStoreService._internal();
  factory FireStoreService() {
    return _fireStoreService;
  }
  FireStoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<KCUser> _controller = StreamController<KCUser>.broadcast();
  void dispose(){
    _controller.close();
  }
  Stream<KCUser> get kcUser=>_controller.stream;

  Future<void> addUser(KCUser user)async{
    var doc=await getUser(user.uid);
    if(doc.exists) return;
    await _firestore.collection(FSCollections.USER).doc(user.uid).set(user.toJason());
    _fireStoreService.addUser(user);
  }
  Future<DocumentSnapshot<Map<String,dynamic>>> getUser(String uid)async{
     var docRef=await _firestore.collection(FSCollections.USER).doc(uid).get(GetOptions(source: Source.serverAndCache));
     if(docRef.exists){
       _controller.add(KCUser.fromJson(docRef.data()!));
     }
     return docRef;
  }
  Future<void> uploadContent(Content content)async{
    await _firestore.collection(FSCollections.CONTENT).doc().set(content.toJson());
    await SendPushNotification(content.type).sendPush();
  }
  Stream<QuerySnapshot<Map<String,dynamic>>> getContentInRealTime()async*{
    yield* FirebaseFirestore.instance.collection(FSCollections.CONTENT).snapshots();
  }
}