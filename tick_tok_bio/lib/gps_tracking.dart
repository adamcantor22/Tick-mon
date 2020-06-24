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
import 'package:flutter/widgets.dart';
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
import 'weather_tracker.dart';
import 'player.dart';

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
  double currentVal = 0;
  String latestFilename;
  bool popUpPresent = false;
  bool sliderVisibility = true;
  bool cancellationPopUpPresent = false;
  double cancelDragVal = 0.0;
  bool confirmationButton = false;
  bool popUpDeletion = false;

  void initState() {
    super.initState();
    SuperListener.setPages(mPage: this);
    initPlayer();
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
  void startNewRoute() async {
    await audioCache.play('start.mp3');
    audioCache.fixedPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        locator = new Geolocator();
        wpts = new List<Wpt>();
        polylinePoints = PolylinePoints();
        trackingRoute = true;
        updateLocation();
      });
    });
  }

  //Cancel location tracking and sent the list of waypoints to be stored as gpx
  void finishRoute() async {
    await playSound('end.mp3');
    Trkseg seg = new Trkseg(
      trkpts: wpts,
    );
    WeatherTracker.updateLocation(currentPosition);
    storeRouteInformation(seg);

    setState(() {
      trackingRoute = false;
      positionSubscription.cancel();
      polylineCoordinates.clear();
    });

    SuperListener.moveAndCreateDrag(latestFilename);
  }

  //Tracking location subscription, update every point as it comes up
  void updateLocation() async {
    setState(() {
      LocationOptions options = LocationOptions(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0, //Testing at distanceFilter: 1? was previously 0
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

  Widget doneConfirmation() {
    return Visibility(
      visible: popUpPresent,
      child: AlertDialog(
        title:
            Text('Are you sure you would like to finish and save this drag?'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Finish and Save Drag',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                finishRoute();
                popUpPresent = false;
              });
            },
          ),
          FlatButton(
            child: Text('Resume Drag'),
            onPressed: () {
              setState(() {
                popUpPresent = false;
                sliderVisibility = true;
              });
            },
          )
        ],
      ),
    );
  }

  Widget startStop() {
    if (trackingRoute == false) {
      return FloatingActionButton(
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (!trackingRoute) {
            startNewRoute();
            setState(() {
              sliderVisibility = true;
            });
          } else {
            finishRoute();
            setState(() {});
          }
        },
      );
    } else if (trackingRoute == true) {
      return Visibility(
        visible: sliderVisibility,
        child: Row(children: [
          Expanded(
            flex: 3,
            child: SliderTheme(
              data: SliderThemeData(
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 50.0,
                  activeTrackColor: Colors.red),
              child: Slider(
                value: cancellationPopUpPresent == false ? currentVal : 0.0,
                onChanged: (double val) {
                  setState(() {
                    currentVal = val;
                  });

                  if (val == 10.0) {
                    setState(() {
                      currentVal = 0;
                      sliderVisibility = false;
                      popUpPresent = true;
                    });
                    print('Done');
                  }
                },
                onChangeEnd: (double val) {
                  if (val != 10.0) {
                    setState(() {
                      currentVal = 0;
                      print('HOOPLA');
                    });
                  }
                },
                min: 0.0,
                max: 10.0,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(),
          )
        ]),
      );
    }
  }

  Widget dragCancellationPopUp() {
    return Visibility(
      visible: cancellationPopUpPresent,
      child: AlertDialog(
        title: Column(children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                cancellationPopUpPresent = false;
                cancelDragVal = 0.0;
              });
            },
          ),
          Text(
            'Exit Pop-Up',
            style: TextStyle(fontSize: 15.0),
          )
        ]),
        content: Text(
            'Are you sure you would like to cancel this drag? Slide and confirm.'),
        actions: <Widget>[
          SliderTheme(
              data: SliderThemeData(
                  activeTrackColor: Colors.red,
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 50.0),
              child: Center(
                child: Slider(
                  min: 0.0,
                  max: 10.0,
                  value: cancelDragVal,
                  onChanged: (newVal) {
                    setState(() {
                      cancelDragVal = newVal;
                      if (newVal == 10.0) {
                        confirmationButton = true;
                      }
                    });
                  },
                  onChangeEnd: (double endPoint) {
                    if (endPoint != 10.0) {
                      setState(() {
                        confirmationButton = false;
                        cancelDragVal = 0.0;
                      });
                    }
                  },
                ),
              )),
          Visibility(
              visible: confirmationButton,
              child: FlatButton(
                child: Text(
                  'Delete Drag',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() {
                    trackingRoute = false;
                    positionSubscription.cancel();
                    polylineCoordinates.clear();
                    cancellationPopUpPresent = false;
                    cancelDragVal = 0.0;
                  });
                },
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: trackingRoute == true
              ? Text('Tracking in Progress')
              : Text('Tracking Not in Progress.')),
      body: Stack(children: <Widget>[
        FutureBuilder(
            future: googleMap(),
            // ignore: missing_return
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
            }),
        Positioned(bottom: 10.0, left: 1.0, right: 5.0, child: startStop()),
        Visibility(
          visible: trackingRoute == true ? true : false,
          child: Positioned(
            top: 3.0,
            left: 3.0,
            child: IconButton(
              icon: Icon(Icons.clear),
              iconSize: 40.0,
              color: Colors.red,
              onPressed: () {
                setState(() {
                  confirmationButton = false;
                  cancellationPopUpPresent = true;
                });
              },
            ),
          ),
        ),
        dragCancellationPopUp(),
        doneConfirmation()
      ]),
    );
  }
}
