import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TestBloc {
  String key = 'background';
  final initialData = {
    'background': Color(0xffff5252),
    'titlelight': Colors.white,
    'titleblack': Colors.black87,
    'textblack': Colors.black54,
    'button': Colors.deepPurple,
  };

  void update(String key, Color color) {
    final map = _streamSubject.value;
    map[key] = color;
    _streamSubject.add(map);
  }

  Stream<Map<String, Color>> get stream => _streamSubject.stream;
  final _streamSubject = BehaviorSubject<Map<String, Color>>();

  TestBloc() {
    _streamSubject.add(initialData);
  }
}

class TestProvider extends InheritedWidget {
  final TestBloc bloc;

  TestProvider({this.bloc, Widget child}) : super(child: child);

  factory TestProvider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(TestProvider);

  TestBloc call() => bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class Test extends StatelessWidget {
  final bloc = TestBloc();

  @override
  Widget build(BuildContext context) {
    return TestProvider(
      bloc: bloc,
      child: StreamBuilder<Map<String, Color>>(
          stream: bloc.stream,
          initialData: bloc.initialData,
          builder: (context, snapshot) {
            final colors = snapshot.data;
            final keys = colors.keys.toList();
            return Scaffold(
              backgroundColor: Colors.cyan[600],
              body: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan[600],
                        Colors.blue[900],
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: ListView.builder(
                      itemCount: keys.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        return index == keys.length
                            ? ColorPicker(
                                pickerColor: colors[bloc.key],
                                onColorChanged: (Color value) {
                                  bloc.update(bloc.key, value);
                                },
                                enableAlpha: true,
                                pickerAreaHeightPercent: 0.7,
                              )
                            : ListTile(
                                title: Text(keys[index]),
                                leading: CircleAvatar(
                                  backgroundColor: colors[keys[index]],
                                  child: Text(
                                    '',
                                    style: TextStyle(
                                      color: colors[keys[index]],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  bloc.key = keys[index];
                                },
                              );
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
