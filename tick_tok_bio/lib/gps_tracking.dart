import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'metadata_page.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:tick_tok_bio/settings_page.dart';

bool trackingRoute = false;

class Maps extends StatefulWidget {
  bool get wantKeepAlive => true;
  const Maps({Key key}) : super(key: key);

  @override
  MapsState createState() => MapsState();
}

class MapsState extends State<Maps> {
  Geolocator locator;
  MapController _mapController = MapController();
  Position currentPosition;
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  List<Wpt> wpts = new List<Wpt>();
  List<Trkseg> segments = new List<Trkseg>();
  //PolylinePoints polylinePoints;
  StreamSubscription<Position> positionSubscription;
  double currentVal = 0;
  String latestFilename;
  bool popUpPresent = false;
  bool sliderVisibility = true;
  bool cancellationPopUpPresent = false;
  double cancelDragVal = 0.0;
  bool confirmationButton = false;
  bool popUpDeletion = false;
  var currentLat = 37.3216;
  var currentLong = -121.9535;
  double zoomLevel = 17.0;
  double distanceBetweenPoints;
  Position lastDropPoint;
  bool afterFirstDrop = false;
  List<Marker> markerLis = [];
  final player = AudioCache();
  double distancePerMarker = 20.0;
  int checkPointsPerMarker;
  int checkPointsCleared = 0;
  double currentDistance = 0.0;
  bool autoMarking = true;
  bool soundsPresent = true;
  bool markerViaTime = true;
  int counter;
  Timer timer;
  bool timerVisibility = false;
  bool autoCamerMove = false;
  bool autoCameraMoveVisibility = false;
  double timePmarker;

  void initState() {
    super.initState();
    getInitPos();
    //markerUpdate();
    lastDropPoint = currentPosition;
    SuperListener.setPages(mPage: this);
    initPlayer();
    getLoc();
    autoTrackingNonDrag();
  }

