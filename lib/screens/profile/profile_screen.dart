import 'package:deca_app/screens/admin/admin_main.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/utility/navigation_drawer.dart';
import 'package:deca_app/screens/profile/templates.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:deca_app/screens/code/qr_screen.dart';

class ProfileScreen extends StatefulWidget {
  String _uid;

  ProfileScreen(uid) {
    this._uid = uid;
  }

  @override
  State<ProfileScreen> createState() {
    return ProfileScreenState(_uid);
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  String _uid;
  int _selectedIndex = 0;

  ProfileScreenState(String uid) {
    this._uid = uid;
  }

  Widget changeScreen(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return DynamicProfileUI(_uid);
      case 1:
        return QrScreen(_uid);
        break;
      default:
        return DynamicProfileUI(_uid);
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
                        MaterialPageRoute(
                            builder: (context) => new AdminScreen(_uid)))),
              ],
            ),
          )),
      appBar: new AppBar(
        title: (_selectedIndex == 0)
            ? Text("Profile")
            : (_selectedIndex == 1)
                ? Text("QR Code for Check-In")
                : (_selectedIndex == 2) ? Text("Notifications") : Text("Chats"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new SettingScreen(_uid))),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.qrcode),
            title: Text('Check-In'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            title: Text('Notifications'),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text('Chats')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
