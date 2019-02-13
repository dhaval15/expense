import 'package:expense/builders/form_builder.dart';
import 'package:flutter/material.dart';
import 'theme/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final bloc = ThemeBloc();

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      bloc: bloc,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
          accentColor: Colors.indigoAccent,
        ),
        home: Test(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DocumentForm(
          labels: {
            "Checked": "?",
            "Decimal Number": "amount",
            "Intenger Number": "count",
            "Start Date": "date",
            "End Time": "datetime",
            "Picture": "image",
            "Long Description": "text",
          },
          fieldPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          onSubmit: (document) {
            print(document);
          },
          fieldOptionsMap: {
            'date': DateTimeFieldOptions('DD MMM Y'),
          },
        ),
      ),
    );
  }
}
