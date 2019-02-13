import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const USERS_DB = 'users';
const TRANSACTION_DB = 'transactions';

class FireApi {
  static Future<FirebaseUser> getSelf() => FirebaseAuth.instance.currentUser();

  static Future<UserInfo> getUser(String phoneNo) async =>
      (await FirebaseDatabase.instance
              .reference()
              .child(USERS_DB)
              .child(phoneNo)
              .once())
          .value;

  static Stream<List<Transaction>> getTransactions() {
    return ValueStream(
      reference: FirebaseDatabase.instance.reference().child(TRANSACTION_DB),
      jsonifier: (document) => Transaction.fromJson(document),
    ).values;
  }
}

class ValueStream<T> {
  final List<T> list = [];
  final List<String> keys = [];
  final T Function(dynamic) jsonifier;

  Stream<List<T>> get values => _valuesSubject.stream;
  final _valuesSubject = BehaviorSubject<List<T>>();

  ValueStream(
      {@required DatabaseReference reference, @required this.jsonifier}) {
    reference.onChildAdded.listen(_add);
    reference.onChildChanged.listen(_change);
    reference.onChildRemoved.listen(_remove);
  }

  T _convert(Event event) {
    return jsonifier(event.snapshot.value);
  }

  void _add(Event event) {
    list.add(_convert(event));
    keys.add(event.snapshot.key);
    _valuesSubject.add(list);
  }

  void _change(Event event) {
    int index = keys.indexOf(event.snapshot.key);
    list.removeAt(index);
    list.insert(index, _convert(event));
    _valuesSubject.add(list);
  }

  void _remove(Event event) {
    int index = keys.indexOf(event.snapshot.key);
    list.removeAt(index);
    keys.removeAt(index);
    _valuesSubject.add(list);
  }
}

class UserInfo {
  final String uId;
  final String phoneNo;
  final String displayName;

  UserInfo({@required this.uId, @required this.phoneNo, this.displayName});

  factory UserInfo.fromUser(FirebaseUser user) => UserInfo(
        uId: user.uid,
        phoneNo: user.phoneNumber,
        displayName: user.displayName,
      );

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
      uId: json['phoneNo'],
      phoneNo: json['phoneNo'],
      displayName: json['displayName']);
}

class Transaction {
  final String key;
  final double amount;
  final double interest;
  final List<Share> paidBy;
  final List<Share> consumedBy;

  Transaction({
    this.key,
    this.amount,
    this.interest,
    this.paidBy,
    this.consumedBy,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        key: json['key'],
        amount: json['amount'],
        interest: json['interest'],
        paidBy: json['paidBy'],
        consumedBy: json['consumedBy'],
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'amount': amount,
        'interest': interest,
        'paidBy': paidBy,
        'consumedBy': consumedBy,
      };
}

class Share {
  final String personId;
  final double amount;

  Share({this.personId, this.amount});

  factory Share.fromJson(Map<String, dynamic> json) => Share(
        personId: json['personId'],
        amount: json['amount'],
      );

  Map<String, dynamic> toJson() => {
        'personId': personId,
        'amount': amount,
      };
}
