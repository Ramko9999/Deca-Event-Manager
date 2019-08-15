import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';


class QrTemplate extends StatefulWidget{
  String _uid;
  
  QrTemplate(String uid){
    _uid =uid;
  }

  @override
  State<QrTemplate> createState(){
    return _QrTemplateState(_uid);
  }
}

class _QrTemplateState extends State<QrTemplate>{
  String _uid;
  final qrKey = GlobalKey<FormState>();
  TextEditingController _eventName = TextEditingController();
  TextEditingController _pointValue = TextEditingController();
  _QrTemplateState(String uid){
    _uid = uid;
  }

  Widget build(BuildContext context){
    return Form(
      key: qrKey,
      child: Column(children: <Widget>[
        Text("Event Creator", style: TextStyle(fontFamily: 'Lato', fontSize: 36),
        ),
        TextField(
          controller: _eventName,
          onEditingComplete: ,
        )
      ],)
    )
  }
}