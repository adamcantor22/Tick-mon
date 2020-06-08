import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gpx/gpx.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'file_uploader.dart';

class Maps extends StatefulWidget {
  const Maps({Key key}) : super(key: key);

  @override
  MapsState createState() => MapsState();
}

class MapsState extends State<Maps> {
  static final initialPosition =
      CameraPosition(target: (LatLng(10.42, 16.45)), zoom: 18.0);
  GoogleMapController _controller;
  LocationData currentLocation;
  Location location;
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  StreamSubscription<LocationData> locationSubscription;
  bool trackingRoute = false;

  void storeRouteInformation(Rte route) async {
    GpxWriter writer = new GpxWriter();
    Gpx g = new Gpx();
    g.rtes.add(route);
    String gpxStr = writer.asString(g);
    print(gpxStr);
    String filename = gpxStr.hashCode.toString();
    final fileRef = writeContent(filename, gpxStr);
    fileRef.then((file) {
      print(file.path);
      FileUploader uploader = new FileUploader();
      final url = uploader.fileUpload(file, filename).then((val) {
        print(val);
      });
    });
  }

  Future<File> writeContent(String filename, String fileContent) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/gpx$filename.gpx');
    return file.writeAsString(fileContent);
  }

  void startNewRoute() {
    setState(() {
      location = new Location();
      polylinePoints = PolylinePoints();
      trackingRoute = true;
      updateLocation();
    });
  }

  void finishRoute() async {
    List<Wpt> rtepts = new List<Wpt>();
    for (int i = 0; i < polylineCoordinates.length; i++) {
      rtepts.add(
        new Wpt(
          lat: polylineCoordinates[i].latitude,
          lon: polylineCoordinates[i].longitude,
          name: ('pt' + i.toString()),
        ),
      );
    }

    Rte route = new Rte(
      name: 'new route',
      rtepts: rtepts,
    );
    storeRouteInformation(route);

    setState(() {
      trackingRoute = false;
      locationSubscription.cancel();
      polylineCoordinates.clear();
    });
  }

  void updateLocation() async {
    setState(() {
      locationSubscription =
          location.onLocationChanged.listen((LocationData cLoc) {
        currentLocation = cLoc;
        LatLng pos =
            new LatLng(currentLocation.latitude, currentLocation.longitude);
        polylineCoordinates.add(pos);
        updatePolyline();
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Overview'),
      ),
      body: GoogleMap(
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
      ),
      floatingActionButton: FloatingActionButton(
        child: trackingRoute ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (!trackingRoute) {
            startNewRoute();
          } else {
            finishRoute();
            setState(() {
              HomePageState().pageNavigator(3);
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
