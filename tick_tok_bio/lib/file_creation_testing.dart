import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

String str;
class FileCreation extends StatefulWidget {

  final Storage storage;
  FileCreation({Key key, @required this.storage}) : super(key: key);

  @override
  _FileCreationState createState() => _FileCreationState();
}

class _FileCreationState extends State<FileCreation> {
  var myController = TextEditingController();
  var myController1 = TextEditingController();
  var myController2 = TextEditingController();
  var myController3 = TextEditingController();

  Storage storage = Storage();
  Map state;
  Future<Directory> _appDocDir;
  Directory dir;
  String fileName = 'myfile11.json';
  File dataFile;
  var fileContent;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      dataFile = File(dir.path + '/' + fileName);
    });
    widget.storage.readData().then((value) => {
      state = value
    }
    );
  }

  Future<File> writeInfo() async {
    setState(() {
      state = {myController.text: myController1.text, myController2.text: myController3.text};

      myController.text = '';
    });
    return widget.storage.writeData(state);
  }

  void getAppDirectory() {
    _appDocDir = getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter into file'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('${state ?? "File is empty"}'),
          Card(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Key',
              ),
              controller: myController,
            ),
          ),
          Card(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Value',
              ),
              controller: myController1,
            ),
          ),
          Card(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Key2',
              ),
              controller: myController2,
            ),
          ),
          Card(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter value2',
              ),
              controller: myController3,
            ),
          ),
          FlatButton(
            child: Text(
              'Write to File'
            ),
            onPressed: () async {
              writeInfo();
            },
          ),
          FlatButton(
            child: Text(
              'Get Directory Path'
            ),
            onPressed: () {
              getAppDirectory();
            },
          ),
//          FutureBuilder<Directory> (
//            future: _appDocDir,
//            builder: (BuildContext context, AsyncSnapshot<Directory> snapshot) {
//              Text text = Text('');
//              if (snapshot.connectionState == ConnectionState.done) {
//                if(snapshot.hasError) {
//                  text = Text('Error: ${snapshot.error}');
//                }
//                else if(snapshot.hasData) {
//                  text = Text('Path: ${snapshot.data.path}');
//                }
//                else {
//                  text = Text('Unavailable');
//                }
//              }
//              return Container(
//                child: text,
//
//              );
//            },
//
//          )
        ],
      ),
    );
  }
}

class Storage{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future writeData(Map content) async {
    try{
    final file = await _localFile;
    return file.writeAsString(json.encode(content));
  }
  catch(e) {
    print(e);
    return e;
    }
  }

  Future readData() async {
    try{
      final file = await _localFile;

      var contents = await file.readAsString();
      return contents;
    }
    catch(e) {
      return 0;
    }
  }
}