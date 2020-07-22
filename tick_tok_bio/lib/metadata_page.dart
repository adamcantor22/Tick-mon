import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tick_tok_bio/user_page.dart';
import 'decorationInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'super_listener.dart';
import 'helper.dart';
import 'file_uploader.dart';
import 'weather_tracker.dart';
import 'package:weather/weather_library.dart';
import 'gps_tracking.dart';
import 'package:tick_tok_bio/helper.dart';

//These are the three boolean values used to determine which screen we are currently on
bool viewingDrags = true;
bool viewingData = false;
bool editingData = false;

bool siteSelected = false;
bool moistureSelected = false;
bool habitatSelected = false;

var myController0 = TextEditingController();
var myController1 = TextEditingController();
var myController2 = TextEditingController();
var myController3 = TextEditingController();
var myController4 = TextEditingController();
var myController5 = TextEditingController();
var myController6 = TextEditingController();
var myController7 = TextEditingController();
var myController8 = TextEditingController();
var myController9 = TextEditingController();
var myController10 = TextEditingController();
var myController11 = TextEditingController();
var myController12 = TextEditingController();
var myController13 = TextEditingController();
var myController14 = TextEditingController();

List<TextEditingController> subs = [
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
];

List dropVals = <dynamic>[
  '',
  '',
  '',
];

var iScapN = 0;
var iScapAM = 0;
var iScapAF = 0;
var aAmer = 0;
var dVari = 0;
var hLong = 0;
var lxod = 0;
var selectedSpec;

Map fileContent;

class MetadataSection extends StatefulWidget {
  const MetadataSection({Key key}) : super(key: key);

  @override
  MetadataSectionState createState() => MetadataSectionState();
}

class MetadataSectionState extends State<MetadataSection> {
  File jsonFile;
  Directory dir;
  Directory gpxDir;
  Directory jsonDir;
  List fileList;
  String fileName = 'drag1.json';
  bool fileExists = false;
  String currentFile;
  List<Widget> dragList = [];
  String editingFilename;
  Weather curWeather;
  final _editKey = GlobalKey<FormState>();
  bool changesMade;
  bool loadingData = false;
  bool celsius = false;
  List<Map<String, int>> segmentedTickData;
  Map<String, bool> syncMap = Map<String, bool>();
  File syncFile;

  List habitatList = <String>[
    'Field/Grass',
    'Forest Edge',
    'Closed Canopy (Oak)',
    'Closed Canopy (Tulip/Maple)',
    'Closed Canopy (Mixed Conifer)',
    'Other',
  ];

  List siteList = <String>[
    'AT',
    'BP',
    'GA',
    'LH',
    'LM',
    'RM',
    'SM',
    'SP',
    'SW',
    'TP',
    'Other',
  ];

  List moistureList = <String>[
    'Very Dry (No Rain 2+ Weeks)',
    'Dry (No Rain 1 Week)',
    'Medium (Moderate Rain Within Week)',
    'Moist (Heavy Rain Within 3 Days)',
    'Other',
  ];

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
      syncChecker();

