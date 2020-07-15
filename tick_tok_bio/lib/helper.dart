/*
    A couple different pages need the functions listed in this file.
 */

import 'package:flutter/material.dart';
import 'gps_tracking.dart';

class Helper {
  //Returns an AlertDialog with a custom message and an OK button
  Widget message(String m, BuildContext context) {
    return AlertDialog(
      title: Text(m),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Widget boolMessage(String m, Function f, BuildContext context) {
    return AlertDialog(
      title: Text(m),
      actions: <Widget>[
        FlatButton(
          child: Text('NO'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('YES'),
          onPressed: () {
            f();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class HelperText extends StatefulWidget {
  int segment;
  BuildContext cont;

  HelperText(int segment, BuildContext cont) {
    this.segment = segment;
    this.cont = cont;
  }

  @override
  _HelperTextState createState() => _HelperTextState(segment, cont);
}

class _HelperTextState extends State<HelperText> {
  int segment;
  BuildContext cont;
  List<TextFormField> fields;
  List<TextEditingController> controllers = [TextEditingController()];

  _HelperTextState(int segment, BuildContext cont) {
    this.segment = segment;
    this.cont = cont;
    fields = [
      TextFormField(
        controller: controllers[0],
        validator: (val) => valid(val),
      )
    ];
  }

  String valid(String val) {
    if (val == null || val == '') {
      return 'Enter Data';
    }
    return null;
  }

  Widget segmentTextDialog(int segment, BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text('Segment $segment Metadata'),
      content: Form(
        key: formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: fields),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (formKey.currentState.validate()) {
              print('pressed');
              Navigator.of(context).pop();
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return segmentTextDialog(segment, cont);
  }
}
