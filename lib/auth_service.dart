import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _authService = AuthService._internal();
  factory AuthService() {
    return _authService;
  }
  AuthService._internal();
  final FirebaseAuth _auth=FirebaseAuth.instance;

  Stream<User?> authStateChange() async* {
    yield* _auth.authStateChanges();
  }

  User? get currentUser => _auth.currentUser;

  Future<void> verifyPhoneNumber(
      String phoneNumber,
      PhoneVerificationFailed phoneVerificationFailed,
      PhoneCodeSent phoneCodeSent) async {
    await _auth.verifyPhoneNumber(
      timeout: Duration.zero,
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: phoneVerificationFailed,
      codeSent: phoneCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

 Future<UserCredential> signInWithCredential(AuthCredential credential){
    return _auth.signInWithCredential(credential);
  }
  Future<void> logOut(){
   return  _auth.signOut();
  }
}
