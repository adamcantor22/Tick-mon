import 'package:flutter/material.dart';
import 'metadata_page.dart';

class MetaDataDisplay extends StatefulWidget {
  const MetaDataDisplay({Key key}) : super(key: key);

  @override
  _MetaDataDisplayState createState() => _MetaDataDisplayState();
}

class _MetaDataDisplayState extends State<MetaDataDisplay> {
  String date = '06/4/20';
  String time = '02:34:34';
  String site = 'GQ';
  String name = 'Jonah';
  String temperature = '55';
  String humidity = '70%';
  String groundMoisture = 'damp';
  String habitatType = 'rainforest';
  int numNymphs = 34;
  int numBlackLegged = 12;
  Widget infoRow(
    String category,
    value,
  ) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Expanded(
              child: Text(
                '$category: $value',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$time $date',
        ),
      ),
      body: Column(
        children: <Widget>[
          infoRow('Site', site),
          infoRow('Name', name),
          infoRow('Temperature', temperature),
          infoRow('Humidity', humidity),
          infoRow('Ground Moisture', groundMoisture),
          infoRow('Type of Habitat', habitatType),
          infoRow('Nymphs', numNymphs),
          infoRow('BlackLegged', numBlackLegged)
        ],
      ),
    );
  }
}
