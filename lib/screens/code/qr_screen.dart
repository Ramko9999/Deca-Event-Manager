import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/global.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  QrScreen();

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          width: screenWidth * 0.9,
          height: screenWidth * 0.9,
          child: QrImage(
            data: Global.uid,
            version: 9,
          ),
        ),
      ),
    );
  }
}
