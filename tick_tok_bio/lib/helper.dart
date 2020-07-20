/*
    A couple different pages need the functions listed in this file.
 */

import 'package:flutter/material.dart';
import 'gps_tracking.dart';
import 'decorationInfo.dart';

int iScapNymph = 0;
int iScapAdultMale = 0;
int iScapAdultFemale = 0;
int aAmer = 0;
int dVar = 0;
int hLong = 0;
int other = 0;

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
    'I. scapularis nymph',
    'I. scapularis adult male',
    'I. scapularis adult female',
    'A. americanum (Lone Star)',
  ];
  int blackLegSeg;
  int iScapNymphSeg;
  int iScapAdultMaleSeg;
  int iScapAdultFemaleSeg;
  int aAmerSeg;
  int dVarSeg;
  int hLongSeg;
  int otherSeg;

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
        child: Text(
          value,
          style: TextStyle(fontSize: 8.0),
        ),
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
      onChanged: (value) {
        setState(() {
          print(value);
          blackLegSeg = int.parse(value);
        });
      },
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
          width: 10.0,
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
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fieldRows,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              newField();
            });
          },
        ),
        FlatButton(
          onPressed: () {
            iScapNymph += iScapNymphSeg;
            iScapAdultMale += iScapAdultMaleSeg;
            iScapAdultFemale += iScapAdultFemaleSeg;
            aAmer += aAmerSeg;
            dVar += dVarSeg;
            hLong += hLongSeg;
            other += otherSeg;
            print('pressed');
            Navigator.of(context).pop();
//            if (formKey.currentState.validate()) {
//            }
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
