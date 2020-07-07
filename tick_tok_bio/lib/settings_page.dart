import 'package:flutter/material.dart';
import 'package:tick_tok_bio/metadata_page.dart';
import 'package:tick_tok_bio/super_listener.dart';

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

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(sPage: this);
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
        ]),
      ),
    );
  }
}
