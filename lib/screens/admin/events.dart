import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/admin/scanner.dart';
import 'package:deca_app/screens/admin/views.dart';
import 'package:deca_app/screens/db/databasemanager.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:deca_app/utility/transition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import 'finderscreen.dart';

//used for creating an event
class CreateEventUI extends StatefulWidget {
  CreateEventUI();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CreateEventUIState();
  }
}

class _CreateEventUIState extends State<CreateEventUI> {
  String dropdownValue;
  bool _isManualEnter = false;
  bool _isQuickEnter = false;
  String eventDateText;
  bool _isTryingToCreateEvent = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //final values that are entered into firestore
  String _eventDate;
  TextEditingController _eventName = new TextEditingController();
  String _eventType;
  String _enterType;
  TextEditingController _goldPoints = new TextEditingController();

  Map eventMetadata;

  _CreateEventUIState();

  //execute the event creation
  void executeEventCreation(BuildContext context) async {
    final container = StateContainer.of(context);

    //creating a new event in Firestore
    if (_isManualEnter) {
      eventMetadata = {
        "event_name": _eventName.text,
        "event_date": _eventDate,
        "event_type": _eventType,
        "enter_type": _enterType,
        "attendee_count": 0,
        "attendees": [],
      } as Map;
      
      await Firestore.instance
          .collection("Events")
          .document(_eventName.text)
          .setData(eventMetadata);

    } else {
      eventMetadata = {
        "event_name": _eventName.text,
        "event_date": _eventDate,
        "event_type": _eventType,
        "enter_type": _enterType,
        'gold_points': int.parse(_goldPoints.text),
        "attendees": [],
        "attendee_count": 0,
      } as Map;
      
      await Firestore.instance
          .collection("Events")
          .document(_eventName.text)
          .setData(eventMetadata);
    }

    //append to aggregator
    await DataBaseManagement.eventAggregator.updateData({'event_list': FieldValue.arrayUnion([_eventName.text])});

    setState(() => _isTryingToCreateEvent = false);
    container.setEventMetadata(eventMetadata);

    Navigator.of(context).pop();
    if (eventMetadata['enter_type'] == 'ME') {
      Navigator.of(context)
          .push(NoTransition(builder: (context) => FinderScreen()));
    } else {
      Navigator.of(context).push(NoTransition(builder: (context) => Scanner()));
    }
    //clearAll();
  }

  void clearAll() {
    setState(() {
      _eventName.clear();
      eventDateText = null;
      dropdownValue = null;
      _isManualEnter = false;
      _isQuickEnter = false;
      _goldPoints.clear();
    });
  }

