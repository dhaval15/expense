import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/services.dart';
import 'package:validators/validators.dart' as validators;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

/// A dynamically generate form that allows creating new documents or
/// editing existing documents in a DocumentList. Specifying an index
/// for a document in a DocumentList causes the form to be in edit mode,
/// otherwise it will create a new document.
class DocumentForm extends StatefulWidget {
  /// The DocumentList on which the forms acts.
  //final DocumentList documentList;
  final Map<String, String> labels;
  final Map<String, FieldOptions> fieldOptionsMap;

  /// If supplied, the Document to edit. If null, a new Document
  /// will be created.
  final Map<String, dynamic> document;

  /// If supplied, will be used to decorate the form
  final BoxDecoration decoration;

  // If supplied, will be used to decorate fields in the form
  final BoxDecoration fieldDecoration;

  final Function(Map<String, dynamic> document) onSubmit;

  final EdgeInsets fieldPadding;

  DocumentForm(
      {this.document,
      this.decoration,
      this.fieldDecoration,
      this.labels,
      this.fieldOptionsMap,
      this.onSubmit,
      this.fieldPadding = const EdgeInsets.all(4)});

  @override
  _DocumentFormState createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // A document to get updated by the form
  Map<String, dynamic> _document;

  @override
  void initState() {
    // create a new document if one was not supplied
    if (widget.document == null)
      _document = Map();
    else
      _document = widget.document;
    super.initState();
  }

  List<Widget> _buildFormFields(BuildContext context) {
    List<Widget> fields = [];

    // creat a form field for each support label
    widget.labels.keys.forEach((String label) {
      String fieldName = widget.labels[label];
      // Use the labels map to get initial values in the case
      // where the form is editing an existing document
      dynamic initialValue;
      if (widget.document != null) {
        initialValue = _document[fieldName];
      }
      FieldOptions fieldOptions;
      if (widget.fieldOptionsMap != null) {
        fieldOptions = widget.fieldOptionsMap[fieldName];
      }
      // add to the array of input fields
      fields.add(
        Container(
          padding: widget.fieldPadding,
          decoration: widget.fieldDecoration,
          child: TypedInputField(fieldName,
              label: label,
              fieldOptions: fieldOptions,
              initialValue: initialValue, onSaved: (dynamic value) {
            _document[widget.labels[label]] = value;
          }),
          margin: EdgeInsets.all(10.0),
        ),
      );
    });

    fields.add(Container(
      padding: EdgeInsets.only(left: 100.0, right: 100.0),
      child: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            formKey.currentState.save();
            widget.onSubmit(_document);
          }),
    ));
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        decoration: widget.decoration,
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            children: _buildFormFields(context),
          ),
        ),
      ),
    );
  }
}

abstract class FieldOptions {}

/// Forces an input field to be rendered as a ListPicker
class InputListFieldOptions extends FieldOptions {
  final String documentType;
  final String displayField;
  final String valueField;

  InputListFieldOptions(this.documentType, this.displayField, this.valueField);
}

/// Field options for amount fields, currently ignored by the android
///  keyboard.
class AmountFieldOptions extends FieldOptions {
  final bool allowNegatives;

  AmountFieldOptions(this.allowNegatives);
}

/// Forces an input field to be rendered as an IntegerPicker.
class IntegerPickerFieldOptions extends FieldOptions {
  final int minimum;
  final int maximum;

  IntegerPickerFieldOptions(this.minimum, this.maximum);
}

/// Provides options for configuring a Date or DateTime form field
class DateTimeFieldOptions extends FieldOptions {
  final String formatString;

  DateTimeFieldOptions(this.formatString);
}

class TypedInputField extends StatelessWidget {
  /// Options for configuring the InputField
  final FieldOptions fieldOptions;

  /// The name of the field, used to calculate which type of input to return
  final String fieldName;

  /// The label to display in the UI for the specified fieldName
  final String label;

  /// Call back function invoked when the Form parent of the FormField is
  /// saved. The value returned is determined by the type of the field.
  final Function onSaved;

  /// The initial value to display in the FormField.
  final dynamic initialValue;

  TypedInputField(this.fieldName,
      {@required this.label,
      @required this.onSaved,
      this.initialValue,
      this.fieldOptions});

