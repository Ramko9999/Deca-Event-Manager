import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_first_app/utility/error_popup.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:barcode_scan/barcode_scan.dart';



class QrReaderScreen extends StatefulWidget{

  String _uid;

  QrReaderScreen(String uid){
    this._uid = uid;
  }

  @override
  _QrReaderScreenState createState() => _QrReaderScreenState(_uid);
}

class _QrReaderScreenState extends State<QrReaderScreen> {
  HashSet<String> _scannedUids = new HashSet();
  bool _isCheckIn;
  String _uid;

  _QrReaderScreenState(String uid){
    this._uid = uid;
  }

  void onLoad(BuildContext context){
    checkConnection(context);
  }

  void scanBarcodes() async {
    BarcodeScanner.scan().then((onValue){
      print(onValue);
    }).catchError((error){
      print(error);
    });
  }

  void checkCameraPermission(BuildContext context) async{
    SimplePermissions.requestPermission(Permission.Camera).then((isAccepted){    
      if(isAccepted != PermissionStatus.authorized){
        Navigator.of(context).pop();
      }
      else{
        scanBarcodes();
      }

    });
  }

  void checkConnection(BuildContext context) async {
    Connectivity().checkConnectivity().then(
      (connectionState){
        if(connectionState == ConnectivityResult.none){
          return Exception('Phone is not connected to wifi');
        }
        else{
          //execute check camera permission
          checkCameraPermission(context);
        }
      }
    ).catchError(
      (error){
        if(error.contains("wifi")){
          showDialog(
            context: context,
            builder: (context){
              return ErrorPopup("Phone is not connected to wifi", (){
                Navigator.of(context).pop();
                checkConnection(context);
              });
            }

          );
        }
      }
    );
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Reader"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()=> Navigator.of(context).pop(),
        ), 
        ),
        body: Form(
          key:
        )

    );
  }
}