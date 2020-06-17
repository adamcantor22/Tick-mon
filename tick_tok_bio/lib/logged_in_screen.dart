import 'package:flutter/material.dart';

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
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Text(
              ('User Page'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            RaisedButton(
              color: Colors.blue,
              onPressed: () {
                setState(() {
                  //signOutGoogle();
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
    ));
  }
}
