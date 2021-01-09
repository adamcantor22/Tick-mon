import 'dart:ffi';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'super_listener.dart';

class FileDownloader {
  Future<Map<String, Map<String, String>>> getFilenames(String labGroup) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //IS CONNECTED TO INTERNET
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        StorageReference storage = FirebaseStorage.instance.ref();
        CollectionReference docs = firestore.collection("docs");
        var titles = List<String>();
        var people = List<String>();
        var sites = List<String>();
        var map = Map<String, Map<String, String>>();
        QuerySnapshot qs = await docs.get();
        qs.docs.forEach((doc) {
          if (doc.data().containsKey('lab_group') &&
              labGroup == doc["lab_group"]) {
            titles.add(doc["title"]);
            people.add(doc["person"]);
            sites.add(doc["site"]);
          }
        });
        for (String s in titles) {
          map[s] = Map<String, String>();
          map[s]['gpxUrl'] = await storage.child("$s.gpx").getDownloadURL();
          map[s]['jsonUrl'] = await storage.child("$s.json").getDownloadURL();
          map[s]['person'] = people.removeAt(0);
          map[s]['site'] = sites.removeAt(0);
        }
        return map;
      }
    } on SocketException catch (_) {
      //IS NOT CONNECTED
      return {
        'error': {'error': 'error'}
      };
    }
    return null;
  }
}
