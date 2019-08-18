import 'package:flutter/material.dart';
import 'package:deca_app/screens/admin//templates.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AdminScreen extends StatefulWidget
{
  String _uid;

  AdminScreen(this._uid);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AdminScreenState(_uid);
  }
}

class _AdminScreenState extends State<AdminScreen>
{
  String uid;
  _AdminScreenState(uid)
  {
    this.uid = uid;
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // TODO: implement build
    return new AdminScreenUI(uid);
  }
}