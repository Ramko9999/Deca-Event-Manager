import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class Sender extends StatefulWidget {
  Sender();

  State<Sender> createState() {
    return SenderState();
  }
}

class SenderState extends State<Sender> {
  String filter = "Any"; //used to only send notifications to certain committies
  String date;
  String connectionState = "wifi";
  TextEditingController header = new TextEditingController();
  TextEditingController message = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SenderState();
  StreamSubscription connectionStream;

  void initState() {
    connectionStream =
        Connectivity().onConnectivityChanged.listen((recentState) {
      setState(() {
        connectionState = recentState.toString();
      });
    });
  }

  void dispose() {
    super.dispose();
    connectionStream.cancel();
  }

  void executeNotification() {
    Map<String, dynamic> notificationData = {
      'header': header.text,
      'body': message.text
    };
    /*attaching a date will make the notification a remainder meaning
    that when the mobile phone gets the notification there will be a local notification
    scheduled on the phone */
    if (date != null) {
      notificationData.addAll({'date': date});
    }

    if (filter != "Any") {
      notificationData.addAll({'filter': filter});
    }

    //creating a new notification will trigger a cloud function that pushes the notification to everyone
    Firestore.instance
        .collection("Notifications")
        .add(notificationData)
        .then((_) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Pushed!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Send Notifications"),
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
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            "Send a Notification",
                            style: TextStyle(fontFamily: 'Lato', fontSize: 25),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: TextFormField(
                              controller: header,
                              style: TextStyle(fontFamily: 'Lato'),
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
                          padding: EdgeInsets.only(top: 15),
                          child: TextFormField(
                              controller: message,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: TextStyle(fontFamily: 'Lato'),
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
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Container(
                            width: screenWidth / 1.7,
                            child: DropdownButton(
                              value: filter,
                              isExpanded: true,
                              hint: Text(
                                  "Send Notification to Specific Committie"),
                              onChanged: (String group) {
                                setState(() => filter = group);
                              },
                              items: [
                                'Any',
                                'Gold Point',
                                'Website',
                                'none',
                              ].map((String group) {
                                return DropdownMenuItem(
                                  value: group,
                                  child: Text(
                                    group,
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 17,
                                        color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Container(
                            height: 50,
                            width: screenWidth / 1.1,
                            child: FlatButton(
                              child: Text(
                                date == null ? "Send as a Remainder" : date,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 17,
                                ),
                              ),
                              textColor: Colors.blue,
                              onPressed: () {
                                DatePicker.showDatePicker(context,
                                    showTitleActions: true,
                                    minTime: DateTime(2019, 8, 31),
                                    onChanged: (DateTime dateTime) {
                                  setState(() {
                                    date = new DateFormat('yyyy-MM-dd')
                                        .format(dateTime)
                                        .toString();
                                    ;
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                        FlatButton(
                          child: date == null
                              ? Text(
                                  "Optional Feature",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                )
                              : Text(
                                  "Don't send as reminder",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14),
                                ),
                          onPressed: date == null
                              ? () => print("Nothing shall happen")
                              : () {
                                  setState(() => date = null);
                                },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 70),
                          child: Container(
                            width: screenWidth / 1.1,
                            child: FlatButton(
                              child: Text(
                                "Push",
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 24,
                                    color: Colors.green),
                              ),
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
                                        style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 1),
                                  ));
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (connectionState.contains("none"))
              if (Platform.isAndroid)
                AlertDialog(
                  title: Container(
                    height: MediaQuery.of(context).size.height / 15,
                    child: Text(
                      "Connecting...",
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  content: Text(
                    'This will automatically dissapear when we connect you back to the servers',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              else
                CupertinoAlertDialog(
                  title: Container(
                    height: MediaQuery.of(context).size.height / 15,
                    child: Text(
                      "Connecting...",
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  content: Text(
                    'This will automatically dissapear when we connect you back to the servers',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
          ],
        ));
  }
}
