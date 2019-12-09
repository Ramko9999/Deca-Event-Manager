import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StateContainerState extends State<StateContainer> {
  /* Properties that will be persisted on the side of the Admin */
  String uid;
  Map eventMetadata;
  Map userData; //this is not the app user's UID, but the data of the person who is getting changed
  bool isCardTapped = false;
  String filterType;
  bool isManualEnter = false;
  String group; //this is the group that might be created or edited
  int counter = 0;
  bool isAdmin = false;

  /*Properties that will be persisted on the side of the user */
  List notifications = [];
  int notificationCounter =
      0; //used to show the number of notifications at the bottom
  bool isThereConnectionError = false;
  bool isThereAnExplicitConnectionError = false;
  bool isThereANetworkConnectionError = false;

  // You can (and probably will) have methods on your StateContainer
  // These methods are then used through our your app to
  // change state.
  // Using setState() here tells Flutter to repaint all the
  // Widgets in the app that rely on the state you've changed.

  //-----methods go here-----
  void setConnectionErrorStatus(bool e) {
    setState(() {
      isThereConnectionError = e;
    });
  }

  void setEventMetadata(Map newMetadata) {
    setState(() {
      eventMetadata = newMetadata;
    });
  }

  void setIsAdmin(bool newVal) {
    setState(() {
      isAdmin = newVal;
    });
  }

  void setIsManualEnter(bool value) {
    setState(() {
      isManualEnter = value;
    });
  }

  void setUserData(Map newUserData) {
    setState(() {
      userData = newUserData;
    });
  }

  void setUID(String _uid) {
    setState(() {
      uid = _uid;
    });
  }

  void setGroup(String g) {
    setState(() {
      group = g;
    });
  }

  //used to add to the notifications of the user
  void addToNotifications(Map notification) {
    setState(() {
      this.notifications.add(notification);
      this.notificationCounter += 1;
    });
  }

  void removeNotification(Map notification) {
    setState(() {
      this.notifications.remove(notification);
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
        addToEvents(userUniqueId, manualGP)
            .then((_) => syncGPWithEvents(userUniqueId)));
    //adds the current event in eventMetadata state to events field for the user that is parameterized
    //updates gp value to match events field in user
  }

  void syncGPWithEvents(String userUniqueId) {
    Firestore.instance
        .collection('Users')
        .document(userUniqueId)
        .get()
        .then((userData) {
      int totalGP = 0;
      Map eventsList = userData.data['events'];
      print(eventsList);

      for (var gp in eventsList.keys) {
        totalGP += eventsList[gp];
      }

      Firestore.instance
          .collection('Users')
          .document(userUniqueId)
          .updateData({'gold_points': totalGP});
    });
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
        if (eventName == eventMetadata['event_name']) {
          hasAttended = true;
          break;
        }

        if (!hasAttended) {
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
      }
    });
  }

  Future decrementAttendees(String eventName) async {
    //decrement the events
    Firestore.instance
        .collection('Events')
        .document(eventName)
        .updateData({'attendee_count': FieldValue.increment(-1)});
  }

  //adds the current event in eventMetadata state to events field for the user that is parameterized
  Future addToEvents(String userUniqueId, [int manualGP]) async {
    int pointVal = eventMetadata['gold_points'];
    DocumentSnapshot userDoc = await Firestore.instance
        .collection("Users")
        .document(userUniqueId)
        .get();
    Map finalEvents = userDoc.data['events'];
    print(finalEvents);

    if (finalEvents != null) {
      if (eventMetadata['enter_type'] == 'QE') {
        finalEvents[eventMetadata['event_name']] = pointVal;
      } else if (manualGP != null) {
        finalEvents[eventMetadata['event_name']] = manualGP;
      }
    } else {
      if (eventMetadata['enter_type'] == 'QE') {
        finalEvents[eventMetadata['event_name']] = pointVal;
      } else {
        finalEvents[eventMetadata['event_name']] = manualGP;
      }
    }
    await Firestore.instance
        .collection('Users')
        .document(userUniqueId)
        .updateData({'events': finalEvents});
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
  final bool isAdmin;
  final String filterType;
  final bool isManualEnter;

  StateContainer(
      {@required this.child,
      this.uid,
      this.isAdmin,
      this.eventMetadata,
      this.userData,
      this.isCardTapped,
      this.filterType,
      this.isManualEnter});

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
