import 'package:flutter/material.dart';
import 'package:tick_tok_bio/decorationInfo.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'database.dart';
import 'gps_tracking.dart';
import 'metadata_page.dart';
import 'json_storage.dart';
import 'super_listener.dart';
import 'dart:async';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>{


  MetadataSection metadataSection = MetadataSection();
  Maps maps = Maps();
  UserPage userPage = UserPage();

  int pageIndex = 0;
  //static int _widgetIndex;



//  final List<Widget> pages = [
//    UserPage(
//      key: PageStorageKey('UserPage'),
//    ),
//    Maps(
//      key: PageStorageKey('GPSPage'),
//    ),
//    MetadataSection(
//      key: PageStorageKey('MetadataPage'),
//    ),
//  ];

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 2;
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
      //mPage: pages,
    );
  }

  void startLoadTimer() {
    _loadTimer = Timer.periodic(
      Duration(seconds: 3),
      (timer) {
        if (_loading)
          build(context);
        else
          timer.cancel();
      },
    );
  }

  void checkEmpty() {
    int empty = SuperListener.emptyRef();
    if (empty >= 0) {
      setState(() {
        _selectedIndex = empty;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void pageNavigator(int num) {
    setState(() {
      pageIndex = num;
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
      onTap: (int index) => setState(() => pageIndex = index),
      currentIndex: pageIndex,
      backgroundColor: Colors.blue,
      type: BottomNavigationBarType.shifting,
      items: <BottomNavigationBarItem>[
        navBarItem(Icons.person, 'User'),
        navBarItem(Icons.satellite, 'Updated Map'),
        navBarItem(Icons.sd_storage, 'DragHistory'),
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
      body:
        Column(
          children: <Widget>[
            Expanded(
                child: IndexedStack(
                  index: pageIndex,
                  children: <Widget>[
                    userPage,
                    maps,
                    metadataSection,
                  ],
                ),
            ),
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      checkEmpty();
      return Stack(
        children: <Widget>[
          mainBody(),
          loadingScreen(),
        ],
      );
    }
    return mainBody();
  }
}
