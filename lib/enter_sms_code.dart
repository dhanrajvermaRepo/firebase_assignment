import 'package:firebase_assignment/auth_service.dart';
import 'package:firebase_assignment/modals/app_user.dart';
import 'package:firebase_assignment/repository/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EnterSMSCode extends StatefulWidget {
  EnterSMSCode({required this.verificationId});
  final String verificationId;

  @override
  _EnterSMSCodeState createState() => _EnterSMSCodeState();
}

class _EnterSMSCodeState extends State<EnterSMSCode> {
  final TextEditingController _controller = TextEditingController();

  final AuthService _authService = AuthService();
  final FireStoreService _fireStoreService = FireStoreService();

  OverlayEntry? _overlayEntry;

  void _showOverLay() {
    if (_overlayEntry != null) return;
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) {
      return Container(
        color: Colors.black.withOpacity(0.3),
        alignment: Alignment.center,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
    overlayState?.insert(_overlayEntry!);
  }

  void _removeOverLay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Code"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(25.0),
            child: TextFormField(
              controller: _controller,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'sms code',hintStyle: TextStyle(color: Colors.grey)),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                _showOverLay();
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId, smsCode: _controller.text);
                // Sign the user in (or link) with the credential
                var creds=await _authService.signInWithCredential(credential);
                if(creds.user!=null){
                  var user = KCUser(uid:creds.user!.uid, isAdmin: false);
                  await _fireStoreService.addUser(user);
                }
                _removeOverLay();
                Navigator.of(context).pop();
              },
              child: Text("Submit"))
        ],
      ),
    );
  }
}
