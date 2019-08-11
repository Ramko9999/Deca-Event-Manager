import 'package:flutter/material.dart';
import 'package:flutter_first_app/screens/settings/setting_screen.dart';
import 'package:flutter_first_app/utility/navigation_drawer.dart';
import 'package:flutter_first_app/screens/profile/templates.dart';

class ProfileScreen extends StatefulWidget {
  String _uid;

  ProfileScreen(uid) {
    this._uid = uid;
  }

  @override
  State<ProfileScreen> createState() {
    return ProfileScreenState(_uid);
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  String _uid;

  ProfileScreenState(String uid) {
    this._uid = uid;
    print(this._uid);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: new DynamicProfileUI(_uid),
      drawer: new NavigationDrawer(_uid),
      appBar: new AppBar(
        title: Text("View Profile"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new SettingScreen(_uid))),
          )
        ],
      ),
    );
  }
}
