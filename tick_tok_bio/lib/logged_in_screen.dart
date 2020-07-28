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
bool access = false;
final GoogleSignIn googleSignIn = GoogleSignIn();
String name;
String email;

class LoggedInScreen extends StatefulWidget {
  @override
  LoggedInScreenState createState() => LoggedInScreenState();
}

class LoggedInScreenState extends State<LoggedInScreen> {
  bool temperatureState = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  bool creatingAccount = false;

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(lPage: this);
    print('LOGGED IN PAGE INITIALIZED');
    getPrefs(email);
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
    print('THIS HAS COMPLEED');

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

//    print('THIS IS AN SOSOSOOSS');
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
//    print('THIS IS AN SOSOSOOSS');
    final AuthResult authResult = await _auth.signInWithCredential(credential);
//    print('THIS IS AN SOSOSOOSS');
    final FirebaseUser user = authResult.user;
//    print('THIS IS AN SOSOSOOSS');
//
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

    final FirebaseUser currentUser = await _auth.currentUser();
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
                            setState(() {
                              SuperListener.logInSwitch();
                            });
                            signInWithGoogle();
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
    final FirebaseUser user1 = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
  }

  Widget loggedStatus() {
    if (loggedIn == true) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(80.0),
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
    } else if (loggedIn == false) {
      return loginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loggedStatus();
  }
}
