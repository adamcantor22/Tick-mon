/*
    A couple different pages need the functions listed in this file.
 */

import 'package:flutter/material.dart';
import 'gps_tracking.dart';
import 'decorationInfo.dart';

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
  List<Widget> fieldRows;
  List<TextEditingController> controllers;
  List<DropdownMenuItem<String>> items;
  List<String> dropdownItems = [
    'Blacklegged',
    'Nymph',
  ];

  _HelperTextState(int segment, BuildContext cont) {
    this.segment = segment;
    this.cont = cont;
  }

  void initState() {
    super.initState();
    controllers = new List<TextEditingController>();
    fieldRows = new List<Widget>();
    items = dropdownItems.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    newField();
  }

  void newField() {
    setState(() {
      controllers.add(new TextEditingController());
    });

    TextFormField tmpField = TextFormField(
      decoration: kTextFieldDecoration,
      controller: controllers[controllers.length - 1],
      validator: (val) => valid(val),
    );
    DropdownButtonFormField tmpDrop = DropdownButtonFormField(
      value: dropdownItems[0],
      items: items,
      onChanged: (val) {
        print(val);
      },
    );
    Row tmpRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 5,
          child: tmpField,
        ),
        SizedBox(
          width: 15.0,
        ),
        Flexible(
          flex: 4,
          child: tmpDrop,
        ),
      ],
    );

    setState(() {
      fieldRows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: tmpRow,
        ),
      );
    });
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
      contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 2.0),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: fieldRows,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      newField();
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      print('pressed');
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return segmentTextDialog(segment, cont);
  }
}
