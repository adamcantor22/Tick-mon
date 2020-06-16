//import 'dart:html';
//  import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';
import 'decorationInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'super_listener.dart';

//These are the three boolean values used to determine which screen we are currently on
bool viewingDrags = true;
bool viewingData = false;
bool editingData = false;

class MetadataSection extends StatefulWidget {
  const MetadataSection({Key key}) : super(key: key);

  @override
  MetadataSectionState createState() => MetadataSectionState();
}

class MetadataSectionState extends State<MetadataSection>
    with AutomaticKeepAliveClientMixin<MetadataSection> {
  File jsonFile;
  Directory dir;
  Directory gpxDir;
  Directory jsonDir;
  List fileList;
  String fileName = 'drag1.json';
  bool fileExists = false;
  Map fileContent;
  String currentFile;
  List dragList;
  String editingFilename;

  @override
  bool get wantKeepAlive => true;

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
    myController0.dispose();
    myController1.dispose();
    myController2.dispose();
    myController3.dispose();
    myController4.dispose();
    myController5.dispose();
    myController6.dispose();
    myController7.dispose();
    super.dispose();
  }

//This inital state is set in order to give the dir value the proper path to the working directory through the program.
  //Also as fileName currently is drag1.json, this loads that as the file primed if you were to hit the add button.
  //I imagine this will not be a problem when these drags are loaded how we want them to be.
  @override
  void initState() {
    super.initState();
    SuperListener.setPages(dPage: this);
    getDirList().then((d) {
      dir = d;
      createFilePaths();
      drags();
      //deleteFiles(); //careful with this
    });

    setState(() {
      viewingDrags = true;
      viewingData = false;
      editingData = false;
    });
  }

  void deleteFiles() async {
    for (FileSystemEntity f in fileList) {
      String p = f.path;
      if (p.substring(p.length - 4, p.length) == '.gpx') {
        print('DELETING: $p');
        f.deleteSync(recursive: true);
      }
    }
  }

  void createFilePaths() async {
    bool gpxExists = false;
    bool jsonExists = false;
    for (FileSystemEntity f in fileList) {
      String p = f.path;
      print(p);
      if (p.substring(p.length - 4, p.length) == '/gpx') {
        gpxExists = true;
        gpxDir = f;
      } else if (p.substring(p.length - 5, p.length) == '/json') {
        jsonExists = true;
        jsonDir = f;
      }
    }
    String newPath;
    if (!gpxExists) {
      newPath = '${dir.path}/gpx';
      gpxDir = await new Directory(newPath).create(recursive: true);
    }
    if (!jsonExists) {
      newPath = '${dir.path}/json';
      jsonDir = await new Directory(newPath).create(recursive: true);
    }
  }

  Future<Directory> getDirList() async {
    final d = await getApplicationDocumentsDirectory();
    fileList = d.listSync();
    return d;
  }

//I believe that this program is unnecessary as I kind of put its function in the getFile function
//  void createFile(Map content, Directory dir, String fileName) {
//    print('Creating File');
//    File file = new File(dir.path + '/' + fileName);
//    file.createSync();
//    fileExists = true;
//    file.writeAsStringSync(json.encode(content));
//  }

  //This function is used to write the data which has been entered into the text fields and saves it in the JSON File.
  //this is done by updating the content in the var fileContent.

  void writeToFile(
    String filename,
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
    String value7,
  ) {
    print('Writing to File');
    Map<String, String> content = {
      key: value,
      key1: value1,
      key2: value2,
      key3: value3,
      key4: value4,
      key5: value5,
      key6: value6,
      key7: value7,
      'visible': 'true',
    };
    if (fileExists) {
      print('File Exists');
      Map<String, dynamic> jsonFileContents =
          json.decode(jsonFile.readAsStringSync());

      jsonFileContents.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContents));
    } else {
      print('File Does not exist');
      print(jsonEncode(content));
    }
    this.setState(() {
      fileContent = json.decode(jsonFile.readAsStringSync());
      print(fileContent);
    });
  }

  //This function should either modify the current file to one which already exists or to create a new JSON file for a new drag.
  //This is done in accordance with the var fileNum. This is the integer placed at the end of the names like drag4.json.
  void getFile(String thisFilename) {
    fileName = '$thisFilename.json';
    getApplicationDocumentsDirectory().then((Directory directory) async {
      dir = Directory(directory.path + '/json');
      print(fileName);
      jsonFile = File(dir.path + '/' + fileName);
      fileExists = await jsonFile.exists();
      if (fileExists) {
        setState(() {
          fileContent = json.decode(jsonFile.readAsStringSync());
        });
      } else {
        File file = File(dir.path + '/' + fileName);
        file.createSync();
        fileExists = true;
        Map contents = {};
        file.writeAsStringSync(json.encode(contents));
        setState(() {
          fileContent = json.decode(file.readAsStringSync());
        });
      }
    });
  }