      //deleteFiles(); //careful with this
    });

    setState(() {
      viewingDrags = true;
      viewingData = false;
      editingData = false;
    });
  }

  void clearControllers() {
    myController0.clear();
    myController1.clear();
    myController2.clear();
    myController3.clear();
    myController4.clear();
    myController5.clear();
    myController6.clear();
    myController7.clear();
    myController8.clear();
    myController9.clear();
    myController10.clear();
    myController11.clear();
    myController12.clear();
    myController13.clear();
    myController14.clear();
  }

  //This function is the actual home of the scaffold and controls which screens will be seen on the app.
  Widget pageBody() {
    if (loadingData) {
      return loadingWait();
    } else if (viewingDrags == true) {
      return viewDrags();
    } else if (viewingData == true) {
      return viewData();
    } else if (editingData == true) {
      return editDrag(editingFilename);
    }
    return Container(); //On Error, essentially
  }

  void syncChecker() async {
    bool syncExists = false;
    syncFile = File('$dir/sync.json');
    for (FileSystemEntity f in fileList) {
      String p = f.path;
      if (p.substring(p.length - 9, p.length) == 'sync.json') {
        syncExists = true;
        syncMap = jsonDecode(syncFile.readAsStringSync());
        break;
      }
    }
    if (!syncExists) {
      syncFile.createSync();
    }
  }

  void changeSync(String f, bool b) {
    syncMap[f] = b;
    print("Setting $f to $b");
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

  Widget loadingWait() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

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
    String key8,
    String value8,
    String key9,
    String value9,
    String key10,
    String value10,
    String key11,
    String value11,
    String key12,
    String value12,
    String key13,
    String value13,
    String key14,
    List<Map<String, int>> value14,
  ) {
    print('Writing to File');
    Map<String, dynamic> content = {
      key: value,
      key1: value1,
      key2: value2,
      key3: value3,
      key4: value4,
      key5: value5,
      key6: value6,
      key7: value7,
      key8: value8,
      key9: value9,
      key10: value10,
      key11: value11,
      key12: value12,
      key13: value13,
      key14: value14,
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

  String getDragDisplayName() {
    String s = '';
    s += (fileContent != null &&
                fileContent['Site'] != null &&
                fileContent['Site'].toString().trim() != ''
            ? fileContent['Site'].toString()
            : 'GQ') +
        ' ';
    //s += '1' + ' '; //put this back with a functioning counter, not just 1
    s += '${name.substring(0, 3).toUpperCase()}' + ' ';
    s += editingFilename.substring(0, 10);
    return s;
  }

  Future<bool> attemptFileUploads() async {
    bool ret = true;
    File file1 = File('${gpxDir.path}/$editingFilename.gpx');
    File file2 = File('${jsonDir.path}/$editingFilename.json');
    FileUploader uploader = new FileUploader();
    String s1 = await uploader.fileUpload(file1, '$editingFilename.gpx');
    String s2 = await uploader.fileUpload(file2, '$editingFilename.json');
    if (s1 == 'error' || s2 == 'error') ret = false;
    return ret;
  }

  //This function allows for the creation of cards to represent each drag's data.
  Future<Widget> dragMenu(String name) async {
    editingFilename = name;
    final b = await getFile(name);
    String display = getDragDisplayName();
    String key1 = '${gpxDir.path}/$editingFilename.gpx';
    String key2 = '${jsonDir.path}/$editingFilename.json';
    bool fileUploaded = syncMap.containsKey(key1) &&
        syncMap.containsKey(key2) &&
        syncMap[key1] == true &&
        syncMap[key2] == true;

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
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              fileUploaded ? Colors.green[500] : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                fileUploaded ? Colors.green[500] : Colors.black,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_upload,
                                size: 24.0,
                                color:
                                    fileUploaded ? Colors.white : Colors.black,
                              ),
                              FlatButton(
                                onPressed: () async {
                                  if (!fileUploaded) {
                                    bool b = await attemptFileUploads();
                                    setState(() {
                                      drags();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
//                          IconButton),
//                        (
//                          icon: Icon(Icons.file_upload),
//                          iconSize: 24.0,
//                          color: fileUploaded ? Colors.white : Colors.black,
//                          onPressed: () async {
//                            if (!fileUploaded) {
//                              await attemptFileUploads();
//                            }
//                          },
//                        ),
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
  Widget infoRow(String key, String value) {
    final cutoffPoint = 15;
    TextStyle ts = TextStyle(
      letterSpacing: -0.7,
      fontSize: 17.5,
      fontWeight: FontWeight.w600,
      fontFamily: 'RobotoMono',
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 5.0, 8.0),
                child: Text(
                  '$key:',
                  style: ts,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          Flexible(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[200],
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.0, 8.0, 0.0, 8.0),
                child: Text(
                  value != null && value != 'null'
                      ? value.length <= cutoffPoint
                          ? value
                          : value.substring(0, cutoffPoint - 3) + '...'
                      : 'None',
                  style: ts,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//This is used to populate the textBoxes and link them with their proper controllers in the entering data screen.
  Widget dataField(
    TextEditingController controller,
    String field,
    String hText, {
    bool required = true,
  }) {
    Widget widget = Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: TextFormField(
        decoration: kTextFieldDecoration.copyWith(
            hintText: 'Enter $field', labelText: field),
        controller: controller,
        validator: (value) {
          if (required &&
              (controller.text == null || controller.text.trim() == '')) {
            return 'Enter All Data';
          }
          return null;
        },
        onChanged: (s) {
          changesMade = true;
        },
      ),
    );
    if (hText != null) {
      controller.text = hText;
    } else {
      controller.text = '';
    }
    return widget;
  }

  void createNewDrag(String newFilename) async {
    trackingRoute = false;

    setState(() {
      loadingData = true;
    });
    print('REACHES HERE');
    curWeather = await WeatherTracker.getWeather();
    Widget newDrag = await dragMenu(newFilename);

    setState(() {
      dragList.add(newDrag);
      editingFilename = newFilename;
    });

    final b = await addDeterminedFields();

    setState(() {
      print('CHANGING TO EDIT MODE');
      viewingDrags = false;
      viewingData = false;
      editingData = true;
      loadingData = false;
    });
  }

  Future<bool> addDeterminedFields() async {
    final b = await getFile(editingFilename);

    if (curWeather != null) {
      fileContent['Temp'] = (celsius
              ? curWeather.temperature.celsius
              : curWeather.temperature.fahrenheit)
          .toStringAsPrecision(5)
          .toString();
      fileContent['Humidity'] = curWeather.humidity.toString();
    }
    fileContent['Name'] = name;
    fileContent['Iscap'] = iScapN.toString();
    iScapN = 0;
    return b;
  }

  void sendSegmentedTickData(List<Map<String, int>> data) {
    segmentedTickData = data;
  }

  void tempCelsius(bool state) {
    setState(() {
      celsius = state;
    });
  }

  void updateTickText() {
    myController6.text = iScapN.toString();
    print(iScapN);
  }

  void setTickData(Map tickData) {
    print(tickData);
    if (tickData.containsKey('I. scapN')) {
      iScapN += tickData['I. scapN'];
    }
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
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          padding: EdgeInsets.only(top: 15.0),
          children:
              getDragList(), // != null ? dragList : <Widget>[Text('No Data')],
        ),
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
        title: Text('Viewing: ${getDragDisplayName()}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                moistureSelected = true;
                habitatSelected = true;
                siteSelected = true;
                changesMade = false;
                editingData = true;
                viewingData = false;
                dropVals[0] = fileContent['HabitatType'];
                dropVals[1] = fileContent['Site'];
                dropVals[2] = fileContent['GroundMoisture'];
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
        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
        color: Colors.grey[200],
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 7.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[400],
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
                  child: Column(
                    children: [
                      //of unsure what fileContent is referring to
                      //fileContent =  json.decode(File(dir.path + "/" + fileName).readAsStringSync())['SPECIFIC_KEY'].toString()),
                      infoRow('Name', fileContent['Name'].toString()),
                      infoRow('Site', fileContent['Site'].toString()),
                      infoRow('Temperature', fileContent['Temp'].toString()),
                      infoRow('Humidity', fileContent['Humidity'].toString()),
                      infoRow('Ground Moisture',
                          fileContent['GroundMoisture'].toString()),
                      infoRow('Habitat Type',
                          fileContent['HabitatType'].toString()),
                      infoRow('I. scapularis nymph',
                          fileContent['Iscap'].toString()),
                      infoRow('I. scapularis adult male',
                          fileContent['IscapAM'].toString()),
                      infoRow(
                          'I. scapularis adult female', fileContent['IscapAF']),
                      infoRow(
                          'A. americanum (Lone star)', fileContent['loneStar']),
                      infoRow(
                          'D. variabilis (American dog)', fileContent['Adog']),
                      infoRow(
                          'H. longicornis (Longhorned)', fileContent['Hlong']),
                      infoRow('lxodes spp (other)', fileContent['other']),
                      infoRow('Notes', fileContent['Notes'].toString()),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 100.0),
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

  void revertChanges() {
    setState(() {
      editingData = false;
      viewingDrags = false;
      viewingData = true;
    });
  }

//This function is used to change the metadata for a specific drag which has been done.
  //It is populated with Text Fields
  Widget editDrag(String thisFilename) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing ${getDragDisplayName()}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              if (_editKey.currentState.validate()) {
                if (changesMade) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Helper().boolMessage(
                        'Are you sure you want to exit? All changed data will be reverted.',
                        revertChanges,
                        context,
                      );
                    },
                  );
                } else {
                  setState(() {
                    editingData = false;
                    viewingDrags = false;
                    viewingData = true;
                  });
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 8,
            child: Form(
              key: _editKey,
              child: ListView(
                padding: EdgeInsets.only(top: 10.0),
                children: [
                  dataField(
                    myController0,
                    'Name',
                    fileContent['Name'],
                  ),
                  DropDownMenu(
                    label: 'Site',
                    dropIndex: 1,
                    controller: myController1,
                    items: siteList,
                    jsonVal: 'Site',
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
                  DropDownMenu(
                    label: 'Ground Moisture',
                    items: moistureList,
                    dropIndex: 2,
                    controller: myController4,
                    jsonVal: 'GroundMoisture',
                  ),
                  DropDownMenu(
                    label: 'Habitat Type',
                    items: habitatList,
                    dropIndex: 0,
                    controller: myController5,
                    jsonVal: 'HabitatType',
                  ),
                  //markerInfo(5),
                  dataField(
                    myController6,
                    'I. scapularis nymph',
                    fileContent['Iscap'],
                  ),
                  dataField(
                    myController7,
                    'I. scapularis adult male',
                    fileContent['IscapAM'],
                  ),
                  dataField(
                    myController8,
                    'I. scapularis adult female',
                    fileContent['IscapAF'],
                  ),
                  dataField(
                    myController9,
                    'A. americanum (Lone star)',
                    fileContent['loneStar'],
                  ),
                  dataField(
                    myController10,
                    'D. variablis (American dog)',
                    fileContent['Dvari'],
                  ),
                  dataField(
                    myController11,
                    'H. longicornis (Longhorned)',
                    fileContent['Hlong'],
                  ),
                  dataField(
                    myController12,
                    'lxodes spp (other)',
                    fileContent['other'],
                  ),
                  dataField(
                    myController13,
                    'Notes',
                    fileContent['Notes'],
                    required: false,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                ],
              ),
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
                    print(moistureSelected);
                    print(habitatSelected);
                    print(siteSelected);
                    if (_editKey.currentState.validate()) {
                      if (siteSelected == true &&
                          moistureSelected == true &&
                          habitatSelected == true) {
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
                          'Iscap',
                          myController6.text,
                          'IscapAM',
                          myController7.text,
                          'IscapAF',
                          myController8.text,
                          'loneStar',
                          myController9.text,
                          'Dvari',
                          myController10.text,
                          'Hlong',
                          myController11.text,
                          'other',
                          myController12.text,
                          'Notes',
                          myController13.text,
                          'Ticks',
                          segmentedTickData,
                        );
                        sendJsonToCloud();
                        drags();

                        setState(() {
                          editingData = false;
                          viewingData = false;
                          viewingDrags = true;
                        });
                      }
                    }
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
      if (val == 'error') {
      } else {
        print(val);
      }
    });
  }

  Widget markerInfo(int segmentCount) {
    List<Widget> entries = new List<Widget>();
    for (int i = 0; i < segmentCount; i++) {
      entries.add(
        dataField(
          subs[i],
          'Segment $i',
          'Segment $i',
          required: false,
        ),
      );
    }
    return Flex(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      direction: Axis.horizontal,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: SizedBox(),
        ),
        Flexible(
          flex: 1,
          child: Container(
            height: 50.0 * segmentCount,
            width: 3.0,
            color: Colors.blue[900],
          ),
        ),
        Flexible(
          flex: 6,
          child: Column(
            children: entries,
          ),
        ),
      ],
    );
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return pageBody();
  }
}

class DropDownMenu extends StatefulWidget {
  DropDownMenu({
    @required this.label,
    @required this.items,
    @required this.dropIndex,
    @required this.controller,
    @required this.jsonVal,
  });

  final String label;
  final List<String> items;
  final int dropIndex;
  final TextEditingController controller;
  final String jsonVal;
  _DropDownMenuState createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> {
  @override
  Widget build(BuildContext context) {
    dropVals[widget.dropIndex] = fileContent[widget.jsonVal];
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        child: DropdownButtonFormField(
          // ignore: missing_return
          validator: (value) {
            if (value == null) {
              return "Please Select an Item";
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: widget.label,
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(rad)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2.5),
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
          //hint: Text('Select a Habitat Type'),
          items: widget.items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          value: dropVals[widget.dropIndex],
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.deepPurple),
          onChanged: (value) {
            setState(() {
              widget.controller.text = value;
//              print(controller.text);
              dropVals[widget.dropIndex] = value;
              if (widget.label == 'Site') {
                siteSelected = true;
              } else if (widget.label == 'Habitat Type') {
                habitatSelected = true;
              } else if (widget.label == 'Ground Moisture') {
                moistureSelected = true;
              }
            });
          },
          // ignore: missing_return
        ),
      ),
    );
  }
}
