import 'package:flutter/material.dart';
import 'map.dart';
import 'database.dart';
import 'gps_tracking.dart';
import 'metadata_page.dart';

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
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = [
    MapPage(
      key: PageStorageKey('MapPage'),
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

  int _selectedIndex = 0;

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
        navBarItem(Icons.map, 'Map'),
        navBarItem(Icons.settings, 'Data'),
        navBarItem(Icons.satellite, 'Updated Map'),
        navBarItem(Icons.sd_storage, 'MetaData'),
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
