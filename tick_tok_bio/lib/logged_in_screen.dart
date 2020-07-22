import 'package:flutter/material.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'main.dart';
import 'user_page.dart';
import 'super_listener.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedInScreen extends StatefulWidget {
  @override
  LoggedInScreenState createState() => LoggedInScreenState();
}

class LoggedInScreenState extends State<LoggedInScreen> {
  bool temperatureState = false;

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(lPage: this);
    print('LOGGED IN PAGE INITIALIZED');
    getPrefs(email);
  }

  Future<void> getPrefs(String email) async {
    List docs =
        (await Firestore.instance.collection('lab_groups').getDocuments())
            .documents;
    bool found = false;
    for (DocumentSnapshot doc in docs) {
      if (doc.data['name'] == 'muhlenberg') {
        for (String s in doc.data['users']) {
          if (s == email) {
            //SuperListener.tempCelsius(doc.data['celsius']);
            found = true;
            break;
          }
        }
      }
      if (found) break;
    }
  }

  void tempCelsius(bool state) {
    setState(() {
      temperatureState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(80.0),
          child: Column(
            children: <Widget>[
              RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  setState(() {
                    googleSignIn.signOut();
                    access = false;
                    Navigator.pushReplacementNamed(context, 'LoginScreen');
                    SuperListener.cancelCurrentDrag();
                  });
                },
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                ),
              ),
              SizedBox(
                height: 100.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  )
                ],
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 100.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
