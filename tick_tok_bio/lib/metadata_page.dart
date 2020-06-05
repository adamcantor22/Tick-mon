import 'package:flutter/material.dart';
import 'main.dart';
import 'metadata_viewinginfo.dart';
import 'decorationInfo.dart';

class MetadataSection extends StatefulWidget {
  const MetadataSection({Key key}) : super(key: key);

  @override
  _MetadataSectionState createState() => _MetadataSectionState();
}

class _MetadataSectionState extends State<MetadataSection> {
  bool viewingDrags = true;
  bool viewingData = false;
  bool editingData = false;
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

  Widget pageBody() {
    if (viewingDrags == true) {
      return viewDrags();
    }
    else if (viewingData == true) {
      return viewData();
    }
    else if (editingData == true) {
      return editDrag();
    }
  }

  Widget dragMenu(String time) {
    return GestureDetector(
      onTap: () {
        setState(() {
          viewingData = true;
          viewingDrags = false;
        });
      },
      child: Card(
          margin: EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              time,
              style: TextStyle(
                fontSize: 25.0,
              ),),
          )),
    );
  }


  Widget viewDrags() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Previous Drags',
            style: TextStyle(
              fontSize: 25.0,
            ),),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            dragMenu('2:30:50 6/4/20'),
            dragMenu('2:30:50 6/4/20'),
            
          ],
        )
    );
  }

  Widget infoRow(String category, value,) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            '$category: $value',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ],
    );
  }


  Widget viewData() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$time $date',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
          onPressed: () {
              setState(() {
                editingData = true;
                viewingData = false;
              });
          },),
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


  Widget editDrag() {
    return Scaffold(
        appBar: AppBar(
        title: Text(DateTime.now().toString()),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.close), onPressed: () {
              setState(() {
                editingData = false;
                viewingDrags = true;
              });
            })
          ],
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
    ),);

  }

  @override
  Widget build(BuildContext context) {
    return pageBody();
  }
}
