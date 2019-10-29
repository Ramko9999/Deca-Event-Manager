import 'package:deca_app/screens/authentication/test.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/screens/authentication/authentication_screen.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(StateContainer(
    child: OverlaySupport(
      child: new MaterialApp(
          home: AuthenticationScreen(),
          routes: <String, WidgetBuilder>{
            '/Profile': (BuildContext context) => ProfileScreen(),
            '/Settings': (BuildContext context) => SettingScreen(),
          }),
    ),
  ));
}
