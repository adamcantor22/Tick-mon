import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tick_tok_bio/gps_tracking.dart';
import 'package:tick_tok_bio/metadata_page.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'main.dart';
import 'user_page.dart';
import 'super_listener.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool loggedIn = false;
bool makingNewGroup = false;
bool access = false;
bool admin = false;
final GoogleSignIn googleSignIn = GoogleSignIn();
String name;
String email;

class LoggedInScreen extends StatefulWidget {
  @override
  LoggedInScreenState createState() => LoggedInScreenState();
}

class LoggedInScreenState extends State<LoggedInScreen> {
  bool temperatureState = false;

  FirebaseAuth _auth;

  final _formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  final codeController = TextEditingController();

  final nameLabGroupController = TextEditingController();

  bool creatingAccount = false;

  String labGroup = '';
  String adminCode = '';

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(lPage: this);
    print('LOGGED IN PAGE INITIALIZED');
  }

  void onFirebaseInitialized() {
    _auth = FirebaseAuth.instance;
    getPrefs(email);
  }

  bool getAdmin() {
    return admin;
  }

  String getLabGroup() {
    return labGroup;
  }

  cancelDragFirst(BuildContext context) {
    Widget agreement = FlatButton(
        onPressed: () {
          setState(() {
            Navigator.pop(context);
          });
        },
        child: Text('Ok.'));

    AlertDialog alert = AlertDialog(
      title: Text('You cannot log out while there is a drag in progress.'),
      actions: [agreement],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  finishDragEdit(BuildContext context) {
    Widget agreement = FlatButton(
        onPressed: () {
          setState(() {
            Navigator.pop(context);
          });
        },
        child: Text('Ok.'));

    AlertDialog alert = AlertDialog(
      title: Text('You cannot log out while a drag edit is opened'),
      actions: [agreement],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  noLoginMidDrag(BuildContext context) {
    Widget agreement = FlatButton(
        onPressed: () {
          setState(() {
            Navigator.pop(context);
          });
        },
        child: Text('Ok.'));

    AlertDialog alert = AlertDialog(
      title: Text('You cannot log in while a drag is in progress.'),
      actions: [agreement],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future<void> getPrefs(String email) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference docs = firestore.collection("users");
    bool found = false;
    QuerySnapshot qs = await docs.get();
    qs.docs.forEach((doc) async {
      if (doc['email'] == email) {
        if (doc['lab_group'] != null && doc['lab_group'] != '') {
          setState(() {
            labGroup = doc['lab_group'];
          });
        }
        if (doc['admin'] != null) {
          admin = doc['admin'];
          CollectionReference groups = firestore.collection('lab_groups');
          QuerySnapshot qsGroups = await groups.get();
          qsGroups.docs.forEach((group) {
            if (group['name'] == labGroup) {
              setState(() {
                adminCode = group['code'];
              });
            }
          });
        }
      }
    });
  }

  void tempCelsius(bool state) {
    setState(() {
      temperatureState = state;
    });
  }

//  bool loggedIn = false;

//  final FirebaseAuth _auth = FirebaseAuth.instance;
//
//  final _formKey = GlobalKey<FormState>();
//  final userController = TextEditingController();
//  final pwdController = TextEditingController();
//
//  bool creatingAccount = false;

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    print('THIS HAS COMPLETED');

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);

    final User user = authResult.user;

    if (user.displayName != null) {
      setState(() {
        name = user.displayName;
      });
    } else {
      setState(() {
        name = "";
      });
    }
    if (user.email != null) {
      email = user.email;
      print(email);
    } else {
      email = "";
    }
    print('THIS IS AN SOSOSOOSS');
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    if (user != null) {
      print(user);
      Navigator.pushReplacementNamed(context, 'LoggedInFeatures');
      loggedIn = true;
    }

    return 'User: $user';
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    setState(() {
      name = null;
      email = null;
      loggedIn = false;
    });
  }

  String getUser() {
    //return user;
  }

  //Sets up this page to be controllable through SuperListener
//  void initState() {
//    super.initState();
//    SuperListener.setPages(
//      uPage: this,
//    );
//  }

  //Main body controller, uses bools to determine what page should be shown

  void bobPrinter() {
    print('BOB');
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
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30.0,
                      ),
                      Container(
                        height: 55.0,
                        child: RaisedButton(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Colors.white,
                          onPressed: () {
                            if (trackingRoute == false) {
                              setState(() {
                                SuperListener.logInSwitch();
                              });
                              signInWithGoogle();
                            } else {
                              noLoginMidDrag(context);
                            }
                          },
                          child: Row(
                            children: [
                              Image(
                                image: AssetImage('images/google_logo.png'),
                                height: 40.0,
                                width: 50.0,
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                child: Text(
                                  'Login with Google',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: Text(
                    'Hello, Please Login to have access to the database.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
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
//  Future<bool> validateLogin(String name, String pwd) {
//    final myFuture = Future<bool>(() {
//      Future<QuerySnapshot> q =
//          Firestore.instance.collection('users').getDocuments();
//      return q.then((val) {
//        for (DocumentSnapshot d in val.documents) {
//          if (d.data['username'] == name) {
//            if (d.data['password'] == pwd) {
//              return true;
//            }
//          }
//        }
//        return false;
//      });
//    });
//    return myFuture;
//  }

  void createUser(String email, dynamic password) async {
    final User user1 = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
  }

  void joinGroup(String code) async {
    bool userFound = false;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference docs = firestore.collection('lab_groups');
    QuerySnapshot qs = await docs.get();
    qs.docs.forEach((group) async {
      if (group['code'] != null && group['code'] == code) {
        labGroup = group['name'];

        CollectionReference users = firestore.collection("users");
        QuerySnapshot qsUsers = await users.get();
        qsUsers.docs.forEach((doc) {
          if (doc.data()['email'] == email) {
            userFound = true;
            users
                .doc(doc.id)
                .set({'email': email, 'lab_group': labGroup, 'admin': false});
          }
        });
        if (!userFound) {
          users.add({'email': email, 'lab_group': labGroup, 'admin': false});
        }
        setState(() {
          loggedIn = true;
          admin = false;
        });
        return;
      }
    });
  }

  void uploadNewGroup(String name) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference groups = firestore.collection("lab_groups");
    final r = Random();
    String code = '';
    for (int i = 0; i < 4; i++) {
      code += r.nextInt(10).toString();
    }
    groups.add({'name': name, 'code': code});
    labGroup = name;
    adminCode = code;

    bool userFound = false;
    CollectionReference users = firestore.collection("users");
    QuerySnapshot qsUsers = await users.get();
    qsUsers.docs.forEach((doc) {
      if (doc.data()['email'] == email) {
        userFound = true;
        users
            .doc(doc.id)
            .set({'email': email, 'lab_group': labGroup, 'admin': true});
      }
    });

    if (!userFound) {
      users.add({'email': email, 'lab_group': labGroup, 'admin': true});
    }
    setState(() {
      loggedIn = true;
      makingNewGroup = false;
      admin = true;
    });
  }

  Widget newGroup() {
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        height: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(80.0, 80.0, 80.0, 0.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      'New Lab Group',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    TextFormField(
                      controller: nameLabGroupController,
                      decoration: InputDecoration(
                        hintText: 'Enter Lab Group Name',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 1.5),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.5),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    FlatButton(
                      onPressed: () {
                        uploadNewGroup(nameLabGroupController.text);
                        setState(() {});
                      },
                      color: Colors.green,
                      child: Text('Create Group'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loggedStatus() {
    if (makingNewGroup) {
      return newGroup();
    }
    if (loggedIn == true) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 80.0, left: 80.0, right: 80.0),
            child: Column(
              children: <Widget>[
                RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    signingOff = true;
                    if (trackingRoute == false && editingData == false) {
                      setState(() {
                        //SuperListener.posSubDispose();
                        //SuperListener.cancelCurrentDrag();
                        googleSignIn.signOut();
                        access = false;
                        loggedIn = false;
                        //Navigator.pushReplacementNamed(context, 'LoginScreen');
                      });
                    } else if (trackingRoute == true) {
                      cancelDragFirst(context);
                    } else if (editingData == true) {
                      finishDragEdit(context);
                    }
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
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
                  height: 15.0,
                ),
                Text(
                  labGroup != ''
                      ? (admin ? 'Admin' : 'Member') +
                          ' of ' +
                          labGroup +
                          ' Lab Group'
                      : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Visibility(
                  visible: admin,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30.0,
                      ),
                      Text(
                        'Lab Group Join Code: ',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        adminCode,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: labGroup == '',
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Enter Lab Group Code: ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      TextFormField(
                        key: _formKey,
                        controller: codeController,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                makingNewGroup = true;
                              });
                              ;
                            },
                            color: Colors.green,
                            child: Text('New Group'),
                          ),
                          FlatButton(
                            onPressed: () {
                              joinGroup(codeController.text);
                            },
                            color: Colors.blue,
                            child: Text('Join Group'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return loginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loggedStatus();
  }
}
