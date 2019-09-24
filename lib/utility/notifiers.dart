import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

//these file contains classes that are used to alert the viewer if an error has occured or an event has occured
class ConnectionError extends StatelessWidget {
  String message;

  ConnectionError([String m]) {
    message = m;
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelTwoWidth = 411.42857142857144;

    return Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.black45,
        child: Platform.isAndroid
            ? AlertDialog(
                title: Container(
                  height: MediaQuery.of(context).size.height / 15,
                  child: Text(
                    "Connecting...",
                    style:
                        TextStyle(fontSize: 26 * screenWidth / pixelTwoWidth),
                  ),
                ),
                content: Text(
                  message != null
                      ? message
                      : 'This will automatically dissapear when we connect you back to the servers',
                  style: TextStyle(
                    fontSize: 16 * screenWidth / pixelTwoWidth,
                  ),
                ),
              )
            : CupertinoAlertDialog(
                title: Container(
                  height: MediaQuery.of(context).size.height * 15,
                  child: Text(
                    "Connecting...",
                    style:
                        TextStyle(fontSize: 26 * screenWidth / pixelTwoWidth),
                  ),
                ),
                content: Text(
                  'This will automatically dissapear when we connect you back to the servers',
                  style: TextStyle(
                    fontSize: 16 * screenWidth / pixelTwoWidth,
                  ),
                ),
              ));
  }
}

//Error Popup is used to show errors
class ErrorPopup extends StatelessWidget {
  String _errorMessage;
  Function _action;

  ErrorPopup(String errorMessage, Function action) {
    this._errorMessage = errorMessage;
    this._action = action;
  }
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    double pW = 411.42857142857144;
    double pH = 683.4285714285714;

    bool isPlatformAndroid = Platform.isAndroid;
    return isPlatformAndroid
        ? AlertDialog(
            title: Text("Error",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32 * sW / pW,
                )),
            content: Container(
              height: sH / 6.5,
              width: sW / 2.0,
              child: Column(
                children: <Widget>[
                  Text(_errorMessage, style: TextStyle(fontSize: 18 * sW / pW)),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel", style: TextStyle(fontSize: 16 * sW / pW)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text("Try Again",
                    style:
                        TextStyle(color: Colors.blue, fontSize: 16 * sW / pW)),
                onPressed: _action,
              )
            ],
          )
        : CupertinoAlertDialog(
            title: Text("Error",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 32 * sW / pW,
                )),
            content: Container(
              height: sH / 6.5,
              width: sW / 2.0,
              child: Column(
                children: <Widget>[
                  Text(_errorMessage, style: TextStyle(fontSize: 18 * sW / pW)),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel", style: TextStyle(fontSize: 16 * sW / pW)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text("Try Again",
                    style: TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.blue,
                        fontSize: 16 * sW / pW)),
                onPressed: _action,
              )
            ],
          );
  }
}

//a popup with an  'ok' button
class SingleActionPopup extends StatelessWidget {
  String _message;
  String _header;
  Color _color;

  SingleActionPopup(String message, String header, Color color) {
    this._header = header;
    this._message = message;
    this._color = color;
  }
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    double pW = 411.42857142857144;
    double pH = 683.4285714285714;

    bool isPlatformAndroid = Platform.isAndroid;
    return isPlatformAndroid
        ? AlertDialog(
            title: Text(_header,
                style: TextStyle(color: _color, fontSize: 26 * sW / pW)),
            content: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                height: MediaQuery.of(context).size.height / 15,
                child: Column(
                  children: <Widget>[
                    Text(_message, style: TextStyle(fontSize: 16 * sW / pW)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.blue, fontSize: 24 * sW / pW),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          )
        : CupertinoAlertDialog(
            title: Text(_header,
                style: TextStyle(color: _color, fontSize: 26 * sW / pW)),
            content: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Container(
                height: MediaQuery.of(context).size.height / 15,
                child: Column(
                  children: <Widget>[
                    Text(_message, style: TextStyle(fontSize: 16 * sW / pW)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.blue, fontSize: 24 * sW / pW),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
  }
}

class OfflineNotifier extends StatelessWidget {
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          height: MediaQuery.of(context).size.height * 0.04,
          width: MediaQuery.of(context).size.width,
          color: Colors.amber,
          child: Text(
            "You are offline",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontFamily: 'Lato', fontSize: 15),
          )),
    );
  }
}
