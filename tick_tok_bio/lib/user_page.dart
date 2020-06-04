import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gps_tracking.dart';
import 'package:location/location.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  @override
  String user = null;

  Widget userPageBody() {
    if (user == null) {
      return loginPage();
    }
    return userScreen();
  }

  Widget loginPage() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                'You are not logged in. Login to start.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                    ),
                  ),
                  TextFormField(
                    controller: pwdController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: () async {
                      print('***PRESSED***');
                      validateLogin(userController.text, pwdController.text)
                          .then((response) {
                        if (response) {
                          print('***LOGIN SUCCESS***');
                          setState(() {
                            user = userController.text;
                          });
                        } else {
                          print('***LOGIN FAILURE***');
                        }
                      });
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> validateLogin(String user, String pwd) {
    final myFuture = Future<bool>(() {
      Future<QuerySnapshot> q =
          Firestore.instance.collection('users').getDocuments();
      return q.then((val) {
        for (DocumentSnapshot d in val.documents) {
          if (d.data['username'] == user) {
            if (d.data['password'] == pwd) {
              return true;
            }
          }
        }
        return false;
      });
    });
    return myFuture;
  }

  Widget userScreen() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Text(
              (user + '\'s User Page'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            RaisedButton(
              color: Colors.blue,
              onPressed: () {
                setState(() {
                  user = null;
                });
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: userPageBody(),
    );
  }
}
