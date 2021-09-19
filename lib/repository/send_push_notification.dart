import 'dart:convert';
import 'dart:io';

import 'package:firebase_assignment/topics.dart';
import 'package:http/http.dart'as http;
class SendPushNotification{
  SendPushNotification(this.contentName);
  final String contentName;
  final String _url = "https://fcm.googleapis.com/fcm/send";
  final String _serverKey = "key=AAAAZq_19qw:APA91bFGLZioKwytjTO3gYvYhX0Wf2AwN"
      "idvtXI_P2hZLEvEHcRz-BuTgjI6u3gqJFOnlqnODWyNVh7rC1k9MPsgtg1H5BOX3pg-ingf"
      "Aqa2xuRpGL_N5B_dHam1V1sicnLqM9GZUALQ";

  Future<bool> sendPush()async{
    http.Response response;
    try{
      response=await http.post(Uri.parse(_url),headers: {
        'Authorization':_serverKey,
        'Content-Type':'application/json'
      },body: json.encode({
        "to": "/topics/${Topics.ALL_USERS}",
        "notification": {
          "body": "A new content $contentName has been uploaded.",
          "title": "KnowledgeCity"
        }
      }));
    }catch(_){
      return false;
    }
    if(response.statusCode==200){
      var responseBody = json.decode(response.body);
      if(responseBody['message_id']!=null){
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }
}