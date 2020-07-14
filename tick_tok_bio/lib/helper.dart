/*
    A couple different pages need the functions listed in this file.
 */

import 'package:flutter/material.dart';

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

  Widget segmentTextDialog(int segment, BuildContext context) {
    TextEditingController c1 = TextEditingController();
    TextEditingController c2 = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text('Segment $segment Metadata'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: c1,
              validator: (val) {
                if (val == null || val == '') {
                  return 'Enter Data';
                }
                return null;
              },
            ),
            TextFormField(
              controller: c2,
              validator: (val) {
                if (val == null || val == '') {
                  return 'Enter Data';
                }
                return null;
              },
            ),
          ],
        ),
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
}