  @override
  Widget build(BuildContext context) {
    /*if (fieldOptions != null) {
      if (fieldOptions.runtimeType == InputListFieldOptions) {
        return _getListPickerFormField(fieldOptions);
      }
    }*/
    if (fieldName.toLowerCase().endsWith("count")) {
      return _getIntegerFormField();
    }
    if (fieldName.toLowerCase().endsWith("amount")) {
      return _getAmountFormField();
    }
    if (fieldName.toLowerCase().endsWith("datetime")) {
      String dateTimeFormat;
      if (fieldOptions != null) {
        dateTimeFormat = _getFormatStringFromOptions();
      } else {
        dateTimeFormat = "EEE, MMM d, y H:mm:s";
      }
      return _getDateTimeFormField(dateTimeFormat, false, context);
    }
    if (fieldName.toLowerCase().endsWith("date")) {
      String dateFormat;
      if (fieldOptions != null) {
        dateFormat = _getFormatStringFromOptions();
      } else {
        dateFormat = "yMd";
      }
      return _getDateTimeFormField(dateFormat, true, context);
    }
    if (fieldName.toLowerCase().endsWith("latlong")) {
      //work around json.decode reading _InternalHashMap<String, dynamic>
      Map<String, double> v;
      if (initialValue != null) {
        v = Map<String, double>.from(initialValue);
      }
      return MapPointFormField(fieldName, label: label, initialValue: v,
          onSaved: (Map<String, double> value) {
        this.onSaved(value);
      });
    }

    if (fieldName.toLowerCase().endsWith("image")) {
      return ImageFormField(
        fieldName,
        initialValue: initialValue,
        label: label,
        onSaved: (String value) {
          this.onSaved(value);
        },
      );
    }

    if (fieldName.toLowerCase().endsWith("text")) {
      return _getTextFormField(lines: 10);
    }

    if (fieldName.toLowerCase().endsWith("?")) {
      return BooleanFormField(
        fieldName,
        label: label,
        initialValue: initialValue,
        onSaved: (bool value) {
          this.onSaved(value);
        },
      );
    }

    return _getTextFormField();
  }

  String _getFormatStringFromOptions() {
    String dateTimeFormat;
    if (fieldOptions.runtimeType == DateTimeFieldOptions) {
      DateTimeFieldOptions fo = fieldOptions as DateTimeFieldOptions;
      dateTimeFormat = fo.formatString;
    }
    return dateTimeFormat;
  }

  Widget _getTextFormField({int lines: 1}) {
    return TextFormField(
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
        initialValue: initialValue,
        onSaved: (String value) {
          this.onSaved(value);
        });
  }

  DateTimePickerFormField _getDateTimeFormField(
      formatString, dateOnly, BuildContext context) {
    DateFormat format = DateFormat(formatString);
    return DateTimePickerFormField(
      format: format,
      decoration: InputDecoration(labelText: label),
      dateOnly: dateOnly,
      onSaved: (DateTime value) {
        String v = format.format(value);
        this.onSaved(v);
      },
      initialValue: _formatInitialDateTime(format),
    );
  }

  DateTime _formatInitialDateTime(DateFormat format) {
    if (initialValue == null) {
      return DateTime.now();
    } else {
      DateTime dt = format.parse(initialValue);
      return dt;
    }
  }

  Widget _getIntegerFormField() {
    if (fieldOptions != null) {
      if (fieldOptions.runtimeType == IntegerPickerFieldOptions) {
        IntegerPickerFieldOptions fo =
            fieldOptions as IntegerPickerFieldOptions;

        if (fo.minimum != null && fo.maximum != null) {
          return IntegerPickerFormField(
            label: label,
            initialValue: initialValue,
            fieldOptions: fieldOptions,
            onSaved: (int val) {
              this.onSaved(val);
            },
          );
        }
      }
    }

    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue == null ? "0" : initialValue.toString(),
      onSaved: (String value) {
        this.onSaved(int.parse(value));
      },
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: false),
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
    );
  }

  Widget _getAmountFormField() {
    bool signed = false;
    if (fieldOptions.runtimeType == AmountFieldOptions) {
      AmountFieldOptions fo = fieldOptions as AmountFieldOptions;
      signed = fo.allowNegatives;
    }
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue == null ? "0" : initialValue.toString(),
      onSaved: (String value) {
        this.onSaved(double.parse(value));
      },
      keyboardType:
          TextInputType.numberWithOptions(signed: signed, decimal: true),
    );
  }
}

