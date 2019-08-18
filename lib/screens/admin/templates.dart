import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:deca_app/utility/error_popup.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:path_provider/path_provider.dart';

class Scanner extends StatefulWidget {
  int pointVal;

  Scanner(int point) {
    this.pointVal = point;
  }
  State<Scanner> createState() {
    return _ScannerState(pointVal);
  }
}

class _ScannerState extends State<Scanner> {
  HashSet<String> _scannedUids; //used to keep track of already scanned codes
  String _connectionState; //used to listen to connection changes
  List _cameras; //used to grab cameras
  CameraController _mainCamera; //camera that will give us the feed
  bool _isCameraInitalized = false;
  int pointVal;

  _ScannerState(int point) {
    _scannedUids = new HashSet();
    _connectionState = "Unknown Connection";
    pointVal = point;
  }

  //runs scanStream forever on delay
  void scanStream() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      scanImage();
    }
  }

  //scan the actual barcode through an image stream
  void scanImage() async {

    //starting image stream and saving file

    getApplicationDocumentsDirectory().then((dir) {
      String imagePath = dir.path + "/code.png"; //path for the image
      if (File(imagePath).existsSync()) {
        File(imagePath).deleteSync();
      }
      //take picture and save progress
      _mainCamera.takePicture(imagePath).then((val) {
        //apply ml to the picture and get raw value
        FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(imagePath);
        FirebaseVision.instance
            .barcodeDetector()
            .detectInImage(image)
            .then((barcodes) {
          for (int i = 0; i < barcodes.length; i++) {
            //update db
            String userUniqueID = barcodes[0].rawValue;

            //check if uid has already been scanned
            if(!_scannedUids.contains(userUniqueID)){
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
              
              //update the scaffold

              //append to the hashset the uniqueID
              _scannedUids.add(userUniqueID);
            }).catchError((onError) => print(onError));
            }
            else{
              print("Already Scanned this person");
            }
            
          }
        });
      }).catchError((onError) {
        print(onError);
      });
    });
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
      _mainCamera = CameraController(allCameras[0], ResolutionPreset.high);
      _mainCamera.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() => _isCameraInitalized = true); //show the actual camera
        scanStream();
      }).catchError((error) {
        if (error.runtimeType == CameraException) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Issues with Camera"),
          ));
        }
      });
    });
  }

  void dispose(){
    _mainCamera.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
      children: <Widget>[
        _connectionState.contains('none')
            ? showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Network Error",
                        style:
                            TextStyle(fontFamily: 'Lato', color: Colors.red)),
                    content: Text(
                        "There is an error connecting to network, once we detect a connecton, this page will automatically dissapear"),
                  );
                })
            : Stack(
                children: <Widget>[
                  Container(
                      height: screenHeight,
                      width: screenWidth,
                      child: _isCameraInitalized
                          ? RotationTransition(
                              child: CameraPreview(_mainCamera),
                              turns: AlwaysStoppedAnimation(270 / 360))
                          : Text("Loading...")),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                        child: Text("Done"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                ],
              ),
      ],
    ));
  }
}
