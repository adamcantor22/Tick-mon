//import 'dart:html';
//  import 'dart:html';

import 'package:flutter/material.dart';
import 'main.dart';
import 'metadata_viewinginfo.dart';
import 'decorationInfo.dart';
//import 'package:path_provider/path_provider.dart';


bool viewingDrags = true;
bool viewingData = false;
bool editingData = false;
String dateTime = DateTime.now().toString();
String name;
String site;
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


  var myController0 = TextEditingController();
  var myController1 = TextEditingController();
  var myController2 = TextEditingController();
  var myController3 = TextEditingController();
  var myController4 = TextEditingController();
  var myController5 = TextEditingController();
  var myController6 = TextEditingController();
  var myController7 = TextEditingController();

  @override
  void dispose() {
    myController1.dispose();
    myController2.dispose();
    myController3.dispose();
    myController4.dispose();
    myController5.dispose();
    myController6.dispose();
    myController7.dispose();
    super.dispose();
  }

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

          ''
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
              setState(() async {

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
        title: Text(dateTime),
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
        controller: myController0,
      ),
    ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Site'),
          controller: myController1,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Temperature'),
          controller: myController2,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Humidity'),
          controller: myController3,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Ground Moisture'),
          controller: myController4,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Habitat Type'),
          controller: myController5,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter # of Nymphs Caught'),
          controller: myController6,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextField(
          decoration: kTextFieldDecoration.copyWith(hintText: 'Enter # of Blackleggeds Caught'),
          controller: myController7,
        ),
      ),
      FlatButton(onPressed: ()  {
        print(myController0.text);
        print(myController1.text);
        print(myController2.text);
        print(myController3.text);
        print(myController4.text);
        print(myController5.text);
        print(myController6.text);
        print(myController7.text);

//      lis.add(myController0.text);
//      lis.add(myController1.text);
//      lis.add(myController2.text);
//      lis.add(myController3.text);
//      lis.add(myController4.text);
//      lis.add(myController5.text);
//      lis.add(myController6.text);
//      lis.add(myController7.text);
//      print(lis);
//
//
//        var pref = await SharedPreferences.getInstance();
//        pref.setStringList('drag', lis);
        //saveData('drag', lis);


        //getData('drag');
        
        setState(() {
          name = myController0.text;
          site = myController1.text;
          temperature = myController2.text;
          humidity = myController3.text;
          groundMoisture = myController4.text;
          habitatType = myController5.text;
          numNymphs = myController6.text;
          numBlackLegged = myController7.text;

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