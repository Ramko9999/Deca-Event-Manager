import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/admin/admin_main.dart';
import 'package:deca_app/screens/code/qr_screen.dart';
import 'package:deca_app/screens/db/databasemanager.dart';
import 'package:deca_app/screens/notifications/templates.dart';
import 'package:deca_app/screens/profile/templates.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/global.dart';
import 'package:deca_app/utility/network.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:deca_app/utility/transition.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  bool isAdmin = false;

  ProfileScreenState();


  void checkAdminStatus() async {
    
    if(Global.isAdmin){

      print("Fetched");
      DataBaseManagement.eventAggregator = Firestore.instance.collection("Aggregators").document("Event");
      DataBaseManagement.groupAggregator =  Firestore.instance.collection("Aggregators").document("Group");
      DataBaseManagement.userAggregator = Firestore.instance.collection("Aggregators").document("User");
    }

  }

  //listens to and changes connection status
  void startConnectionStream() {
    //check for connection, and notify different screens of connection issue

    Connectivity().onConnectivityChanged.listen((connectionResult) {
      bool implictError =
          StateContainer.of(context).isThereANetworkConnectionError;

      if (connectionResult == ConnectivityResult.none) {
        StateContainer.of(context).isThereAnExplicitConnectionError = true;
        StateContainer.of(context).setConnectionErrorStatus(true);
      } else {
        StateContainer.of(context).setConnectionErrorStatus(implictError);
      }
    });
  }

  //if the platfrom is IOS we will have to request for permissions
  void initState() {

    super.initState();
    initNotifications();
    checkAdminStatus();



    //listen for notifications on profile screen due to the fact profile screen will never be popped out of navigator
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


    _firebaseMessaging.configure(
      
      onLaunch: (Map<String, dynamic> notification) async {
      //append notification
      StateContainer.of(context).addToNotifications(notification);
      Global.notificationDataFile.writeAsStringSync(
          json.encode(StateContainer.of(context).notifications));
    }, 
    
    onMessage: (Map<String, dynamic> notification) async {
      
      StateContainer.of(context).addToNotifications(notification);
      Global.notificationDataFile.writeAsStringSync(
          json.encode(StateContainer.of(context).notifications));
      
      
      scheduleLocalNotification(notification);
    },
    
     onResume: (Map<String, dynamic> notification) async {
      
      
      //append notification
      StateContainer.of(context).addToNotifications(notification);
      Global.notificationDataFile.writeAsStringSync(
          json.encode(StateContainer.of(context).notifications));
    });

    startConnectionStream();
  }

  //used to get the locally stored notifications
  void initNotifications() {
    getApplicationDocumentsDirectory().then((appDirec) async {
      String userInformation = Global.userDataFile.readAsStringSync();
      String username = json.decode(userInformation)['username'];

      //so different accounts don't collide
      File notificationFile = File(appDirec.path + "/$username-notify.json");

      if (notificationFile.existsSync()) {
        List localNotifications =
            json.decode(notificationFile.readAsStringSync());
        StateContainer.of(context).initNotifications(localNotifications);
      } else {
        notificationFile.createSync();
        //encode a dummy list
        notificationFile.writeAsStringSync(json.encode([]));
      }
      Global.notificationDataFile = notificationFile;
    });
  }

  

  void scheduleLocalNotification(Map notification) async {
    
    
    //used for scheduling as well as displaying notifications
    StateContainer.of(context).addToNotifications(notification);
    Global.notificationDataFile.writeAsStringSync(
        json.encode(StateContainer.of(context).notifications));
    String header;
    String body;

    if(Platform.isIOS)
    {
      header = notification['header'];
      body = notification['body'];
    }
    else{
      header = notification['data']['header'];
      body = notification['data']['body'];
    }


    //show the actual notification
    showSimpleNotification(Text(header),
        subtitle: Text(body));
    //schedule a notification for future
  }

  Widget changeScreen(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return DynamicProfileUI(Global.uid);
      case 1:
        return QrScreen();
        break;
      default:
        return NotificationUI();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Widget build(BuildContext context) {
    int numOfNotifications = StateContainer.of(context).notificationCounter;
    final container = StateContainer.of(context);
 

    return Scaffold(
      body: Stack(
        children: <Widget>[
          changeScreen(_selectedIndex),
          if (StateContainer.of(context).isThereConnectionError)
            OfflineNotifier()
        ],
      ),
      appBar: new AppBar(
        title: (_selectedIndex == 0)
            ? Text("Profile")
            : (_selectedIndex == 1)
                ? Text("QR Code for Check-In")
                : (_selectedIndex == 2) ? Text("Notifications") : Text("Chats"),
        leading: (!Global.isAdmin)?
        Container():
        IconButton(
          icon: Icon(Icons.supervisor_account),
        onPressed: () async => Navigator.push(context,
            NoTransition(builder: (context) => new AdminScreen()))),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
                NoTransition(builder: (context) => new SettingScreen())),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          const BottomNavigationBarItem(
            icon: Icon(MdiIcons.qrcode),
            title: Text('Check-In'),
          ),
          BottomNavigationBarItem(
            icon: numOfNotifications != 0
                ? Stack(
                    children: <Widget>[
                      Icon(
                        Icons.notifications,
                        color: Colors.blue,
                      ),
                      Positioned(
                        right: 0,
                        top: 10,
                        child: ClipOval(
                          child: Container(
                            width: 13,
                            height: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      //create the notification circle
                      Positioned(
                        right: 0,
                        top: 11,
                        child: ClipOval(
                          child: Container(
                            width: 11,
                            height: 11,
                            color: Colors.red,
                            child: Text(
                              "$numOfNotifications",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lato',
                                  fontSize: 8),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Icon(Icons.notifications_none),
            title: Text('Notifications'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
