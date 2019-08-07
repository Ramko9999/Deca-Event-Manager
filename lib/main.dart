import 'package:flutter/material.dart';
import 'package:flutter_first_app/utility/background_image.dart';
import 'package:flutter_first_app/screens/authentication/templates.dart';
import 'package:flutter_first_app/screens/authentication/authentication_screen.dart';
import 'package:flutter_first_app/screens/profile/profile_screen.dart';

void main() {
  runApp(new MaterialApp(
      home: new AuthenticationScreen(),
      routes: <String, WidgetBuilder>{'/ProfileScreen': null}));
}
