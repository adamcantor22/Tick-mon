import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Tick Tok Database Prototype'),
        ),
        body: InputSection(),
      ),
    );
  }
}

class InputSection extends StatefulWidget {
  @override
  _InputSectionState createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: 'Test Input Here',
          ),
          RaisedButton(
            onPressed: () {
              //do something
              return;
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
