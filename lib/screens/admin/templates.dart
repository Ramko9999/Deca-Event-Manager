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

class Finder extends StatefulWidget{
  Map eventMetaData;

  Finder(Map e){
    this.eventMetaData = e;
  }

  State<Finder> createState(){
    return FinderState(eventMetaData);
  }
}

class FinderState extends State<Finder>{
  Map eventMetaData;
  TextEditingController _firstName = new TextEditingController();
  TextEditingController _lastName = new TextEditingController();
  var barTitle;
  

  FinderState(Map e){
    this.eventMetaData = e;
    barTitle = Text("Search something");
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: barTitle,
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: (){
            setState((){
              barTitle = Row(children: <Widget>[
                TextField(
                  controller: _firstName,
                  onChanged:(val)=> setState(()=> print("grab results")) ,
                  decoration: InputDecoration(
                    labelText: 'First Name'
                  ),
                ),
                TextField(
                  controller: _lastName,
                  decoration: InputDecoration(
                    labelText: 'Last Name'
                  ),
                  onChanged: (val)=> setState(()=> print("grab results")),
                )
              ],);
            });
          },
      ),
    ),
    body: SingleChildScrollView(child: grabListElements(context))
    );
  }

  Widget grabListElements(BuildContext context){
    MaxList relevanceList = getData();
    if(relevanceList.length == 0){
      return Text("No results bro!");
    }

    Node current = relevanceList.head;
    return ListView.builder(
      itemCount: relevanceList.length,
      itemBuilder: (context, itemCount){
       ListTile userTile = ListTile(
         title: Text(current.element['info']['first_name'] + " " + current.element['info']['last_name'], style: TextStyle(fontFamily: 'Lato'),),
         subtitle: Text(current.element['info']['god_points'], style: TextStyle(fontFamily: 'Lato', color:  Color.fromARGB(255, 249, 166, 22) ),),
       );
       current = current.next;
       return userTile;
      },
    );

  }

  MaxList getData(){
     Firestore.instance.collection("Users").getDocuments().then((onDocuments){
       List<Map> userList = [];
       //turn this into map with uid and names
       for(int i = 0; i <onDocuments.documents.length; i++){
         Map userData = onDocuments.documents[i].data;
         userList.add(userData);
       }

       Searcher searcher = new Searcher(userList, _firstName.text, _lastName.text);
       return searcher.search(); //return a MaxList that contains all the values of the users in a relevant manner
     });
  }
}

class Scanner extends StatefulWidget {
  Map eventMetaData;

  Scanner(Map e) {
    this.eventMetaData  = e;
  }
  State<Scanner> createState() {
    return _ScannerState(eventMetaData);
  }
}

class _ScannerState extends State<Scanner> {
  HashSet<String> _scannedUids; //used to keep track of already scanned codes
  String _connectionState; //used to listen to connection changes
  List _cameras; //used to grab cameras
  CameraController _mainCamera; //camera that will give us the feed
  bool _isCameraInitalized = false;
  Map eventMetadata;
  int pointVal;

  _ScannerState(Map e) {
    _scannedUids = new HashSet();
    _connectionState = "Unknown Connection";
    eventMetadata = e;
    pointVal = eventMetadata['gold_points'];
  }

  //runs scanStream forever on delay
  void scanStream() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      scanImage();
    }
  }

  //scan the actual barcode through an image stream
  void scanImage() async {

    //starting image stream and saving file
    getApplicationDocumentsDirectory().then((dir) {
      String imagePath = dir.path + "/code.png"; //path for the image
      if (File(imagePath).existsSync()) {
        File(imagePath).deleteSync();
      }
      //take picture and save progress
      _mainCamera.takePicture(imagePath).then((val) {
        //apply ml to the picture and get raw value
        FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(imagePath);
        FirebaseVision.instance
            .barcodeDetector()
            .detectInImage(image)
            .then((barcodes) {
          for (int i = 0; i < barcodes.length; i++) {
            //update db
            String userUniqueID = barcodes[0].rawValue;

            //check if uid has already been scanned
            if(!_scannedUids.contains(userUniqueID)){
              Firestore.instance
                .collection("Users")
                .document(userUniqueID)
                .get()
                .then((userData) {
              //blindly increment gold points this might be where you want to change such that event data and user dictionary are updated
              Firestore.instance
                  .collection("Users")
                  .document(userUniqueID)
                  .updateData(
                      {'gold_points': userData.data['gold_points'] + pointVal});

              //update the events
              Firestore.instance.collection('Events').document(eventMetadata['event_name']).updateData({'attendee_count': FieldValue.increment(1)});        
              //update the scaffold

              //append to the hashset the uniqueID
              _scannedUids.add(userUniqueID);
            }).catchError((onError) => print(onError));
            }
            else{
              print("Already Scanned this person");
            }
            
          }
        });
      }).catchError((onError) {
        print(onError);
      });
    });
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
      _mainCamera = CameraController(allCameras[0], ResolutionPreset.high);
      _mainCamera.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() => _isCameraInitalized = true); //show the actual camera
        scanStream();
      }).catchError((error) {
        if (error.runtimeType == CameraException) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Issues with Camera"),
          ));
        }
      });
    });
  }

  void dispose(){
    _mainCamera.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
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
                        "There is an error connecting to network, once we detect a connecton, this page will automatically dissapear"),
                  );
                })
            : Stack(
                children: <Widget>[
                  Container(
                      height: screenHeight,
                      width: screenWidth,
                      child: _isCameraInitalized
                          ? RotationTransition(
                              child: CameraPreview(_mainCamera),
                              turns: AlwaysStoppedAnimation(270 / 360))
                          : Text("Loading...")),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                        child: Text("Done"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                ],
              ),
      ],
    ));
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
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Finder(eventMetaData)));
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
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Scanner(eventMetaData)));
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