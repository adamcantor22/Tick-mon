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

  bool creatingAccount = false;
  String user = null;

  Widget userPageBody() {
    if (user == null) {
      if (creatingAccount) {
        return createAccountPage();
      }
      return loginPage();
    }
    return userScreen();
  }

  Widget loginPage() {
    return Container(
      color: Colors.grey[200],
      child: Form(
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
                        validateLogin(userController.text.trim(),
                                pwdController.text.trim())
                            .then((response) {
                          if (response) {
                            print('***LOGIN SUCCESS***');
                            setState(() {
                              user = userController.text.trim();
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
                    RaisedButton(
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          creatingAccount = true;
                        });
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> validateLogin(String name, String pwd) {
    final myFuture = Future<bool>(() {
      Future<QuerySnapshot> q =
          Firestore.instance.collection('users').getDocuments();
      return q.then((val) {
        for (DocumentSnapshot d in val.documents) {
          if (d.data['username'] == name) {
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

  Widget createAccountPage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: userController,
                decoration: InputDecoration(
                  hintText: 'New Username',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: pwdController,
                decoration: InputDecoration(
                  hintText: 'New Password',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    usernameAvailable(userController.text.trim())
                        .then((response) {
                      print(response);
                      if (!response) {
                        userController.text = '';
                        showDialog(
                          context: context,
                          builder: (context) {
                            return message('Username Unavailable');
                          },
                        );
                      } else {
                        Firestore.instance
                            .collection('users')
                            .document()
                            .setData({
                          'username': userController.text,
                          'password': pwdController.text,
                        });
                        setState(() {
                          creatingAccount = false;
                          user = userController.text;
                        });
                      }
                    });
                  }
                },
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget message(String m) {
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

  Future<bool> usernameAvailable(String name) {
    final myFuture = Future<bool>(() {
      Future<QuerySnapshot> q =
          Firestore.instance.collection('users').getDocuments();
      return q.then((val) {
        for (DocumentSnapshot d in val.documents) {
          if (d.data['username'] == name) {
            return false;
          }
        }
        return true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: userPageBody(),
    );
  }
}
