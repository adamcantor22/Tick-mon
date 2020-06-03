import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:gpx/gpx.dart';

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
  bool trackingRoute = false;

  void startNewRoute() {
    setState(() {
      location = new Location();
      polylinePoints = PolylinePoints();
      trackingRoute = true;
      updateLocation();
    });
  }

  void finishRoute() {
    setState(() {
      trackingRoute = false;
    });
  }

  void updateLocation() {
    if (trackingRoute) {
      setState(() {
        location.onLocationChanged.listen((LocationData cLoc) {
          currentLocation = cLoc;
          LatLng pos =
              new LatLng(currentLocation.latitude, currentLocation.longitude);
          polylineCoordinates.add(pos);
          debugPrint(polylineCoordinates.toString());
          updatePolyline();
        });
      });
    }
  }

  void updatePolyline() {
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
          } else {}
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
