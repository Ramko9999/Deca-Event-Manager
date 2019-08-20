import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:deca_app/screens/admin/searcher.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/utility/error_popup.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Finder extends StatefulWidget {
  Map eventMetaData;

  Finder(Map e) {
    this.eventMetaData = e;
  }

  State<Finder> createState() {
    return FinderState(eventMetaData);
  }
}

class FinderState extends State<Finder> {
  Map eventMetaData;
  TextEditingController _firstName = new TextEditingController();
  TextEditingController _lastName = new TextEditingController();
  Node current;
  MaxList results;

  FinderState(Map e) {
    this.eventMetaData = e;
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text('Search'),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: _firstName,
              onChanged: (val) {
                getData();
              },
              onSubmitted: (val) {
                getData();
              },
              decoration: InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: _lastName,
              onChanged: (val) {
                getData();
              },
              onSubmitted: (val) {
                getData();
              },
              decoration: InputDecoration(labelText: "Last Name"),
            ),
            Flexible(
              child: current == null
                  ? Container(
                    child: CircularProgressIndicator()
                    
                    /*Column(children: <Widget>[
                      Container(child: Image.asset("assets/logos/error-triangle.png"),
                      width: screenWidth * 0.6, height: screenHeight * 0.6,),
                      Text("No results were found!", textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontFamily: 'Lato', fontWeight: FontWeight.bold, fontSize: 32,))
                    ],) */
                  )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.getSize(),
                      itemBuilder: (context, i) {
                        print(results.getSize());
                        print(current.element['info']);
                        UserCard user =  UserCard(current.element);
                        current = current.next;
                        return user;
                      }),
            ),
          ],
        ));
  }

  void getData() {
    Firestore.instance.collection("Users").getDocuments().then((onDocuments) {
      List<Map> userList = [];
      //turn this into map with uid and names
      for (int i = 0; i < onDocuments.documents.length; i++) {
        Map userData = onDocuments.documents[i].data;
        userList.add(userData);
      }
      Searcher searcher =
          new Searcher(userList, _firstName.text, _lastName.text);
      MaxList relevanceList = searcher.search();
      setState(() {
        results = relevanceList;
        current = relevanceList.head;
      });
    });
  }
}

class UserCard extends StatefulWidget {
  Map userInfo;
  UserCard(Map e) {
    this.userInfo = e;
  }

  State<UserCard> createState() {
    return UserCardState(userInfo);
  }
}

class UserCardState extends State<UserCard> {
  Map userInfo;
  TextEditingController pointVal = new TextEditingController();
  Color memberLevelColor;
  static Color goldMember = Color.fromARGB(255, 249, 166, 22);
  static Color silverMember = Colors.blueGrey;
  static Color member = Colors.blueAccent;
  static Color notMember = Colors.black;

  UserCardState(Map u) {
    this.userInfo = u;
    int goldPoints = userInfo['info']['gold_points'] as int;
    memberLevelColor = notMember;
    if (goldPoints > 75) {
      memberLevelColor = member;
    }
    if (goldPoints > 150) {
      memberLevelColor = silverMember;
    }
    if (goldPoints > 300) {
      memberLevelColor = goldMember;
    }
  }

  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      leading: Icon(Icons.person, color: memberLevelColor),
      title: Text(
        userInfo['info']['first_name'] + " " + userInfo['info']['last_name'],
        style: TextStyle(fontFamily: 'Lato'),
      ),
      subtitle: Text(
        userInfo['info']['gold_points'].toString(),
        style: TextStyle(
            fontFamily: 'Lato', color: Color.fromARGB(255, 249, 166, 22)),
      ),
      trailing: TextField(
        controller: pointVal,
      ),
    ));
  }
}

class Scanner extends StatefulWidget {
  Map eventMetaData;
  String _uid;
  Scanner(Map e,String uid) {
    this.eventMetaData  = e;
    this._uid = uid;
  }
  State<Scanner> createState() {
    return _ScannerState(eventMetaData,_uid);
  }
}

