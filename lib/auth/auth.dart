import 'package:flutter/material.dart';
import '../theme/theme.dart' as theme;
import 'phone_field.dart';

class AuthBloc {
  final String title = 'Expense';
}

class AuthProvider extends InheritedWidget {
  final AuthBloc bloc;

  AuthProvider({this.bloc, Widget child}) : super(child: child);

  factory AuthProvider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(AuthProvider);

  AuthBloc call() => bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class Auth extends StatelessWidget {
  static final builder = MaterialPageRoute(builder: (context) => Auth());

  final bloc = AuthBloc();

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      bloc: bloc,
      child: Scaffold(
        backgroundColor: theme.splash_screen_colors[0],
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme.splash_screen_colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Hero(
                    tag: 'app_title',
                    child: Text(
                      bloc.title,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3,
                        color: theme.white_text,
                      ),
                    ),
                  ),
                  Card(
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          PhoneField(),
                          FlatButton(
                            onPressed: () {},
                            child: Text('Login'),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
