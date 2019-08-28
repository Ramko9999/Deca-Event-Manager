import 'package:deca_app/screens/admin/notification_sender.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/screens/code/qr_screen.dart';

class NavigationDrawer extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              FlatButton(
                  child: Text("QR Code"),
                  onPressed: () async => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => new QrScreen()))),
              FlatButton(
                  child: Text("Push Notifications"),
                  onPressed: () async => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => new Sender())))
            ],
          ),
        ));
  }
}
