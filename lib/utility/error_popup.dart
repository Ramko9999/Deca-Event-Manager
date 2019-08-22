import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Error Popup is used to show errors
class ErrorPopup extends StatelessWidget {
  String _errorMessage;
  Function _action;

  ErrorPopup(String errorMessage, Function action) {
    this._errorMessage = errorMessage;
    this._action = action;
  }
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isPlatformAndroid = Platform.isAndroid;
    return isPlatformAndroid
        ? AlertDialog(
            title: Text("ERROR!",
                style: TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.red,
                  fontSize: 32 * textScaleFactor,
                )),
            content: Container(
              height: screenHeight / 6.5,
              width: screenWidth / 2.0,
              child: Column(
                children: <Widget>[
                  Text(_errorMessage,
                      style: TextStyle(
                          fontFamily: 'Lato', fontSize: 18 * textScaleFactor)),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel",
                    style: TextStyle(
                        fontFamily: 'Lato', fontSize: 16 * textScaleFactor)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text("Try Again",
                    style: TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.blue,
                        fontSize: 16 * textScaleFactor)),
                onPressed: _action,
              )
            ],
          )
        : CupertinoAlertDialog(
            title: Text("ERROR!",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 32 * textScaleFactor,
                )),
            content: Container(
              height: screenHeight / 6.5,
              width: screenWidth / 2.0,
              child: Column(
                children: <Widget>[
                  Text(_errorMessage,
                      style: TextStyle(fontSize: 18 * textScaleFactor)),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel",
                    style: TextStyle(fontSize: 16 * textScaleFactor)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text("Try Again",
                    style: TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.blue,
                        fontSize: 16 * textScaleFactor)),
                onPressed: _action,
              )
            ],
          );
  }
}
