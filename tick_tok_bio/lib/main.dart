import 'package:flutter/material.dart';
import 'package:tick_tok_bio/decorationInfo.dart';
import 'package:tick_tok_bio/metadata_viewinginfo.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'map.dart';
import 'database.dart';
import 'gps_tracking.dart';
import 'metadata_page.dart';
import 'file_creation_testing.dart';
import 'json_storage.dart';

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
    FileCreation(
      key: PageStorageKey('FileMaker'),
      storage: Storage(),
    ),
    JSONStorage(
      key: PageStorageKey('JSON')
    )
//    MetaDataDisplay(
//      key: PageStorageKey('DataDisplay'),
//    )
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;

  void pageNavigator(int i) {
      _selectedIndex = i;
      _bottomNavBar(i);

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
        navBarItem(Icons.insert_drive_file, 'File Creator'),
        navBarItem(Icons.attach_file, 'JSON Storage')
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
