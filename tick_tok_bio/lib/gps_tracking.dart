import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';



class Maps extends StatefulWidget {


  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  static final initialPosition = CameraPosition(target: (LatLng(37.42,-122.45)),zoom: 16.0 );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map'
        ),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: initialPosition,
      ),
    );
  }
}

