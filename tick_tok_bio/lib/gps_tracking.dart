import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Maps extends StatefulWidget {
  const Maps({Key key}) : super(key: key);

  @override
  MapsState createState() => MapsState();
}

class MapsState extends State<Maps> {
  var point;
  List coordinates = [];
  StreamSubscription subscription;
  Map<LatLng, Marker> markers = new Map<LatLng, Marker>();
  static final initialPosition =
      CameraPosition(target: (LatLng(10.42, 16.45)), zoom: 18.0);
  GoogleMapController _controller;
  Location _location = Location();

  addArrow() async {
    ByteData image =
        await DefaultAssetBundle.of(context).load('images/blackarrow.png');
    return image.buffer.asUint8List();
  }

  updatePos(LocationData newLocalData, Uint8List imageData) {
    LatLng latLng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      markers[latLng] = Marker(
        markerId: MarkerId('position'),
        position: latLng,
        draggable: false,
        zIndex: 2,
        rotation: newLocalData.heading,
        icon: BitmapDescriptor.fromBytes(imageData),
        flat: true,
      );
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await addArrow();
      var _loc = await _location.getLocation();
      updatePos(_loc, imageData);
      subscription = _location.onLocationChanged.listen((event) {
        if (_controller != null) {
          _controller
              .animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
            bearing: 192.83,
            target: LatLng(event.latitude, event.longitude),
            zoom: 16.0,
          )));
          coordinates.add(LatLng(event.latitude, event.longitude));
          print(LatLng(event.latitude, event.longitude));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void cancelSub() {
    if (subscription != null) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Overview'),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: markers.values.toSet(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.accessibility),
        backgroundColor: Colors.black,
        onPressed: () {
          getCurrentLocation();
        },
      ),
    );
  }
}
