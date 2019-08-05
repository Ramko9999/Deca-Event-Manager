import 'package:flutter/material.dart';

//class is used to make quick background images
class BackgroundImage extends StatelessWidget{
  String _filePath;

  BackgroundImage(this._filePath);
  
  Widget build(BuildContext context){
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage(this._filePath),
          fit: BoxFit.cover,
      )
      )
    ,
    height: double.infinity,
    width: double.infinity);
  }
}