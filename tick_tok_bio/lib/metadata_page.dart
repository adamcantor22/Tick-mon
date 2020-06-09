//import 'dart:html';
//  import 'dart:html';

import 'package:flutter/material.dart';
import 'main.dart';
import 'metadata_viewinginfo.dart';
import 'decorationInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'json_storage_funcs.dart';
import 'file_creation_testing.dart';


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
  File jsonFile;
  Directory dir;
  String fileName = 'myfile12.json';
  bool fileExists = false;
  Map fileContent;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) async {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = await jsonFile.exists();
      if(fileExists) {
        setState(() {
          fileContent = json.decode(jsonFile.readAsStringSync());
        });
      }
    });
  }

  void createFile(Map content, Directory dir, String fileName) {
    print('Creating File');
    File file = new File(dir.path + '/' + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));

  }

  void writeToFile(String key, String value, String key1, String value1,String key2, String value2, String key3, String value3,String key4, String value4, String key5, String value5,String key6, String value6, String key7, String value7) {
    print('Writing to File');
    Map<String, String> content = {key: value, key1: value1, key2: value2, key3: value3, key4: value4, key5: value5, key6: value6, key7: value7};
    if (fileExists) {
      print('File Exists');
      Map<String, dynamic> jsonFileContents = json.decode(jsonFile.readAsStringSync());

      jsonFileContents.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContents));
    }
    else {
      print('FIle Does not exist');
      createFile(content, dir, fileName);
    }
    this.setState(() {
      fileContent = json.decode(jsonFile.readAsStringSync());
      print(fileContent);
    });
  }


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

        setState(() {
          writeToFile('Name', myController0.text, 'Site', myController1.text, 'Temp', myController2.text, 'Humidity', myController3.text, 'GroundMoisture',myController4.text, 'HabitatType', myController5.text, 'NumNymphs', myController6.text, 'NumBlacklegged', myController7.text);

          name = fileContent['Name'].toString();
          site = fileContent['Site'].toString();
          temperature = fileContent['Temp'].toString();
          humidity = fileContent['Humidity'].toString();
          groundMoisture = fileContent['GroundMoisture'].toString();
          habitatType = fileContent['HabitayType'].toString();
          numNymphs = fileContent['NumNymphs'].toString();
          numBlackLegged = fileContent['NumBlacklegged'].toString();

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