//This function is the actual home of the scaffold and controls which screens will be seen on the app.
  Widget pageBody() {
    if (viewingDrags == true) {
      return viewDrags();
    } else if (viewingData == true) {
      return viewData();
    } else if (editingData == true) {
      return editDrag(editingFilename);
    }
    return Container(); //On Error, essentially
  }

  //This function allows for the creation of cards to represent each drag's data.
  Widget dragMenu(String name) {
    editingFilename = name;
    getFile(name);
    return FlatButton(
      onPressed: () {
        setState(() {
          editingFilename = name;
          getFile(name);
          viewingData = true;
          viewingDrags = false;
        });
      },
      child: Container(
        height: 70.0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            elevation: 6.0,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 5,
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Center(
                      child: Icon(
                        Icons.file_upload,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//This function is used to populate the screen where all the data for a drag is being viewed.
  Widget infoRow(key, value) {
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

//This is used to populate the textBoxes and link them with their proper controllers in the entering data screen.
  Widget dataField(String hText, controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: TextField(
        decoration: kTextFieldDecoration.copyWith(hintText: hText),
        controller: controller,
      ),
    );
  }

  void drags() {
    setState(() {
      final jsonList = jsonDir.listSync();
      dragList = new List<Widget>();
      for (FileSystemEntity f in jsonList) {
        String p = f.path;
        dragList.add(dragMenu(
          p.substring(p.length - 28, p.length - 5),
        ));
      }
//      dragList = <Widget>[
//        //dragMenu(fileContent['time'].toString(), 1, visibilityList[0]),
//        dragMenu(
//          'TESTDATA' + DateTime.now().toString(),
//          2,
//        ),
//        dragMenu(
//          'TESTDATA' + DateTime.now().toString(),
//          3,
//        ),
//        dragMenu(
//          'TESTDATA' + DateTime.now().toString(),
//          4,
//        ),
//        dragMenu(
//          'TESTDATA' + DateTime.now().toString(),
//          5,
//        ),
//        dragMenu(
//          'TESTDATA' + DateTime.now().toString(),
//          30,
//        ),
//      ];
    });
    print(dragList.length);
  }

  void createNewDrag(String newFilename) {
    setState(() {
      print('***DATAPAGE MAKING NEW DRAG***');
      dragList.add(dragMenu(
        newFilename,
      ));
      viewingDrags = false;
      editingData = true;
      editingFilename = newFilename;
    });
  }

  //This is the screen that appears if on clicks over to the metaData tag.
  //It is populated with a bunch of clickable cards, each represents a drag which has been done.
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
                dragList.add(dragMenu(
                  'New Drag',
                ));
                viewingDrags = false;
                editingData = true;
                editingFilename = 'TESTDATA_' + DateTime.now().toString();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: ListView(
          children: dragList,
        ),
      ),
    );
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
          //of unsure what fileContent is referring to
          //fileContent =  json.decode(File(dir.path + "/" + fileName).readAsStringSync())['SPECIFIC_KEY'].toString()),
          infoRow('Name', fileContent['Name'].toString()),
          infoRow('Site', fileContent['Site'].toString()),
          infoRow('Temperature', fileContent['Temp'].toString()),
          infoRow('Humidity', fileContent['Humidity'].toString()),
          infoRow('Ground Moisture', fileContent['GroundMoisture'].toString()),
          infoRow('Habitat Type', fileContent['HabitatType'].toString()),
          infoRow('Nymphs Collected', fileContent['NumNymphs'].toString()),
          infoRow('BlackLegged Ticks Collected',
              fileContent['NumBlacklegged'].toString())
        ],
      ),
    );
  }

//This function is used to change the metadata for a specific drag which has been done.
  //It is populated with Text Fields
  Widget editDrag(String thisFilename) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Title'),
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
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 7,
            child: ListView(
              padding: EdgeInsets.only(top: 10.0),
              children: [
                dataField('Enter Name', myController0),
                dataField('Enter Site', myController1),
                dataField('Enter Temperature', myController2),
                dataField('Enter Humidity', myController3),
                dataField('Enter Ground Mosture', myController4),
                dataField('Enter Habitat Type', myController5),
                dataField('Enter Number of Nymphs Caught', myController6),
                dataField('Enter Number of BlackLeggeds caught', myController7),
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Flexible(
            flex: 1,
            child: RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: () {
                setState(() {
                  writeToFile(
                    thisFilename,
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
                    myController7.text,
                  );

                  editingData = false;
                  viewingData = true;
                });
              },
              child: Text('Save Drag Data'),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody();
  }
}
