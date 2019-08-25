import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StateContainerState extends State<StateContainer> {
  // Whichever properties you wanna pass around your app as state
  String uid;
  Map eventMetadata;
  Map userData;
  bool isCardTapped = false;
  String filterType;

  // You can (and probably will) have methods on your StateContainer
  // These methods are then used through our your app to
  // change state.
  // Using setState() here tells Flutter to repaint all the
  // Widgets in the app that rely on the state you've changed.

  //-----methods go here-----
  void setEventMetadata(Map newMetadata)
  {
    setState(() {
      eventMetadata = newMetadata;
    });
  }
  void setUserData(Map newUserData)
  {
    setState(() {
      userData = newUserData;
    });
  }
  void setUID(String _uid)
  {
    setState(() {
      uid = _uid;
    });
  }

  void setFilterType(String newFilterType)
  {
    setState(() {
      filterType = newFilterType;
    });
  }

  void updateGP(String userUniqueId, [int manualGP])
  {
    //adds the current event in eventMetadata state to events field for the user that is parameterized
    addToEvents(userUniqueId, manualGP);
    //updates gp value to match events field in user
    incrementAttendees();
    print('hello');
    Firestore.instance
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
    });
  }

  void incrementAttendees()
  {
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

  //adds the current event in eventMetadata state to events field for the user that is parameterized
  void addToEvents(String userUniqueId, [int manualGP])
  {
    int pointVal = eventMetadata['gold_points'];
    Map finalEvents = userData['events'];

    if (finalEvents != null) {
      if(eventMetadata['enter_type'] == 'QE')
      {
        finalEvents.addAll({eventMetadata['event_name']: pointVal});
      }
      else if(manualGP != null)
      {
        finalEvents.addAll({eventMetadata['event_name']: manualGP});
      }
    }
    else {
      finalEvents = {eventMetadata['event_name']: pointVal};
    }
      Firestore.instance
          .collection('Users')
          .document(userUniqueId)
          .updateData({'events': finalEvents});

  }

  List<DocumentSnapshot> setIsCardTapped(bool newVal)
  {
    if(!newVal)
      {
        Firestore.instance.collection("Users").getDocuments().then((documents) {
          setState(() {
            isCardTapped = false;
            return documents.documents;
          });
        });
      }
    else
      {
        setState(() {
          isCardTapped = true;
        });
      }
    return null;
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

  StateContainer({
    @required this.child,
    this.uid,
    this.eventMetadata,
    this.userData,
    this.isCardTapped,
    this.filterType,
  });

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
    as _InheritedStateContainer).data;
  }

  @override
  StateContainerState createState() => new StateContainerState();
}