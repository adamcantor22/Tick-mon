import 'package:flutter/material.dart';
import 'metadata_page.dart';

//String date = '06/4/20';
//String time = '02:34:34';
String site = 'GQ';
String name = 'Jonah';
String temperature = '55';
String humidity = '70%';
String groundMoisture = 'damp';
String habitatType = 'rainforest';
int numNymphs = 34;
int numBlackLegged = 12;

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);



  Widget dataField(String hText, variable) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: TextField(
        decoration: kTextFieldDecoration.copyWith(hintText: hText),
        onChanged: (value) {
          variable = value;
        },
      ),
    );
  }

class DataInput extends StatefulWidget {
  const DataInput({Key key}) : super(key: key);
  @override
  _DataInputState createState() => _DataInputState();
}

class _DataInputState extends State<DataInput> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(DateTime.now().toString()),
      ),
        body: ListView(
          children: [
            dataField('Enter Name', name),
            dataField('Enter Site Code', site),
            dataField('Enter Temperature', temperature),
            dataField('Enter Humidity', humidity),
            dataField('Enter Ground Moisture Level', groundMoisture),
            dataField('Enter Habitat Type', habitatType),
            dataField('Enter Number of Nymphs Collected', numNymphs),
            dataField('Enter Number of BlackLegged Ticks Collected', numBlackLegged)

      ]
        ),
//      Column(
//        children: <Widget>[
//          Row(
//            children: <Widget>[
//              TextField(
//                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Name'),
//                onChanged: (value) {
//                  name = value;
//                },
//              ),
//            ],
//          ),
//        ],
//      ),
      );
  }
}
