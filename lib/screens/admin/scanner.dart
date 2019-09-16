import 'dart:collection';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/admin/finder.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Scanner extends StatefulWidget {
  State<Scanner> createState() {
    return _ScannerState();
  }
}

class _ScannerState extends State<Scanner> {
  HashSet<String> _scannedUids; //used to keep track of already scanned codes
  CameraController _mainCamera; //camera that will give us the feed
  bool _isCameraInitalized = false;
  Map eventMetadata;
  bool _isQR = true;
  bool _isSearcher = false;
  int pointVal;
  int scanCount;
  bool isInfo = false;
  bool _cameraPermission = true;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isManualEnter;
  bool isInProcessOfScanning = false;

  void pushToDB(String userUniqueID) async {
    isInProcessOfScanning = true;
    final gpContainer = StateContainer.of(
        _scaffoldKey.currentContext); //This is actually smart as hell
    Firestore.instance
        .collection("Users")
        .document(userUniqueID)
        .get()
        .then((userData) {
      gpContainer.setUserData(userData.data);

      if (gpContainer.eventMetadata['enter_type'] == 'ME') {
        gpContainer.setIsManualEnter(true);
      } else {
        gpContainer.updateGP(userUniqueID);
        String firstName = gpContainer.userData['first_name'];

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Color.fromRGBO(46, 204, 113, 1),
          content: Text("Scanned " + firstName),
          duration: Duration(seconds: 1),
        ));
      }
      isInProcessOfScanning = false;
    }).catchError((onError) => print(onError));
  }

  void runStream() {
    _scannedUids = new HashSet();
    _mainCamera.startImageStream((image) {
      FirebaseVisionImageMetadata metadata;
      //metadata tag for the for image format.
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

      FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromBytes(image.planes[0].bytes, metadata);

      FirebaseVision.instance
          .barcodeDetector()
          .detectInImage(visionImage)
          .then((barcodes) {
        for (Barcode barcode in barcodes) {
          if (!_scannedUids.contains(barcode.rawValue) &&
              !isInProcessOfScanning) {
            _scannedUids.add(barcode.rawValue);
            pushToDB(barcode.rawValue);
          } else {
            if (!isInProcessOfScanning) {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                backgroundColor: Color.fromRGBO(255, 0, 0, 1),
                content: Text("Already Scanned"),
                duration: Duration(seconds: 1),
              ));
            }
          }
        }
      }).catchError((error) {
        if (error.runtimeType == CameraException) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Issues with Camera"),
          ));
        }
      });
    });
  }

  //get a list of permissions that are still denied
  Future<List> getPermissionsThatNeedToBeChecked(
      PermissionGroup cameraPermission,
      PermissionGroup microphonePermission) async {
    PermissionStatus cameraPermStatus =
        await PermissionHandler().checkPermissionStatus(cameraPermission);
    PermissionStatus microphonePermStatus =
        await PermissionHandler().checkPermissionStatus(microphonePermission);
    List<PermissionGroup> stillNeedToBeGranted = [];
    if (cameraPermStatus == PermissionStatus.denied) {
      stillNeedToBeGranted.add(cameraPermission);
    }
    if (microphonePermStatus == PermissionStatus.denied) {
      stillNeedToBeGranted.add(microphonePermission);
    }
    return stillNeedToBeGranted;
  }

  //create camera based on permissions
  void createCamera() {
    getPermissionsThatNeedToBeChecked(
            PermissionGroup.camera, PermissionGroup.microphone)
        .then((permList) {
      if (permList.length == 0) {
        //get all the avaliable cameras
        availableCameras().then((allCameras) {
          _mainCamera = CameraController(allCameras[0], ResolutionPreset.low);

          _mainCamera.initialize().then((_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isCameraInitalized = true;
            }); //show the actual camera
            runStream();
          }).catchError((onError) {
            //permission denied
            if (onError.toString().contains("permission not granted")) {
              setState(() {
                _cameraPermission = false;
              });
            }
          });
        });
      } else {
        setState(() {
          _cameraPermission = false;
        });
      }
    });
  }

  //request permissions and check until all are requestsed
  void requestPermStatus(List<PermissionGroup> permissionGroups) {
    bool allAreAccepted = true;
    PermissionHandler()
        .requestPermissions(permissionGroups)
        .then((permissionResult) {
      permissionResult.forEach((k, v) {
        if (v == PermissionStatus.denied) {
          allAreAccepted = false;
        }
      });
      if (allAreAccepted) {
        setState(() {
          _cameraPermission = true;
        });
        createCamera();
      }
    });
  }

  void initState() {
    super.initState();
    createCamera();
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
    //turn of image stream if searcher is selected
    if (_isCameraInitalized) {
      if (_isQR) {
        if (!_mainCamera.value.isStreamingImages) {
          runStream();
        } else if (StateContainer.of(context).isThereConnectionError) {
          _mainCamera.stopImageStream();
        }
      } else {
        if (_mainCamera.value.isStreamingImages) {
          _mainCamera.stopImageStream();
        }
      }
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final container = StateContainer.of(context);
    eventMetadata = container.eventMetadata;
    isManualEnter = container.isManualEnter;

    _scannedUids = new HashSet();

    pointVal = eventMetadata['gold_points'];
    scanCount = eventMetadata['attendee_count'];

    return Scaffold(
      key: _scaffoldKey,
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
            icon: Icon(Icons.info),
            onPressed: () {
              setState(() {
                isInfo = true;
              });
            },
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
                      child: _cameraPermission
                          ? _isCameraInitalized
                              ? Platform.isAndroid
                                  ? RotationTransition(
                                      child: CameraPreview(_mainCamera),
                                      turns: AlwaysStoppedAnimation(270 / 360))
                                  : CameraPreview(_mainCamera)
                              : Container(
                                  child: Text("Loading"),
                                )
                          : GestureDetector(
                              onTap: () {
                                getPermissionsThatNeedToBeChecked(
                                        PermissionGroup.camera,
                                        PermissionGroup.microphone)
                                    .then((permGroupList) {
                                  requestPermStatus(permGroupList);
                                });
                              },
                              child: Container(
                                child: Text(Platform.isAndroid
                                    ? "You have denied camera permissions, please accept them by clicking on this text"
                                    : "You have denied camera permissions, please go to settings to activate them"),
                              )),
                    ),
                  if (_isSearcher)
                    Container(
                      width: screenWidth - 50,
                      height: screenHeight - 250,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Finder(
                          //call back function argument
                          (BuildContext context,
                              StateContainerState stateContainer,
                              Map userInfo) {
                        stateContainer.setUserData(userInfo);
                        if (stateContainer.eventMetadata['enter_type'] ==
                            'QE') {
                          stateContainer.updateGP(userInfo['uid']);
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                              "Succesfully added ${stateContainer.eventMetadata['gold_points'].toString()} to ${userInfo['first_name']}",
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ));
                        } else {
                          stateContainer.setIsCardTapped(true);
                        }
                      },
                          //alert widget argument, optional
                          GestureDetector(
                            onTap: () {
                              container.setIsCardTapped(false);
                            },
                            child: Container(child: ManualEnterPopup()),
                          ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isManualEnter)
              GestureDetector(
                child: Center(
                  child: Container(
                    width: screenWidth - 50,
                    height: screenHeight - 250,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: new ManualEnterPopup(),),
                ),
                onTap: () {
                  container.setIsManualEnter(false);
                },
              ),
              Container(
                child: new ManualEnterPopup(),
              ),
             if (StateContainer.of(context).isThereConnectionError)
            ConnectionError(),
          if (isInfo)
            GestureDetector(
              onTap: () {
                setState(() {
                  isInfo = false;
                });
              },
              child: Container(
                width: screenWidth,
                height: screenHeight,
                decoration: new BoxDecoration(color: Colors.black45),
                child: Align(
                    alignment: Alignment.center, child: new EventInfoUI()),
              ),
            )
            
            ]));
         
    
  
}
}
