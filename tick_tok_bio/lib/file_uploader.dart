import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploader {
  Future<String> fileUpload(File gpxFile, String fileName) async {
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = storageRef.putFile(gpxFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var downloadUrl = await taskSnapshot.ref.getDownloadURL();
    final url = downloadUrl.toString();
    return url;
  }
}
