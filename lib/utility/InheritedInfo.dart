import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StateContainerState extends State<StateContainer> {
  // Whichever properties you wanna pass around your app as state
  String uid;
  Map eventMetadata;
  Map userData; //this is not the app user's UID, but the data of the person who is getting changed
  bool isCardTapped = false;
  String filterType;
  List notifications = [];
  String group; //this is the group that might be created or edited
  bool hasSeenNotification =
      false; //supposed to be use to change the notification icon when a notification comes up NOT WORKING!
  bool isManualEnter = false;

  // You can (and probably will) have methods on your StateContainer
  // These methods are then used through our your app to
  // change state.
  // Using setState() here tells Flutter to repaint all the
  // Widgets in the app that rely on the state you've changed.

  //-----methods go here-----
  void setEventMetadata(Map newMetadata) {
    setState(() {
      eventMetadata = newMetadata;
    });
  }

  void setIsManualEnter(bool value)
  {
    setState(() {
      isManualEnter = value;
    });
  }

  void setUserData(Map newUserData)
  {
    setState(() {
      userData = newUserData;
    });
  }

  void setUID(String _uid) {
    setState(() {
      uid = _uid;
    });
  }

  void hasSawNotification() {
    setState(() {
      hasSeenNotification = true;
    });
  }

  void setGroup(String g){
    setState((){
      group = g;
    });
  }

  //used to add to the notifications of the user
  void addToNotifications(Map notification) {
    setState(() {
      this.notifications.add(notification);
      hasSeenNotification = true;
    });
  }

  void initNotifications(List notifications) {
    setState(() {
      this.notifications = notifications;
    });
  }

  void setFilterType(String newFilterType) {
    setState(() {
      filterType = newFilterType;
    });
  }

  void updateGP(String userUniqueId, [int manualGP]) {
    incrementAttendees(userUniqueId).then((_) =>
        addToEvents(userUniqueId, manualGP).then((_) => Firestore.instance
                .collection('Users')
                .document(userUniqueId)
                .get()
                .then((userData) {
              int totalGP = 0;
              Map eventsList = userData['events'];
              for (var gp in eventsList.keys) {
                totalGP += eventsList[gp];
              }
              print(totalGP);
              Firestore.instance
                  .collection('Users')
                  .document(userUniqueId)
                  .updateData({'gold_points': totalGP});
            })));
    //adds the current event in eventMetadata state to events field for the user that is parameterized
    //updates gp value to match events field in user
  }

  Future incrementAttendees(String _uid) async {
    bool hasAttended = false;
    Map userSnapshot;
    await Firestore.instance
        .collection('Users')
        .document(_uid)
        .get()
        .then((data) {
      userSnapshot = data.data;
    }).whenComplete(() {
      for (String eventName in userSnapshot['events'].keys) {
        print(eventName);
        print("Line 75 Inherited Info: $userSnapshot");
        for(String eventName in userSnapshot['events'].keys)
        {
          print("Event Name: $eventName");
          print(eventMetadata['event_name']);
          if (eventName == eventMetadata['event_name']) {
            hasAttended = true;
            break;
          }
        }
      print(hasAttended);
      if(!hasAttended)
      {
        print('Incrementing attendees');
        int scanCount = eventMetadata['attendee_count'];
        //update the events
        Firestore.instance
            .collection('Events')
            .document(eventMetadata['event_name'])
            .updateData({'attendee_count': FieldValue.increment(1)});
        setState(() {
          scanCount += 1;
        });
        }
      }});
  }

  //adds the current event in eventMetadata state to events field for the user that is parameterized
  Future addToEvents(String userUniqueId, [int manualGP]) async {
    print("adding events");
    int pointVal = eventMetadata['gold_points'];
    Map finalEvents = userData['events'];

    if (finalEvents != null) {
      if (eventMetadata['enter_type'] == 'QE') {
        finalEvents.addAll({eventMetadata['event_name']: pointVal});
      } else if (manualGP != null) {
        finalEvents.addAll({eventMetadata['event_name']: manualGP});
      }
    } else {
      finalEvents = {eventMetadata['event_name']: pointVal};
    }
    await Firestore.instance
        .collection('Users')
        .document(userUniqueId)
        .updateData({'events': finalEvents});
    print('finished adding to events');
  }

  void setIsCardTapped(bool newVal) {
    setState(() => isCardTapped = newVal);
  }

  // Simple build method that just passes this state through
  // your InheritedWidget
  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  // Data is your entire state. In our case just 'User'
  final StateContainerState data;

  // You must pass through a child and your state.
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}

class StateContainer extends StatefulWidget {
  // You must pass through a child.
  final Widget child;
  final String uid;
  final Map eventMetadata;
  final Map userData;
  final bool isCardTapped;
  final String filterType;
  final bool isManualEnter;

  StateContainer({
    @required this.child,
    this.uid,
    this.eventMetadata,
    this.userData,
    this.isCardTapped,
    this.filterType,
    this.isManualEnter
  });

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  StateContainerState createState() => new StateContainerState();
}
