import 'package:expense/forms/sign_up.dart';
import 'package:rxdart/rxdart.dart';

import '../theme/background.dart';
import '../theme/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../splash/splash.dart' show HeroTitle;
import 'package:firebase_auth/firebase_auth.dart';

class AuthEvent {
  static const int phoneEvent = 0;
  static const int codeEvent = 1;
  static const int progressEvent = 2;

  final int eventCode;
  final data;

  const AuthEvent({this.eventCode, this.data});
}

class AuthBloc {
  final String title = 'Expense';
  String _phoneNumber;
  String _verificationId;

  get formattedPhoneNumber => '+91$_phoneNumber';
  final fireAuth = FirebaseAuth.instance;

  Stream<AuthEvent> get status => _statusSubject.stream;
  final _statusSubject = BehaviorSubject<AuthEvent>();

  void sendCode(String text) {
    _phoneNumber = text;
    _statusSubject.sink.add(AuthEvent(
      eventCode: AuthEvent.progressEvent,
      data: 'Sending Code ...',
    ));
    fireAuth.verifyPhoneNumber(
      phoneNumber: formattedPhoneNumber,
      timeout: Duration(seconds: 45),
      verificationCompleted: (user) {},
      verificationFailed: (exception) {
        _statusSubject.sink
            .add(AuthEvent(eventCode: AuthEvent.phoneEvent, data: exception));
      },
      codeSent: (verificationId, [timeout]) {
        _verificationId = verificationId;
        _statusSubject.sink
            .add(AuthEvent(eventCode: AuthEvent.codeEvent, data: 0));
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _statusSubject.sink
            .add(AuthEvent(eventCode: AuthEvent.codeEvent, data: 0));
      },
    );
  }

  void verifyCode(String smsCode) async {
    _statusSubject.sink.add(AuthEvent(
      eventCode: AuthEvent.progressEvent,
      data: 'Verifying Code ...',
    ));
    try {
      final user = await fireAuth.signInWithPhoneNumber(
          verificationId: _verificationId, smsCode: smsCode);
      if (user == null)
        _statusSubject.sink
            .add(AuthEvent(eventCode: AuthEvent.codeEvent, data: -1));
    } catch (e) {
      _statusSubject.sink
          .add(AuthEvent(eventCode: AuthEvent.codeEvent, data: -1));
    }
  }

  void editPhoneNumber() {
    _statusSubject.sink.add(AuthEvent(eventCode: AuthEvent.phoneEvent));
  }
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

class Auth extends StatefulWidget {
  static final builder = MaterialPageRoute(builder: (context) => Auth());

  @override
  AuthState createState() {
    return AuthState();
  }
}

class AuthState extends State<Auth> {
  final bloc = AuthBloc();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen(_onUser);
  }

  void _onUser(FirebaseUser user) {
    if (user != null) {
      Navigator.of(context).pushReplacement(SignUpForm.builder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackGround(
      child: AuthProvider(
        bloc: bloc,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              HeroTitle(),
              Glass(
                child: StreamBuilder<AuthEvent>(
                  initialData: AuthEvent(eventCode: AuthEvent.phoneEvent),
                  stream: bloc.status,
                  builder: (context, snapshot) {
                    final event = snapshot.data;
                    switch (event.eventCode) {
                      case AuthEvent.phoneEvent:
                        return PhoneWidget(event.data);
                      case AuthEvent.codeEvent:
                        return SMSWidget(event.data);
                      case AuthEvent.progressEvent:
                        return Column(
                          children: <Widget>[
                            Text(
                              event.data,
                              textAlign: TextAlign.center,
                            ),
                            CircularProgressIndicator(),
                          ],
                        );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneWidget extends StatelessWidget {
  final _controller = TextEditingController();
  final AuthException exception;

  PhoneWidget(this.exception);

  @override
  Widget build(BuildContext context) {
    final bloc = AuthProvider.of(context)();
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: 'Phone No'),
          maxLength: 10,
        ),
        SizedBox(height: 8),
        FlatButton(
          onPressed: () {
            bloc.sendCode(_controller.text);
          },
          child: Text('Send Code'),
        ),
      ],
    );
  }
}

class SMSWidget extends StatelessWidget {
  final _controller = TextEditingController();
  final int data;

  SMSWidget(this.data);

  @override
  Widget build(BuildContext context) {
    final bloc = AuthProvider.of(context)();
    return Column(
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: 'We have sent smscode to ',
            children: [
              TextSpan(
                text: bloc.formattedPhoneNumber,
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    bloc.editPhoneNumber();
                  },
              ),
              TextSpan(text: 'tap to edit'),
            ],
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
              labelText: 'Sms Code',
              errorText: data == -1 ? 'Invalid Sms Code' : null),
          maxLength: 6,
        ),
        SizedBox(height: 8),
        FlatButton(
          onPressed: () {
            bloc.verifyCode(_controller.text);
          },
          child: Text('Verify Code'),
        ),
      ],
    );
  }
}
