import 'package:flutter/material.dart';

class ErrorPopup extends StatelessWidget{
  String _errorMessage;
  
  ErrorPopup(String errorMessage){
    this._errorMessage = errorMessage;
  }
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text("ERROR!",
      style:TextStyle(
        fontFamily: 'Lato',

      )),
    );
  }
}