import 'package:connectivity/connectivity.dart';
import 'package:deca_app/screens/admin/finder.dart';
import 'package:deca_app/screens/admin/notification_sender.dart';
import 'package:deca_app/screens/admin/scanner.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

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

  //final values that are entered into firestore
  String _eventDate;
  TextEditingController _eventName = new TextEditingController();
  String _eventType;
  String _enterType;
  TextEditingController _goldPoints = new TextEditingController();

  Map eventMetadata;

  _CreateEventUIState();

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
      } as Map;
      await Firestore.instance
          .collection("Events")
          .document(_eventName.text)
          .setData(eventMetadata);

      setState(() => _isTryingToCreateEvent = false);
      container.setEventMetadata(eventMetadata);
    } else {
      eventMetadata = {
        "event_name": _eventName.text,
        "event_date": _eventDate,
        "event_type": _eventType,
        "enter_type": _enterType,
        'gold_points': int.parse(_goldPoints.text),
        "attendee_count": 0,
      } as Map;
      await Firestore.instance
          .collection("Events")
          .document(_eventName.text)
          .setData(eventMetadata);

      setState(() => _isTryingToCreateEvent = false);

      container.setEventMetadata(eventMetadata);
    }
    Navigator.of(context).push(NoTransition(builder: (context) => Scanner()));
    clearAll();
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
          style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
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
    double screenWidth = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
        appBar: new AppBar(
          title: Text("Admin Functions"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {
                    Navigator.pop(context)
                    
                  }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => new SettingScreen())),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: new EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 15.0),
                      width: double.infinity,
                      child: Text(
                        "Create an Event",
                        textAlign: TextAlign.left,
                        style: new TextStyle(fontSize: 25, fontFamily: 'Lato'),
                      ),
                    ),
                    Container(
                        padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                        width: screenWidth - 50,
                        child: TextFormField(
                            controller: _eventName,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontFamily: 'Lato'),
                            decoration: new InputDecoration(
                              labelText: "Event Name",
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                borderSide: new BorderSide(color: Colors.blue),
                              ),
                            ))),
                    Container(
                        padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                        width: screenWidth - 50,
                        height: 75,
                        child: new RaisedButton(
                          child: Text(updateDateButton(),
                              style: new TextStyle(
                                  fontSize: 17, fontFamily: 'Lato')),
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
                        padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                        width: screenWidth - 50,
                        height: 75,
                        child: RaisedButton(
                          child: Text(
                            (dropdownValue == null)
                                ? "Choose Event Type"
                                : dropdownValue,
                            textAlign: TextAlign.center,
                            style:
                                new TextStyle(fontSize: 17, fontFamily: 'Lato'),
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
                                        child: Text('Miscallaneous'),
                                        onPressed: () {
                                          setState(() {
                                            dropdownValue = 'Miscallaneous';
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
                      padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                      width: screenWidth - 50,
                      height: 75,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              flex: 7,
                              child: Container(
                                height: 75,
                                child: RaisedButton(
                                  onPressed: () => setState(
                                      () => this.updateButtons('Quick Enter')),
                                  child: Text(
                                    "Quick Enter",
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                      fontSize: 15,
                                    ),
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
                                height: 75,
                                child: RaisedButton(
                                  onPressed: () => setState(
                                      () => this.updateButtons('Manual Enter')),
                                  child: Text("Manual Enter",
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(
                                        fontSize: 15,
                                      )),
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
                          padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                          width: 125,
                          child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _goldPoints,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Lato'),
                              decoration: new InputDecoration(
                                labelText: "Gold Points",
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  borderSide:
                                      new BorderSide(color: Colors.blue),
                                ),
                              ))),
                    Container(
                        padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                        width: screenWidth - 200,
                        height: 75,
                        child: new RaisedButton(
                          child: Text('Create',
                              style: new TextStyle(
                                  fontSize: 17, fontFamily: 'Lato')),
                          textColor: Colors.white,
                          color: Color.fromRGBO(46, 204, 113, 1),
                          onPressed: () {
                            tryToCreateEvent(context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        )),
                    if (_isTryingToCreateEvent) //to add the progress indicator
                      Container(
                          width: screenWidth - 50,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator())
                  ],
                ),
              ),
            ),
            if (StateContainer.of(context).isThereConnectionError)
              ConnectionError()
          ],
        ));
  }
}

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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => new SettingScreen())),
            ),
          ],
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
                  leading: Icon(Icons.supervisor_account),
                  title: Text('Create a Group'),
                  onTap: () => Navigator.push(context,
                      NoTransition(builder: (context) => CreateGroupUI())),
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

class CreateGroupUI extends StatefulWidget {
  CreateGroupUI();

  State<CreateGroupUI> createState() {
    return _CreateGroupUIState();
  }
}

class _CreateGroupUIState extends State<CreateGroupUI> {
  TextEditingController _groupName = TextEditingController();
  bool _hasCreatedGroup = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _CreateGroupUIState();

