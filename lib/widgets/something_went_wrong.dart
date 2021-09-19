import 'package:flutter/material.dart';

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Material(
      child: Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: Text("Something went wrong!!"),
      ),
    );
  }
}
