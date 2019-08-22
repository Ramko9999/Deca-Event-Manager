import 'dart:collection';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:deca_app/screens/admin/finder.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Scanner extends StatefulWidget {
  Map eventMetaData;
  String _uid;

  Scanner(Map e, String uid) {
    this.eventMetaData = e;
    this._uid = uid;
  }

  State<Scanner> createState() {
    return _ScannerState(eventMetaData, _uid);
  }
}

class _ScannerState extends State<Scanner> {
  HashSet<String> _scannedUids; //used to keep track of already scanned codes
  String _connectionState; //used to listen to connection changes
  List _cameras; //used to grab cameras
  CameraController _mainCamera; //camera that will give us the feed
  bool _isCameraInitalized = false;
  Map eventMetadata;
  bool _isQR;
  bool _isSearcher;
  int pointVal;
  int scanCount;
  String _uid;

  _ScannerState(Map e, String uid) {
    _scannedUids = new HashSet();
    _connectionState = "Unknown Connection";
    eventMetadata = e;

    pointVal = eventMetadata['gold_points'];
    scanCount = eventMetadata['attendee_count'];
    this._uid = uid;
    _isQR = true;
    _isSearcher = false;
  }
  void updateGP(String _uid) {
    Firestore.instance
        .collection('Users')
        .document(_uid)
        .get()
        .then((userData) {
      int totalGP = 0;
      Map eventsList = userData['events'].values;
      for (var gp in eventsList.keys) {
        totalGP += gp;
      }
      Firestore.instance
          .collection('Users')
          .document(_uid)
          .updateData({'gold_points': totalGP});
    });
  }

  void pushToDB(String userUniqueID) {
    print(userUniqueID);
    if (!_scannedUids.contains(userUniqueID)) {
      Firestore.instance
          .collection("Users")
          .document(userUniqueID)
          .get()
          .then((userData) {
        //blindly increment gold points this might be where you want to change such that event data and user dictionary are updated
        Firestore.instance
            .collection("Users")
            .document(userUniqueID)
            .updateData(
                {'gold_points': userData.data['gold_points'] + pointVal});

        //update the events
        Firestore.instance
            .collection('Events')
            .document(eventMetadata['event_name'])
            .updateData({
          'events': () {
            Map events = userData['events'];
            if (events != null) {
              events.addAll({eventMetadata['event_name']: pointVal});
              return events;
            } else {
              return {eventMetadata['event_name']: pointVal};
            }
          }
        });
        updateGP(userUniqueID);

        //update the events
        Firestore.instance
            .collection('Events')
            .document(eventMetadata['event_name'])
            .updateData({'attendee_count': FieldValue.increment(1)});
        setState(() {
          scanCount += 1;
        });
        //update the scaffold

        //append to the hashset the uniqueID
        _scannedUids.add(userUniqueID);
      }).catchError((onError) => print(onError));
      Firestore.instance
          .collection('Users')
          .document(userUniqueID)
          .get()
          .then((user) {
        String firstName = user.data['first_name'];
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Color.fromRGBO(46, 204, 113, 1),
          content: Text("Scanned" + firstName),
        ));
      }).catchError((onError) => print(onError));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Already Scanned This Person'),
      ));
    }
  }

  void initState() {
    super.initState();

    //listening for changes in connection
    Connectivity().onConnectivityChanged.listen((connectionStatus) {
      setState(() {
        _connectionState = connectionStatus.toString();
      });
    });

    //get all the avaliable cameras
    availableCameras().then((allCameras) {
      _cameras = allCameras;
      _mainCamera = CameraController(allCameras[0], ResolutionPreset.medium);
      _mainCamera.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() => _isCameraInitalized = true); //show the actual camera
        _mainCamera.startImageStream((image) {
          FirebaseVisionImageMetadata metadata;
          //android image format is different than ios
          if (Platform.isAndroid) {
            //metadata tag for the yvu format.
            //source https://github.com/flutter/flutter/issues/26348
            metadata = FirebaseVisionImageMetadata(
                rawFormat: image.format.raw,
                size: Size(image.width.toDouble(), image.height.toDouble()),
                planeData: image.planes
                    .map((plane) => FirebaseVisionImagePlaneMetadata(
                        bytesPerRow: plane.bytesPerRow,
                        height: plane.height,
                        width: plane.width))
                    .toList());
          }
          FirebaseVisionImage visionImage =
              FirebaseVisionImage.fromBytes(image.planes[0].bytes, metadata);
          FirebaseVision.instance
              .barcodeDetector()
              .detectInImage(visionImage)
              .then((barcodes) {
            for (Barcode barcode in barcodes) {
              pushToDB(barcode.rawValue);
            }
          });
        }).catchError((error) {
          if (error.runtimeType == CameraException) {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Issues with Camera"),
            ));
          }
        });
      });
    });
  }

  void dispose() {
    _mainCamera.dispose();
    super.dispose();
  }

  void updateButtons(String state) {
    if (state == 'QR') {
      setState(() {
        _isQR = true;
        _isSearcher = !_isQR;
      });
    } else {
      setState(() {
        _isSearcher = true;
        _isQR = !_isSearcher;
      });
    }
  }

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: new AppBar(
        title: AutoSizeText(
          "Add Members to \'" + eventMetadata['event_name'] + "\'",
          maxLines: 1,
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {Navigator.of(context).pop()}),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new SettingScreen(_uid))),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                    width: screenWidth - 50,
                    height: 75,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 7,
                            child: Container(
                              height: 50,
                              child: RaisedButton(
                                onPressed: () =>
                                    setState(() => updateButtons('QR')),
                                child: Text(
                                  "QR Reader",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: _isQR ? Colors.blue : Colors.grey,
                                textColor: Colors.white,
                              ),
                            )),
                        Spacer(flex: 1),
                        Expanded(
                            flex: 7,
                            child: Container(
                              height: 50,
                              child: RaisedButton(
                                onPressed: () =>
                                    setState(() => updateButtons('S')),
                                child: Text("Searcher",
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                      fontSize: 15,
                                    )),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: _isSearcher ? Colors.blue : Colors.grey,
                                textColor: Colors.white,
                              ),
                            ))
                      ],
                    ),
                  ),
                  if (_isQR)
                    Container(
                        height: screenHeight - 350,
                        width: screenWidth - 100,
                        child: _isCameraInitalized
                            ? RotationTransition(
                                child: CameraPreview(_mainCamera),
                                turns: AlwaysStoppedAnimation(270 / 360))
                            : Text("Loading...")),
                  Container(
                      padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                      width: screenWidth - 200,
                      height: 75,
                      child: new RaisedButton(
                        child: Text('Finish',
                            style: new TextStyle(
                                fontSize: 17, fontFamily: 'Lato')),
                        textColor: Colors.white,
                        color: Color.fromRGBO(46, 204, 113, 1),
                        onPressed: () {
                          _mainCamera.stopImageStream();
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              NoTransition(
                                  builder: (context) => new EditEventUI(_uid)));
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      )),
                  if (_isSearcher) Finder(eventMetadata),
                ],
              ),
            ),
          ),
          if (_connectionState.contains("none"))
            Container(
              color: Colors.black45,
              child: AlertDialog(
                title: Text("Network Error",
                    style: TextStyle(fontFamily: 'Lato', color: Colors.red)),
                content: Text(
                    "There is an error connecting to network. Once we detect a connecton, this page will automatically disappear."),
              ),
            )
        ],
      ),
    );
  }
}
