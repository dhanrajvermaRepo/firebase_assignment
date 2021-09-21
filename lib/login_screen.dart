import 'package:firebase_assignment/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enter_sms_code.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  final AuthService _authService = AuthService();
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

  void removeOverLay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void authenticationFailed(FirebaseAuthException e) {
    removeOverLay();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${e.code}')));
  }

  void codeSent(String verificationId, int? resendToken) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EnterSMSCode(
        verificationId: verificationId,
      );
    }));
    removeOverLay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign-in to knowledge city"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],
              controller: _controller,
              maxLength: 10,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Text("+91",style: TextStyle(color: Colors.black,fontSize: 16),),
                  border: UnderlineInputBorder(),
                  prefixIconConstraints: BoxConstraints(maxHeight: 20,maxWidth: 50),
                  errorBorder: UnderlineInputBorder(),
                  hintText: "Phone number"),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                _showOverLay();
                await _authService.verifyPhoneNumber(
                    '+91${_controller.text}', authenticationFailed, codeSent);
              },
              child: Text('Sign-in'))
        ],
      ),
    );
  }
}
