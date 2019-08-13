import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text(_header, style: TextStyle(color: _color, fontFamily: 'Lato')),
      content: Container(
        height: MediaQuery.of(context).size.height / 6,
        child: Column(
          children: <Widget>[
            Text(_message, style: TextStyle(fontFamily: 'Lato')),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(
                      fontFamily: 'Lato', color: Colors.blue, fontSize: 26),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
