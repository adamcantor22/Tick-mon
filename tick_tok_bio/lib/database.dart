/*
    Old page for testing the realtime database. Defunct as of 6/11.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputSection extends StatefulWidget {
  const InputSection({Key key}) : super(key: key);
  @override
  _InputSectionState createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  bool showData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Page'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: myController,
                    decoration: InputDecoration(
                      labelText: 'Test Input Here',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(
                        () {
                          if (_formKey.currentState.validate()) {
                            String newUser = myController.text;
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('submitting'),
                              ),
                            );
                            Firestore.instance
                                .collection('test_usernames')
                                .document()
                                .setData({'username': newUser});
                          }
                        },
                      );
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                setState(() {
                  showData = !showData;
                });
              },
              child: Text('Toggle Showing Data'),
            ),
            if (showData)
              StreamBuilder(
                stream:
                    Firestore.instance.collection('test_usernames').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Text('Loading...');
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemExtent: 80.0,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            snapshot.data.documents[index]['username'],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
