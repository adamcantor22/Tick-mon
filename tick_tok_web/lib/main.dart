import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() => runApp(MotherShipApp());

class MotherShipApp extends StatefulWidget {
  @override
  _MotherShipAppState createState() => _MotherShipAppState();
}

class _MotherShipAppState extends State<MotherShipApp> {
//  StorageReference store;
//
//  @override
//  void initState() {
//    super.initState();
//    getFirestoreReference();
//  }
//
//  void getFirestoreReference() async {
////    store = FirebaseStorage.instance.ref().getRoot();
////    var list = await store.listAll();
//    //print('Good morning! ' + list);
//  }
//
//  void getFiles() {}

  @override
  Widget build(BuildContext context) {
    print('tests');
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'HENLOOOOO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
      ),
    );
  }
}
