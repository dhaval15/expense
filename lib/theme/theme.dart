import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UI {
  final List<Color> splashScreenColor;
  final Color titleColor;
  final Color theme;

  UI({this.splashScreenColor, this.titleColor, this.theme});
}

class ThemeBloc {
  final decoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.cyan[600],
        Colors.blue[900],
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
  final splashScreenColor = Colors.cyan[600];
  final titleColor = Colors.white;
}

class ThemeProvider extends InheritedWidget {
  final ThemeBloc bloc;

  ThemeProvider({this.bloc, Widget child}) : super(child: child);

  factory ThemeProvider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(ThemeProvider);

  ThemeBloc call() => bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class ColorButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String action;

  const ColorButton({this.onPressed, this.action});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: StadiumBorder(),
      highlightElevation: 2,
      onPressed: onPressed,
      color: Colors.teal,
      child: Text(
        action,
        style: TextStyle(color: Colors.white),
      ),
      elevation: 1,
    );
  }
}

class SimpleButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String action;

  const SimpleButton({this.onPressed, this.action});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        action,
        style: TextStyle(color: Colors.greenAccent),
      ),
      onPressed: onPressed,
    );
  }
}
