import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'metadata_page.dart';


File jsonFile;
Directory dir;
String fileName = 'myfile2.json';
bool fileExists = false;
Map fileContent;

void createFile(Map content, Directory dir, String fileName) {
  print('Creating File');
  File file = File(dir.path + '/' + fileName);
  file.createSync();
  fileExists = true;
  file.writeAsStringSync(json.encode(content));
}

void writeToFile(dynamic key, dynamic value) {
  print('Writing to File');
  Map content = {key: value};
  if (fileExists) {
    print('File Exists');
    Map jsonFileContents = json.decode(jsonFile.readAsStringSync());
    print(jsonFileContents);
    //jsonFileContents.addAll(content);
//      jsonFile.writeAsStringSync(json.encode(jsonFileContents));
//      print(jsonFileContents);
  }
  else {
    print('FIle Does not exist');
    createFile(content, dir, fileName);
  }
}
