import 'package:connectivity/connectivity.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/utility/error_popup.dart';
import 'package:deca_app/utility/single_action_popup.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventUI extends StatefulWidget {
  String _uid;

  CreateEventUI(uid) {
    this._uid = uid;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return (_CreateEventUIState(_uid));
  }
}

class _CreateEventUIState extends State<CreateEventUI> {
  String dropdownValue;
  bool _isManualEnter = false;
  bool _isQuickEnter = false;
  String _uid;
  String eventDateText;
  bool _isTryingToCreateEvent = false;

  //final values that are entered into firestore
  String _eventDate;
  TextEditingController _eventName = new TextEditingController();
  String _eventType;
  String _enterType;
  TextEditingController _goldPoints = new TextEditingController();

  _CreateEventUIState(String uid) {
    this._uid = uid;
  }

  void executeEventCreation() async {

      //creating a new event in Firestore
    if(_isManualEnter)
      {
        await Firestore.instance.collection("Events").document(_eventName.text).setData({
          "event_name": _eventName.text,
          "event_date": _eventDate,
          "event_type": _eventType,
          "enter_type": _enterType,
          "attendee_count":0,
        });
      }
    else
      {
        await Firestore.instance.collection("Events").document(_eventName.text).setData({
          "event_name": _eventName.text,
          "event_date": _eventDate,
          "event_type": _eventType,
          "enter_type": _enterType,
          'gold_points': int.parse(_goldPoints.text),
          "attendee_count":0,
        });
      }

      setState(() => _isTryingToCreateEvent = false);
      clearAll();
  }
  void clearAll()
  {
    setState(() {
      _eventName.clear();
      eventDateText = null;
      dropdownValue = null;
      _isManualEnter = false;
      _isQuickEnter = false;
      _goldPoints.clear();
    });
  }
  bool validateForm(BuildContext context)
  {
    String errorMessage;
    // Find the Scaffold in the widget tree and use
    // it to show a SnackBar.
    if(_eventName.text == '')
      {
        errorMessage = 'Event Name is Empty';
      }
    else if(_eventDate == null)
      {
        errorMessage = 'Missing Date of Event';
      }
    else if(dropdownValue == null)
      {
        errorMessage = 'Missing Event Type';
      }
    else if(!(_isManualEnter || _isQuickEnter))
    {
      errorMessage = 'Missing Enter Type';
    }
    else if(_isQuickEnter && _goldPoints.text == '')
      {
        errorMessage = 'Missing Gold Points';
      }
    else
      {
        _eventType = dropdownValue;
        _enterType = _isManualEnter?'ME':'QE';
        return true;
      }
    SnackBar snackBar = SnackBar(content: Text(errorMessage,
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold
        )),
      backgroundColor: Colors.red,duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
    return false;
  }

