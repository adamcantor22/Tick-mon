import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gpx/gpx.dart';
import 'package:tick_tok_bio/logged_in_screen.dart';
import 'package:tick_tok_bio/super_listener.dart';
import 'package:path_provider/path_provider.dart';
import 'file_uploader.dart';
import 'package:geolocator/geolocator.dart';
import 'helper.dart';
import 'super_listener.dart';
import 'package:date_format/date_format.dart';
import 'weather_tracker.dart';
import 'player.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:tick_tok_bio/settings_page.dart';
import 'segment_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tick_tok_bio/metadata_page.dart';

bool trackingRoute = false;
bool signingOff = false;

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
  List<LatLng> polylineCoordinates = [];
  List<Wpt> wpts = new List<Wpt>();
  List<Trkseg> segments = new List<Trkseg>();
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
  double timePmarker = 1.0;
  List<SegmentData> segmentData = [];
  int c = 0;
  int markerColorsIndex = 0;
  Random ranGen = Random();

  void initState() {
    super.initState();
    //getInitPos();
    //markerUpdate();
    //lastDropPoint = currentPosition;
    SuperListener.setPages(mPage: this);
    initPlayer();
    getLoc();
    autoTrackingNonDrag();
  }

  void getInitPos() async {
    Position pos = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    _mapController.move(
      LatLng(
        pos.latitude,
        pos.longitude,
      ),
      zoomLevel,
    );
    setState(() {
      markerLis.add(userLocationMarkerFunc());
      currentPosition = pos;
      currentLat = pos.latitude;
      currentLong = pos.longitude;
    });
  }

  void setSoundPref(bool soundSet) {
    print('SOSOSOSO SOUNDS GETTING SET TO $soundSet');
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
    print('The drag is being hanndled');
    if (markerViaTime == true) {
      timer.cancel();
    }
    trackingRoute = false;
    polylineCoordinates.clear();
    cancellationPopUpPresent = false;
    cancelDragVal = 0.0;
    markerLis = [];
    lastDropPoint = null;
    afterFirstDrop = false;
    checkPointsCleared = 0;
    timerVisibility = false;
    //positionMarker();
    autoCameraMoveVisibility = false;
    iScapN = 0;
    iScapAM = 0;
    iScapAF = 0;
    aAmer = 0;
    dVari = 0;
    hLong = 0;
    lxod = 0;
    print('Done');
  }
//    setState(() {
//      if (markerViaTime == true) {
//        timer.cancel();
//      }
//      trackingRoute = false;
//      positionSubscription.cancel();
//      polylineCoordinates.clear();
//      cancellationPopUpPresent = false;
//      cancelDragVal = 0.0;
//      markerLis = [];
//      lastDropPoint = null;
//      afterFirstDrop = false;
//      checkPointsCleared = 0;
//      timerVisibility = false;
//      markerLis.clear();
//      autoCameraMoveVisibility = false;
//    });
//  }

  void removeLatestMarker() {
    markerLis.removeLast();
  }

