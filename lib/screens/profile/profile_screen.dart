import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_first_app/screens/profile/templates.dart';

class ProfileScreen extends StatefulWidget {
  String _uid;

  ProfileScreen(_uid);

  @override
  State<ProfileScreen> createState() {
    return ProfileScreenState(_uid);
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  //make an object for these fields
  String _firstName = "N/A";
  String _lastName = "N/A";
  int _goldPoints = -999;
  String _memberLevel = "N/A";
  List _groups = ["N/A"];
  String _uid;

  ProfileScreenState(String uid) {
    this._uid = uid;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: new DynamicProfileUI(_uid),
      drawer: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Drawer(
            child: ListView(
              children: <Widget>[
                FlatButton(
                    child: Text("QR Code"),
                    onPressed: () async => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => null))),
                FlatButton(
                  child: Text("Chats"),
                  onPressed: () async => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => null)),
                ),
                FlatButton(
                    child: Text("Notifications"),
                    onPressed: () async => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => null))),
                FlatButton(
                    child: Text("Home"),
                    onPressed: () async => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new ProfileScreen(_uid))))
              ],
            ),
          )),
      appBar: new AppBar(
        title: Text("View Profile"),
      ),
    );
  }
}