  void getInitPos() async {
    Position pos = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    _mapController.move(LatLng(pos.latitude, pos.longitude), zoomLevel);
    setState(() {
      markerLis.add(Marker(
          point: LatLng(pos.latitude, pos.longitude),
          builder: (build) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
              )));
      currentPosition = pos;
      currentLat = pos.latitude;
      currentLong = pos.longitude;
    });
  }

  void setSoundPref(bool soundSet) {
    setState(() {
      soundsPresent = soundSet;
    });
  }

  void setAutoTracking(bool setting) {
    setState(() {
      autoMarking = setting;
    });
  }

  void setMarkerMethod(bool set) {
    setState(() {
      markerViaTime = set;
    });
  }

  void setTimeOfMarker(double time) {
    setState(() {
      timePmarker = time;
    });
  }

  void startTimer() {
    print('new Timer created');
    counter = timePmarker.toInt() * 60;
    print(counter);
    timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0) {
          counter--;
        }
      });
    });
  }

  void stepsToTerminateNDelete() {
    if (trackingRoute == true) {
      setState(() {
        if (markerViaTime == true) {
          timer.cancel();
        }
        trackingRoute = false;
        positionSubscription.cancel();
        polylineCoordinates.clear();
        cancellationPopUpPresent = false;
        cancelDragVal = 0.0;
        markerLis = [];
        lastDropPoint = null;
        afterFirstDrop = false;
        checkPointsCleared = 0;
        timerVisibility = false;
        positionMarker();
        autoCameraMoveVisibility = false;
      });
    }
  }

  void positionMarker() {
    setState(() {
      markerLis.clear();
      markerLis.add(Marker(
          point: LatLng(currentLat, currentLong),
          builder: (build) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
              )));
    });
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
  void storeRouteInformation() async {
    GpxWriter writer = new GpxWriter();
    Gpx g = new Gpx();
    Trk trk = new Trk(trksegs: segments);
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
      final url = uploader.fileUpload(file, filename).then((val) {});
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
    markerUpdate();
    autoCameraMoveVisibility = true;
    getLoc();
    if (markerViaTime == true) {
      startTimer();
      timerVisibility = true;
    }
    if (soundsPresent == true) {
      await audioCache.play('start.mp3');
      StreamSubscription<void> sub;
      sub = audioCache.fixedPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          print('Marking by time is' + markerViaTime.toString());
          markerLis.clear();
          sliderVisibility = true;
          locator = new Geolocator();
          wpts = new List<Wpt>();
          segments = new List<Trkseg>();
          segments.add(new Trkseg());
          polylineCoordinates = [];
          trackingRoute = true;
          updateLocation();
          sub.cancel();
        });
      });
    } else {
      sliderVisibility = true;
      locator = new Geolocator();
      wpts = new List<Wpt>();
      segments = new List<Trkseg>();
      segments.add(new Trkseg());
      polylineCoordinates = [];
      trackingRoute = true;
      updateLocation();
    }
  }

  //Cancel location tracking and sent the list of waypoints to be stored as gpx
  void finishRoute() async {
    WeatherTracker.updateLocation(currentPosition);
    storeRouteInformation();

    setState(() {
      trackingRoute = false;
      positionSubscription.cancel();
      polylineCoordinates.clear();
    });
    SuperListener.moveAndCreateDrag(latestFilename);
  }

  void getLoc() async {
    locator = Geolocator();
    Position position = await locator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    setState(() {
      currentLat = position.latitude;
      currentLong = position.longitude;
      currentPosition = position;
      _mapController.move(
          LatLng(currentPosition.latitude, currentPosition.longitude),
          zoomLevel);
      if (trackingRoute == false) {
        markerLis.clear();
//        markerLis.add(Marker(
//            height: 15.0,
//            width: 15.0,
//            point: LatLng(currentPosition.latitude, currentPosition.longitude),
//            builder: (build) => Container(
//                  child: Icon(
//                    Icons.location_on,
//                    color: Colors.red,
//                  ),
//                )));
      }

//      polylineCoordinates.add(LatLng(currentLat, currentLong));
      //print(LatLng(currentLat, currentLong));
    });
  }

  void autoTrackingNonDrag() {
    LocationOptions opt = LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );
    positionSubscription =
        locator.getPositionStream(opt).listen((Position cPos) {
      if (trackingRoute == false) {
        setState(() {
          currentLat = cPos.latitude;
          currentLong = cPos.longitude;
          markerLis.clear();
          markerLis.add(Marker(
              point: LatLng(currentLat, currentLong),
              builder: (build) => Container(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                  )));
        });
      }
    });
  }

  //Tracking location subscription, update every point as it comes up
  void updateLocation() async {
    LocationOptions options = LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0, //Testing at distanceFilter: 1? was previously 0
    );
    positionSubscription =
        locator.getPositionStream(options).listen((Position cPos) {
      setState(() {
        currentPosition = cPos;
        currentLat = cPos.latitude;
        currentLong = cPos.longitude;
        //LatLng pos = LatLng(cPos.latitude, cPos.longitude);
        Wpt pt = new Wpt(
          lat: currentPosition.latitude,
          lon: currentPosition.longitude,
          ele: cPos.altitude,
          time: DateTime.now(),
        );
        if (autoCamerMove == true) {
          _mapController.move(LatLng(currentLat, currentLong), zoomLevel);
        }
        segments[segments.length - 1].trkpts.add(pt);
        wpts.add(pt);
        polylineCoordinates
            .add(LatLng(currentPosition.latitude, currentPosition.longitude));
        autoMarking == true ? markerUpdate() : print('No Auto Mark');
      });
    });
  }

  void dropTrackBreakPoint() {
    segments.add(new Trkseg());
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
                if (markerViaTime == true) {
                  timer.cancel();
                  timerVisibility = false;
                }
                finishRoute();
                popUpPresent = false;
                lastDropPoint = null;
                afterFirstDrop = false;
                markerLis.clear();
                lastDropPoint = null;
                checkPointsCleared = 0;
                positionMarker();
                autoCameraMoveVisibility = false;
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

  void markerUpdate() async {
    checkPointsPerMarker = (distancePerMarker ~/ 5);
    if (afterFirstDrop == false) {
      lastDropPoint = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      afterFirstDrop = true;
    }
    if (lastDropPoint != null) {
      currentDistance = await Geolocator().distanceBetween(
        lastDropPoint.latitude,
        lastDropPoint.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (markerViaTime == false) {
        if (currentDistance >= 5.0) {
          checkPointsCleared += 1;
          print(checkPointsCleared);

          lastDropPoint = currentPosition;
          print('CheckPoint Cleared');
          if (checkPointsCleared == checkPointsPerMarker) {
            checkPointsCleared = 0;

            if (soundsPresent == true) {
              player.play('/sounds/bell.mp3');
            }

            dropTrackBreakPoint();
            setState(() {
              print('PLace Marker');
              markerLis.add(
                Marker(
                  height: 15.0,
                  width: 15.0,
                  point: LatLng(
                      currentPosition.latitude, currentPosition.longitude),
                  builder: (build) => Container(
                    child: Icon(
                      Icons.my_location,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
              lastDropPoint = currentPosition;
            });
          }
        }
      }
      if (markerViaTime == true) {
        if (counter == 0) {
          counter = timePmarker.toInt() * 60;
          if (soundsPresent == true) {
            player.play('/sounds/bell.mp3');
          }
          dropTrackBreakPoint();
          setState(() {
            print('PLace Marker');
            markerLis.add(
              Marker(
                height: 15.0,
                width: 15.0,
                point:
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                builder: (build) => Container(
                  child: Icon(
                    Icons.my_location,
                    color: Colors.red,
                  ),
                ),
              ),
            );
            lastDropPoint = currentPosition;
          });
        }
      }
    }
  }

  void manualMarkerPlacement() {
    dropTrackBreakPoint();
    setState(() {
      markerLis.add(
        Marker(
          height: 15.0,
          width: 15.0,
          point: LatLng(currentPosition.latitude, currentPosition.longitude),
          builder: (build) => Container(
            child: Icon(
              Icons.my_location,
              color: Colors.green,
            ),
          ),
        ),
      );
    });
  }

  Widget startStop() {
    if (trackingRoute == false) {
      return FloatingActionButton(
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (!trackingRoute) {
            startNewRoute();
            markerLis.clear();
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
                    if (markerViaTime == true) {
                      timer.cancel();
                    }
                    trackingRoute = false;
                    positionSubscription.cancel();
                    polylineCoordinates.clear();
                    cancellationPopUpPresent = false;
                    cancelDragVal = 0.0;
                    markerLis = [];
                    lastDropPoint = null;
                    afterFirstDrop = false;
                    checkPointsCleared = 0;
                    timerVisibility = false;
                    positionMarker();
                    autoCameraMoveVisibility = false;
                  });
                },
              ))
        ],
      ),
    );
  }

  void setDistanceMarker(double dist) {
    setState(() {
      distancePerMarker = dist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: trackingRoute == true
              ? Text('Tracking in Progress')
              : Text('Tracking Not in Progress.')),
      body: Stack(children: <Widget>[
        FlutterMap(
          options: MapOptions(
            center: LatLng(currentLat, currentLong),
            zoom: zoomLevel,
          ),
          mapController: _mapController,
          layers: [
            TileLayerOptions(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c']),
            MarkerLayerOptions(
                markers: markerLis != null
                    ? markerLis
                    : [
                        Marker(
                            width: 15.0,
                            height: 15.0,
                            point: currentLat != null
                                ? LatLng(currentLat, currentLong)
                                : LatLng(50.0, 50.0),
                            builder: (build) => Container(
                                    child: Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 30.0,
                                )))
                      ]),
            PolylineLayerOptions(
              polylines: [
                Polyline(
                  strokeWidth: 5.0,
                  color: Colors.lightBlue,
                  borderColor: Colors.white,
                  points: polylineCoordinates,
                )
              ],
            )
          ],
        ),
        Positioned(
            bottom: 150.0,
            right: 10.0,
            child: IconButton(
                iconSize: 50.0,
                icon: Icon(Icons.zoom_in),
                onPressed: () {
                  setState(() {
                    zoomLevel += 1;
                    _mapController.move(
                        LatLng(currentLat, currentLong), zoomLevel);
                    print(markerViaTime);
                  });
                })),
        Positioned(
            bottom: 100.0,
            right: 10.0,
            child: IconButton(
                iconSize: 50.0,
                icon: Icon(Icons.zoom_out),
                onPressed: () {
                  setState(() {
                    zoomLevel -= 1;
                    _mapController.move(
                        LatLng(currentLat, currentLong), zoomLevel);
                  });
                })),
        Positioned(
            top: 15.0,
            right: 10.0,
            child: Container(
              color: Colors.blue,
              child: IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      getLoc();
                      autoTrackingNonDrag();
                    });
                  }),
            )),
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
        Visibility(
          visible: trackingRoute == true ? true : false,
          child: Positioned(
              top: 100.0,
              right: 10.0,
              child: Container(
                color: Colors.blue,
                child: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        manualMarkerPlacement();
                      });
                    }),
              )),
        ),
        Visibility(
            visible: autoCameraMoveVisibility,
            child: Positioned(
              right: 10.0,
              top: 200.0,
              child: Container(
                color: Colors.blue,
                child: IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: autoCamerMove == true ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        autoCamerMove = !autoCamerMove;
                      });
                    }),
              ),
            )),
        Visibility(visible: timerVisibility, child: Text(counter.toString())),
        dragCancellationPopUp(),
        doneConfirmation(),
      ]),
    );
  }
}
