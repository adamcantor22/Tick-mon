/*
    This class defines the user page of the app. Upon startup, it shows the
    login page. If the user successfully logs in, it will display the user's
    personal page. The user can also choose to create an account, and upon
    having done so the user will also be sent to their new personal page.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tick_tok_bio/super_listener.dart';
import 'gps_tracking.dart';
import 'package:location/location.dart';
import 'helper.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key key}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  final _formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  bool creatingAccount = false;
  String user;

  String getUser() {
    return user;
  }

  //Sets up this page to be controllable through SuperListener
  void initState() {
    super.initState();
    SuperListener.setPages(
      uPage: this,
    );
  }

  //Main body controller, uses bools to determine what page should be shown
  Widget userPageBody() {
    if (user == null) {
      if (creatingAccount) {
        return createAccountPage();
      }
      return loginPage();
    }
    return userScreen();
  }

  //Startup page. Scrollable, includes login and create account buttons
  Widget loginPage() {
    return Container(
      color: Colors.grey[200],
      height: double.maxFinite,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
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
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
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
                          inputTrim();
                          validateLogin(userController.text, pwdController.text)
                              .then((response) {
                            if (response) {
                              setState(() {
                                user = userController.text.trim();
                              });
                            } else {}
                          });
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 15.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      RaisedButton(
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            creatingAccount = true;
                            inputClear();
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
      ),
    );
  }

  //Helper function to trim input
  void inputTrim() {
    userController.text = userController.text.trim();
    pwdController.text = pwdController.text.trim();
  }

  //Helper function to clear input
  void inputClear() {
    userController.clear();
    pwdController.clear();
  }

  //Returns a future, populates true if the login is valid, else false
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

  //Returns the create account page. very similar to login, with different functionality
  Widget createAccountPage() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Create New Account',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
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
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        creatingAccount = false;
                      });
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50.0,
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: () {
                      inputTrim();
                      if (_formKey.currentState.validate()) {
                        usernameAvailable(userController.text).then((response) {
                          if (!response) {
                            inputClear();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Helper()
                                    .message('Username Unavailable', context);
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
            ],
          ),
        ),
      ),
    );
  }

  //Similar to validateLogin(), returns a future that populates true if the username is available
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

  //Returns the user's (currently bare bones) personal page
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