  //handles registration of user
  void tryToRegister(BuildContext context) async {
    setState(() => _isTryingToCreateEvent = true);
    if (validateForm(context)) {
      Connectivity().checkConnectivity().then((connectionState) {
        if (connectionState == ConnectivityResult.none) {
          throw Exception("Phone is not connected to wifi");
        } else {
          executeEventCreation();
        }
      }).catchError((connectionError) {
        setState(() => _isTryingToCreateEvent = false);
        if (connectionError.toString().contains("wifi")) {
          showDialog(
              context: context,
              builder: (context) {
                return ErrorPopup("Phone is not connected to wifi", () {
                  Navigator.of(context).pop();
                  tryToRegister(context);
                });
              });
        }
      });
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
        body: Center(
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
                  )
              )
          ),
          Container(
              padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
              width: screenWidth - 50,
              height: 75,
              child: new RaisedButton(
                child: Text(updateDateButton(),
                    style: new TextStyle(fontSize: 17, fontFamily: 'Lato')),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2019, 1, 1), onConfirm: (date) {
                    setState(() {
                      eventDateText = new DateFormat('EEEE, MMMM d, y')
                          .format(date)
                          .toString();
                      _eventDate = new DateFormat.yMd()
                          .format(date)
                          .toString();
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )),
          Container(
            padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
            width: screenWidth - 50,
            child: DropdownButton<String>(
              isExpanded: true,
              iconEnabledColor: Colors.blue,
              iconDisabledColor: Colors.blue,
              hint: Text('Choose Event Type',
                  style: new TextStyle(
                      fontSize: 17, fontFamily: 'Lato', color: Colors.blue)),
              value: dropdownValue,
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: <String>[
                'Meeting',
                'Social',
                'Event',
                'Competition',
                'Committee',
                'Cookie Store',
                'Miscellaneous'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: new TextStyle(
                          color: Colors.blue, fontFamily: 'Lato')),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
            width: screenWidth - 50,
            height: 75,
            child:
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 7,
                      child: Container(
                        height: 75,
                        child: RaisedButton(
                          onPressed: () =>
                              setState(() => this.updateButtons('Quick Enter')),
                          child: Text(
                            "Quick Enter",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: _isQuickEnter ? Colors.blue : Colors.grey,
                          textColor: Colors.white,
                        ),
                      )),
                  Spacer(flex: 1),
                  Expanded(
                      flex: 7,
                      child: Container(
                        height: 75,
                        child: RaisedButton(
                          onPressed: () =>
                              setState(() => this.updateButtons('Manual Enter')),
                          child: Text("Manual Enter",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontSize: 15,
                              )),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: _isManualEnter ? Colors.blue : Colors.grey,
                          textColor: Colors.white,
                        ),
                      ))
                ],
              ),
          ),
          if (_isQuickEnter)
            Container(
                padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                width: screenWidth - 300,
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _goldPoints,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Lato'),
                    decoration: new InputDecoration(
                      labelText: "Gold Points",
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                        borderSide: new BorderSide(color: Colors.blue),
                      ),
                    )
                )

            ),
          Container(
              padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
              width: screenWidth - 200,
              height: 75,
              child: new RaisedButton(
                child: Text('Create',
                    style: new TextStyle(fontSize: 17, fontFamily: 'Lato')),
                textColor: Colors.white,
                color: Color.fromRGBO(46, 204, 113, 1),
                onPressed: () {
                  tryToRegister(context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )
          ),
          if (_isTryingToCreateEvent) //to add the progress indicator
            Container(
                width: screenWidth - 50,
                alignment: Alignment.center,
                child: CircularProgressIndicator())
        ],
      ),
    ));
  }
}

class AdminScreenUI extends StatefulWidget {
  String _uid;

  AdminScreenUI(uid) {
    this._uid = uid;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return (_AdminUIState(_uid));
  }
}

class _AdminUIState extends State<AdminScreenUI> {
  String _uid;
  String _activeFunction;

  _AdminUIState(uid) {
    this._uid = uid;
  }

  Widget changeScreen(String functionName) {
    switch (functionName) {
      case 'Create an Event':
        return CreateEventUI(_uid);
      case 'Edit Events':
        return null;
      case 'Edit Individual Members':
        return null;
        break;
      default:
        return CreateEventUI(_uid);
    }
  }

  Widget returnAdminScreen()
  {
    return ListView(
      children: <Widget>[
        Card(
            child: ListTile(
              leading: Icon(Icons.create),
              title: Text('Create an Event'),
              onTap: () =>
                  setState(() => _activeFunction = 'Create an Event'),
            )),
        Card(
            child: ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Edit Events'),
              onTap: () =>
                  setState(() => _activeFunction = 'Edit Events'),
            )),
        Card(
            child: ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text('Edit Individual Members'),
              onTap: () => setState(
                      () => _activeFunction = 'Edit Individual Members'),
            )),
      ],
    );
  }

  void backAction()
  {
    if(_activeFunction == null)
    {
      Navigator.push(context, NoTransition(builder: (context) => new ProfileScreen(_uid)));
    }
    else
    {
      setState(() {
        _activeFunction = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: new AppBar(
          title: Text("Admin Functions"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {this.backAction()}
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new SettingScreen(_uid))),
            ),
          ],
        ),
        body: (_activeFunction != null)
            ? changeScreen(_activeFunction)
            : returnAdminScreen());
  }
}

class NoTransition<T> extends MaterialPageRoute<T> {
  NoTransition({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return child;
  }
}
