import 'dart:async';

import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';

class PhoneFieldBloc {
  Sink<Country> get country => _countryController.sink;
  final _countryController = StreamController<Country>();
}

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
  final bloc = PhoneFieldBloc();

  @override
  Widget build(BuildContext context) {
    return PhoneFieldProvider(
      bloc: bloc,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Phone No',
            /*prefix: CountryPickerDropdown(
              itemBuilder: _buildDropdownItem,
              onValuePicked: bloc.country.add,
            ),*/
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            Image.asset(
              CountryPickerUtils.getFlagImageAssetPath(country.isoCode),
              height: 18,
              width: 27,
              fit: BoxFit.fitWidth,
              package: "country_pickers",
            ),
            SizedBox(
              width: 8.0,
            ),
            Text("+${country.phoneCode}"),
          ],
        ),
      );
}
