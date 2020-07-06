import 'package:flutter/material.dart';
import 'package:tick_tok_bio/metadata_page.dart';
import 'package:tick_tok_bio/super_listener.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool temperatureState = false;
  bool autoMarker = false;
  Widget twoChoiceSwitch(String choice1, String choice2) {
    return Row(
      children: [],
    );
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
        child: Column(
          children: [
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
              children: [
                Text(
                  'Auto-Marker',
                  style: TextStyle(fontSize: 18.0),
                ),
                Switch(
                    value: autoMarker,
                    onChanged: (val) {
                      setState(() {
                        autoMarker = val;
                      });
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
