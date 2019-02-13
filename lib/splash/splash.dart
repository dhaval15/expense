import 'package:expense/auth/auth.dart';

import '../theme/background.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import '../theme/theme.dart' show ThemeProvider;

class SplashBloc {
  final String title = 'Expense';

  Stream<String> get motto => _mottoSubject.stream;
  final _mottoSubject = BehaviorSubject<String>();

  SplashBloc() {
    FirebaseDatabase.instance
        .reference()
        .child('configs')
        .child('motto')
        .onValue
        .listen((event) => _mottoSubject.add(event.snapshot.value));
  }
}

class SplashProvider extends InheritedWidget {
  final SplashBloc bloc;

  SplashProvider({this.bloc, Widget child}) : super(child: child);

  factory SplashProvider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(SplashProvider);

  SplashBloc call() => bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class Splash extends StatefulWidget {
  final bloc = SplashBloc();

  @override
  SplashState createState() {
    return SplashState();
  }
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _delay();
  }

  void _delay() async {
    await Future.delayed(Duration(seconds: 5));
    Navigator.of(context).pushReplacement(Auth.builder);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;
    final ui = ThemeProvider.of(context)();
    return SplashProvider(
      bloc: bloc,
      child: BackGround(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HeroTitle(),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {},
                child: StreamBuilder<String>(
                  stream: bloc.motto,
                  initialData: '',
                  builder: (context, snapshot) => Text(
                        snapshot.data,
                        style: TextStyle(
                          color: ui.titleColor,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroTitle extends StatelessWidget {
  final title = 'Expense';

  @override
  Widget build(BuildContext context) {
    final ui = ThemeProvider.of(context)();
    return Hero(
      tag: 'app_title',
      child: Material(
        color: Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            color: ui.titleColor,
          ),
        ),
      ),
    );
  }
}
