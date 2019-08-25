import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DynamicProfileUI extends StatelessWidget {
  String _uid;
  String _firstName;
  String _lastName;
  int _goldPoints;
  String _memberLevel;
  List _groups;

  DynamicProfileUI() {}

  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    _uid = container.uid;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
        //connecting to firebase and gathering user data
        stream: Firestore.instance
            .collection('Users')
            .where("uid", isEqualTo: _uid)
            .snapshots(),
        builder: (context, snapshot) {
          //if data has been updated
          if (snapshot.hasData) {
            //grab the data and populate the fields as such
            DocumentSnapshot userInfo = snapshot.data.documents[0];
            _firstName = userInfo.data['first_name'] as String;
            _lastName = userInfo.data['last_name'] as String;
            _goldPoints = userInfo.data['gold_points'];
            //setting memberLevel based on gold points
            if (_goldPoints < 75) {
              _memberLevel = "N/A";
            } else if (_goldPoints < 125) {
              _memberLevel = "Member";
            } else if (_goldPoints < 200) {
              _memberLevel = "Silver";
            } else {
              _memberLevel = "Gold";
            }

            _groups = userInfo.data['groups'];

            //setting the new UI
            return Center(
                child: Column(
              children: <Widget>[
                Container(
                  padding: new EdgeInsets.fromLTRB(20.0, 20.0, 30.0, 15.0),
                  width: double.infinity,
                  child: Text(
                    "Hello " + _firstName + '.',
                    textAlign: TextAlign.left,
                    style:
                        new TextStyle(fontSize: 36, fontFamily: 'Lato-Regular'),
                  ),
                ),
                Container(
                    height: screenHeight - 400,
                    width: screenWidth - 25,
                    child: ListView(
                      children: <Widget>[
                        Card(
                            child: ListTile(
                          leading: Icon(Icons.stars,
                              color: Color.fromARGB(255, 249, 166, 22)),
                          title: Text('Gold Points',
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          subtitle: Text('Click for more details!'),
                          onTap: () => Navigator.push(
                              context,
                              NoTransition(
                                  builder: (context) => new GPInfoScreen())),
                          trailing: Text(
                            _goldPoints.toString(),
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 249, 166, 22)),
                          ),
                        )),
                        Card(
                            child: ListTile(
                          leading: Icon(MdiIcons.accountBadge,
                              color: (_memberLevel == 'Member')
                                  ? Colors.blueAccent
                                  : (_memberLevel == 'Silver')
                                      ? Colors.blueGrey
                                      : (_memberLevel == 'Gold')
                                          ? Color.fromARGB(255, 249, 166, 22)
                                          : Colors.black),
                          title: Text('Member Status',
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          subtitle: (_memberLevel == 'N/A')
                              ? Text((75 - _goldPoints).toString() +
                                  ' GP until you\'re a member!')
                              : (_memberLevel == 'Member')
                                  ? Text((125 - _goldPoints).toString() +
                                      ' GP until you\'re a SILVER member!')
                                  : (_memberLevel == 'Silver')
                                      ? Text((200 - _goldPoints).toString() +
                                          ' GP until you\'re a GOLD member!')
                                      : null,
                          trailing: Text(
                            _memberLevel,
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 20,
                                color: (_memberLevel == 'Member')
                                    ? Colors.blueAccent
                                    : (_memberLevel == 'Silver')
                                        ? Colors.blueGrey
                                        : (_memberLevel == 'Gold')
                                            ? Color.fromARGB(255, 249, 166, 22)
                                            : Colors.black),
                          ),
                        ))
                      ],
                    )),
              ],
            ));
          } else {
            return Container(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Text(
                      "Connecting...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Lato",
                        color: Colors.grey,
                        fontSize: 32,
                      ),
                    ),
                    CircularProgressIndicator()
                  ],
                ));
          }
        });
  }
}

class GPInfoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GPInfoScreenState();
  }
}

class GPInfoScreenState extends State<GPInfoScreen> {
  String _uid;
  List<EventObject> eventList;
  String filterType;

  ListView _buildEventList(context, eventSnapshot, userSnapshot) {

    eventList = filter(eventSnapshot, userSnapshot);

    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: eventList.length,
      // A callback that will return a widget.
      itemBuilder: (context, i) {
        DocumentSnapshot event = eventList[i].info;
        int gold_points = event['gold_points']; // change
        return Card(
          child: ListTile(
            title: Text(event['event_name'],
                textAlign: TextAlign.left,
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            subtitle: Text(event['event_type']),
            trailing: Text(gold_points.toString(),
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 249, 166, 22))),
          ),
        );
      },
    );
  }

  List<EventObject> filter(eventSnapshot, userSnapshot) {
    List<EventObject> eventList = [];
    if (!userSnapshot['events'].isEmpty()) {
      for (DocumentSnapshot event in eventSnapshot) {
        for (String userEvent in userSnapshot['events'].keys) {
          if (event['event_name'] == userEvent) {
            eventList.add(new EventObject(event));
          }
        }
      }
      eventList.sort();
    }
    return eventList;
  }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    _uid = container.uid;
    filterType = container.filterType;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('GP Information'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
          )
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('Events').snapshots(),
          builder: (context, eventSnapshot) {
            return StreamBuilder(
                stream: Firestore.instance
                    .collection('Users')
                    .where("uid", isEqualTo: _uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  return Container(
                    height: screenHeight - 75,
                    width: screenWidth - 25,
                    child: _buildEventList(context, eventSnapshot, userSnapshot),
                  );
                });
          }),
    );
  }
}

class EventObject implements Comparable<EventObject> {
  final DocumentSnapshot info;
  DateTime eventDate;

  EventObject(this.info) {
    eventDate = DateTime.parse(info['event_date']);
  }

  int compareTo(EventObject other) {
    int order = eventDate.compareTo(other.eventDate);
    return order;
  }
}
