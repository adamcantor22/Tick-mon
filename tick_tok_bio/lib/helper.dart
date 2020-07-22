/*
    A couple different pages need the functions listed in this file.
 */

import 'package:flutter/material.dart';
import 'super_listener.dart';
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
  List<TextEditingController> drops;
  List<DropdownMenuItem<String>> items;
  List<String> dropdownItems = [
    'I. scapularis nymph',
    'I. scapularis adult male',
    'I. scapularis adult female',
    'A. americanum (Lone Star)',
  ];

  _HelperTextState(int segment, BuildContext cont) {
    this.segment = segment;
    this.cont = cont;
  }

  void initState() {
    super.initState();
    controllers = new List<TextEditingController>();
    fieldRows = new List<Widget>();
    drops = new List<TextEditingController>();
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
    int setText = 0;
    setState(() {
      controllers.add(new TextEditingController());
      drops.add(new TextEditingController(text: dropdownItems[setText]));
    });

    TextFormField tmpField = TextFormField(
      keyboardType: TextInputType.number,
      decoration: kTextFieldDecoration,
      controller: controllers[controllers.length - 1],
      validator: (val) => valid(controllers[controllers.length - 1].text),
    );
    DropdownButtonFormField tmpDrop = DropdownButtonFormField(
      value: drops[drops.length - 1].text,
      items: items,
      onChanged: (val) {
        print(val);
        drops[drops.length - 1].text = val;
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

  void storeTextData() {
    Map<String, int> map = new Map<String, int>();
    for (int i = 0; i < drops.length; i++) {
      map[drops[i].text] = int.parse(controllers[i].text);
    }
    SuperListener.addTickSegmentData(map);
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
                  color: drops.length < dropdownItems.length
                      ? Colors.green
                      : Colors.grey,
                  onPressed: () {
                    if (drops.length < dropdownItems.length) {
                      setState(() {
                        newField();
                      });
                    }
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
                    SuperListener.removeLasMarker();
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
                    bool passes = true;
                    for (int i = 0; i < drops.length - 1; i++) {
                      for (int j = i + 1; j < drops.length; j++) {
                        if (drops[i].text == drops[j].text) {
                          passes = false;
                          break;
                        }
                      }
                      if (!passes) break;
                    }

                    if (!passes) {
                      showDialog(
                        context: cont,
                        builder: (cont) => Helper().message(
                          'A tick type has been listed more than once.',
                          cont,
                        ),
                      );
                    } else if (formKey.currentState.validate()) {
                      storeTextData();
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
