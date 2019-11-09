import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/db/databasemanager.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/global.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sender extends StatefulWidget {
  Sender();

  State<Sender> createState() {
    return SenderState();
  }
}

class SenderState extends State<Sender> {
  String filter = "All"; //used to only send notifications to certain committies
  String date;
  String dropdownValue;
  List<String> groups = [];
  TextEditingController header = new TextEditingController();
  TextEditingController message = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SenderState();

  void initState() {
    super.initState();

    DataBaseManagement.groupAggregator.get().then((document) {

      List<String> potentialGroups= [];

      document.data['group_list'].forEach((f)=> potentialGroups.add(f.toString()));
    
      potentialGroups.add("All");
      setState(() {
        groups = potentialGroups;
        filter = groups.last;
      });
    });
  }

  //creates a new notification in the cloud firestore database
  void executeNotification() {
    Map<String, dynamic> notificationData = {
      'header': header.text,
      'body': message.text,
      'uid': Global.uid,
    };
    /*attaching a date will make the notification a remainder meaning
    that when the mobile phone gets the notification there will be a local notification
    scheduled on the phone */
    if (date != null) {
      notificationData.addAll({'date': date});
    }

    if (filter != "All") {
      notificationData.addAll({'filter': filter});
    }

    //creating a new notification will trigger a cloud function that pushes the notification to everyone
    Firestore.instance.collection("Notifications").add(notificationData).then(
        (_) {
      setState(() {
        //reset the notifications
        header.text = "";
        message.text = "";
        date = null;
        filter = groups.last;
      });

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            "Message Sent!",
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: Sizer.getTextSize(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.width, 20),
                color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        dropdownValue = null;
      });
    }, onError: (e) {});
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Send a Notification"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    width: screenWidth / 1.1,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.04),
                          child: TextFormField(
                              controller: header,
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: Sizer.getTextSize(
                                      screenWidth, screenHeight, 16)),
                              decoration: InputDecoration(
                                  labelText: "Notification Header",
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ))),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.03),
                          child: TextFormField(
                              controller: message,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: Sizer.getTextSize(
                                      screenWidth, screenHeight, 16)),
                              decoration: InputDecoration(
                                  labelText: "Notification Body",
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ))),
                        ),
                        if (Platform.isAndroid)
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.03),
                            child: Container(
                                width: screenWidth / 1.7,
                                child: groups.isEmpty
                                    ? Text(
                                        "Loading Committees...",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.blue),
                                      )
                                    : DropdownButton(
                                        value: filter,
                                        isExpanded: true,
                                        hint: Text("Notification Destination"),
                                        onChanged: (String group) {
                                          setState(() => filter = group);
                                        },
                                        items: groups.map((String group) {
                                          return DropdownMenuItem<String>(
                                            value: group,
                                            child: Text(
                                              group,
                                              style: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontSize: Sizer.getTextSize(
                                                      screenWidth,
                                                      screenHeight,
                                                      17),
                                                  color: Colors.blue),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }).toList(),
                                      )),
                          ),
                        if (Platform.isIOS)
                          Container(
                              padding: new EdgeInsets.only(top: sH * 0.03),
                              width: sW * 0.9,
                              height: sH * 0.12,
                              child: RaisedButton(
                                child: AutoSizeText(
                                  (dropdownValue == null)
                                      ? "Choose Notification Destination"
                                      : "Destination: " + dropdownValue,
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      fontSize: Sizer.getTextSize(sW, sH, 17),
                                      fontFamily: 'Lato'),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoActionSheet(
                                          title:
                                              Text('Notification Destination'),
                                          actions: groups.map((String group) {
                                            return CupertinoActionSheetAction(
                                              onPressed: () {
                                                setState(() {
                                                  dropdownValue = group;
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Text(
                                                group,
                                                style: TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: Sizer.getTextSize(
                                                        screenWidth,
                                                        screenHeight,
                                                        17),
                                                    color: Colors.blue),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      });
                                },
                              )),
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.03),
                          child: Container(
                              width: screenWidth * 0.45,
                              height: screenHeight * 0.08,
                              child: new RaisedButton(
                                child: Text('Send',
                                    style: new TextStyle(
                                        fontSize: Sizer.getTextSize(
                                            screenWidth, screenHeight, 17),
                                        fontFamily: 'Lato')),
                                textColor: Colors.white,
                                color: Color.fromRGBO(46, 204, 113, 1),
                                onPressed: () {
                                  try {
                                    if (header.text.trim() == "") {
                                      throw Exception("Header cannot be empty");
                                    }
                                    if (message.text.trim() == "") {
                                      throw Exception("Body cannot be empty");
                                    }
                                    executeNotification();
                                  } catch (error) {
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(error.toString(),
                                          style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: Sizer.getTextSize(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  20),
                                              color: Colors.white)),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ));
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (StateContainer.of(context).isThereConnectionError)
              ConnectionError()
          ],
        ));
  }
}
