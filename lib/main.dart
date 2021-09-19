import 'package:firebase_assignment/repository/firestore_services.dart';
import 'package:firebase_assignment/topics.dart';
import 'package:firebase_assignment/home.dart';
import 'package:firebase_assignment/widgets/loading.dart';
import 'package:firebase_assignment/widgets/something_went_wrong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_service.dart';
import 'login_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MaterialApp(home: App(),));
}

class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }


  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if(_error) {
      return SomethingWentWrong();
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Loading();
    }

    return StreamBuilder<User?>(builder: (context, AsyncSnapshot<User?> snapshot){
      if(snapshot.connectionState==ConnectionState.waiting){
        return Loading();
      }else if(snapshot.hasError){
        return SomethingWentWrong();
      }
      else if(snapshot.hasData){
        if(snapshot.data!=null){
          FireStoreService().getUser(snapshot.data!.uid);
          return Home();
        }
        return SomethingWentWrong();
      }else{
        return LoginScreen();
      }
    },stream: AuthService().authStateChange(),initialData: AuthService().currentUser,);
  }
}

