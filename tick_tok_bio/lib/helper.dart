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
}
