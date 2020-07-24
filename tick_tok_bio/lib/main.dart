import 'package:flutter/material.dart';
import 'package:tick_tok_bio/decorationInfo.dart';
import 'package:tick_tok_bio/logged_in_screen.dart';
import 'package:tick_tok_bio/settings_page.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'database.dart';
import 'gps_tracking.dart';
import 'metadata_page.dart';
import 'json_storage.dart';
import 'super_listener.dart';
import 'dart:async';
import 'user_page.dart';
import 'weather_tracker.dart';
import 'settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'LoggedInFeatures',
      routes: {
        //'LoginScreen': (context) => UserPage(),
        'LoggedInFeatures': (context) => HomePage()
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  MetadataSection metadataSection = MetadataSection();
  Maps maps = Maps();
  LoggedInScreen loggedInPage = LoggedInScreen();
  //UserPage userPage = UserPage();
  Settings settings = Settings();
  int priorIndex;

  int pageIndex = 0;

  int _selectedIndex = 0;
  bool _loading = true;
  Timer _loadTimer;

  @override
  void initState() {
    super.initState();
    setListeners();
    startLoadTimer();
  }

  void setListeners() {
    SuperListener.setPages(
      hPage: this,
    );
    WeatherTracker.startupWeather();
  }

  void startLoadTimer() {
    _loadTimer = Timer.periodic(
      Duration(seconds: 3),
      (timer) {
        build(context);
        if (!_loading) timer.cancel();
      },
    );
  }

  void checkEmpty() {
    int empty = SuperListener.emptyRef();
    print('EMPTY: $empty');
    if (empty >= 0) {
      setState(() {
        _selectedIndex = empty;
      });
    } else {
      setState(() {
        print('STOP LOADING');
        _loading = false;
      });
    }
  }

  void pageNavigator(int num) {
    setState(() {
      print('WE SHOULD BE CHANGING PAGES');
      pageIndex = num;
    });
  }

  settingsMidDragPopUp(BuildContext context) {
    Widget agreement = FlatButton(
        onPressed: () {
          setState(() {
            Navigator.pop(context);
          });
        },
        child: Text('Ok.'));

    AlertDialog alert = AlertDialog(
      title: Text('Settings are unable to be changed during a drag.'),
      actions: [agreement],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  BottomNavigationBarItem navBarItem(IconData icon, String title) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.blue,
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      onTap: (int index) {
        setState(() {
          if (trackingRoute == true && index == 3) {
            print('Drag must be finished prior');
            settingsMidDragPopUp(context);
          } else {
            pageIndex = index;
          }
          if (priorIndex == 3) {
            SuperListener.checkSettings();
          }

          priorIndex = index;
        });
      },
      currentIndex: pageIndex,
      backgroundColor: Colors.blue,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        navBarItem(Icons.person, 'User'),
        navBarItem(Icons.explore, 'Map'),
        navBarItem(Icons.storage, 'Drags'),
        navBarItem(Icons.settings, 'Settings'),
      ],
    );
  }

  Widget loadingScreen() {
    return Center(
      child: Container(
        width: 700.0,
        height: 700.0,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 50.0,
              ),
              Text(
                'Loading App...',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 23.0,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainBody() {
    return Scaffold(
      bottomNavigationBar: _bottomNavBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: IndexedStack(
              index: pageIndex,
              children: <Widget>[
                loggedInPage,
                maps,
                metadataSection,
                settings,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return mainBody();
  }
}
