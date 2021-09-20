import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
class FirebaseStorageService {
  static final FirebaseStorageService _firebaseStorageService = FirebaseStorageService._internal();
  factory FirebaseStorageService() {
    return _firebaseStorageService;
  }
  FirebaseStorageService._internal();
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
}