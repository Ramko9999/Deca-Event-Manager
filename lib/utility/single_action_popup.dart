import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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
    bool isPlatformAndroid = Platform.isAndroid;
    return isPlatformAndroid
        ? AlertDialog(
            title: Text(_header,
                style:
                    TextStyle(color: _color, fontFamily: 'Lato', fontSize: 26)),
            content: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                height: MediaQuery.of(context).size.height / 15,
                child: Column(
                  children: <Widget>[
                    Text(_message,
                        style: TextStyle(fontFamily: 'Lato', fontSize: 16)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(
                      fontFamily: 'Lato', color: Colors.blue, fontSize: 24),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          )
        : CupertinoAlertDialog(
            title: Text(_header, style: TextStyle(color: _color, fontSize: 26)),
            content: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Container(
                height: MediaQuery.of(context).size.height / 15,
                child: Column(
                  children: <Widget>[
                    Text(_message, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.blue, fontSize: 24),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
  }
}
