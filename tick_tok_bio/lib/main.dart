import 'package:flutter/material.dart';
import 'package:tick_tok_bio/decorationInfo.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'database.dart';
import 'gps_tracking.dart';
import 'metadata_page.dart';
import 'json_storage.dart';
import 'super_listener.dart';



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

  @override
  void initState() {
    super.initState();
    setListeners();
  }

  void setListeners() {
    SuperListener.setPages(
      hPage: this,
      //mPage: pages,
    );
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

  @override
  Widget build(BuildContext context) {
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
}
