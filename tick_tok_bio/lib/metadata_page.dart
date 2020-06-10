//import 'dart:html';
//  import 'dart:html';

import 'package:flutter/material.dart';
import 'main.dart';
import 'decorationInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';


bool viewingDrags = true;
bool viewingData = false;
bool editingData = false;
String dateTime = DateTime.now().toString();


class MetadataSection extends StatefulWidget {
  const MetadataSection({Key key}) : super(key: key);

  @override
  _MetadataSectionState createState() => _MetadataSectionState();
}

class _MetadataSectionState extends State<MetadataSection> {
  File jsonFile;
  Directory dir;
  String fileName = 'drag1.json';
  bool fileExists = false;
  Map fileContent;
  String currentFile;

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
//intital state is set to give the dir variable the proper directory which can be used throughout the page.
  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) async {

      print(fileName);
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = await jsonFile.exists();
      if(fileExists) {
        setState(() {
          viewingDrags = true;
          viewingData = false;
          editingData = false;
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

  //This function is used to write the data which has been entered into the textfields and put it into the JSON file.
  void writeToFile(
      String key,
      String value,
      String key1,
      String value1,
      String key2,
      String value2,
      String key3,
      String value3,
      String key4,
      String value4,
      String key5,
      String value5,
      String key6,
      String value6,
      String key7,
      String value7) {
    print('Writing to File');
    Map<String, String> content = {
      key: value,
      key1: value1,
      key2: value2,
      key3: value3,
      key4: value4,
      key5: value5,
      key6: value6,
      key7: value7
    };
    if (fileExists) {
      print('File Exists');
      Map<String, dynamic> jsonFileContents =
          json.decode(jsonFile.readAsStringSync());

      jsonFileContents.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContents));
    } else {
      print('FIle Does not exist');
      createFile(content, dir, fileName);
    }
    this.setState(() {
      fileContent = json.decode(jsonFile.readAsStringSync());
      print(fileContent);
    });
  }

  //This function should either modity the current file to one which already exists or to create a new JSON file for a new drag.
  void getFile(String fileNum) {
    getApplicationDocumentsDirectory().then((Directory directory) async {
      dir = directory;
      fileName = "drag$fileNum.json";
      print(fileName);
      jsonFile = File(dir.path + "/" + "drag$fileNum.json");
      fileExists = await jsonFile.exists();
      if(fileExists) {
        setState(() {
          fileContent = json.decode(jsonFile.readAsStringSync());
        });
      }
      else {
        File file = File(dir.path + "/drag$fileNum.json");
        file.createSync();
        fileExists = true;
       // Map contents = {'Name': ' ', 'Site': " ", 'Temperature': ' '};
        Map contents = {};
        file.writeAsStringSync(json.encode(contents));
        setState(() {
          fileContent = json.decode(file.readAsStringSync());
        });
      }
    }
    );
  }

//This function is the actual home of the scaffold and controls which screens will be seen on the app.
  Widget pageBody() {
    if (viewingDrags == true) {
      return viewDrags();
    } else if (viewingData == true) {
      return viewData();
    } else if (editingData == true) {
      return editDrag();
    }
  }

  //This function allows for the creation of cards to represnt each drag's data.
  Widget dragMenu(String time, String dragNum) {
    return GestureDetector(
      onTap: () {
        setState(() {
          getFile(dragNum);
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
              ),
            ),
          )),
    );
  }


//This function is used to populate the viewing data for a drag screen.
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

  //This is the screen that appears if on clicks over to the metaData tag.
  Widget viewDrags() {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Previous Drags',
            style: TextStyle(
              fontSize: 25.0,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    //fileName = updateFile();
                    viewingDrags = false;
                    editingData = true;
                  });
                })
          ],
        ),
        body: ListView(
          children: <Widget>[
            dragMenu('2:30:50 6/4/20', '1'),
            dragMenu('OPton2', '2'),
            dragMenu('OPton2', '3'),
            dragMenu('option 4', '4'),

          ],
        ));
  }
//This function is used to display a the specific data for the specific drag.
  Widget viewData() {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                editingData = true;
                viewingData = false;
              });
            },
          ),
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
          //infoRow('Name', json.decode(File(dir.path + "/" + fileName).readAsStringSync())['Name'].toString()),
          infoRow('Name', fileContent['Name'].toString()),
          infoRow('Site', fileContent['Site'].toString()),
          infoRow('Temperature', fileContent['Temp'].toString()),
          infoRow('Humidity', fileContent['Humidity'].toString()),
          infoRow('Ground Moisture', fileContent['GroundMoisture'].toString()),
          infoRow('Habitat Type', fileContent['HabitatType'].toString()),
          infoRow('Nymphs Collected', fileContent['NumNymphs'].toString()),
          infoRow('BlackLegged Ticks Collected', fileContent['NumBlacklegged'].toString())
        ],
      ),
    );
  }

//This function is used to change the metadata for a specific drag which has been done.
  Widget editDrag() {
    return Scaffold(
      appBar: AppBar(
        title: Text(dateTime),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  editingData = false;
                  viewingDrags = true;
                });
              })
        ],
      ),
      body: ListView(children: [
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
            decoration:
                kTextFieldDecoration.copyWith(hintText: 'Enter Temperature'),
            controller: myController2,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: TextField(
            decoration:
                kTextFieldDecoration.copyWith(hintText: 'Enter Humidity'),
            controller: myController3,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: TextField(
            decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter Ground Moisture'),
            controller: myController4,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: TextField(
            decoration:
                kTextFieldDecoration.copyWith(hintText: 'Enter Habitat Type'),
            controller: myController5,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: TextField(
            decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter # of Nymphs Caught'),
            controller: myController6,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: TextField(
            decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter # of Blackleggeds Caught'),
            controller: myController7,
          ),
        ),
        FlatButton(
            onPressed: () {
              setState(() {
                writeToFile(
                    'Name',
                    myController0.text,
                    'Site',
                    myController1.text,
                    'Temp',
                    myController2.text,
                    'Humidity',
                    myController3.text,
                    'GroundMoisture',
                    myController4.text,
                    'HabitatType',
                    myController5.text,
                    'NumNymphs',
                    myController6.text,
                    'NumBlacklegged',
                    myController7.text
                );

                editingData = false;
                viewingData = true;
              });
            },
            child: Text('Save Drag Data'))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody();
  }
}
