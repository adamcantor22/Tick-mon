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
  bool timeTracking = false;
  File jsonFile;
  Directory dir;
  String fileName = 'settings.json';
  bool fileExists;
  Map fileContentSettings;
  bool soundOn = true;

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(sPage: this);
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = File(dir.path + '/' + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        setState(() {
          fileContentSettings = jsonDecode(jsonFile.readAsStringSync());

          if (fileContentSettings['Sound'] != null) {
            configureSettings();
          }
        });
      } else {}
    });
  }

  void configureSettings() {
    setState(() {
      soundOn = fileContentSettings['Sound'];
      SuperListener.settingSoundPref(soundOn);
      temperatureState = fileContentSettings['TempStatus'];
      SuperListener.tempCelsius(temperatureState);
      autoMarker = fileContentSettings['Auto-Marker'];
      SuperListener.autoMarking(autoMarker);
      timeTracking = fileContentSettings['TimeTracking'];

      selectedDistancePerMarker = fileContentSettings['Distance'];
      SuperListener.setMarkingDistance(selectedDistancePerMarker);
    });
  }

  void createFile(Map<dynamic, dynamic> content) {
    print('creating File');
    File file = File(dir.path + '/' + fileName);
    fileExists = true;
    file.writeAsStringSync(jsonEncode(content));
  }

  void writeToFile(val, val1, val2, val3, val4) {
    print('Writing to File');
    Map<String, dynamic> content = {
      'Sound': val,
      'TempStatus': val1,
      'Auto-Marker': val2,
      'TimeTracking': val3,
      'Distance': val4,
    };
    if (fileExists) {
      print('FIle Exists');
      Map<String, dynamic> jsonFileContent1 =
          jsonDecode(jsonFile.readAsStringSync());
      jsonFileContent1.addAll(content);
      jsonFile.writeAsStringSync(jsonEncode(jsonFileContent1));
    } else {
      print('File does not exist');
      createFile(content);
    }
    setState(() {
      fileContentSettings = jsonDecode(jsonFile.readAsStringSync());
    });
  }

  double getDistancePerMarker() {
    return selectedDistancePerMarker;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Settings',
          style: TextStyle(fontSize: 30.0),
        )),
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
                      print(temperatureState);
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
                      print(val);
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
          FlatButton.icon(
              color: Colors.blue,
              onPressed: () {
                setState(() {
                  writeToFile(soundOn, temperatureState, autoMarker,
                      timeTracking, selectedDistancePerMarker);
                  print(fileContentSettings['Distance']);
                });
              },
              icon: Icon(Icons.check),
              label: Text('Apply Changes')),
          FlatButton(
              onPressed: () {
                setState(() {
                  configureSettings();
                });
              },
              child: Text('Refresh'))
        ]),
      ),
    );
  }
}
