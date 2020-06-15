/*
    The map page which controls tracking of the user's drag. The user is currently
    able to start and stop a drag, and upon stopping the data will be sent to a
    gpx file stored on both the local device and Cloud Storage.
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gpx/gpx.dart';
import 'package:tick_tok_bio/super_listener.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'file_uploader.dart';
import 'package:geolocator/geolocator.dart';
import 'helper.dart';
import 'super_listener.dart';
import 'package:date_format/date_format.dart';

class Maps extends StatefulWidget {
  bool get wantKeepAlive => true;
  const Maps({Key key}) : super(key: key);

  @override
  MapsState createState() => MapsState();
}

class MapsState extends State<Maps> {
  Geolocator locator;
  CameraPosition initialPosition;
  GoogleMapController _controller;
  Position currentPosition;
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  List<Wpt> wpts = new List<Wpt>();
  PolylinePoints polylinePoints;
  StreamSubscription<Position> positionSubscription;
  bool trackingRoute = false;
  String latestFilename;

  void initState() {
    super.initState();
    SuperListener.setPages(mPage: this);
  }

  //A method which allows the map to start at the user's location, rather than
  // a random hardcoded spot
  Future<CameraPosition> getInitialPos() async {
    Position tmpP = await Geolocator().getCurrentPosition();
    final cPos = CameraPosition(
      target: LatLng(tmpP.latitude, tmpP.longitude),
      zoom: 18.0,
    );
    return cPos;
  }

  //This is the filename for the gpx files, created to be the current datetime
  String currentTime() {
    DateTime now = DateTime.now();
    // NOTE '꞉' is not a colon, as colons cannot appear in all filenames.
    //  it is a similar-looking unicode character 'Modified Letter Colon' U+A789
    String ret = formatDate(
        now, [yyyy, '-', mm, '-', dd, '_', hh, '꞉', nn, '꞉', ss, '꞉', SSS]);
    latestFilename = ret;
    //intentionally in this order
    ret += '.gpx';
    return ret;
  }

  //Write information to gpx file, record to local disk and send to FileUploader
  void storeRouteInformation(Trkseg seg) async {
    GpxWriter writer = new GpxWriter();
    Gpx g = new Gpx();
    List<Trkseg> segs = new List<Trkseg>();
    segs.add(seg);
    Trk trk = new Trk(trksegs: segs);
    g.creator = 'TickTok-Flutter';
    g.metadata = Metadata(
      time: DateTime.now(),
      keywords: 'Flutter TickTok Tickémon-Go',
    );
    g.trks.add(trk);
    String gpxStr = writer.asString(g);
    print(gpxStr);
    String filename = currentTime();
    final fileRef = writeContent(filename, gpxStr);
    fileRef.then((file) {
      print(file.path);
      FileUploader uploader = new FileUploader();
      final url = uploader.fileUpload(file, filename).then((val) {
        print(val);
      });
    });
  }

  //Write the content to the local disk
  Future<File> writeContent(String filename, String fileContent) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/gpx';
    final file = File('$path/$filename');
    return file.writeAsString(fileContent);
  }

  //Set up location tracking subscription and polyline creation
  void startNewRoute() {
    //FIXME: DO NOT LEAVE THE TRUE IN HERE, IT IS FOR TESTING CONVENIENCE
    if (true || SuperListener.getUser() != null) {
      setState(() {
        locator = new Geolocator();
        wpts = new List<Wpt>();
        polylinePoints = PolylinePoints();
        trackingRoute = true;
        updateLocation();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return Helper().message('Login to start new drag!', context);
        },
      );
    }
  }

  //Cancel location tracking and sent the list of waypoints to be stored as gpx
  void finishRoute() async {
    Trkseg seg = new Trkseg(
      trkpts: wpts,
    );
    storeRouteInformation(seg);

    setState(() {
      trackingRoute = false;
      positionSubscription.cancel();
      polylineCoordinates.clear();
    });

    print('***MAPPAGE MAKING NEW DRAG***');
    SuperListener.moveAndCreateDrag(latestFilename);
  }

  //Tracking location subscription, update every point as it comes up
  void updateLocation() async {
    setState(() {
      LocationOptions options = LocationOptions(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1, //Testing at distanceFilter: 1? was previously 0
      );
      positionSubscription =
          locator.getPositionStream(options).listen((Position cPos) {
        currentPosition = cPos;
        LatLng pos =
            new LatLng(currentPosition.latitude, currentPosition.longitude);
        Wpt pt = new Wpt(
          lat: currentPosition.latitude,
          lon: currentPosition.longitude,
          ele: currentPosition.altitude,
          time: DateTime.now(),
        );
        wpts.add(pt);
        polylineCoordinates.add(pos);
        updatePolyline();
      });
    });
  }

  //Adds new segments to the polyline. Can probably be optimized?
  void updatePolyline() async {
    setState(() {
      _polylines.add(
        Polyline(
          width: 5, // set the width of the polylines
          polylineId: PolylineId('poly'),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates,
        ),
      );
    });
  }

  //This is a bit spaghetti, but calls the function that gets the initialPosition
  Future<CameraPosition> googleMap() async {
    final initPos = await getInitialPos();
    initialPosition = initPos;
    return initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Overview'),
      ),
      body: FutureBuilder<CameraPosition>(
        future: googleMap(),
        builder: (context, snapshot) {
          if (initialPosition == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.hybrid,
              initialCameraPosition: initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: trackingRoute ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (!trackingRoute) {
            startNewRoute();
          } else {
            finishRoute();
            setState(() {});
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