  bool validateForm(BuildContext context) {
    String errorMessage;

    if (_eventName.text == '') {
      errorMessage = 'Event Name is Empty';
    } else if (_eventDate == null) {
      errorMessage = 'Missing Date of Event';
    } else if (dropdownValue == null) {
      errorMessage = 'Missing Event Type';
    } else if (!(_isManualEnter || _isQuickEnter)) {
      errorMessage = 'Missing Enter Type';
    } else if (_isQuickEnter && _goldPoints.text == '') {
      errorMessage = 'Missing Gold Points';
    } else {
      _eventType = dropdownValue;
      _enterType = _isManualEnter ? 'ME' : 'QE';
      return true;
    }
    SnackBar snackBar = SnackBar(
      content: Text(errorMessage,
          textAlign: TextAlign.center,
          style: new TextStyle(
              fontFamily: 'Lato',
              fontSize: Sizer.getTextSize(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.width, 20),
              fontWeight: FontWeight.bold)),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    return false;
  }

  void tryToCreateEvent(BuildContext context) async {
    setState(() => _isTryingToCreateEvent = true);
    if (validateForm(context)) {
      executeEventCreation(context);
    } else {
      setState(() => _isTryingToCreateEvent = false);
    }
  }

  void updateButtons(String state) {
    if (state == 'Manual Enter') {
      setState(() {
        _isManualEnter = true;
        _isQuickEnter = !_isManualEnter;
      });
    } else {
      setState(() {
        _isQuickEnter = true;
        _isManualEnter = !_isQuickEnter;
      });
    }
  }

  String updateDateButton() {
    if (eventDateText == null) {
      setState(() {
        eventDateText = 'Choose Event Date';
      });
    }
    return eventDateText;
  }

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text("Create an Event"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {Navigator.pop(context)}),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: new EdgeInsets.only(
                            top: sH * 0.03, bottom: sH * 0.03),
                        width: sW * 0.9,
                        child: TextFormField(
                            controller: _eventName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: Sizer.getTextSize(sW, sH, 18)),
                            decoration: new InputDecoration(
                              labelText: "Event Name",
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                borderSide: new BorderSide(color: Colors.blue),
                              ),
                            ))),
                    Container(
                      padding: new EdgeInsets.only(bottom: sH * 0.03),
                      width: sW * 0.9,
                      height: sH * 0.12,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              flex: 7,
                              child: Container(
                                height: sH * 0.10,
                                child: RaisedButton(
                                  onPressed: () => setState(
                                      () => this.updateButtons('Quick Enter')),
                                  child: Text(
                                    "Quick Enter",
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontSize: Sizer.getTextSize(sW, sH, 15),
                                        fontFamily: "Lato"),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color:
                                      _isQuickEnter ? Colors.blue : Colors.grey,
                                  textColor: Colors.white,
                                ),
                              )),
                          Spacer(flex: 1),
                          Expanded(
                              flex: 7,
                              child: Container(
                                height: sH * 0.10,
                                child: RaisedButton(
                                  onPressed: () => setState(
                                      () => this.updateButtons('Manual Enter')),
                                  child: Text("Manual Enter",
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(
                                          fontSize:
                                              Sizer.getTextSize(sW, sH, 15),
                                          fontFamily: "Lato")),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: _isManualEnter
                                      ? Colors.blue
                                      : Colors.grey,
                                  textColor: Colors.white,
                                ),
                              ))
                        ],
                      ),
                    ),
                    if (_isQuickEnter)
                      Container(
                          padding: new EdgeInsets.only(bottom: sH * 0.03),
                          width: sW * 0.3,
                          child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _goldPoints,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: Sizer.getTextSize(sW, sH, 14)),
                              decoration: new InputDecoration(
                                labelText: "Gold Points",
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  borderSide:
                                      new BorderSide(color: Colors.blue),
                                ),
                              ))),
                    Container(
                        padding: new EdgeInsets.only(bottom: sH * 0.03),
                        width: sW * 0.9,
                        height: sH * 0.12,
                        child: RaisedButton(
                          child: Text(
                            (dropdownValue == null)
                                ? "Choose Event Type"
                                : dropdownValue,
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: Sizer.getTextSize(sW, sH, 17),
                                fontFamily: 'Lato'),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return CupertinoActionSheet(
                                    title: Text('Choose Event Type'),
                                    actions: <Widget>[
                                      CupertinoActionSheetAction(
                                        child: Text('Meeting'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Meeting';
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Social'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Social';
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Event'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Event';
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Competition'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Competition';
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Committee'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Committee';
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Cookie Store'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Cookie Store';
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Miscellaneous'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Miscellaneous';
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                        )),
                    Container(
                        padding: new EdgeInsets.only(bottom: sH * 0.03),
                        width: sW * 0.9,
                        height: sH * 0.12,
                        child: new RaisedButton(
                          child: Text(updateDateButton(),
                              style: new TextStyle(
                                  fontSize: Sizer.getTextSize(sW, sH, 17),
                                  fontFamily: 'Lato')),
                          textColor: Colors.white,
                          color: Colors.blue,
                          onPressed: () {
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(2019, 1, 1),
                                onConfirm: (date) {
                              setState(() {
                                eventDateText =
                                    new DateFormat('EEEE, MMMM d, y')
                                        .format(date)
                                        .toString();
                                _eventDate = new DateFormat('yyyy-MM-dd')
                                    .format(date)
                                    .toString();
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        )),
                    Container(
                        width: sW * 0.45,
                        height: sH * 0.08,
                        child: new RaisedButton(
                          child: Text('Create',
                              style: new TextStyle(
                                  fontSize: Sizer.getTextSize(sW, sH, 17),
                                  fontFamily: 'Lato')),
                          textColor: Colors.white,
                          color: Color.fromRGBO(46, 204, 113, 1),
                          onPressed: () {
                            tryToCreateEvent(context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        )),
                  ],
                ),
              ),
            ),
            if (_isTryingToCreateEvent)
              Container(
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
            if (StateContainer.of(context).isThereConnectionError)
              ConnectionError()
          ],
        ));
  }
}

//a class used to edit Previous events as well as delete previous events

class EditEventUI extends StatefulWidget {
  EditEventUI();

  State<EditEventUI> createState() {
    return _EditEventUIState();
  }
}

class _EditEventUIState extends State<EditEventUI> {
  _EditEventUIState();

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //used to show the snack bar

  Widget _buildEventList(context, snapshot) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;


    List events = snapshot.data['event_list'];

    if(events.length == 0){
      return Text("There are no current events");
    }

    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: events.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
       String event = events[int];

        return Dismissible(
          key: UniqueKey(),

          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Card(
            child: ListTile(
              title: Text(event,
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Sizer.getTextSize(sW, sH, 20))),
              onTap: () async {

                //fetch the actual event

                DocumentSnapshot eventData = await Firestore.instance.collection("Events").document(event).get();
                
                //set the eventMetadata to be have the Map of the event that will be edited
                final container = StateContainer.of(context);
                container.setEventMetadata(eventData.data);

                /* If the event is a manual enter event then there will be no scanner */
                if (eventData.data['enter_type'] == 'ME') {
                  Navigator.of(context)
                      .push(NoTransition(builder: (context) => FinderScreen()));
                } else {
                  Navigator.of(context)
                      .push(NoTransition(builder: (context) => Scanner()));
                }
              },

              onLongPress: () async{

                //fetch the actual event

                DocumentSnapshot eventData = await Firestore.instance.collection("Events").document(event).get();
                
                //set the eventMetadata to be have the Map of the event that will be edited
                final container = StateContainer.of(context);
                container.setEventMetadata(eventData.data);

                Navigator.of(context).push(NoTransition(builder: (context)=> EventView(eventData['event_name'],  eventData)));

              },
            ),
          ),

          onDismissed: (direction) async {
            /*grab all the users who have been to this event, so that we can remove this event
              and the gold points associated with this event in their map
            */

            //batches allow for multiple writes as a single operation
            WriteBatch batch = Firestore.instance.batch();

            QuerySnapshot userDocs =
                await Firestore.instance.collection("Events").getDocuments();

            //iterate through the users and remove instance of the event
            for (DocumentSnapshot userDocument in userDocs.documents) {
              Map eventData = userDocument['events'];

              //remove the event name key as well the pair in the map
              eventData.remove(event);

              //recompute the gold points
              num goldPoints = 0;

              eventData.forEach((k, v) {
                goldPoints += v;
              });

              /*update the whole user document with the deletion of the event as well the
              recomputation of gold points
              */

              Map documentData = userDocument.data;
              documentData['events'] = eventData;
              documentData['gold_points'] = goldPoints;

              batch.setData(userDocument.reference, documentData);
            }

            //all the operations done to the user documents are done in one move
            batch.commit().then((_) {
              //delete the actual document containing the event once all the batch commits are deleted

              Firestore.instance.collection("Events").document(event).delete().then((_) async {

               await DataBaseManagement.eventAggregator.updateData({"event_list": FieldValue.arrayRemove([event])});

                //display a snackbar to show the user the event is deleted
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    "The event has been deleted",
                    style: TextStyle(fontFamily: 'Lato', color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ));
              });
            });
          },

          // a way to guarantee that the user truly wants to delete the group
          confirmDismiss: (direction) {
            return showDialog(
                context: context,
                builder: (context) {
                  return Platform.isAndroid
                      ? AlertDialog(
                          content: Text(
                              "Everyone who has been to this event will lose their gold points for this event"),
                          title: Text("Are you sure?"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                            FlatButton(
                              child: Text("Don't Delete"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        )
                      : CupertinoAlertDialog(
                          content: Text(
                              "Everyone who has been to this event will lose their gold points for this event"),
                          title: Text("Are you sure?"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                            FlatButton(
                              child: Text("Don't Delete"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text("Edit an Event"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {Navigator.pop(context)}),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: DataBaseManagement.eventAggregator.get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Center(
                        child: Container(
                          height: screenHeight * 0.99,
                          width: screenWidth,
                          child: _buildEventList(context, snapshot),
                        ),
                      );
                    } else {
                      return Text("Loading...");
                    }
                  },
                ),
              ],
            ),
          ),
          if (StateContainer.of(context).isThereConnectionError)
            OfflineNotifier()
        ],
      ),
    );
  }
}

//event informaiton

class EventInfoUI extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  EventInfoUI({Key key, this.scaffoldKey}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventInfoUIState();
  }
}