//  void positionMarker() {
//    setState(() {
//      markerLis.clear();
//      markerLis.add(Marker(
//          point: LatLng(currentLat, currentLong),
//          builder: (build) => Container(
//                child: Icon(
//                  Icons.location_on,
//                  color: Colors.red,
//                ),
//              )));
//    });
//  }

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

    if (loggedIn == true) {
      fileRef.then((file) {
        print(file.path);
        FileUploader uploader = new FileUploader();
        final url = uploader.fileUpload(file, filename);
      });
    }
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
          segmentData = new List<SegmentData>();
          segmentData.add(new SegmentData());
          polylineCoordinates = [];
          trackingRoute = true;
          updateLocation();
          sub.cancel();
        });
      });
    } else {
      setState(() {
        print('Marking by time is' + markerViaTime.toString());
        markerLis.clear();
        sliderVisibility = true;
        locator = new Geolocator();
        wpts = new List<Wpt>();
        segments = new List<Trkseg>();
        segments.add(new Trkseg());
        segmentData = new List<SegmentData>();
        segmentData.add(new SegmentData());
        polylineCoordinates = [];
        trackingRoute = true;
        updateLocation();
      });
    }
  }

  //Cancel location tracking and sent the list of waypoints to be stored as gpx
  void finishRoute() async {
    if (soundsPresent == true) {
      await playSound('end.mp3');
    }
    WeatherTracker.updateLocation(currentPosition);
    List<Map<String, int>> tickData = getJSONTickData();

    storeRouteInformation();

    setState(() {
      trackingRoute = false;
      positionSubscription.cancel();
      polylineCoordinates.clear();
    });
    //SuperListener.settingTickNum();
    SuperListener.moveAndCreateDrag(latestFilename);
    SuperListener.sendTickData(tickData);
  }

  List<Map<String, int>> getJSONTickData() {
    if (segmentData[segmentData.length - 1].isEmpty())
      segmentData.removeAt(segmentData.length - 1);
    List<Map<String, int>> obj = new List<Map<String, int>>();
    for (int i = 1; i <= segmentData.length; i++) {
      obj.add(segmentData[i - 1].getData());
    }
    return obj;
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
      markerLis.add(userLocationMarkerFunc());
    });
  }

  void autoTrackingNonDrag() {
    LocationOptions opt = LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter: trackingRoute == true ? 0 : 1,
    );
    positionSubscription =
        locator.getPositionStream(opt).listen((Position cPos) {
      c += 1;
      if (signingOff == false) {
        if (trackingRoute == false) {
          if (c > 4) {
            setState(() {
              currentLat = cPos.latitude;
              currentLong = cPos.longitude;
              markerLis.clear();
              markerLis.add(userLocationMarkerFunc());
              if (autoCamerMove == true) {
                _mapController.move(LatLng(currentLat, currentLong), zoomLevel);
              }
            });
          }
        }
      }
    });
  }

  void positionSubDispose() {
    positionSubscription.cancel();
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

        if (markerLis.length > 0) {
          markerLis.removeLast();
        }
        markerLis.add(userLocationMarkerFunc());
        if (autoMarking == true) {
          markerUpdate();
        }
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
                SuperListener.upDateTickData();
                moistureSelected = false;
                habitatSelected = false;
                siteSelected = false;
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
                //Possibly add something
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
          ),
        ],
      ),
    );
  }

