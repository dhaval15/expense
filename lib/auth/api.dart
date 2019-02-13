import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

enum PhoneAuthEvent {
  init,
  loading,
  invalidPhoneNo,
  invalidSmsCode,
  networkError,
  successful
}

class PhoneAuthState {
  final PhoneAuthEvent event;
  final data;

  PhoneAuthState(this.event, this.data);
}

class PhoneAuthBloc {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Sink<String> get phoneNo => _phoneNoController.sink;
  final _phoneNoController = StreamController<String>();

  Sink<String> get smsCode => _smsCodeController.sink;
  final _smsCodeController = StreamController<String>();

  Stream<PhoneAuthState> get state => _stateSubject.stream;
  final _stateSubject = BehaviorSubject<PhoneAuthState>();

  PhoneAuthBloc() {
    _stateSubject.sink.add(PhoneAuthState(PhoneAuthEvent.init, null));
    _phoneNoController.stream.listen(_validate);
  }

  void _validate(String phoneNo) {}

  void authenticate(String phoneNo) {
    auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      timeout: Duration(seconds: 60),
      verificationCompleted: _verificationCompeted,
      verificationFailed: _verificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
    );
  }

  void verify(String smsCode) {}

  void _verificationCompeted(FirebaseUser firebaseUser) {
    _stateSubject.sink
        .add(PhoneAuthState(PhoneAuthEvent.successful, firebaseUser));
  }

  void _verificationFailed(AuthException error) {}

  void _codeSent(String verificationId, int forceResendingToken) {}

  void _codeAutoRetrievalTimeout(String verificationId) {}
}

class PhoneAuthProvider extends InheritedWidget {
  final PhoneAuthBloc bloc;

  PhoneAuthProvider({this.bloc, Widget child}) : super(child: child);

  factory PhoneAuthProvider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(PhoneAuthProvider);

  PhoneAuthBloc call() => bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class PhoneAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PhoneAuthProvider(
      bloc: PhoneAuthBloc(),
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {},
      ),
    );
  }
}

class AsyncWidget<T> extends StatefulWidget {
  @override
  AsyncWidgetState<T> createState() => AsyncWidgetState<T>();
}

class AsyncWidgetState<T> extends State<AsyncWidget<T>> {
  T value;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
