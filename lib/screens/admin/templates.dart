import 'package:deca_app/screens/admin/finder.dart';
import 'package:deca_app/screens/admin/notification_sender.dart';
import 'package:deca_app/screens/profile/templates.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:deca_app/utility/transition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'events.dart';
import 'groups.dart';

class AdminScreenUI extends StatefulWidget {
  AdminScreenUI();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return (_AdminUIState());
  }
}

class _AdminUIState extends State<AdminScreenUI> {
  _AdminUIState();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: new AppBar(
          title: Text("Admin Functions"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Card(
                    child: ListTile(
                        leading: Icon(Icons.create),
                        title: Text('Create an Event'),
                        onTap: () => Navigator.push(
                            context,
                            NoTransition(
                                builder: (context) => new CreateEventUI())))),
                Card(
                    child: ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text('Edit Events'),
                  onTap: () => Navigator.push(context,
                      NoTransition(builder: (context) => new EditEventUI())),
                )),
                Card(
                    child: ListTile(
                  leading: Icon(Icons.group_add),
                  title: Text('Create a Group'),
                  onTap: () => Navigator.push(context,
                      NoTransition(builder: (context) => CreateGroupUI())),
                )),
                Card(
                    child: ListTile(
                  leading: Icon(Icons.group),
                  title: Text('Edit a Group'),
                  onTap: () => Navigator.push(context,
                      NoTransition(builder: (context) => EditGroupUI())),
                )),
                Card(
                    child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Edit Members'),
                  onTap: () => Navigator.push(context,
                      NoTransition(builder: (context) => EditMemberUI())),
                )),
                Card(
                    child: ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Push Notifications'),
                  onTap: () => Navigator.push(
                      context, NoTransition(builder: (context) => Sender())),
                ))
              ],
            ),
            if (StateContainer.of(context).isThereConnectionError)
              OfflineNotifier()
          ],
        ));
  }
}

class EditMemberUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditMemberUIState();
  }
}

class EditMemberUIState extends State<EditMemberUI> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: new AppBar(
        title: Text("Edit a Member"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {Navigator.of(context).pop()}),
      ),
      body: Center(child: Finder((BuildContext context,
          StateContainerState stateContainer, Map userInfo) {
        stateContainer.setUserData(userInfo);
        Navigator.push(context,
            NoTransition(builder: (context) => new EditMemberProfileUI()));
      })),
    );
  }
}

class EditMemberProfileUI extends StatelessWidget {
  String _uid;
  String _firstName;
  int _goldPoints;
  String _memberLevel;

  Widget build(BuildContext context) {
    final infoContainer = StateContainer.of(context);
    _uid = infoContainer.userData['uid'];
    _firstName = infoContainer.userData['first_name'];

    return Scaffold(
        appBar: new AppBar(
          title: Text("$_firstName's Profile"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {Navigator.pop(context)}),
        ),
        body: DynamicProfileUI(
          _uid,
          editable: true,
        ));
  }
}
