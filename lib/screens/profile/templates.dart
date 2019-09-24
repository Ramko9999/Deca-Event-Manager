import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/global.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DynamicProfileUI extends StatelessWidget {
  String _uid;
  String _firstName;
  int _goldPoints;
  String _memberLevel;

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    return StreamBuilder(
        //connecting to firebase and gathering user data
        stream: Firestore.instance
            .collection('Users')
            .where("uid", isEqualTo: Global.uid)
            .snapshots(),
        builder: (context, snapshot) {
          //if data has been updated
          if (snapshot.hasData) {
            //grab the data and populate the fields as such
            DocumentSnapshot userInfo = snapshot.data.documents[0];
            _firstName = userInfo.data['first_name'] as String;
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

            //setting the new UI
            return Center(
                child: Column(
              children: <Widget>[
                Container(
                  padding: new EdgeInsets.fromLTRB(screenWidth / 20,
                      screenHeight / 40, screenWidth / 20, screenHeight / 80),
                  width: double.infinity,
                  child: Text(
                    "Hello " + _firstName + '.',
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                        fontSize: 36 * screenWidth / pixelTwoWidth,
                        fontFamily: 'Lato-Regular'),
                  ),
                ),
                Container(
                    height: screenHeight * 0.59,
                    width: screenWidth * 0.95,
                    child: ListView(
                      children: <Widget>[
                        Card(
                            child: ListTile(
                          leading: Icon(Icons.stars,
                              color: Color.fromARGB(255, 249, 166, 22)),
                          title: Text('Gold Points',
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20 * screenWidth / pixelTwoWidth)),
                          subtitle: Text(
                            'Click to view attended events!',
                            style: TextStyle(
                                fontSize: 16 * screenWidth / pixelTwoWidth),
                          ),
                          onTap: () => Navigator.push(
                              context,
                              NoTransition(
                                  builder: (context) => new GPInfoScreen())),
                          trailing: Text(
                            _goldPoints.toString(),
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 20 * screenWidth / pixelTwoWidth,
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20 * screenWidth / pixelTwoWidth)),
                          subtitle: (_memberLevel == 'N/A')
                              ? Text(
                                  (75 - _goldPoints).toString() +
                                      ' GP until you\'re a member!',
                                  style: TextStyle(
                                      fontSize:
                                          16 * screenWidth / pixelTwoWidth),
                                )
                              : (_memberLevel == 'Member')
                                  ? Text(
                                      (125 - _goldPoints).toString() +
                                          ' GP until you\'re a SILVER member!',
                                      style: TextStyle(
                                          fontSize:
                                              16 * screenWidth / pixelTwoWidth),
                                    )
                                  : (_memberLevel == 'Silver')
                                      ? Text(
                                          (200 - _goldPoints).toString() +
                                              ' GP until you\'re a GOLD member!',
                                          style: TextStyle(
                                              fontSize: 16 *
                                                  screenWidth /
                                                  pixelTwoWidth),
                                        )
                                      : null,
                          trailing: Text(
                            _memberLevel,
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 20 * screenWidth / pixelTwoWidth,
                                color: (_memberLevel == 'Member')
                                    ? Colors.blueAccent
                                    : (_memberLevel == 'Silver')
                                        ? Colors.blueGrey
                                        : (_memberLevel == 'Gold')
                                            ? Color.fromARGB(255, 249, 166, 22)
                                            : Colors.black),
                          ),
                        )),
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.group, color: Colors.lightBlue),
                            title: Text('List of Committees',
                                textAlign: TextAlign.left,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        20 * screenWidth / pixelTwoWidth)),
                            subtitle: Column(
                                children:
                                    createColumn(userInfo.data['groups'])),
                          ),
                        )
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
                        color: Colors.grey,
                        fontSize: 32 * screenWidth / pixelTwoWidth,
                      ),
                    ),
                    CircularProgressIndicator()
                  ],
                ));
          }
        });
  }

  List<Widget> createColumn(List data) {
    List<Widget> groups = new List();
    for (String g in data) {
      groups.add(Text(
        g,
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.black),
      ));
    }
    return groups;
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    eventList = filter(eventSnapshot, userSnapshot);

    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: eventList.length,
      // A callback that will return a widget.
      itemBuilder: (context, i) {
        DocumentSnapshot event = eventList[i].info;
        return Card(
          color: eventList[i].eventColor,
          child: ListTile(
            title: Text(event['event_name'],
                textAlign: TextAlign.left,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * screenWidth / pixelTwoWidth)),
            subtitle: Text(event['event_type']),
            trailing: Text(eventList[i].gp.toString(),
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 20 * screenWidth / pixelTwoWidth,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  List<EventObject> filter(eventSnapshot, DocumentSnapshot userSnapshot) {
    List<EventObject> eventList = [];
    Map userMetadata = userSnapshot.data as Map;

    if (!userMetadata.isEmpty) {
      for (DocumentSnapshot event in eventSnapshot) {
        for (String userEvent in userMetadata['events'].keys) {
          if (event['event_name'] == userEvent) {
            if (event['enter_type'] == "ME") {
              eventList.add(
                  new EventObject(event, userMetadata['events'][userEvent]));
            } else {
              eventList.add(new EventObject(event));
            }
          }
        }
      }
      eventList.sort();
      if (filterType == 'eventType') {
        Map<String, List<EventObject>> eventSortedList = {
          'Meeting': [],
          'Social': [],
          'Event': [],
          'Competition': [],
          'Committee': [],
          'Cookie Store': [],
          'Miscellaneous': []
        };
        for (EventObject element in eventList) {
          eventSortedList[element.eventType].add(element);
        }
        List<EventObject> finalEventSortedList = [];
        for (List<EventObject> value in eventSortedList.values) {
          if (value != []) {
            finalEventSortedList.addAll(value);
          }
        }
        return finalEventSortedList;
      }
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
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Events Attended'),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: ActionChip(
                  avatar: (filterType == null)
                      ? Icon(Icons.event)
                      : (filterType == 'date')
                          ? Icon(Icons.event)
                          : Icon(Icons.access_time),
                  label: (filterType == null)
                      ? Text('Filter by Event Type')
                      : (filterType == 'date')
                          ? Text('Filter by Event Type')
                          : Text('Filter Chronologically'),
                  onPressed: () {
                    if (filterType == null || filterType == 'date') {
                      container.setFilterType('eventType');
                    } else {
                      container.setFilterType('date');
                    }
                  }),
            ),
          ),
          StreamBuilder(
              stream: Firestore.instance.collection('Events').snapshots(),
              builder: (context, eventSnapshot) {
                if (eventSnapshot.hasData) {
                  List<DocumentSnapshot> eventSnap =
                      eventSnapshot.data.documents;
                  return StreamBuilder(
                      stream: Firestore.instance
                          .collection('Users')
                          .where("uid", isEqualTo: _uid)
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.hasData) {
                          DocumentSnapshot userSnap =
                              userSnapshot.data.documents[0];
                          return Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              height: screenHeight * 0.8,
                              width: screenWidth * 0.9,
                              child:
                                  _buildEventList(context, eventSnap, userSnap),
                            ),
                          );
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
                                      fontSize:
                                          32 * screenWidth / pixelTwoWidth,
                                    ),
                                  ),
                                  CircularProgressIndicator()
                                ],
                              ));
                        }
                      });
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
                              fontSize: 32 * screenWidth / pixelTwoWidth,
                            ),
                          ),
                          CircularProgressIndicator()
                        ],
                      ));
                }
              }),
        ],
      ),
    );
  }
}

class EventObject implements Comparable<EventObject> {
  final DocumentSnapshot info;
  DateTime eventDate;
  Color eventColor;
  int gp;
  String eventType;

  final Map<String, Color> eventColors = {
    'Meeting': Colors.blueAccent,
    'Social': Colors.orange,
    'Event': Colors.tealAccent,
    'Competition': Colors.lightGreenAccent,
    'Committee': Colors.redAccent,
    'Cookie Store': Colors.yellowAccent,
    'Miscellaneous': Colors.grey
  };

  EventObject(this.info, [this.gp]) {
    eventType = info['event_type'];
    eventDate = DateTime.parse(info['event_date']);
    eventColor = eventColors[info['event_type']];
    if (this.gp == null) {
      this.gp = info['gold_points'];
    }
  }

  int compareTo(EventObject other) {
    int order = eventDate.compareTo(other.eventDate);
    return order;
  }
}
