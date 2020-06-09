import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';


class JSONStorage extends StatefulWidget {
  const JSONStorage({Key key}) : super(key: key);
  @override
  _JSONStorageState createState() => _JSONStorageState();
}

class _JSONStorageState extends State<JSONStorage> {
  TextEditingController keyInputController = TextEditingController();
  TextEditingController valueInputController = TextEditingController();
  File jsonFile;
  Directory dir;
  String fileName = 'myfile.json';
  bool fileExists = false;
  Map fileContent;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) async {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = await  jsonFile.exists();
      if(fileExists) this.setState(() {
        fileContent = json.decode(jsonFile.readAsStringSync());
        print(fileContent);
      });
  });
  }



  @override
  void dispose() {
    keyInputController.dispose();
    valueInputController.dispose();
    super.dispose();
  }

  void createFile(Map content, Directory dir, String fileName) {
    print('Creating File');
    File file = new File(dir.path + '/' + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));

  }

  void writeToFile(String key, String value) {
    print('Writing to File');
    Map<String, String> content = {key: value};
    if (fileExists) {
      print('File Exists');
      Map<String, dynamic> jsonFileContents = json.decode(jsonFile.readAsStringSync());

      jsonFileContents.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContents));
    }
    else {
      print('FIle Does not exist');
      createFile(content, dir, fileName);
    }
    this.setState(() {
      fileContent = json.decode(jsonFile.readAsStringSync());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JSON Storage')
      ),
      body: Column(
        children: <Widget>[
          Text('File Content: '),
          Text(fileContent['Name'].toString()),
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          ),
          TextField(
            controller: keyInputController,
            decoration: InputDecoration(hintText: 'Add KEY'),
          ),
          TextField(
            controller: valueInputController,
            decoration: InputDecoration(hintText: 'Add value'),
          ),
          RaisedButton(
            child: Text('Add to JSON file'),
              onPressed: () {
              writeToFile(keyInputController.text, valueInputController.text);
          })
        ],
      ),
    );
  }
}