import 'package:flutter/material.dart';

class PhoneFieldBloc {}

class PhoneFieldProvider extends InheritedWidget {
  final PhoneFieldBloc bloc;

  PhoneFieldProvider({this.bloc, Widget child}) : super(child: child);

  factory PhoneFieldProvider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(PhoneFieldProvider);

  PhoneFieldBloc call() => bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class PhoneField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PhoneFieldProvider(
      bloc: PhoneFieldBloc(),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Phone No',
        ),
      ),
    );
  }
}
