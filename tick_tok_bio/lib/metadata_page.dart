//import 'dart:html';
import 'package:flutter/material.dart';
import 'main.dart';
import 'metadata_viewinginfo.dart';
import 'decorationInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool viewingDrags = true;
bool viewingData = false;
bool editingData = false;
String date;
String time;
String site;
String name;
String temperature;
String humidity;
String groundMoisture;
String habitatType;
String numNymphs;
String numBlackLegged;
List lis;

class MetadataSection extends StatefulWidget {
  const MetadataSection({Key key}) : super(key: key);

  @override
  _MetadataSectionState createState() => _MetadataSectionState();
}

class _MetadataSectionState extends State<MetadataSection> {


  Widget pageBody() {
    if (viewingDrags == true) {
      return viewDrags();
    }
    else if (viewingData == true) {
      return viewData();
    }
    else if (editingData == true) {
      return editDrag();
    }
  }

  Widget dragMenu(String time) {
    return GestureDetector(
      onTap: () {
        setState(() {
          viewingData = true;
          viewingDrags = false;
        });
      },
      child: Card(
          margin: EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              time,
              style: TextStyle(
                fontSize: 25.0,
              ),),
          )),
    );
  }


  Widget viewDrags() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Previous Drags',
            style: TextStyle(
              fontSize: 25.0,
            ),),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.add), onPressed: () {
              setState(() {
                viewingDrags = false;
                editingData = true;
              });
            })
          ],
        ),
        body: ListView(
          children: <Widget>[
            dragMenu('2:30:50 6/4/20'),
            dragMenu('2:30:50 6/4/20'),

          ],
        )
    );
  }




  Widget viewData() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$time $date',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
          onPressed: () {
              setState(() {
                editingData = true;
                viewingData = false;
              });
          },),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                viewingData = false;
                viewingDrags = true;

              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          infoRow('Name', name),
          infoRow('Site', site),
          infoRow('Temperature', temperature),
          infoRow('Humidity', humidity),
          infoRow('Ground Moisture', groundMoisture),
          infoRow('Habitat Type', habitatType),
          infoRow('Nymphs Collected', numNymphs),
          infoRow('BlackLegged Ticks Collected', numBlackLegged)
        ],
      ),
    );
  }

    infoRow(key, value) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            '$key: $value',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ],
    );
  }

//  Widget dataField(String hText, variable) {
//
//    return Padding(
//      padding: EdgeInsets.only(top: 10.0),
//      child: TextField(
//        decoration: kTextFieldDecoration.copyWith(hintText: hText),
//        onChanged: (value) {
//          setState(() {
//            variable = value;
//            print(site);
//          });
//        },
//      ),
//    );
//  }


  Widget editDrag() {
    return Scaffold(
        appBar: AppBar(
        title: Text(DateTime.now().toString()),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.close), onPressed: () {
              setState(() {
                editingData = false;
                viewingDrags = true;
              });
            })
          ],
    ),
    body: ListView(
    children: [
    Padding(
    padding: EdgeInsets.only(top: 10.0),
      child: TextField(
        decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Name'),
        onChanged: (value) {
          setState(() {
            name = value;
          });
        },
      ),
    ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Site'),
          onChanged: (value) {
            setState(() {
              site = value;
              print(site);
            });
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Temperature'),
          onChanged: (value) {
            setState(() {
              temperature = value;
            });
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Humidity'),
          onChanged: (value) {
            setState(() {
              humidity = value;
            });
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Ground Moisture'),
          onChanged: (value) {
            setState(() {
              groundMoisture = value;
            });
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Habitat Type'),
          onChanged: (value) {
            setState(() {
              habitatType = value;
            });
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter # of Nymphs Caught'),
          onChanged: (value) {
            setState(() {
              numNymphs = value;
            });
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter # of Blackleggeds Caught'),
          onChanged: (value) {
            setState(() {
              numBlackLegged = value;
            });
          },
        ),
      ),
      FlatButton(onPressed: () {
        setState(() {
          editingData = false;
          viewingData = true;
        });
      }, child: Text(
        'Save Drag Data'
      )
      )
    ]
    ),);

  }

 void saveData(var key, var value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
 }


  @override
  Widget build(BuildContext context) {
    return pageBody();
  }
}

//void setNum() async {
//    var prefs = await SharedPreferences.getInstance();
//    prefs.setInt('number', 11);
//  }
//
//  void getNum() async {
//    var prefs = await SharedPreferences.getInstance();
//    int num = prefs.getInt('number');
//    print(num);
//  }