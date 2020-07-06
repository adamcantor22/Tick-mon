import 'package:flutter/material.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'main.dart';
import 'user_page.dart';
import 'super_listener.dart';

class LoggedInScreen extends StatefulWidget {
  @override
  _LoggedInScreenState createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
  bool temperatureState = false;

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
              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: [
//                  Text(
//                    'Fahrenheit',
//                    style: TextStyle(
//                      fontSize: 18.0,
//                    ),
//                  ),
//                  Switch(
//                    inactiveThumbColor: Colors.red,
//                    inactiveTrackColor: Colors.red[200],
//                    value: temperatureState,
//                    onChanged: (val) {
//                      setState(() {
//                        temperatureState = val;
//                        SuperListener.tempCelsius(val);
//                      });
//                    },
//                  ),
//                  Text(
//                    'Celsius',
//                    style: TextStyle(
//                      fontSize: 18.0,
//                    ),
//                  ),
//                ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
