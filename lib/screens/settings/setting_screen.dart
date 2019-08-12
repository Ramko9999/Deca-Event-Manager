import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';

class SettingScreen extends StatefulWidget {
  String _uid;

  SettingScreen(String uid) {
    this._uid = uid;
  }
  @override
  State<SettingScreen> createState() => new SettingScreenState(_uid);
}

class SettingScreenState extends State<SettingScreen> {
  final _settingsForm = new GlobalKey<FormState>();
  TextEditingController _newUsername = new TextEditingController();
  TextEditingController _newPassword = new TextEditingController();
  TextEditingController _enteredOldPassword = new TextEditingController();
  String _oldpassword;
  bool _isAutoLoginEnabled = false;
  String _uid;
  bool _isAsyncActionOccuring =
      false; //this will be used as a progress indicator

  SettingScreenState(String uid) {
    this._uid = uid;
    grabLocalStorage(); //initally grabbing the local storage
  }

  //used to create a pop up
  Widget _successPopup(BuildContext context) {
    return AlertDialog(
      title: Text("Successful", style: TextStyle(fontFamily: 'Lato')),
      content: Container(
        height: MediaQuery.of(context).size.height/6.0,
        child: Column(
          children: <Widget>[
            Text("We have succesfully updated your information!",
                style: TextStyle(fontFamily: 'Lato')),
            FlatButton(
              child: Text("Got it!", style: TextStyle(fontFamily: 'Lato')),
              onPressed: () => Navigator.of(context).pop(),
              textColor: Colors.blue,
            )
          ],
        ),
      ),
    );
  }

  //will actually connect and change the data
  void connectAndChange() async{
    final user = await FirebaseAuth.instance.currentUser(); //from FirebaseAuth
    final userData = Firestore.instance
        .collection("Users")
        .document(_uid); // from Cloud Firestore
    
    //grab the local storage and get local user info contents
    final appDirectory = await getApplicationDocumentsDirectory();
    File localUserInfo = File(appDirectory.path + "/user.json");
    Map userInfo = json.decode(await localUserInfo.readAsString());
    //start updating the fields
    if (_newUsername.text != "") {
      user.updateEmail(_newUsername.text); //updating firebase auth
      userInfo['username'] = _newUsername.text; //updating local storage
      userData.updateData({'username': _newUsername.text});
    }
    if (_newPassword.text != "") {
      user.updatePassword(_newPassword.text);
      userInfo['password'] = _newPassword.text;
      userData.updateData({'password': _newPassword.text});
    }

    userInfo['auto'] = _isAutoLoginEnabled;
    localUserInfo.writeAsStringSync(json.encode(userInfo)); //write the json string to the documents
    grabLocalStorage();
    //shows a success screen
    showDialog(
        context: context,
        builder: (context) {
          return _successPopup(context);
        });
  }

  //function is responsible for handling changes
  void changeDetails() async {
    setState(()=>_isAsyncActionOccuring = true);
    
    //check if network is working
    Connectivity().checkConnectivity().then((connectionState){
      print(connectionState);
      if(connectionState == ConnectivityResult.none){
        setState(() => _isAsyncActionOccuring = false);
        throw Exception("Phone is not connected to internet");
      }
      else{
        connectAndChange();
      }

    }).catchError((error){
      print("ERROR IS $error");
    });
    
    }

  //used to reupdate _oldpassword
  void grabLocalStorage() async {
    //getting app directory used to store data
    final appDirectory = await getApplicationDocumentsDirectory();
    Map userInfo = json
        .decode(await File(appDirectory.path + "/user.json").readAsString());
    _oldpassword = userInfo['password'];
    _isAutoLoginEnabled = userInfo['auto'];
    setState(() => _isAsyncActionOccuring = false);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_left),
            onPressed: () => Navigator.of(context).pop(), //goes back a screen
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Form(
                key: _settingsForm,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _newUsername,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Lato'),
                      decoration: new InputDecoration(
                        labelText: "Change Email",
                      ),
                      validator: (val) {
                        //check if email is valid or even entered
                        if (val != "") {
                          bool containsDot = val.contains(".");
                          bool containsAt = val.contains("@");
                          if (!(containsDot && containsAt)) {
                            return "Invalid Email";
                          }
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                        controller: _enteredOldPassword,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Lato'),
                        obscureText: true,
                        decoration: new InputDecoration(
                          labelText: "Enter Old Password",
                        ),
                        validator: (val) {
                          if (_newPassword.text != "") {
                            if (val != _oldpassword && val != "") {
                              return "Old Password Is Wrong";
                            }
                          }
                          return null;
                        }),
                    TextFormField(
                      controller: _newPassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Lato'),
                      obscureText: true,
                      decoration:
                          new InputDecoration(labelText: "Enter New Password"),
                      validator: (val) {
                        if (val == "") {
                          return null;
                        }
                        if (_enteredOldPassword.text == "") {
                          return "Please Enter Your Old Password";
                        }
                        if (val.length < 8) {
                          return "Password too weak";
                        }
                        return null;
                      },
                    ),
                    FlatButton(
                      child: _isAutoLoginEnabled
                          ? Text(
                              "Disable Autofill",
                              style: TextStyle(
                                  fontFamily: 'Lato', color: Colors.red),
                            )
                          : Text("Enable Autofill",
                              style: TextStyle(
                                  fontFamily: 'Lato', color: Colors.blue)),
                      onPressed: () => setState(
                          () => _isAutoLoginEnabled = !_isAutoLoginEnabled),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "Apply Changes",
                          style: TextStyle(fontFamily: 'Lato', fontSize: 32),
                        ),
                        onPressed: () {
                          if (_settingsForm.currentState.validate()) {
                            changeDetails();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (_isAsyncActionOccuring)
              Stack(
                children: <Widget>[
                  Container(
                    color: Colors.black45,
                  ),
                  Container(
                    child: Positioned(
                        top: MediaQuery.of(context).size.height / 2,
                        right: MediaQuery.of(context).size.width / 2,
                        child: CircularProgressIndicator()),
                  )
                ],
              )
          ],
        ));
  }
}
