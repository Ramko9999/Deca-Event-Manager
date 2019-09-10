import 'dart:convert';
import 'dart:io';

import 'package:deca_app/screens/admin/admin_main.dart';
import 'package:deca_app/screens/admin/notification_sender.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/notifications/templates.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/utility/InheritedInfo.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/utility/navigation_drawer.dart';
import 'package:deca_app/screens/profile/templates.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:deca_app/screens/code/qr_screen.dart';
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

  //if the platfrom is IOS we will have to request for permissions
  void initState() {
    initNotifications();
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
      print(notification);
      scheduleLocalNotification(notification);
    }, onMessage: (notification) {
      print(notification);
      scheduleLocalNotification(notification);
    }, onResume: (notification) {
      scheduleLocalNotification(notification);
    });
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
        file.writeAsStringSync(json.encode([
        ])); //dummy writing
      }
    });
  }

  Future notificationOnSelect(String payload) {
    setState(() => _selectedIndex = 2);
  }

  void scheduleLocalNotification(Map notification) async {
    StateContainer.of(context).addToNotifications(notification);
    AndroidNotificationDetails androidSettings = AndroidNotificationDetails(
        "channel id", "channel NAME", "CHANNEL DESCRIPTION");
    IOSNotificationDetails iosSettings = IOSNotificationDetails();
    NotificationDetails platformSettings =
        NotificationDetails(androidSettings, iosSettings);
    //show the actual notifications
    await FlutterLocalNotificationsPlugin().show(
        0,
        notification['notification']['title'],
        notification['notification']['body'],
        platformSettings);
    //schedule a notification for future

    //not working right now
    if (true) {
      await FlutterLocalNotificationsPlugin().schedule(
          0,
          "Scheduled Notification",
          "Scheduling stuff",
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
      body: changeScreen(_selectedIndex),
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
                    onTap: () async => Navigator.push(
                        context,
                        NoTransition(
                            builder: (context) => new AdminScreen()))),
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
            onPressed: () async => Navigator.push(
                context,
                NoTransition(
                    builder: (context) => new AdminScreen()
                )
            )
        ),
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
            icon: Icon(StateContainer.of(context).hasSeenNotification
                ? Icons.notification_important
                : Icons.notifications_none),
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