/// A FormField for choosing integer values, rendered
/// as a spinning chooser. You must provide a map
/// of field options that include min and max, in the form of:
/// fieldOptions: {"min":0,"max":10}, in order to provide a
/// FormField limited to 0 through 10.
class IntegerPickerFormField extends StatefulWidget {
  const IntegerPickerFormField({
    Key key,
    @required this.initialValue,
    @required this.fieldOptions,
    @required this.onSaved,
    this.label,
  }) : super(key: key);

  final IntegerPickerFieldOptions fieldOptions;
  final Function onSaved;
  final int initialValue;
  final String label;

  @override
  _IntegerPickerFormFieldState createState() {
    return new _IntegerPickerFormFieldState();
  }
}

class _IntegerPickerFormFieldState extends State<IntegerPickerFormField> {
  int _currentValue;

  @override
  void initState() {
    widget.initialValue == null
        ? _currentValue = widget.fieldOptions.minimum
        : _currentValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FormFieldCaption(widget.label),
        FormField(
          builder: (FormFieldState<int> state) {
            return NumberPicker.integer(
              initialValue: _currentValue,
              maxValue: widget.fieldOptions.maximum,
              minValue: widget.fieldOptions.minimum,
              onChanged: (num val) {
                setState(() {
                  _currentValue = val;
                });
              },
            );
          },
          onSaved: (int val) {
            widget.onSaved(_currentValue);
          },
        ),
      ],
    );
  }
}

/// A widget for captioning fields in DocumentForm and DocumentPage.
class FormFieldCaption extends StatelessWidget {
  const FormFieldCaption(this.label, {Key key}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label == null) return Container();
    return Text(
      label,
      style: Theme.of(context).textTheme.caption,
      textAlign: TextAlign.start,
    );
  }
}

class BooleanFormField extends StatefulWidget {
  /// The name of the field, used to calculate which type of input to return
  final String fieldName;

  /// The label to display in the UI for the specified fieldName
  final String label;

  /// Call back function invoked when the Form parent of the FormField is
  /// saved. The value returned is determined by the type of the field.
  final Function onSaved;

  /// The initial value to display in the FormField. Should be a string that is
  /// either a path to an image on the device, or a URL to an image on the
  /// internet.
  final bool initialValue;

  const BooleanFormField(this.fieldName,
      {Key key, this.label, @required this.onSaved, this.initialValue: false})
      : super(key: key);

  _BooleanFormFieldState createState() => _BooleanFormFieldState();
}

class _BooleanFormFieldState extends State<BooleanFormField> {
  bool currentValue;

  @override
  void initState() {
    if (widget.initialValue == null) {
      currentValue = false;
    } else {
      currentValue = widget.initialValue;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: ((FormFieldState<bool> state) {
        return Row(children: [
          Text(widget.label),
          Checkbox(
            value: currentValue,
            onChanged: ((bool newVal) {
              setState(() {
                currentValue = newVal;
              });
            }),
          ),
        ]);
      }),
      onSaved: (bool val) {
        widget.onSaved(currentValue);
      },
    );
  }
}

class MapPointFormField extends StatefulWidget {
  /// The name of the field in the Document
  final String fieldName;

  /// The label to display in the UI for the specified fieldName
  final String label;

  /// Call back function invoked when the Form parent of the FormField is
  /// saved. The value returned is determined by the type of the field.
  final Function onSaved;

  /// The initial location to display in the map. If null, the map
  /// will use the device's location as the initial value.
  /// The value must be a Map<String, double> with at least the
  /// keys "latitude" and "longitude" defined.
  final Map<String, double> initialValue;

  MapPointFormField(this.fieldName,
      {@required this.label, @required this.onSaved, this.initialValue});

  _MapPointFormFieldState createState() => _MapPointFormFieldState();
}

class _MapPointFormFieldState extends State<MapPointFormField> {
  Map<String, double> _currentValue;

