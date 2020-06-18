import 'package:flutter/material.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'main.dart';
import 'user_page.dart';

class LoggedInScreen extends StatefulWidget {
  @override
  _LoggedInScreenState createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserPage()));
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
            Text(
              'Welcome Kevin! \n Kevin@email.com',
              style: TextStyle(
                fontSize: 25.0,
              ),
            )
          ],
        ),
      ),
    ));
  }
}
