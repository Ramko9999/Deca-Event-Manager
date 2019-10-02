import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:deca_app/screens/admin/admin_main.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/notifications/templates.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/global.dart';
import 'package:deca_app/utility/network.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:deca_app/utility/transistion.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/screens/profile/templates.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:deca_app/screens/code/qr_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';


class ProfileScreen extends StatefulWidget {
  ProfileScreen();

  @override
  State<ProfileScreen> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  ProfileScreenState();


  void startNetworkConnectionStream(){
    print("Stream is started");
    ConnectionStream networkStream = new ConnectionStream();
    networkStream.startConnectionChecker().listen(
      (onResponse){
        if(onResponse == 404){
          print(404);
          /*
          StateContainer.of(context).isThereANetworkConnectionError = true;
          StateContainer.of(context).setConnectionErrorStatus(true);
          */
          
        }
        else{
          print(200);
          
          /*
          StateContainer.of(context).isThereANetworkConnectionError = false;
          StateContainer.of(context).setConnectionErrorStatus(false);
          */
        }
      
    });
  }

  //listens to and changes connection status
  void startConnectionStream() {
    //check for connection, and notify different screens of connection issue

    Connectivity().onConnectivityChanged.listen((connectionResult) {
      bool implictError = StateContainer.of(context).isThereANetworkConnectionError;
      
      if (connectionResult == ConnectivityResult.none) {
        StateContainer.of(context).isThereAnExplicitConnectionError =true;
        StateContainer.of(context).setConnectionErrorStatus(true);
      } 
      else {
        StateContainer.of(context).setConnectionErrorStatus(implictError);
      }

    });
  }

  //if the platfrom is IOS we will have to request for permissions
  void initState() {
    super.initState();
    initNotifications();
    startNetworkConnectionStream();

    //put in our app logo here
    AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    IOSInitializationSettings iosInitSettings = IOSInitializationSettings();

    FlutterLocalNotificationsPlugin().initialize(
        InitializationSettings(androidInitSettings, iosInitSettings),
        onSelectNotification: (String payload) =>
            notificationOnSelect(payload));

    //listen for notifications on profile screen due to the fact profile screen will never be popped out of navigator
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.configure(onLaunch: (notification) {
      print("On Launch");

      //append notification
      StateContainer.of(context).addToNotifications(notification);
      Global.notificationDataFile.writeAsStringSync(
          json.encode(StateContainer.of(context).notifications));
    }, onMessage: (notification) {
      print("On Message");
      scheduleLocalNotification(notification);
    }, onResume: (notification) {
      print("On Resume");

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

  Future notificationOnSelect(String payload) {
    setState(() => _selectedIndex = 2);
  }

  void scheduleLocalNotification(Map notification) async {
    //used for scheduling as well as displaying notifications
    StateContainer.of(context).addToNotifications(notification);
    Global.notificationDataFile.writeAsStringSync(
        json.encode(StateContainer.of(context).notifications));

    //init settings
    AndroidNotificationDetails androidSettings = AndroidNotificationDetails(
        "channel id", "channel NAME", "CHANNEL DESCRIPTION");
    IOSNotificationDetails iosSettings = IOSNotificationDetails();
    NotificationDetails platformSettings =
        NotificationDetails(androidSettings, iosSettings);

    //show the actual notification
    showSimpleNotification(Text(notification['data']['header']),
        subtitle: Text(notification['data']['body']));
    //schedule a notification for future

    //not working right now on android
    if (notification['data'].keys.contains("date")) {
      await FlutterLocalNotificationsPlugin().schedule(
          0,
          notification['data']['header'],
          notification['data']['body'],
          DateTime.now().add(Duration(seconds: 10)),
          platformSettings);
    }
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
        leading: IconButton(
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
