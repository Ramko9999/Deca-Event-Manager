import 'dart:convert';
import 'dart:io';

import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/global.dart';
import 'package:flutter/material.dart';

//UI should simply be a list that contains notifications

class NotificationUI extends StatefulWidget {
  NotificationUI();

  State<NotificationUI> createState() {
    return NotificationUIState();
  }
}

class NotificationUIState extends State<NotificationUI> {
  NotificationUIState();

  Widget build(BuildContext context) {
    StateContainer.of(context).notificationCounter = 0;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
        height: screenHeight / 1.1,
        width: screenWidth,
        child: getListItems(StateContainer.of(context).notifications));
  }

  //build the notifications when a new notification is recieved
  Widget getListItems(documents) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    if (documents.length == 0) {
      return Container(
          alignment: Alignment.center, child: Text("No notifications here"));
    }
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, i) {
        int index = documents.length - 1 - i;
        String header;
        String body;

        if (Platform.isIOS) {
          header = documents[index]['header'];
          body = documents[index]['body'];
        } else {
          header = documents[index]['data']['header'];
          body = documents[index]['data']['body'];
        }
        //gives the dismiss animation, still working on the dismiss
        return Dismissible(
          background: Container(
            color: Colors.red,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "Deleting",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lato',
                    fontSize: Sizer.getTextSize(sW, sH, 24)),
              ),
            ),
          ),
          key: Key(UniqueKey().toString()),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              //remove notification and save as such in file
              StateContainer.of(context).removeNotification(documents[index]);
              Global.notificationDataFile.writeAsStringSync(
                  json.encode(StateContainer.of(context).notifications));
            }
          },
          child: Card(
            child: ListTile(
              title: Text(
                header.toString(),
                style: TextStyle(fontFamily: 'Lato'),
              ),
              subtitle: Text(
                body.toString(),
                style: TextStyle(fontFamily: 'Lato'),
              ),
            ),
          ),
        );
      },
    );
  }
}
