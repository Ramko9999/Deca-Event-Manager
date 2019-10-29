import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//a transistion that has no animation
class NoTransition<T> extends MaterialPageRoute<T> {
  NoTransition({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return child;
  }
}