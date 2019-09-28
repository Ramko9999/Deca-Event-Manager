
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deca_app/screens/admin/finder.dart';
import 'package:deca_app/screens/admin/notification_sender.dart';
import 'package:deca_app/screens/admin/scanner.dart';
import 'package:deca_app/screens/admin/searcher.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/screens/profile/templates.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

      container.setEventMetadata(eventMetadata);
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(NoTransition(builder: (context) => Scanner()));
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
          style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          title: Text("Admin Functions"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {
                    Navigator.pop(context)
                    
                  }),

        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: sH * 0.03),
                      width: double.infinity,
                      child: Text(
                        "Create an Event",
                        textAlign: TextAlign.left,
                        style: new TextStyle(fontSize: Sizer.getTextSize(sW, sH, 25), fontFamily: 'Lato'),
                      ),
                    ),
                    Container(
                        padding: new EdgeInsets.only(top: sH * 0.03, bottom: sH * 0.03),
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
                        padding: new EdgeInsets.only(top: sH * 0.03, bottom: sH * 0.03),
                        width: sW * 0.9,
                        height: sH * 0.15,
                        child: new RaisedButton(
                          child: Text(updateDateButton(),
                              style: new TextStyle(
                                  fontSize: Sizer.getTextSize(sW, sH, 17), fontFamily: 'Lato')),
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
                        padding: new EdgeInsets.only(bottom: sH * 0.03),
                        width: sW * 0.9,
                        height: sH * 0.12,
                        child: RaisedButton(
                          child: Text(
                            (dropdownValue == null)
                                ? "Choose Event Type"
                                : dropdownValue,
                            textAlign: TextAlign.center,
                            style:
                                new TextStyle(fontSize: Sizer.getTextSize(sW, sH, 17), fontFamily: 'Lato'),
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
                                      fontFamily: "Lato"
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
                                 height: sH * 0.10,
                                child: RaisedButton(
                                  onPressed: () => setState(
                                      () => this.updateButtons('Manual Enter')),
                                  child: Text("Manual Enter",
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(
                                        fontSize: Sizer.getTextSize(sW, sH, 15),
                                      fontFamily: "Lato"
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
                          padding: new EdgeInsets.only( bottom: sH * 0.03),
                          width: sW * 0.3,
                          child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _goldPoints,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Lato', fontSize: Sizer.getTextSize(sW, sH, 14)),
                              decoration: new InputDecoration(
                                labelText: "Gold Points",
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  borderSide:
                                      new BorderSide(color: Colors.blue),
                                ),
                              ))),
                    Container(
                        width: sW * 0.45,
                        height: sH * 0.08,
                        child: new RaisedButton(
                          child: Text('Create',
                              style: new TextStyle(
                                  fontSize: Sizer.getTextSize(sW, sH, 17), fontFamily: 'Lato')),
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
            if(_isTryingToCreateEvent)
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
                  leading: Icon(Icons.supervisor_account),
                  title: Text('Create a Group'),
                  onTap: () => Navigator.push(context,
                      NoTransition(builder: (context) => CreateGroupUI())),
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
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  bool hasSearched = false;
  Map recentCardInfo;
  List<DocumentSnapshot> userDocs;

  @override
  void initState() {
    print('here');
    super.initState();
    _firstName.addListener(() {
      this.build(context);
    });
    _lastName.addListener(() {
      this.build(context);
    });
    Firestore.instance.collection("Users").getDocuments().then((documents) {
      setState(() => userDocs = documents.documents);
    });
  }

  @override
  Widget build(BuildContext context) {
    //query and update documents based on additions and deletions
    Firestore.instance.collection("Users").getDocuments().then((documents) {
      if (this.mounted) {
        setState(() => userDocs = documents.documents);
      }
    });

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: new AppBar(
        title: Text("Edit a Member"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {
              Navigator.of(context).pop()
            }
            ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => new SettingScreen())),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: screenWidth * 0.9,
          height: screenHeight * 0.9,
          child: Finder(
            (BuildContext context, StateContainerState infoContainer, Map userData){
              infoContainer.setUserData(userData);
              Navigator.push(context,
                    NoTransition(builder: (context) => new EditMemberProfileUI()));
            }
          ),
        ),
      ),
    );
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
                        fontFamily: 'Lato', fontSize: Sizer.getTextSize(sW, sH, 18), color: Colors.white),
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
                                  fontSize: Sizer.getTextSize(sW, sH, 18),
                                  color: Colors.white),
                            ),
                            duration: Duration(milliseconds: 250),
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
                    "Added ${userData['first_name']} to ${stateContainer.group}",
                    style: TextStyle(
                        fontFamily: 'Lato', fontSize: Sizer.getTextSize(sW, sH, 18), color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(milliseconds: 250),
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
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
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
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: Sizer.getTextSize(sW, sH, 20))),
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final container = StateContainer.of(context);
    eventMetadata = container.eventMetadata;
    scanCount = eventMetadata['attendee_count'];
    // TODO: implement build
    return Container(
      width: screenWidth * .8,
      height: screenHeight * 0.6,
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.03),
              child: Container(
                  child: Text("Event Info",
                      style: TextStyle(
                          fontFamily: 'Lato', fontSize: Sizer.getTextSize(screenWidth, screenHeight, 28)))),
            ),
            Container(
              width: screenWidth * .8,
              height: screenHeight * .5,
              child: ListView(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.stars,
                          color: Color.fromARGB(255, 249, 166, 22)),
                      title: Text('GP',
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize:  Sizer.getTextSize(screenWidth, screenHeight, 20))),
                      trailing: Container(
                        width: screenWidth * 0.2,

                        child: TextFormField(
                          initialValue: (eventMetadata['enter_type'] == 'QE')
                              ? (eventMetadata['gold_points'].toString())
                              : "N/A",
                          enabled: (eventMetadata['enter_type'] == 'ME')
                              ? false
                              : true,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontSize: Sizer.getTextSize(screenWidth, screenHeight, 20),
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
                              fontWeight: FontWeight.bold, fontSize: Sizer.getTextSize(screenWidth, screenHeight, 20))),
                      trailing: Text(
                        eventMetadata['event_date'],
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: Sizer.getTextSize(screenWidth, screenHeight, 20),
                            color: Color.fromARGB(255, 249, 166, 22)),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.stars,
                          color: Color.fromARGB(255, 249, 166, 22)),
                      title: Text('Count',
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: Sizer.getTextSize(screenWidth, screenHeight, 20))),
                      trailing: Container(
                        width: screenWidth * 0.2,

                        child: Text(
                          scanCount.toString(),
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontSize: Sizer.getTextSize(screenWidth, screenHeight, 20),
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


class EditMemberProfileUI extends StatelessWidget {
  String _uid;
  String _firstName;
  int _goldPoints;
  String _memberLevel;

  Widget build(BuildContext context) {
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
        body: StreamBuilder(
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
                                        'Click to view events!',
                                        style: TextStyle(
                                            fontSize: 16 * screenWidth /
                                                pixelTwoWidth),
                                      ),
                                      onTap: () =>
                                          Navigator.push(
                                              context,
                                              NoTransition(
                                                  builder: (
                                                      context) => new EditGPInfoScreen()
                                              )
                                          ),
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
                                                    context) => new EditCommitteeInfoScreen())),
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
            }
        )
    );
  }
}

class EditCommitteeInfoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditCommitteeInfoScreenState();
  }
}

class EditCommitteeInfoScreenState extends State<EditCommitteeInfoScreen> {
  String _uid;
  String firstName;
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
    _uid = container.userData['uid'];
    firstName = container.userData['first_name'];
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
        title: AutoSizeText(
          "Edit " + firstName + "\'s Committees",
          maxLines: 1,
        ),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
              stream: Firestore.instance
                  .collection('Users')
                  .where("uid", isEqualTo: _uid)
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
                      height: screenHeight * 0.8,
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

class EditGPInfoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditGPInfoScreenState();
  }
}

class EditGPInfoScreenState extends State<EditGPInfoScreen> {
  String _uid;
  List<EventObject> eventList;
  String filterType;
  String firstName;

  ListView _buildEventList(context, eventSnapshot, userSnapshot) {
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
    Map userMetadata = userSnapshot.data;

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
    _uid = container.userData['uid'];
    filterType = container.filterType;
    firstName = container.userData['first_name'];

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
          title: AutoSizeText(
            "Edit " + firstName + "\'s Events",
            maxLines: 1,
          ),
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
                              DocumentSnapshot userSnap = userSnapshot.data
                                  .documents[0];
                              Map eventList = userSnap.data['events'] as Map;
                              bool isEmpty = eventList.isEmpty;
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  height: screenHeight * 0.8,
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
            ]
        )
    );
  }
}