  Widget build(BuildContext context) {

    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Add Users to Group"),
      ),
      body: Stack(
        children: <Widget>[
          //add people to a group on callback
          Finder((BuildContext context, StateContainerState stateContainer,
              Map userData) {
            Firestore.instance
                .collection("Users")
                .document(userData['uid'])
                .get()
                .then((document) {
              List data = document.data['groups'].toList();
              //check if the person is already in the group
              if (data.contains(stateContainer.group)) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    "${userData['first_name']} is already in ${stateContainer.group}",
                    style: TextStyle(
                        fontFamily: 'Lato', fontSize: 20, color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                    label: "REMOVE",
                    textColor: Colors.amber,
                    onPressed: () {
                      //remove the group
                      data.remove(stateContainer.group);

                      //remove user from firestore and show confirmation
                      Firestore.instance
                          .collection("Users")
                          .document(userData['uid'])
                          .updateData({'groups': data}).then((_) {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(
                              "${userData['first_name']} removed from ${stateContainer.group}",
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      });
                    },
                  ),
                ));
              }
              //add the person to the group
              else {
                data.add(stateContainer.group);
                document.reference.updateData({'groups': data});
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    "Succesfully added ${userData['first_name']} to ${stateContainer.group}",
                    style: TextStyle(
                        fontFamily: 'Lato', fontSize: 20, color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ));
              }
            });
          }),
          if (!_hasCreatedGroup)
            Container(
                color: Colors.black45,
                child: AlertDialog(
                  title: Text(
                    "Group Name",
                    style: TextStyle(
                      fontSize: Sizer.getTextSize(sW, sH, 21)
                    ),
                  ),
                  content: TextField(
                    controller: _groupName,
                    style: TextStyle(
                      fontSize: Sizer.getTextSize(sW, sH, 15)
                    ),
                    decoration: InputDecoration(
                      labelText: "Group Name",
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Create"),
                      textColor: Colors.blue,
                      onPressed: () {

                        if (_groupName.text != null) {
                          Firestore.instance
                              .collection("Groups")
                              .add({'name': _groupName.text});
                          StateContainer.of(context).setGroup(_groupName.text);

                          setState(() => _hasCreatedGroup = true);
                        }
                      },
                    )
                  ],
                )),
          if (StateContainer.of(context).isThereConnectionError)
            ConnectionError()
        ],
      ),
    );
  }
}

class EditEventUI extends StatefulWidget {
  EditEventUI();

  State<EditEventUI> createState() {
    return _EditEventUIState();
  }
}

class _EditEventUIState extends State<EditEventUI> {
  _EditEventUIState();

  ListView _buildEventList(context, snapshot) {
    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: snapshot.data.documents.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        DocumentSnapshot eventInfo = snapshot.data.documents[int];
        return Card(
          child: ListTile(
            title: Text(eventInfo['event_name'],
                textAlign: TextAlign.left,
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            subtitle: Text(eventInfo['event_type']),
            onTap: () {
              final container = StateContainer.of(context);
              container.setEventMetadata(eventInfo.data);
              Navigator.of(context)
                  .push(NoTransition(builder: (context) => Scanner()));
            },
          ),
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
      appBar: new AppBar(
        title: Text("Edit an Event"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {
                  Navigator.pop(context)
                }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => new SettingScreen())),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: Firestore.instance.collection('Events').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Center(
                        child: Container(
                          height: screenHeight - 75,
                          width: screenWidth - 25,
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

class NoTransition<T> extends MaterialPageRoute<T> {
  NoTransition({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return child;
  }
}

class EventInfoUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventInfoUIState();
  }
}

class _EventInfoUIState extends State<EventInfoUI> {
  Map eventMetadata;
  int scanCount;

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final container = StateContainer.of(context);
    eventMetadata = container.eventMetadata;
    scanCount = eventMetadata['attendee_count'];
    // TODO: implement build
    return Container(
      width: screenWidth * .9,
      height: screenHeight * .4,
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                  child: Text("Event Info",
                      style: TextStyle(
                          fontFamily: 'Lato', fontSize: 32 * textScaleFactor))),
            ),
            Container(
              width: screenWidth * .8,
              height: screenHeight * .3,
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
                      trailing: Container(
                        width: 100,
                        height: 50,
                        child: TextFormField(
                          initialValue: (eventMetadata['enter_type'] == 'QE')
                              ? (eventMetadata['gold_points'].toString())
                              : "N/A",
                          enabled: (eventMetadata['enter_type'] == 'ME')
                              ? false
                              : true,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 249, 166, 22)),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.stars,
                          color: Color.fromARGB(255, 249, 166, 22)),
                      title: Text('Date',
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      trailing: Text(
                        eventMetadata['event_date'],
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 249, 166, 22)),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.stars,
                          color: Color.fromARGB(255, 249, 166, 22)),
                      title: Text('Attendee Count',
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      trailing: Container(
                        width: 100,
                        height: 50,
                        child: Text(
                          scanCount.toString(),
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontSize: 20,
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
  }
}
