import 'package:flutter/material.dart';

class UserDataState extends State<UserData> {
  String uid; //contains UID of app user
  List notifications; //contains notifications of app user
  bool hasSeenNotification =
      false; //checks whether a notification has been seen
  List groups;
  bool isThereConnectionError = false;

  void setUID(String _uid) {
    setState(() {
      uid = _uid;
    });
  }

  void hasSawNotification() {
    setState(() {
      hasSeenNotification = true;
    });
  }

  //used to add to the notifications of the user
  void addToNotifications(Map notification) {
    setState(() {
      this.notifications.add(notification);
      hasSeenNotification = true;
    });
  }

  void initNotifications(List notifications) {
    setState(() {
      this.notifications = notifications;
    });
  }

  void setConnectionErrorStatus(bool e) {
    setState(() {
      isThereConnectionError = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _UserDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class UserData extends StatefulWidget {
  // You must pass through a child.
  final Widget child;
  final String uid;

  UserData({
    @required this.child,
    this.uid,
  });

  static UserDataState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_UserDataWidget)
            as _UserDataWidget)
        .data;
  }

  @override
  UserDataState createState() => new UserDataState();
}

class _UserDataWidget extends InheritedWidget {
  final UserDataState data;

  _UserDataWidget({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_UserDataWidget old) => true;
}
