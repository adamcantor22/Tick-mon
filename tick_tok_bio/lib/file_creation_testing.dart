import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileCreation extends StatefulWidget {
  const FileCreation({Key key}) : super(key: key);
  @override
  _FileCreationState createState() => _FileCreationState();
}

class _FileCreationState extends State<FileCreation> {
  var myController = TextEditingController();


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    //print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<File> writeCounter(String counter) async {
    final file = await _localFile;
    return file.writeAsString('$counter');
  }

  Future readCounter() async {
    try{
      final file = await _localFile;

      String contents = await file.readAsString();
      return contents;
    }
    catch(e) {
      print(e);
      return 0;
    }
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
          Card(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Data',
              ),
              controller: myController,
            ),
          ),
          FlatButton(
            child: Text(
              'Submit Data To File'
            ),
            onPressed: () async {
              writeCounter(myController.text);
            },
          ),
          FlatButton(
            child: Text(
              'Show Data'
            ),
            onPressed: () async {
              String words = await readCounter();
              print(words);
            },
          )
        ],
      ),
    );
  }
}