class _ScannerState extends State<Scanner> {
  HashSet<String> _scannedUids; //used to keep track of already scanned codes
  String _connectionState; //used to listen to connection changes
  List _cameras; //used to grab cameras
  CameraController _mainCamera; //camera that will give us the feed
  bool _isCameraInitalized = false;
  Map eventMetadata;
  bool _isQR;
  bool _isSearcher;
  int pointVal;
  int scanCount;
  String _uid;

  _ScannerState(Map e, String uid) {
    _scannedUids = new HashSet();
    _connectionState = "Unknown Connection";
    eventMetadata = e;

    pointVal = eventMetadata['gold_points'];
    scanCount = eventMetadata['attendee_count'];
    this._uid = uid;
    _isQR = true;
    _isSearcher = false;
  }
  void updateGP(String _uid)
  {
    Firestore.instance.collection('Users').document(_uid).get().then((userData){
      int totalGP = 0;
      Map eventsList = userData['events'].values;
      for(var gp in eventsList.keys)
        {
          totalGP += gp;
        }
      Firestore.instance.collection('Users').document(_uid).updateData({'gold_points': totalGP});
    });
  }

  void pushToDB(String userUniqueID){
    print(userUniqueID);
    if (!_scannedUids.contains(userUniqueID)) {
              Firestore.instance
                  .collection("Users")
                  .document(userUniqueID)
                  .get()
                  .then((userData) {
                //blindly increment gold points this might be where you want to change such that event data and user dictionary are updated
                Firestore.instance
                    .collection("Users")
                    .document(userUniqueID)
                    .updateData({
                  'gold_points': userData.data['gold_points'] + pointVal
                });

                //update the events
                Firestore.instance
                    .collection('Events')
                    .document(eventMetadata['event_name'])
                  .updateData(
                      {'events': () {
                        Map events = userData['events'];
                        if(events != null)
                          {
                            events.addAll({eventMetadata['event_name']:pointVal});
                            return events;
                          }
                        else
                          {
                            return {eventMetadata['event_name']:pointVal};
                          }
                      }});
              updateGP(userUniqueID);

              //update the events
              Firestore.instance.collection('Events').document(eventMetadata['event_name']).updateData({'attendee_count': FieldValue.increment(1)});        
              setState(() {
                scanCount += 1;
              });
              //update the scaffold

              //append to the hashset the uniqueID
              _scannedUids.add(userUniqueID);
            }).catchError((onError) => print(onError));
              Firestore.instance.collection('Users').document(userUniqueID).get().then((user){
                String firstName = user.data['first_name'];
                Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Color.fromRGBO(46, 204, 113, 1),
                  content: Text("Scanned" + firstName),
                ));
              }).catchError((onError) => print(onError));
            }
            else
              {
              print("Already Scanned this person");
            }
  }

  void initState() {
    super.initState();

    //listening for changes in connection
    Connectivity().onConnectivityChanged.listen((connectionStatus) {
      setState(() {
        _connectionState = connectionStatus.toString();
      });
    });

    //get all the avaliable cameras
    availableCameras().then((allCameras) {
      _cameras = allCameras;
      _mainCamera = CameraController(allCameras[0], ResolutionPreset.medium);
      _mainCamera.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() => _isCameraInitalized = true); //show the actual camera
        _mainCamera.startImageStream((image){
          FirebaseVisionImageMetadata metadata;
          //android image format is different than ios
          if(Platform.isAndroid){
            //metadata tag for the yvu format. 
            //source https://github.com/flutter/flutter/issues/26348
             metadata = FirebaseVisionImageMetadata(
            rawFormat: image.format.raw,
            size: Size(image.width.toDouble(), image.height.toDouble()),
            planeData: image.planes.map((plane)=> FirebaseVisionImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width
            )).toList()
          );
          }
          FirebaseVisionImage visionImage = FirebaseVisionImage.fromBytes(image.planes[0].bytes,metadata);
          FirebaseVision.instance.barcodeDetector().detectInImage(visionImage).then((barcodes){
          for(Barcode barcode in barcodes){
            pushToDB(barcode.rawValue); 
          }
           
        });
      }).catchError((error) {
        if (error.runtimeType == CameraException) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Issues with Camera"),
          ));
        }
      });
    });
  });
  }
  void dispose() {
    _mainCamera.dispose();
    super.dispose();
  }

  void updateButtons(String state) {
    if (state == 'QR') {
      setState(() {
        _isQR = true;
        _isSearcher = !_isQR;
      });
    } else {
      setState(() {
        _isSearcher = true;
        _isQR = !_isSearcher;
      });
    }
  }

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: new AppBar(
        title: AutoSizeText("Add Members to \'" + eventMetadata['event_name'] + "\'", maxLines: 1,),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {Navigator.of(context).pop()}
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
      body: Center(
        child: Column(
                children: <Widget>[
                  _connectionState.contains('none')
                      ? showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Network Error",
                                  style:
                                      TextStyle(fontFamily: 'Lato', color: Colors.red)),
                              content: Text(
                                  "There is an error connecting to network. Once we detect a connecton, this page will automatically disappear."),
                            );
                          })
                      :
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
                              height: 50,
                              child: RaisedButton(
                                onPressed: () =>
                                    setState(() => updateButtons('QR')),
                                child: Text(
                                  "QR Reader",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: _isQR ? Colors.blue : Colors.grey,
                                textColor: Colors.white,
                              ),
                            )),
                        Spacer(flex: 1),
                        Expanded(
                            flex: 7,
                            child: Container(
                              height: 50,
                              child: RaisedButton(
                                onPressed: () =>
                                    setState(() => updateButtons('S')),
                                child: Text("Searcher",
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                      fontSize: 15,
                                    )),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: _isSearcher ? Colors.blue : Colors.grey,
                                textColor: Colors.white,
                              ),
                            ))
                      ],
                    ),
                  ),
                    if(_isQR)
                      Container(
                          height: screenHeight - 350,
                          width: screenWidth - 100,
                          child: _isCameraInitalized
                              ? RotationTransition(
                                  child: CameraPreview(_mainCamera),
                                  turns: AlwaysStoppedAnimation(270 / 360))
                              : Text("Loading...")
                      ),
                    if(_isSearcher)
                      Container(),
                    Container(
                        padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                        width: screenWidth - 200,
                        height: 75,
                        child: new RaisedButton(
                          child: Text('Finish',
                              style: new TextStyle(fontSize: 17, fontFamily: 'Lato')),
                          textColor: Colors.white,
                          color: Color.fromRGBO(46, 204, 113, 1),
                          onPressed: (){
                            _mainCamera.stopImageStream();
                            Navigator.pop(context);},
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        )
                    )
                ],
            ),
      ),
      );
  }

}

