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

class HomePageState extends State<HomePage> {
  final List<Widget> pages = [
    UserPage(
      key: PageStorageKey('UserPage'),
    ),
    InputSection(
      key: PageStorageKey('InputPage'),
    ),
    Maps(
      key: PageStorageKey('GPSPage'),
    ),
    MetadataSection(
      key: PageStorageKey('MetadataPage'),
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    setListeners();
  }

  void setListeners() {
    SuperListener.setPages(
      hPage: this,
      mPage: pages[2],
    );
  }

  int _selectedIndex = 0;

  void pageNavigator(int i) {
    setState(() {
      _selectedIndex = i;
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

  Widget _bottomNavBar(int selectedIndex) {
    return BottomNavigationBar(
      onTap: (int index) => setState(() => _selectedIndex = index),
      currentIndex: selectedIndex,
      backgroundColor: Colors.blue,
      type: BottomNavigationBarType.shifting,
      items: <BottomNavigationBarItem>[
        navBarItem(Icons.person, 'User'),
        navBarItem(Icons.settings, 'Data'),
        navBarItem(Icons.satellite, 'Updated Map'),
        navBarItem(Icons.sd_storage, 'DragHistory'),
        //navBarItem(Icons.edit, 'EditData'),
        //navBarItem(Icons.remove_red_eye, 'DataView'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavBar(_selectedIndex),
      body: PageStorage(
        child: pages[_selectedIndex],
        bucket: bucket,
      ),
    );
  }
}
