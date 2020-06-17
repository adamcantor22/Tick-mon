//import 'dart:html';
//  import 'dart:html';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';
import 'decorationInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'super_listener.dart';
import 'helper.dart';
import 'file_uploader.dart';

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

  void drags() async {
    var tmpList = new List<Widget>();
    final jsonList = jsonDir.listSync();
    for (FileSystemEntity f in jsonList) {
      String p = f.path;
      Widget tmp = await dragMenu(p.substring(p.length - 28, p.length - 5));
      tmpList.add(tmp);
    }
    setState(() {
      dragList = tmpList;
    });
  }

  void deleteFiles() async {
    for (FileSystemEntity f in fileList) {
      String p = f.path;
      if (p.substring(p.length - 4, p.length) == '.gpx' ||
          p.substring(p.length - 5, p.length) == '.json') {
        print('DELETING: $p');
        f.deleteSync(recursive: true);
      }
    }
    try {
      String p = jsonDir.path + '/New Drag.json';
      File(p).deleteSync();
    } catch (e) {
      print('no unintended drags');
    }
  }

  void createFilePaths() async {
    bool gpxExists = false;
    bool jsonExists = false;
    for (FileSystemEntity f in fileList) {
      String p = f.path;
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
  Future<bool> getFile(String thisFilename) async {
    fileName = '$thisFilename.json';
    Directory directory = await getApplicationDocumentsDirectory();
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
    return fileContent != null;
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

  String getDragDisplayName() {
    String s = '';
    s += (fileContent != null &&
                fileContent['Site'] != null &&
                fileContent['Site'].toString().trim() != ''
            ? fileContent['Site'].toString()
            : 'GQ') +
        ' ';
    s += '1' + ' ';
    s += 'ABC' + ' ';
    s += editingFilename.substring(0, 10);
    return s;
  }

  //This function allows for the creation of cards to represent each drag's data.
  Future<Widget> dragMenu(String name) async {
    editingFilename = name;
    final b = await getFile(name);
    String display = getDragDisplayName();
    bool fileUploaded = false;
    StorageReference store;
    try {
      store = FirebaseStorage.instance.ref().child('$editingFilename.json');
      fileUploaded = true;
    } catch (e) {
      print(e);
    }

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
                        display,
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
                        color: fileUploaded ? Colors.green : Colors.black,
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
  Widget dataField(
      TextEditingController controller, String field, String hText) {
    Widget widget = Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextField(
        decoration: kTextFieldDecoration.copyWith(
            hintText: 'Enter $field', labelText: field),
        controller: controller,
      ),
    );
    if (hText != null) {
      controller.text = hText;
    } else {
      controller.text = '';
    }
    return widget;
  }

  void createNewDrag(String newFilename) {
    setState(() {
      dragList.add(dragMenu(
        newFilename,
      ));
      viewingDrags = false;
      viewingData = false;
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
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 10.0),
        children:
            getDragList(), // != null ? dragList : <Widget>[Text('No Data')],
      ),
    );
  }

  List<Widget> getDragList() {
    if (dragList == null) {
      return <Widget>[
        Center(
          child: Text('Data Loading'),
        ),
      ];
    }
    return dragList;
  }

//This function is used to display a the specific data for the specific drag.
  Widget viewData() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viewing Drag Metadata'),
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
      body: Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                //of unsure what fileContent is referring to
                //fileContent =  json.decode(File(dir.path + "/" + fileName).readAsStringSync())['SPECIFIC_KEY'].toString()),
                infoRow('Name', fileContent['Name'].toString()),
                infoRow('Site', fileContent['Site'].toString()),
                infoRow('Temperature', fileContent['Temp'].toString()),
                infoRow('Humidity', fileContent['Humidity'].toString()),
                infoRow('Ground Moisture',
                    fileContent['GroundMoisture'].toString()),
                infoRow('Habitat Type', fileContent['HabitatType'].toString()),
                infoRow(
                    'Nymphs Collected', fileContent['NumNymphs'].toString()),
                infoRow('BlackLegged Ticks Collected',
                    fileContent['NumBlacklegged'].toString())
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 35.0),
              child: RaisedButton(
                color: Colors.red[700],
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Helper().boolMessage(
                        'Are you sure you want to delete this data from your phone? If it has not been uploaded to the cloud it will be permanently deleted.',
                        deleteCurrentDrag,
                        context,
                      );
                    },
                  );
                },
                child: Text(
                  'Delete Drag Data',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteCurrentDrag() {
    File f;
    try {
      f = File('${jsonDir.path}/$editingFilename.json');
      f.deleteSync(recursive: true);
      print('json file deleted');
    } catch (e) {
      print(e);
      print('No such json file');
    }

    try {
      f = File('${gpxDir.path}/$editingFilename.gpx');
      f.deleteSync(recursive: true);
      print('gpx file deleted');
    } catch (e) {
      print('No such gpx file');
    }

    viewingData = false;
    viewingDrags = true;
    drags();
  }

//This function is used to change the metadata for a specific drag which has been done.
  //It is populated with Text Fields
  Widget editDrag(String thisFilename) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing Drag Metadata'),
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
            flex: 8,
            child: ListView(
              padding: EdgeInsets.only(top: 10.0),
              children: [
                dataField(
                  myController0,
                  'Name',
                  fileContent['Name'],
                ),
                dataField(
                  myController1,
                  'Site',
                  fileContent['Site'],
                ),
                dataField(
                  myController2,
                  'Temperature',
                  fileContent['Temp'],
                ),
                dataField(
                  myController3,
                  'Humidity',
                  fileContent['Humidity'],
                ),
                dataField(
                  myController4,
                  'Ground Moisture',
                  fileContent['GroundMoisture'],
                ),
                dataField(
                  myController5,
                  'Habitat Type',
                  fileContent['HabitatType'],
                ),
                dataField(
                  myController6,
                  'Number of Nymphs',
                  fileContent['NumNymphs'],
                ),
                dataField(
                  myController7,
                  'Number of Blackleggeds',
                  fileContent['NumBlacklegged'],
                ),
              ],
            ),
          ),
          Container(
            height: 5.0,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(
                top: BorderSide(
                  width: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              padding: EdgeInsets.zero,
              color: Colors.grey[200],
              child: Center(
                child: RaisedButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () {
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
                    sendJsonToCloud();
                    drags();

                    setState(() {
                      editingData = false;
                      viewingData = false;
                      viewingDrags = true;
                    });
                  },
                  child: Text('Save Drag Data'),
                ),
              ),
            ),
          ),
          Container(
            height: 5.0,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  void sendJsonToCloud() {
    FileUploader uploader = new FileUploader();
    File f = File('${jsonDir.path}/$editingFilename.json');
    uploader.fileUpload(f, '$editingFilename.json').then((val) {
      print(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return pageBody();
  }
}