class CreateEventUI extends StatefulWidget {
  String _uid;

  CreateEventUI(uid) {
    this._uid = uid;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CreateEventUIState(_uid);
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
   Map eventMetaData= {};

      //creating a new event in Firestore
    if(_isManualEnter)
      {
        eventMetaData = {
          "event_name": _eventName.text,
          "event_date": _eventDate,
          "event_type": _eventType,
          "enter_type": _enterType,
          "attendee_count":0,
        } as Map;
        await Firestore.instance.collection("Events").document(_eventName.text).setData(eventMetaData);
        Navigator.of(context).push(NoTransition(builder: (context) => Finder(eventMetaData)));
      }
    else
      {
        eventMetaData = {
          "event_name": _eventName.text,
          "event_date": _eventDate,
          "event_type": _eventType,
          "enter_type": _enterType,
          'gold_points': int.parse(_goldPoints.text),
          "attendee_count":0,
        } as Map;
        await Firestore.instance.collection("Events").document(_eventName.text).setData(eventMetaData);
        Navigator.of(context).push(NoTransition(builder: (context)=> Scanner(eventMetaData,_uid)));
      }

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
        appBar: new AppBar(
          title: Text("Admin Functions"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {Navigator.push(context, NoTransition(builder: (context) => new AdminScreenUI(_uid)))}
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
        body: SingleChildScrollView(
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

  _AdminUIState(uid) {
    this._uid = uid;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: new AppBar(
          title: Text("Admin Functions"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () =>
                  {Navigator.push(context, NoTransition(builder: (context) => new ProfileScreen(_uid)))}
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
        body: ListView(
          children: <Widget>[
            Card(
                child: ListTile(
                    leading: Icon(Icons.create),
                    title: Text('Create an Event'),
                    onTap: () =>
                        Navigator.push(context, NoTransition(builder: (context) => new CreateEventUI(_uid)))
                )),
            Card(
                child: ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text('Edit Events'),
                  onTap: () =>
                      Navigator.push(context, NoTransition(builder: (context) => new EditEventUI(_uid))),
                )),
            Card(
                child: ListTile(
                  leading: Icon(Icons.supervisor_account),
                  title: Text('Edit Individual Members'),
                )
            )
          ],
        )
    );
  }
}

class EditEventUI extends StatefulWidget
{
  String _uid;

  EditEventUI(String uid)
  {
    _uid = uid;
  }

  State<EditEventUI> createState()
  {
    return _EditEventUIState(_uid);
  }
}

class _EditEventUIState extends State<EditEventUI>
{
  String _uid;

  _EditEventUIState(String uid)
  {
    _uid = uid;
  }

  ListView _buildEventList(context, snapshot) {
    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: snapshot.data.documents.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        DocumentSnapshot userInfo = snapshot.data.documents[int];
        return Card(
          child: ListTile(
            title: Text(userInfo['event_name'],
                textAlign: TextAlign.left,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                )
            ),
            subtitle: Text(userInfo['event_type']),
            onTap: (){
              Navigator.of(context).push(NoTransition(builder: (context)=> Scanner(userInfo.data,_uid)));
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
            onPressed: () => {Navigator.push(context, NoTransition(builder: (context) => new AdminScreenUI(_uid)))}
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('Events').snapshots(),
              builder: (context, snapshot){
                if(snapshot.hasData)
                  {
                    return Center(
                      child: Container(
                        height: screenHeight - 75,
                        width: screenWidth - 25,
                        child: _buildEventList(context, snapshot),
                      ),
                    );
                  }
                else {
                  return Text("Loading...");
                }
              },
            ),
          ],
        ),
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

class EventInfoUI extends StatefulWidget
{
  Map eventMetadata;

  EventInfoUI(Map metadata)
  {
    eventMetadata = metadata;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventInfoUIState(eventMetadata);
  }

}

class _EventInfoUIState extends State<EventInfoUI>
{
  Map eventMetadata;
  int scanCount;
  _EventInfoUIState(metadata)
  {
    eventMetadata = metadata;
    scanCount = eventMetadata['attendee_count'];
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // TODO: implement build
    return Container(
      width: screenWidth - 100,
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
                      fontSize: 20
                  )
              ),
              trailing: Container(
                width: 100,
                height:50,
                child: TextFormField(
                  initialValue: (eventMetadata['enter_type'] == 'QE')?(eventMetadata['gold_points'].toString()):"",
                  enabled: (eventMetadata['enter_type'] == 'ME')?true:false,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 249, 166, 22)
                  ),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  )
              ),
              trailing:
              Text(eventMetadata['event_date'],
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 249, 166, 22)
                ),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  )
              ),
              trailing: Container(
                width: 100,
                height:50,
                child: Text(scanCount.toString(),
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 249, 166, 22)
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}