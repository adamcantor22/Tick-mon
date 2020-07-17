//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:tick_tok_bio/metadata_page.dart';
import 'package:tick_tok_bio/super_listener.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool temperatureState = false;
  bool autoMarker = true;
  List<double> distancePerMarker = [5.0, 20.0, 50.0];
  double selectedDistancePerMarker = 20.0;
  List<double> timerPerMarker = [1.0, 2.0, 3.0, 4.0, 5.0];
  double selectedTimePerMarker = 1.0;
  bool timeTracking = false;
  File jsonFile;
  Directory dir;
  String fileName = 'settings.json';
  bool fileExists;
  Map fileContentSettings;
  bool soundOn = true;
  bool notesDisplayed = false;
  bool notesUp = false;
  String markerPlaceDes =
      'This should be pressed when the user wants to make a marker of their location and enter data for the subsection of the drag.';
  String getLocDes =
      "Pressing this icon updates the camera to pinpoint your position to be central on the map. This is useful if a drag is not in progress or you have auto-camera updates turned off during a drag.";
  String freeLookDes =
      "This button toggles whether the camera during a drag will automatically move the camera throughout, or whether you are able to look around the map by dragging.";

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(sPage: this);
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = File(dir.path + '/' + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        print('I HAVE THE SETTINGS FILE');
        setState(() {
          fileContentSettings = jsonDecode(jsonFile.readAsStringSync());
          configureSettings();
          configureMapState();
        });
      } else {
        print('I DO NOT HAVE THE SETTINGS FILE');
      }
    });
  }

  void configureMapState() {
    SuperListener.settingSoundPref(soundOn);
    SuperListener.tempCelsius(temperatureState);
    SuperListener.autoMarking(autoMarker);
    SuperListener.settingMarkerMethod(timeTracking);
    SuperListener.setMarkingDistance(selectedDistancePerMarker);
    SuperListener.setTimePerMarker(selectedTimePerMarker);
  }

  void configureSettings() {
    setState(() {
      soundOn = fileContentSettings['Sound'];
      temperatureState = fileContentSettings['TempStatus'];
      autoMarker = fileContentSettings['Auto-Marker'];
      timeTracking = fileContentSettings['TimeTracking'];
      selectedDistancePerMarker = fileContentSettings['Distance'];
      selectedTimePerMarker = fileContentSettings['Time'];
    });
  }

  showAlertDialog(BuildContext context) {
    Widget applyChanges = FlatButton(
        onPressed: () {
          setState(() {
            configureMapState();
            writeToFile(soundOn, temperatureState, autoMarker, timeTracking,
                selectedDistancePerMarker, selectedTimePerMarker);
            Navigator.pop(context);
          });
        },
        child: Text('Apply Changes'));

    Widget cancel = FlatButton(
        onPressed: () {
          setState(() {
            configureSettings();
            configureMapState();
            Navigator.pop(context);
          });
        },
        child: Text('Cancel My Changes'));

    AlertDialog alert = AlertDialog(
      title: Text(
          'You have not saved the changes you have made to the settings page'),
      actions: [applyChanges, cancel],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void settingsChecker() {
    print('Settings checker has been called');
    if (fileContentSettings['Sound'] != soundOn) {
      showAlertDialog(context);
      print('OOOH');
    } else if (fileContentSettings['TempStatus'] != temperatureState) {
      showAlertDialog(context);
    } else if (fileContentSettings['Auto-Marker'] != autoMarker) {
      showAlertDialog(context);
    } else if (fileContentSettings['TimeTracking'] != timeTracking) {
      showAlertDialog(context);
    } else if (fileContentSettings['Distance'] != selectedDistancePerMarker) {
      showAlertDialog(context);
    } else if (fileContentSettings['Time'] != selectedTimePerMarker) {
      showAlertDialog(context);
    }
    //if(fileContentSettings['TempStatus'] != )
  }

  void createFile(Map<dynamic, dynamic> content) {
//    print('creating File');
    File file = File(dir.path + '/' + fileName);
    fileExists = true;
    file.writeAsStringSync(jsonEncode(content));
  }

  void writeToFile(val, val1, val2, val3, val4, val5) {
//    print('Writing to File');
    Map<String, dynamic> content = {
      'Sound': val,
      'TempStatus': val1,
      'Auto-Marker': val2,
      'TimeTracking': val3,
      'Distance': val4,
      'Time': val5
    };
    if (fileExists) {
//      print('FIle Exists');
      Map<String, dynamic> jsonFileContent1 =
          jsonDecode(jsonFile.readAsStringSync());
      jsonFileContent1.addAll(content);
      jsonFile.writeAsStringSync(jsonEncode(jsonFileContent1));
    } else {
      //print('File does not exist');
      createFile(content);
    }
    setState(() {
      fileContentSettings = jsonDecode(jsonFile.readAsStringSync());
    });
  }

  double getDistancePerMarker() {
    return selectedDistancePerMarker;
  }

  Widget iconDescription(icon, String description) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            color: Colors.blue,
            child: Icon(
              icon,
              color: Colors.red,
              size: 40.0,
            ),
          ),
          Flexible(
            child: Text(description),
          )
        ],
      ),
    );
  }

  Widget pageChooser() {
    if (notesUp == true) {
      return notesPage();
    } else {
      return settingsOptions();
    }
  }

  Widget notesPage() {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 30.0,
              ),
              onPressed: () {
                setState(() {
                  notesUp = false;
                });
              }),
          SizedBox(
            width: 80.0,
          ),
          Text('Notes for User'),
        ],
      )),
      body: ListView(children: [
        Column(
          children: [
            Center(
              child: Text(
                'Icons Functionality',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
              ),
            ),
            iconDescription(Icons.my_location, markerPlaceDes),
            iconDescription(Icons.location_on, getLocDes),
            iconDescription(Icons.remove_red_eye, freeLookDes),
          ],
        ),
      ]),
    );
  }

  Widget settingsOptions() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sound Off',
                style: TextStyle(fontSize: 18.0),
              ),
              Switch(
                value: soundOn,
                inactiveTrackColor: Colors.red[200],
                inactiveThumbColor: Colors.red,
                onChanged: (val) {
                  setState(() {
                    soundOn = val;
                    SuperListener.settingSoundPref(val);
                  });
                },
              ),
              Text(
                'Sound On',
                style: TextStyle(fontSize: 18.0),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fahrenheit',
                style: TextStyle(fontSize: 18.0),
              ),
              Switch(
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.shade200,
                  value: temperatureState,
                  onChanged: (value) {
                    setState(() {
                      temperatureState = value;
                      SuperListener.tempCelsius(value);
                    });
                  }),
              Text(
                'Celsius',
                style: TextStyle(fontSize: 18.0),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Auto-Marker Off',
                style: TextStyle(fontSize: 18.0),
              ),
              Switch(
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.shade200,
                  value: autoMarker,
                  onChanged: (val) {
                    setState(() {
                      SuperListener.autoMarking(val);
                      autoMarker = val;
                    });
                  }),
              Text(
                'Auto-Marker On',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          Visibility(
              visible: autoMarker == true ? true : false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Distance',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Switch(
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.red.shade200,
                      value: timeTracking,
                      onChanged: (bool val) {
                        setState(() {
                          timeTracking = val;
                        });
                      }),
                  Text(
                    'Time',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              )),
          Visibility(
            visible: timeTracking == false && autoMarker == true ? true : false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                    labelText: 'Distance Per Marker Drop',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 2.5),
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    )),
                items: distancePerMarker
                    .map<DropdownMenuItem<double>>((double value) {
                  return DropdownMenuItem<double>(
                      value: value, child: Text(value.toString() + ' meters'));
                }).toList(),
                value: selectedDistancePerMarker,
                onChanged: (value) {
                  setState(() {
                    selectedDistancePerMarker = value;
                    SuperListener.setMarkingDistance(value);
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: timeTracking == true && autoMarker == true ? true : false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                    labelText: 'Time Per Marker Drop',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 2.5),
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    )),
                items: timerPerMarker
                    .map<DropdownMenuItem<double>>((double value) {
                  return DropdownMenuItem<double>(
                      value: value, child: Text(value.toString() + ' minutes'));
                }).toList(),
                value: selectedTimePerMarker,
                onChanged: (value) {
                  setState(() {
                    selectedTimePerMarker = value;
                  });
                },
              ),
            ),
          ),
          FlatButton.icon(
              color: Colors.blue,
              onPressed: () {
                setState(() {
                  configureMapState();
                  writeToFile(
                      soundOn,
                      temperatureState,
                      autoMarker,
                      timeTracking,
                      selectedDistancePerMarker,
                      selectedTimePerMarker);
                });
              },
              icon: Icon(Icons.check),
              label: Text('Apply Changes')),
          FlatButton(
              onPressed: () {
                setState(() {
                  notesUp = true;
                });
              },
              child: Text('Notes for Users')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageChooser();
  }
}
