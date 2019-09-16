import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:deca_app/screens/admin/admin_main.dart';
import 'package:deca_app/screens/admin/notification_sender.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/notifications/templates.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/notifiers.dart';

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
  FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ProfileScreenState();

  //streams

  void startNotificationStream() {
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
      //start up app
    }, onMessage: (notification) {
      //pop till profile screen
    }, onResume: (notification) {
      scheduleLocalNotification(notification);
    });
  }

  //listens to and changes connection status
  void startConnectionStream() {
    //check for connection, and notify different screens of connection issue

    Connectivity().onConnectivityChanged.listen((connectionResult) {
      if (connectionResult != ConnectivityResult.wifi) {
        StateContainer.of(context).setConnectionErrorStatus(true);
      } else {
        StateContainer.of(context).setConnectionErrorStatus(false);
      }
    });
  }

  //if the platfrom is IOS we will have to request for permissions
  void initState() {
    super.initState();
    initNotifications();
    startNotificationStream();
    startConnectionStream();
  }

  //used to get the locally stored notifications
  void initNotifications() {
    getApplicationDocumentsDirectory().then((appDirec) {
      if (File(appDirec.path + "/notify.json").existsSync()) {
        List localNotifications = json
            .decode(File(appDirec.path + "/notify.json").readAsStringSync());
        StateContainer.of(context).initNotifications(localNotifications);
      } else {
        File file = File(appDirec.path + "/notify.json");
        file.writeAsStringSync(json.encode([])); //dummy writing
      }
    });
  }

  Future notificationOnSelect(String payload) {
    setState(() => _selectedIndex = 2);
  }

  void scheduleLocalNotification(Map notification) async {
    //used for scheduling as well as displaying notifications
    StateContainer.of(context).addToNotifications(notification);

    //init settins
    AndroidNotificationDetails androidSettings = AndroidNotificationDetails(
        "channel id", "channel NAME", "CHANNEL DESCRIPTION");
    IOSNotificationDetails iosSettings = IOSNotificationDetails();
    NotificationDetails platformSettings =
        NotificationDetails(androidSettings, iosSettings);

    //show the actual notification
    showSimpleNotification(Text(notification['body']),
        subtitle: Text(notification['title']));
    //schedule a notification for future

    //not working right now on android
    if (true) {
      await FlutterLocalNotificationsPlugin().schedule(
          0,
          notification['title'],
          notification['body'],
          DateTime.now().add(Duration(seconds: 10)),
          platformSettings);
    }
  }

  Widget changeScreen(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return DynamicProfileUI();
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          changeScreen(_selectedIndex),

          if (StateContainer.of(context).isThereConnectionError)
            OfflineNotifier()
        ],
      ),
      drawer: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Drawer(
            child: ListView(
              children: <Widget>[
                ListTile(
                    title: Text(
                      "Admin Functions",
                      textAlign: TextAlign.center,
                    ),
                    onTap: () async => Navigator.push(context,
                        NoTransition(builder: (context) => new AdminScreen()))),
                ListTile(
                    title: Text(
                      "Push Notifications",
                      textAlign: TextAlign.center,
                    ),
                    onTap: () async => Navigator.push(context,
                        NoTransition(builder: (context) => new Sender())))
              ],
            ),
          )),
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
      bottomNavigationBar:
          BottomNavigationBar(
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
                icon: Stack(
                  children: <Widget>[
                    Icon(StateContainer.of(context).hasSeenNotification
                        ? Icons.notification_important
                        : Icons.notifications),
                    Positioned(
                      right: 0,
                      top: 11,
                      child: Container(
                        
                        width: MediaQuery.of(context).size.width * 0.04,
                        height: MediaQuery.of(context).size.height * 0.03,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text("4", 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lato',
                          fontSize: 10

                        ),),
                      ),
                    )
                  ],
                ),
                title: 
                    Text('Notifications'),
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
