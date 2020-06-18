/*
    This class defines the user page of the app. Upon startup, it shows the
    login page. If the user successfully logs in, it will display the user's
    personal page. The user can also choose to create an account, and upon
    having done so the user will also be sent to their new personal page.
 */
import 'main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tick_tok_bio/super_listener.dart';
import 'gps_tracking.dart';
import 'package:location/location.dart';
import 'helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool access = false;

class UserPage extends StatefulWidget {
  const UserPage({Key key}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  bool loggedIn = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  bool creatingAccount = false;
  String user;
  String name;
  String email;

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    final AuthResult authResult = await _auth.signInWithCredential(credential);

    final FirebaseUser user = authResult.user;

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
      email = user.displayName;
    } else {
      email = "";
    }

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'User: $user';
  }

  void signOutGoogle() async {
    await _googleSignIn.signOut();
    setState(() {
      loggedIn = false;
    });
  }

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
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {
                            access = true;
                          });
                          signInWithGoogle().whenComplete(() => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyApp())));
                        },
                        child: Text(
                          'Login with Google',
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

  //Similar to validateLogin(), returns a future that populates true if the username is available

  //Returns the user's (currently bare bones) personal page
//  Widget userScreen() {
//
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: loginPage(),
    );
  }
}
