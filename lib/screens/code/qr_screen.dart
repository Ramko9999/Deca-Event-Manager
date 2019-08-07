import 'package:flutter/material.dart';
import 'package:flutter_first_app/utility/navigation_drawer.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  String _uid;

  QrScreen(this._uid);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("My QR Code"),
      ),
      drawer: new NavigationDrawer(_uid),
      body: Center(
        child: QrImage(
          data: _uid,
          version: 9,
        ),
      ),
    );
  }
}
