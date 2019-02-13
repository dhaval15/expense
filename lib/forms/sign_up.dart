import 'package:expense/theme/background.dart';
import 'package:expense/theme/glass.dart';
import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  static final builder = MaterialPageRoute(builder: (context) => SignUpForm());

  @override
  Widget build(BuildContext context) {
    return BackGround(
      child: Center(
        child: Glass(
            child: Column(
          children: <Widget>[TextField()],
        )),
      ),
    );
  }
}
