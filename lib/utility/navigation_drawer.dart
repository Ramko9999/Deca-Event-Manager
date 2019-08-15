import 'package:flutter/material.dart';
import 'package:flutter_first_app/screens/admin/qr_reader.dart';
import 'package:flutter_first_app/screens/profile/profile_screen.dart';
import 'package:flutter_first_app/screens/code/qr_screen.dart';

class NavigationDrawer extends StatelessWidget {
  String _uid;
  NavigationDrawer(this._uid);

  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              FlatButton(
                  child: Text("QR Reader"),
                  onPressed: () async => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new QrReaderScreen(_uid))))
            ],
          ),
        ));
  }
}