  @override
  void initState() {
    if (_currentValue == null) {
      _currentValue = widget.initialValue;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState<Map<String, double>> state) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            MapPointPicker(
              initialValue: _currentValue,
              onLocationChanged: (Map<String, double> loc) {
                _currentValue = loc;
              },
            ),
          ],
        );
      },
      onSaved: (Map<String, double> loc) {
        if (_currentValue == null && widget.initialValue != null) {
          widget.onSaved(_currentValue);
        } else if (_currentValue != null) {
          widget.onSaved(_currentValue);
        }
      },
    );
  }
}

/// A picker for a point on a map. Used by the MapPointFormField, though
/// it could be generally useful.
class MapPointPicker extends StatefulWidget {
  /// The initial location to display in the map. If null, the map
  /// will use the device's location as the initial value.
  /// The value must be a Map<String, double> with at least the
  /// keys "latitude" and "longitude" defined.
  final Map<String, double> initialValue;

  /// call back function to reveive notification when the map
  /// position changes.
  final Function onLocationChanged;

  MapPointPicker({this.initialValue, this.onLocationChanged});

  _MapPointPickerState createState() => _MapPointPickerState();
}

class _MapPointPickerState extends State<MapPointPicker> {
  Map<String, double> _startingMapPoint;
  Widget awaitingWidget = Center(child: CircularProgressIndicator());
  GoogleMapController mapController;

  Map<String, double> get location {
    if (mapController == null) {
      return _startingMapPoint;
    }
    Map<String, double> mp = {
      "latitude": mapController.cameraPosition.target.latitude,
      "longitude": mapController.cameraPosition.target.longitude,
    };
    return mp;
  }

  @override
  void initState() {
    if (widget.initialValue != null) {
      _startingMapPoint = widget.initialValue;
    } else {
      _setCurrentLocation();
    }
    super.initState();
  }

  void _setCurrentLocation() async {
    Location().getLocation().then((Map<String, double> location) {
      setState(() {
        _startingMapPoint = location;
      });
      if (widget.onLocationChanged != null) {
        widget.onLocationChanged(location);
      }
    });
  }

  @override
  Widget build(BuildContext contexy) {
    return _startingMapPoint == null
        ? CircularProgressIndicator()
        : SizedBox(
            width: 300.0,
            height: 300.0,
            child: Overlay(initialEntries: [
              OverlayEntry(builder: (BuildContext context) {
                return GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(
                      () => new EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                  options: new GoogleMapOptions(
                    trackCameraPosition: true,
                    scrollGesturesEnabled: true,
                    myLocationEnabled: true,
                    cameraPosition: new CameraPosition(
                        target: new LatLng(_startingMapPoint["latitude"],
                            _startingMapPoint["longitude"]),
                        zoom: 15.0),
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    mapController.addListener(() {
                      if (widget.onLocationChanged != null) {
                        Map<String, double> mp = {
                          "latitude":
                              mapController.cameraPosition.target.latitude,
                          "longitude":
                              mapController.cameraPosition.target.longitude,
                        };
                        widget.onLocationChanged(mp);
                      }
                    });
                  },
                );
              }),
              OverlayEntry(builder: (BuildContext context) {
                return Icon(Icons.flag, color: Theme.of(context).accentColor);
              })
            ]),
          );
  }
}

/// A dialog that encapsulated a MapPointPicker. Returns the chosen locations
/// as a Map<String, double> with the keys "latitude" and "longitude."
class MapPointDialog extends StatefulWidget {
  /// The initial location to display in the map. If null, the map
  /// will use the device's location as the initial value.
  /// The value must be a Map<String, double> with at least the
  /// keys "latitude" and "longitude" defined.
  final Map<String, double> initialValue;

  MapPointDialog({this.initialValue});

  _MapPointDialogState createState() => _MapPointDialogState();
}

class _MapPointDialogState extends State<MapPointDialog> {
  @override
  Widget build(BuildContext context) {
    Map<String, double> location;

    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Icon(Icons.map),
            Text(""),
            MapPointPicker(
              initialValue: widget.initialValue,
              onLocationChanged: (Map<String, double> loc) {
                location = loc;
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, location);
              },
            )
          ],
        ),
      ),
    );
  }
}

