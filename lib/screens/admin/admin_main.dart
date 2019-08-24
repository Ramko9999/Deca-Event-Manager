import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/screens/admin//templates.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AdminScreen extends StatefulWidget {
  AdminScreen();
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AdminScreenState();
  }
}

class _AdminScreenState extends State<AdminScreen> {
  _AdminScreenState();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final container = StateContainer.of(context);
    // TODO: implement build
    return new AdminScreenUI();
  }
}