//  dynamic getRandColor() {
//    int myNum = ranGen.nextInt(markerColors.length);
//    print(myNum);
//    Color myColor = markerColors[myNum];
//    return myColor;
//  }

  Marker userLocationMarkerFunc() {
    return Marker(
      height: 15.0,
      width: 15.0,
      point: LatLng(currentLat, currentLong),
      builder: (build) => Container(
        child: Icon(
          Icons.adjust,
          size: 20.0,
        ),
      ),
    );
  }

  dynamic colorChooser(int num) {
    if (num == 0) {}
  }

  Marker droppedMarkerFunc() {
    //int myColor = colorNum;

    return Marker(
      height: 15.0,
      width: 15.0,
      point: LatLng(currentPosition.latitude, currentPosition.longitude),
      builder: (build) => Container(
        child: Icon(
          Icons.location_on,
          color: Colors.red,
        ),
      ),
    );
  }

  void markerUpdate() async {
    checkPointsPerMarker = (distancePerMarker ~/ 2);
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
            player.play('/sounds/bell.mp3');

            dropTrackBreakPoint();
            setState(() {
//              markerLis.removeLast();
//              markerLis.add(droppedMarkerFunc());
//              markerLis.add(userLocationMarkerFunc());
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
//            markerLis.removeLast();
//            markerLis.add(droppedMarkerFunc());
//            markerLis.add(userLocationMarkerFunc());
            lastDropPoint = currentPosition;
          });
        }
      }
    }
  }

  void manualMarkerPlacement() {
    dropTrackBreakPoint();
    setState(() {
      checkPointsCleared = 0;
      markerLis.removeLast();
      markerLis.add(droppedMarkerFunc());
      markerLis.add(userLocationMarkerFunc());
    });

    markerColorsIndex += 1;
    if (markerColorsIndex == 5) {
      markerColorsIndex = 0;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return HelperText(segmentData.length, context);
      },
    );
  }

  void storeSegmentData(Map<String, int> map) {
    segmentData[segmentData.length - 1].addTickData(map: map);
    segmentData.add(new SegmentData());
  }

  Widget startStop() {
    if (!trackingRoute) {
      return FloatingActionButton(
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (!trackingRoute) {
            startNewRoute();
          } else {
            finishRoute();
            setState(() {});
          }
        },
      );
    } else {
      return Visibility(
        visible: sliderVisibility,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 50.0,
                  activeTrackColor: Colors.red,
                ),
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
          ],
        ),
      );
    }
  }

  Widget dragCancellationPopUp() {
    return Visibility(
      visible: cancellationPopUpPresent,
      child: AlertDialog(
        title: Column(
          children: [
            Container(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    cancellationPopUpPresent = false;
                    cancelDragVal = 0.0;
                  });
                },
              ),
            ),
            Text(
              'Exit Pop-Up',
              style: TextStyle(fontSize: 15.0),
            ),
          ],
        ),
        content: Text(
            'Are you sure you would like to cancel this drag? Slide and confirm.'),
        actions: <Widget>[
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.red,
              trackShape: RoundedRectSliderTrackShape(),
              trackHeight: 50.0,
            ),
            child: Center(
              child: Slider(
                min: 0.0,
                max: 10.0,
                value: cancelDragVal,
                onChanged: (newVal) {
                  if (newVal == 10.0) {
                    setState(() {
                      confirmationButton = true;
                    });
                  } else {
                    setState(() {
                      cancelDragVal = newVal;
                    });
                  }
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
            ),
          ),
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
                  //positionMarker();
                  autoCameraMoveVisibility = false;
                  iScapN = 0;
                  iScapAM = 0;
                  iScapAF = 0;
                  aAmer = 0;
                  dVari = 0;
                  hLong = 0;
                  lxod = 0;
                });
              },
            ),
          )
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
            : Text('Tracking Not in Progress.'),
      ),
      body: Stack(children: <Widget>[
        FlutterMap(
          options: MapOptions(
            center: LatLng(currentLat, currentLong),
            zoom: zoomLevel,
          ),
          mapController: _mapController,
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(markers: markerLis
//              markers: markerLis != null
//                  ? markerLis
//                  : [
//                      Marker(
//                        width: 15.0,
//                        height: 15.0,
//                        point: currentLat != null
//                            ? LatLng(currentLat, currentLong)
//                            : LatLng(50.0, 50.0),
//                        builder: (build) => Container(
//                          child: Icon(
//                            Icons.my_location,
//                            color: Colors.blue,
//                            size: 30.0,
//                          ),
//                        ),
//                      ),
                // ],
                ),
            PolylineLayerOptions(
              polylines: [
                Polyline(
                  strokeWidth: 5.0,
                  color: Colors.lightBlue,
                  borderColor: Colors.white,
                  points: polylineCoordinates,
                )
              ],
            ),
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
//                    signingOff = !signingOff;
                    print(signingOff);
                  });
                })),
//        Positioned(
//          bottom: 100.0,
//          right: 10.0,
//          child: IconButton(
//            iconSize: 50.0,
//            icon: Icon(Icons.zoom_out),
//            onPressed: () {
//              setState(() {
//                zoomLevel -= 1;
//                _mapController.move(LatLng(currentLat, currentLong), zoomLevel);
//              });
//            },
//          ),
//        ),

        Positioned(
          bottom: 10.0,
          left: 1.0,
          right: 5.0,
          child: startStop(),
        ),
        Visibility(
          visible: trackingRoute == true ? true : false,
          child: Positioned(
            top: 15.0,
            left: 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                border: Border.all(
                  color: Colors.blueGrey[300],
                  width: 1.3,
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.close),
                iconSize: 30.0,
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
        ),
        Visibility(
          visible: trackingRoute == true ? true : false,
          child: Positioned(
              top: 100.0,
              right: 10.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: IconButton(
                    icon: Icon(
                      Icons.location_on,
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
            visible: true,
            child: Positioned(
              right: 10.0,
              top: 15.0,
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
        Visibility(
          visible: markerViaTime == true &&
                  trackingRoute == true &&
                  autoMarking == true
              ? true
              : false,
          child: Positioned(
            right: 10.0,
            bottom: 30.0,
            child: Text(
              counter.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
          ),
        ),
        dragCancellationPopUp(),
        doneConfirmation(),
      ]),
    );
  }
}
