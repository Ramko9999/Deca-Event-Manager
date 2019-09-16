import 'dart:convert';
import 'dart:io';

import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

//UI should simply be a list that contains notifications

class NotificationUI extends StatefulWidget {
  NotificationUI();

  State<NotificationUI> createState() {
    return NotificationUIState();
  }
}

class NotificationUIState extends State<NotificationUI> {
  NotificationUIState();
  File notificationFile;

  void initState() {
    setNotificationFile();
    super.initState();
  }

  void setNotificationFile() {
    getApplicationDocumentsDirectory().then((directory) {
      setState(() => notificationFile = File(directory.path + '/notify.json'));
    });
  }

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: screenHeight / 1.1,
        width: screenWidth,
        child: getListItems(StateContainer.of(context).notifications));
  }

  Widget getListItems(documents) {
    if (notificationFile == null) {
      return Column(
        children: <Widget>[
          Text("Loading Notifications"),
          CircularProgressIndicator(),
        ],
      );
    }
    if (documents == 0) {
      return Text("No notifications here");
    }
    notificationFile.writeAsStringSync(json.encode(documents));
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, i) {
        //gives the dismiss animation, still working on the dismiss
        return Dismissible(
          background: Container(color: Colors.red),
          key: Key(UniqueKey().toString()),
          onDismissed: (direction) {
            if (direction == DismissDirection.horizontal) {
              StateContainer.of(context).notifications.removeAt(i);
            }
          },
          child: Card(
            child: ListTile(
              title: Text(
                documents[i]['notification']['title'],
                style: TextStyle(fontFamily: 'Lato'),
              ),
              subtitle: Text(
                documents[i]['notification']['body'],
                style: TextStyle(fontFamily: 'Lato'),
              ),
            ),
          ),
        );
      },
    );
  }
}
