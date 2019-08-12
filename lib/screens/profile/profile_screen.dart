import 'package:flutter/material.dart';
import 'package:flutter_first_app/screens/settings/setting_screen.dart';
import 'package:flutter_first_app/utility/navigation_drawer.dart';
import 'package:flutter_first_app/screens/profile/templates.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


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
    print(this._uid);
  }

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: new DynamicProfileUI(_uid),
      drawer: new NavigationDrawer(_uid),
      appBar: new AppBar(
        title: Text("View Profile"),
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
      bottomNavigationBar: BottomNavigationBar(items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.qrcode),
          title: Text('Check-In'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          title: Text('Notifications'),
        ),
        BottomNavigationBarItem(
        icon: Icon(Icons.chat),
        title: Text('Chats')
        ),
      ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,),
    );
  }
}
