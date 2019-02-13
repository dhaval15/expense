import 'package:expense/theme/theme.dart' show ThemeProvider;
import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  final Widget child;

  const BackGround({this.child});

  @override
  Widget build(BuildContext context) {
    final ui = ThemeProvider.of(context)();
    return Scaffold(
      backgroundColor: ui.splashScreenColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: ui.decoration,
          child: child,
        ),
      ),
    );
  }
}

class BackGroundPainter extends CustomPainter {
  final straps = 60;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  _drawRupee(Canvas canvas, double x, double y) {
    TextSpan span = TextSpan(text: RUPEE);
    TextPainter tp = TextPainter(text: span);
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }
}

const RUPEE = '\u20B9';
