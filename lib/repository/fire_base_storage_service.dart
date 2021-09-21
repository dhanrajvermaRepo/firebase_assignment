import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
class FirebaseStorageService {
  static final FirebaseStorageService _firebaseStorageService = FirebaseStorageService._internal();
  factory FirebaseStorageService() {
    return _firebaseStorageService;
  }
  FirebaseStorageService._internal();
  final FirebaseStorage _storage =
     FirebaseStorage.instance;

  Future<String> downloadURL(String path) async {
    String downloadURL = await _storage
        .ref(path)
        .getDownloadURL();
    return downloadURL;
  }

 UploadTask uploadFile(String filePath,String location)  {
    File file = File(filePath);
   return  _storage
        .ref('$location')
        .putFile(file);
  }
}