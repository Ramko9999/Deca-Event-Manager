import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/global.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  List<String> groups = [];
  TextEditingController header = new TextEditingController();
  TextEditingController message = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SenderState();

  void initState(){
    super.initState();
  
     Firestore.instance.collection("Groups").getDocuments().then((documents){
       List<String> potentialGroups = [];
       documents.documents.forEach((d){
         potentialGroups.add(d.data['name']);
       });
       potentialGroups.add("Any");
       setState((){
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

    if (filter != "Any") {
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
          content: Text("Pushed!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    }, onError: (e) {});
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
                          padding: EdgeInsets.only(top: screenHeight * 0.04),
                          child: TextFormField(
                              controller: header,
                              style: TextStyle(
                                  fontFamily: 'Lato', fontSize: Sizer.getTextSize(screenWidth, screenHeight, 16)),
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
                                  fontFamily: 'Lato', fontSize:  Sizer.getTextSize(screenWidth, screenHeight, 16)),
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
                          padding: EdgeInsets.only(top: screenHeight * 0.03),
                          child: Container(
                            width: screenWidth / 1.7,
                            child: 
                            groups.isEmpty? 
                            Text("Loading Groups...", textAlign: TextAlign.center, style: TextStyle(color: Colors.blue),)
                            :
                            DropdownButton(
                              value: filter,
                              isExpanded: true,
                              hint: Text(
                                  "Send Notification to Specific Committie"),
                              onChanged: (String group) {
                                setState(() => filter = group);
                              },
                              items: groups
                              .map((String group) {
                                return DropdownMenuItem<String>(
                                  value: group,
                                  child: Text(
                                    group,
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: Sizer.getTextSize(screenWidth, screenHeight, 17),
                                        color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                            )
                            
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.03),
                          child: Container(
                            width: screenWidth / 1.1,
                            child: FlatButton(
                              child: Text(
                                date == null ? "Send as a Reminder" : date,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize:  Sizer.getTextSize(screenWidth, screenHeight, 18),
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
                                      color: Colors.grey,
                                      fontSize:  Sizer.getTextSize(screenWidth, screenHeight, 12)),
                                )
                              : Text(
                                  "Don't send as reminder",
                                  style: TextStyle(
                                      color: Colors.red, fontSize:  Sizer.getTextSize(screenWidth, screenHeight, 12)),
                                ),
                          onPressed: date == null
                              ? () => print("Nothing shall happen")
                              : () {
                                  setState(() => date = null);
                                },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.10),
                          child: Container(
                            width: screenWidth / 1.1,
                            child: FlatButton(
                              child: Text(
                                "Push",
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize:  Sizer.getTextSize(screenWidth, screenHeight, 24),
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
            if (StateContainer.of(context).isThereConnectionError)
              ConnectionError()
          ],
        ));
  }
}
