import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:tick_tok_bio/logged_in_screen.dart';

//These are the three boolean values used to determine which screen we are currently on
bool viewingDrags = true;
bool viewingData = false;
bool editingData = false;

bool changesMade = false;

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

var oController1 = TextEditingController();
var oController2 = TextEditingController();
var oController3 = TextEditingController();

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
  bool loadingData = false;
  bool celsius = false;
  Map<String, Map<String, int>> segmentedTickData;
  Map<String, dynamic> syncMap = Map<String, bool>();
  File syncFile;

  List habitatList = <String>[
    'Select Habitat',
    'Field/Grass',
    'Forest Edge',
    'Closed Canopy (Oak)',
    'Closed Canopy (Tulip/Maple)',
    'Closed Canopy (Mixed Conifer)',
    'Other',
  ];

  List siteList = <String>[
    'Select Site',
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
    'Select Moisture',
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

      //deleteFiles(); //careful with this, uncomment to clear local files in accordance with the method
    });

    setState(() {
      viewingDrags = true;
      viewingData = false;
      editingData = false;
    });
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
    return Container(); //On Error
  }

  void syncChecker() async {
    bool syncExists = false;
    syncFile = File('${dir.path}/sync.json');
    for (FileSystemEntity f in fileList) {
      String p = f.path;
      if (p.substring(p.length - 9, p.length) == 'sync.json') {
        syncExists = true;
        String toDecode = syncFile.readAsStringSync();
        print('To Decode: $toDecode the end');
        syncMap = jsonDecode(toDecode);
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
    Map<String, dynamic> jsonFileContents;
    try {
      jsonFileContents = json.decode(syncFile.readAsStringSync());
    } on Exception catch (e) {
      jsonFileContents = new Map<String, dynamic>();
    }
    jsonFileContents.addAll(syncMap);
    syncFile.writeAsStringSync(json.encode(jsonFileContents));
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
      print(p);
      if (p.substring(p.length - 4, p.length) == '.gpx' ||
          p.substring(p.length - 5, p.length) == '.json') {
        print('DELETING: $p');
        f.deleteSync(recursive: true);
      }
    }
    try {
      String f = '${dir.path}/sync.json';
      File(f).deleteSync();
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
    Map<String, Map<String, int>> value14,
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
    print(fileName);
    jsonFile = File(jsonDir.path + '/' + fileName);
    fileExists = await jsonFile.exists();
    if (fileExists) {
      setState(() {
        fileContent = json.decode(jsonFile.readAsStringSync());
      });
    } else {
      File file = File(jsonDir.path + '/' + fileName);
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
    //s += '1' + ' '; //TODO: put this back with a functioning counter, not just 1

    name != null
        ? s += '${name.substring(0, 3).toUpperCase()}' + ' '
        : s += 'USER ';

    s += editingFilename.substring(0, 10);
    return s;
  }

  Future<bool> attemptFileUploads(String name) async {
    editingFilename = name;
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
                                  if (loggedIn == true) {
                                    if (!fileUploaded) {
                                      bool b = await attemptFileUploads(name);
                                      setState(() {
                                        drags();
                                      });
                                    }
                                  } else {
                                    logInToUpload(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
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

  logInToUpload(BuildContext context) {
    Widget agreement = FlatButton(
      onPressed: () {
        setState(() {
          Navigator.pop(context);
        });
      },
      child: Text('Ok.'),
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        'You must be logged in to upload to the database. \n Login with google and try again.',
        textAlign: TextAlign.center,
      ),
      actions: [agreement],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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

    if (name != null) {
      fileContent['Name'] = name;
    }
    fileContent['Iscap'] = iScapN.toString();
    iScapN = 0;
    fileContent['IscapAM'] = iScapAM.toString();
    iScapAM = 0;
    fileContent['IscapAF'] = iScapAF.toString();
    iScapAF = 0;
    fileContent['A.amer'] = aAmer.toString();
    aAmer = 0;
    fileContent['D.vari'] = dVari.toString();
    dVari = 0;
    fileContent['H.long'] = hLong.toString();
    hLong = 0;
    fileContent['lxodes'] = lxod.toString();
    return b;
  }

  void sendSegmentedTickData(Map<String, Map<String, int>> data) {
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
    if (tickData.containsKey('I. scapAM')) {
      iScapAM += tickData['I. scapAM'];
    }
    if (tickData.containsKey('I. scapAF')) {
      iScapAF += tickData['I. scapAF'];
    }
    if (tickData.containsKey('A. amer')) {
      aAmer += tickData['A. amer'];
    }
    if (tickData.containsKey('D. vari')) {
      dVari += tickData['D. vari'];
    }
    if (tickData.containsKey('H. long')) {
      hLong += tickData['H. long'];
    }
    if (tickData.containsKey('lxodes spp')) {
      lxod += tickData['lxodes spp'];
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
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        color: Colors.grey[200],
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 7.0),
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
                      infoRow('Name', fileContent['Name'].toString()),
                      infoRow('Site', fileContent['Site'].toString()),
                      infoRow('Temperature', fileContent['Temp'].toString()),
                      infoRow('Humidity', fileContent['Humidity'].toString()),
                      infoRow('Ground Moisture',
                          fileContent['GroundMoisture'].toString()),
                      infoRow('Habitat Type',
                          fileContent['HabitatType'].toString()),
                      infoRow(
                          'I. scap. nymph', fileContent['Iscap'].toString()),
                      infoRow('I. scap. adult male',
                          fileContent['IscapAM'].toString()),
                      infoRow('I. scap. adult female', fileContent['IscapAF']),
                      infoRow('A. amer. (Lone star)', fileContent['A.amer']),
                      infoRow('D. vari. (American dog)', fileContent['D.vari']),
                      infoRow('H. long. (Longhorned)', fileContent['H.long']),
                      infoRow('lxodes spp (other)', fileContent['lxodes']),
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
                  dropDownMenu(
                    'Site',
                    siteList,
                    1,
                    myController1,
                    'Site',
                    oController1,
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
                  dropDownMenu(
                    'Ground Moisture',
                    moistureList,
                    2,
                    myController4,
                    'GroundMoisture',
                    oController2,
                  ),
                  dropDownMenu(
                    'Habitat Type',
                    habitatList,
                    0,
                    myController5,
                    'HabitatType',
                    oController3,
                  ),
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
                    fileContent['A.amer'],
                  ),
                  dataField(
                    myController10,
                    'D. variablis (American dog)',
                    fileContent['D.vari'],
                  ),
                  dataField(
                    myController11,
                    'H. longicornis (Longhorned)',
                    fileContent['H.long'],
                  ),
                  dataField(
                    myController12,
                    'lxodes spp (other)',
                    fileContent['lxodes'],
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
                  onPressed: () async {
                    setState(() {
                      loadingData = true;
                    });
                    if (changesMade) {
                      if (_editKey.currentState.validate()) {
                        if (siteSelected == true &&
                            moistureSelected == true &&
                            habitatSelected == true) {
                          writeToFile(
                            thisFilename,
                            'Name',
                            myController0.text,
                            'Site',
                            myController1.text == 'Other'
                                ? oController1.text
                                : myController1.text,
                            'Temp',
                            myController2.text,
                            'Humidity',
                            myController3.text,
                            'GroundMoisture',
                            myController4.text == 'Other'
                                ? oController2.text
                                : myController4.text,
                            'HabitatType',
                            myController5.text == 'Other'
                                ? oController3.text
                                : myController5.text,
                            'Iscap',
                            myController6.text,
                            'IscapAM',
                            myController7.text,
                            'IscapAF',
                            myController8.text,
                            'A.amer',
                            myController9.text,
                            'D.vari',
                            myController10.text,
                            'H.long',
                            myController11.text,
                            'lxodes',
                            myController12.text,
                            'Notes',
                            myController13.text,
                            'Ticks',
                            segmentedTickData,
                          );
                          await sendJsonToCloud();
                          drags();
                        }
                      }
                    }
                    if (siteSelected && habitatSelected && moistureSelected) {
                      setState(() {
                        editingData = false;
                        viewingData = false;
                        viewingDrags = true;
                      });
                    }
                    setState(() {
                      loadingData = false;
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

  Future<void> sendJsonToCloud() async {
    FileUploader uploader = new FileUploader();
    File f = File('${jsonDir.path}/$editingFilename.json');
    await uploader.fileUpload(f, '$editingFilename.json').then((val) {
      if (val == 'error') {
      } else {
        print(val);
      }
    });
  }

  Widget dropDownMenu(
      String label,
      List<String> items,
      int dropIndex,
      TextEditingController controller,
      String jsonVal,
      TextEditingController otherController) {
    controller.text = fileContent[jsonVal];
    if (controller.text == null || controller.text == '') {
      controller.text = items[0];
    } else if (!items.contains(controller.text)) {
      otherController.text = controller.text;
      controller.text = 'Other';
    }
    Widget ret = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField(
              validator: (value) {
                if (value == null) {
                  return "Please Select an Item";
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: label,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(rad),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
              ),
              items: items.map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
              value: controller.text,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              onChanged: (value) {
                setState(() {
                  changesMade = true;
                  controller.text = value;
                  fileContent[jsonVal] = value;
                  /*FIXME: These next lines seem precarious, if we change the labels
                     somewhere else, this will break */
                  if (value != items[0]) {
                    if (label == 'Site') {
                      siteSelected = true;
                    } else if (label == 'Habitat Type') {
                      habitatSelected = true;
                    } else if (label == 'Ground Moisture') {
                      moistureSelected = true;
                    }
                  } else {
                    if (label == 'Site') {
                      siteSelected = false;
                    } else if (label == 'Habitat Type') {
                      habitatSelected = false;
                    } else if (label == 'Ground Moisture') {
                      moistureSelected = false;
                    }
                  }
                });
              },
            ),
            Visibility(
              visible: controller.text == 'Other',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: TextFormField(
                  decoration: kTextFieldDecoration,
                  controller: otherController,
                  validator: (value) {
                    if (controller.text == 'Other' &&
                        (controller.text == null ||
                            controller.text.trim() == '')) {
                      return 'Enter All Data';
                    }
                    return null;
                  },
                  onChanged: (s) {
                    changesMade = true;
                    fileContent[jsonVal] = s;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return pageBody();
  }
}
