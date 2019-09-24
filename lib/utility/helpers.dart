import 'package:flutter/material.dart';

//aimed to solve the problem that comes with padding
class Spacer extends StatelessWidget {
  double topPad;
  Function callback;
  Widget child;

  Spacer(double t, [Function callback, Widget child]) {
    this.topPad = t;
    this.callback = callback;
    this.child = child;
  }

  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: topPad),
        child: GestureDetector(onTap: callback, child: this.child));
  }
}