class _EventInfoUIState extends State<EventInfoUI> {
  Map eventMetadata;
  int scanCount;
  bool isEditing = false;

  TextEditingController pointController = new TextEditingController();

  void executeEditGP() async {}

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double pixelTwoWidth = 411.42857142857144;
    final container = StateContainer.of(context);
    eventMetadata = container.eventMetadata;
    scanCount = eventMetadata['attendee_count'];

    // TODO: implement build
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Events')
          .document(eventMetadata['event_name']).snapshots()
          ,
      builder: (context, eventSnapshot) {
        
        if (eventSnapshot.hasData) {
          
          DocumentSnapshot eventSnap = eventSnapshot.data;
          eventMetadata = eventSnap.data;

          return Container(
            width: screenWidth * .9,
            height: screenHeight * 0.50,
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.white),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Text("Event Info",
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: Sizer.getTextSize(
                                  screenWidth, screenHeight, 28)))),
                  Container(
                    width: screenWidth * .8,
                    height: screenHeight * .4,
                    child: ListView(
                      children: <Widget>[
                        if (eventMetadata['enter_type'] == 'QE')
                          Card(
                              child: ListTile(
                            leading: Icon(Icons.stars,
                                color: Color.fromARGB(255, 249, 166, 22)),
                            title: Text('Gold Points',
                                textAlign: TextAlign.left,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Sizer.getTextSize(
                                        screenWidth, screenHeight, 20))),
                            trailing: Text(
                              eventMetadata['gold_points'].toString(),
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: Sizer.getTextSize(
                                      screenWidth, screenHeight, 20),
                                  color: Color.fromARGB(255, 249, 166, 22)),
                            ),
                            subtitle: Text(
                              (isEditing)
                                  ? 'Click to Hide'
                                  : 'Click to edit event GP value!',
                              style: TextStyle(
                                fontSize: Sizer.getTextSize(
                                    screenWidth, screenHeight, 14),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                isEditing = !isEditing;
                              });
                            },
                          )),
                        if (isEditing)
                          Card(
                            child: ListTile(
                              title: TextField(
                                style: TextStyle(fontFamily: 'Lato'),
                                textAlign: TextAlign.center,
                                decoration: new InputDecoration(
                                  labelText: "New GP",
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    borderSide:
                                        new BorderSide(color: Colors.blue),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                controller: pointController,
                              ),
                              trailing: RaisedButton(
                                child: Text('Update',
                                    style: new TextStyle(
                                        fontSize: Sizer.getTextSize(
                                            screenWidth, screenHeight, 17),
                                        fontFamily: 'Lato')),
                                textColor: Colors.white,
                                color: Color.fromRGBO(46, 204, 113, 1),
                                onPressed: () async {
                                  //error handling
                                  if (pointController.text == "") {
                                    widget.scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        "Enter GP Value!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: Sizer.getTextSize(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                18),
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ));
                                  } else if (pointController.text ==
                                      eventMetadata['gold_points'].toString()) {
                                    widget.scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        "Same as Old GP Value!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: Sizer.getTextSize(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                18),
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ));
                                  } else {
                                    /*grab all the users who have been to this event, so that we can edit this event's
                gold points associated with this event in their map
              */
                                    setState(() {
                                      isEditing = false;
                                    });
                                    int newGPVal =
                                        int.parse(pointController.text);
                                    WriteBatch batch =
                                        Firestore.instance.batch();

                                    QuerySnapshot userDocs = await Firestore
                                        .instance
                                        .collection("Users")
                                        .getDocuments();

                                    //iterate through the users and remove instance of the event
                                    for (DocumentSnapshot userDocument
                                        in userDocs.documents) {
                                      Map userEventData =
                                          userDocument['events'];
                                      //remove the event name key as well the pair in the map
                                      if (userEventData.containsKey(
                                          eventMetadata['event_name'])) {
                                        userEventData.update(
                                            eventMetadata['event_name'],
                                            (dynamic val) => newGPVal);

                                        //recompute the gold points
                                        num goldPoints = 0;

                                        userEventData.forEach((k, v) {
                                          goldPoints += v;
                                        });

                                        /*update the whole user document with the deletion of the event as well the
                                            recomputation of gold points
                                           */

                                        Map documentData = userDocument.data;
                                        documentData['events'] = userEventData;
                                        documentData['gold_points'] =
                                            goldPoints;

                                        batch.setData(userDocument.reference,
                                            documentData);
                                      }
                                    }

                                    Map newEventMap = eventMetadata;
                                    newEventMap.update('gold_points',
                                        (dynamic val) => newGPVal);

                                    //all the operations done to the user documents are done in one move
                                    batch.commit().then((_) {
                                      //delete the actual document containing the event once all the batch commits are deleted
                                      pointController.clear();
                                      eventSnap.reference
                                          .updateData(newEventMap)
                                          .then((_) {
                                        //display a snackbar to show the user the event is deleted
                                        widget.scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "This event's GP value is updated",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Lato',
                                                color: Colors.white,
                                                fontSize: Sizer.getTextSize(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height,
                                                    18)),
                                          ),
                                          backgroundColor: Colors.green,
                                        ));
                                      });
                                    });
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.view_list,
                                color: Color.fromARGB(255, 249, 166, 22)),
                            title: Text('Enter Type',
                                textAlign: TextAlign.left,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Sizer.getTextSize(
                                        screenWidth, screenHeight, 20))),
                            trailing: Text(
                              eventMetadata['enter_type'] == 'ME'
                                  ? 'Manual'
                                  : 'Quick',
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: Sizer.getTextSize(
                                      screenWidth, screenHeight, 20),
                                  color: Color.fromARGB(255, 249, 166, 22)),
                            ),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.date_range,
                                color: Color.fromARGB(255, 249, 166, 22)),
                            title: Text('Date',
                                textAlign: TextAlign.left,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Sizer.getTextSize(
                                        screenWidth, screenHeight, 20))),
                            trailing: Text(
                              eventMetadata['event_date'],
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: Sizer.getTextSize(
                                      screenWidth, screenHeight, 20),
                                  color: Color.fromARGB(255, 249, 166, 22)),
                            ),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.supervisor_account,
                                color: Color.fromARGB(255, 249, 166, 22)),
                            title: Text('Count',
                                textAlign: TextAlign.left,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Sizer.getTextSize(
                                        screenWidth, screenHeight, 20))),
                            trailing: Container(
                              width: screenWidth * 0.2,
                              child: Text(
                                scanCount.toString(),
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontSize: Sizer.getTextSize(
                                        screenWidth, screenHeight, 20),
                                    color: Color.fromARGB(255, 249, 166, 22)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
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
                      fontSize: 32 * screenWidth / pixelTwoWidth,
                    ),
                  ),
                  CircularProgressIndicator()
                ],
              ));
        }
      },
    );
  }
}

class EditGPPopup extends StatefulWidget {
  State<EditGPPopup> createState() {
    return EditGPPopupState();
  }
}

class EditGPPopupState extends State<EditGPPopup> {
  TextEditingController pointController = new TextEditingController();
  Map eventData;

  ManualEnterPopupState() {
    pointController.text = 0.toString();
  }

  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    eventData = container.eventMetadata;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        width: screenWidth * 0.7,
        height: screenHeight * 0.5,
        child: AlertDialog(
          content: Container(
            child: TextField(
              style: TextStyle(fontFamily: 'Lato'),
              textAlign: TextAlign.center,
              decoration: new InputDecoration(
                labelText: "GP",
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.number,
              controller: pointController,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Submit", style: TextStyle(color: Colors.blue)),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
