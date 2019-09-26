import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
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
                          screenHeight / 40, screenWidth / 20,
                          screenHeight / 80),
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
                                          fontSize: 20 * screenWidth /
                                              pixelTwoWidth)),
                                  subtitle: Text(
                                    'Click to view attended events!',
                                    style: TextStyle(
                                        fontSize: 16 * screenWidth /
                                            pixelTwoWidth),
                                  ),
                                  onTap: () =>
                                      Navigator.push(
                                          context,
                                          NoTransition(
                                              builder: (
                                                  context) => new GPInfoScreen())),
                                  trailing: Text(
                                    _goldPoints.toString(),
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontSize: 20 * screenWidth /
                                            pixelTwoWidth,
                                        color: Color.fromARGB(
                                            255, 249, 166, 22)),
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
                                          fontSize: 20 * screenWidth /
                                              pixelTwoWidth)),
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
                                        fontSize: 20 * screenWidth /
                                            pixelTwoWidth,
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
                                leading: Icon(
                                    Icons.group, color: Colors.lightBlue),
                                title: Text('List of Committees',
                                    textAlign: TextAlign.left,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                        20 * screenWidth / pixelTwoWidth)),
                                subtitle: Text(
                                  'Click to view committees!',
                                  style: TextStyle(
                                      fontSize: 16 * screenWidth /
                                          pixelTwoWidth),
                                ),
                                onTap: () =>
                                    Navigator.push(
                                        context,
                                        NoTransition(
                                            builder: (
                                                context) => new CommitteeInfoScreen())),
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
}

class CommitteeInfoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CommitteeInfoScreenState();
  }
}

class CommitteeInfoScreenState extends State<CommitteeInfoScreen> {
  String _uid;
  List committeeList;

  ListView _buildEventList(context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: committeeList.length,
      // A callback that will return a widget.
      itemBuilder: (context, i) {
        String name = committeeList[i];
        return Card(
          child: ListTile(
            leading: Icon(Icons.group,
                color: Colors.blue),
            title: Text(name,
                textAlign: TextAlign.left,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * screenWidth / pixelTwoWidth)
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    _uid = container.uid;

    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Committees'),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
              stream: Firestore.instance
                  .collection('Users')
                  .where("uid", isEqualTo: Global.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasData) {
                  DocumentSnapshot userSnap = userSnapshot.data.documents[0];
                  List commList = userSnap.data['groups'];
                  committeeList = commList;
                  bool isEmpty = commList.isEmpty;
                  return Center(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      height: screenHeight * 0.7,
                      width: screenWidth * 0.9,
                      child:
                      (isEmpty) ?
                      Text(
                        "Not In Any Committees!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: Colors.black,
                          fontSize:
                          15 * screenWidth / pixelTwoWidth,
                        ),
                      ) :
                      _buildEventList(context),
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
              }
          )
        ],
      ),
    );
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
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;


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
                    fontSize: Sizer.getTextSize(sW, sH, 20))),
            subtitle: Text(event['event_type']),
            trailing: Text(eventList[i].gp.toString(),
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: Sizer.getTextSize(sW, sH, 20) ,
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

    if (userMetadata.isNotEmpty) {
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
          'Miscellaneous': [],
        };
        for (EventObject element in eventList) {
          try{
            assert(eventSortedList[element.eventType] != null);

          }
          catch(e){
            print(element.eventType);
          }

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
    _uid = Global.uid;
    filterType = container.filterType;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    return Scaffold(
      appBar: AppBar(
        title: Text('Events Attended'),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Container(
              alignment: Alignment.topCenter,
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
                          DocumentSnapshot userSnap = userSnapshot.data
                              .documents[0];
                          Map eventList = userSnap.data['events'] as Map;
                          bool isEmpty = eventList.isEmpty;
                          return Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              height: screenHeight * 0.7,
                              width: screenWidth * 0.9,
                              child:
                              (isEmpty) ?
                              Text(
                                "No Events Attended!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  color: Colors.black,
                                  fontSize:
                                  15 * screenWidth / pixelTwoWidth,
                                ),
                              ) :
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