class ImageFormField extends StatefulWidget {
  /// The name of the field, used to calculate which type of input to return
  final String fieldName;

  /// The label to display in the UI for the specified fieldName
  final String label;

  /// Call back function invoked when the Form parent of the FormField is
  /// saved. The value returned is determined by the type of the field.
  final Function onSaved;

  /// The initial value to display in the FormField. Should be a string that is
  /// either a path to an image on the device, or a URL to an image on the
  /// internet.
  final String initialValue;

  ImageFormField(this.fieldName,
      {@required this.label, @required this.onSaved, this.initialValue});

  _ImageFormFieldState createState() => _ImageFormFieldState();
}

class _ImageFormFieldState extends State<ImageFormField> {
  File _imageFile;
  String _imageUrl;
  bool _dirty = false;
  final double _thumbSize = 200.0;

  @override
  void initState() {
    if (widget.initialValue != null) {
      if (validators.isURL(widget.initialValue)) {
        _imageUrl = widget.initialValue;
      } else {
        Uri uri = Uri(path: widget.initialValue);
        _imageFile = File.fromUri(uri);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController(
      text: _imageUrl,
    );

    return FormField(
      builder: (FormFieldState<String> state) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                FormFieldCaption(widget.label),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.grey),
                  child: _imageFile != null
                      ? ImageDisplayField(
                          imageString: _imageFile.path, boxSize: _thumbSize)
                      : ImageDisplayField(
                          imageString: _imageUrl, boxSize: _thumbSize),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        _setImageFile(ImageSource.gallery);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.camera),
                      onPressed: () {
                        _setImageFile(ImageSource.camera);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.insert_link),
                      onPressed: () async {
                        await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Icon(Icons.link),
                              content: TextField(
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                    hintText:
                                        "https://rapido-mobile.github.io/assets/background.jpg"),
                              ),
                              actions: <Widget>[
                                FloatingActionButton(
                                  child: Icon(Icons.check),
                                  onPressed: () {
                                    Navigator.pop(
                                        context, _textEditingController.text);
                                  },
                                ),
                              ],
                            );
                          },
                        ).then((String url) {
                          if (url == "" || url == null) return;
                          setState(() {
                            _imageFile = null;
                            _imageUrl = url;
                            _dirty = true;
                          });
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                          _imageUrl = null;
                          _dirty = true;
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        );
      },
      onSaved: (String path) async {
        if (_dirty) {
          if (_imageFile != null) {
            Directory dir = await getApplicationDocumentsDirectory();
            String path = dir.path;
            String filename = basename(_imageFile.path);
            File newFile = _imageFile.copySync("$path/$filename");
            widget.onSaved(newFile.path);
          } else if (_imageUrl != null) {
            widget.onSaved(_imageUrl);
          } else {
            widget.onSaved(null);
          }
        } else {
          widget.onSaved(widget.initialValue);
        }
      },
    );
  }

  void _setImageFile(ImageSource source) async {
    File file = await ImagePicker.pickImage(source: source);
    if (file == null) return;
    setState(() {
      _imageUrl = null;
      _imageFile = file;
      _dirty = true;
    });
  }
}

class ImageDisplayField extends StatelessWidget {
  /// File path or URL to an image to display
  final String imageString;

  /// The height and widgth of the box in which the map will display
  final double boxSize;

  ImageDisplayField({@required this.imageString, this.boxSize});

  @override
  Widget build(BuildContext context) {
    double sz = _getBoxSize(imageString, boxSize: boxSize);
    if (imageString == null) {
      return Container(
        child: SizedBox(
          height: 200,
          width: 200,
          child: Icon(Icons.broken_image),
        ),
      );
    } else if (validators.isURL(imageString)) {
      return Image(
        image: NetworkImage(imageString),
        height: sz,
        width: sz,
      );
    } else {
      return Container(
        child: Image.file(
          File.fromUri(
            Uri(
              path: imageString,
            ),
          ),
          height: sz,
          width: sz,
        ),
      );
    }
  }
}

double _getBoxSize(dynamic value, {double boxSize = 200}) {
  double sz = 0.0;
  if (value != "" && value != null) {
    return boxSize;
  }
  return sz;
}
