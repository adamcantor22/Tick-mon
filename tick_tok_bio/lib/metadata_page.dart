import 'package:flutter/material.dart';
import 'main.dart';

class MetadataSection extends StatefulWidget {
  const MetadataSection({Key key}) : super(key: key);

  @override
  _MetadataSectionState createState() => _MetadataSectionState();
}

class _MetadataSectionState extends State<MetadataSection> {

  Card dragMenu(String time) {
    return Card(
        margin: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Text(
              time,
              style: TextStyle(
                fontSize: 25.0,
              ),),
            SizedBox(
              width: 10.0,
            ),
            Icon(
              Icons.mode_edit,
              size: 50.0,),
            SizedBox(
              width: 10.0,
            ),
            Icon(
              Icons.pageview,
              size: 50.0,),
          ],
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Drags'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20'),
          dragMenu('2:30:50 6/4/20')
          ],
      )

    );
  }
}
