import 'package:flutter/material.dart';
import 'main.dart';
import 'metadata_viewinginfo.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              time,
              style: TextStyle(
                fontSize: 25.0,
              ),),
              IconButton(
                icon: Icon(
                  Icons.mode_edit,
                  size: 40.0,),
                onPressed: () {
                  setState(() {

                  });
                },
              ),
            IconButton(
              icon: Icon(Icons.pageview,
              size: 40.0,),
              onPressed: () {
                setState(() {


                });

              },
              ),
          ],
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Drags',
        style: TextStyle(
          fontSize: 25.0,
        ),),
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
