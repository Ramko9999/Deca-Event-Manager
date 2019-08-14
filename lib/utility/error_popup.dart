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
    return AlertDialog(
      title: Text("ERROR!",
          style: TextStyle(
            fontFamily: 'Lato',
            color: Colors.red,
            fontSize: 32,
          )),
      content: Container(
        height: MediaQuery.of(context).size.height / 6.0,
        width: MediaQuery.of(context).size.width / 2.0,
        child: Column(
          children: <Widget>[
            Text(_errorMessage, style: TextStyle(fontFamily: 'Lato')),
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text("Cancel", style: TextStyle(fontFamily: 'Lato')),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FlatButton(
                  child: Text("Try Again",
                      style: TextStyle(fontFamily: 'Lato', color: Colors.blue)),
                  onPressed: _action,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
