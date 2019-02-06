import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import '../theme/theme.dart' as theme;
import '../auth/auth.dart';

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
    Navigator.of(context).push(Auth.builder);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;
    return SplashProvider(
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                  SizedBox(height: 16.0),
                  StreamBuilder<String>(
                    stream: bloc.motto,
                    initialData: '',
                    builder: (context, snapshot) => Text(
                          snapshot.data,
                          style: TextStyle(
                            color: theme.white_text,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
