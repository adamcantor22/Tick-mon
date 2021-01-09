/*
    Upload files to the Cloud Storage location
 */

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'super_listener.dart';

class FileUploader {
  Future<String> fileUpload(File f, String fileName,
      {String personName, String siteName, String labGroup}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //IS CONNECTED TO INTERNET
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference docs = firestore.collection("docs");
        if (fileName.substring(fileName.length - 4, fileName.length) ==
            "json") {
          await docs.add({
            "title": "${fileName.substring(0, fileName.length - 5)}",
            "person": "$personName",
            "site": "$siteName",
            "lab_group": "$labGroup"
          });
        }
        StorageReference storageRef =
            FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = storageRef.putFile(f);
        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        var downloadUrl = await taskSnapshot.ref.getDownloadURL();
        final url = downloadUrl.toString();
        SuperListener.setSync(f.path, true);
        return url;
      }
    } on SocketException catch (_) {
      //IS NOT CONNECTED
      SuperListener.setSync(f.path, false);
      return 'error';
    }
  }
}
