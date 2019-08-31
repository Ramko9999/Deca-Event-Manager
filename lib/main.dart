import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/utility/background_image.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/screens/authentication/templates.dart';
import 'package:deca_app/screens/authentication/authentication_screen.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';

void main() {
  runApp(StateContainer(
    child: new MaterialApp(
        home: new AuthenticationScreen(),
        routes: <String, WidgetBuilder>{
          '/Profile': (BuildContext context) => ProfileScreen(),
          '/Settings': (BuildContext context) => SettingScreen(),
        }),
  ));
}
