import 'package:connectivity/connectivity.dart';
import 'package:deca_app/utility/error_popup.dart';
import 'package:deca_app/utility/single_action_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class SettingScreen extends StatefulWidget {
  String _uid;

  SettingScreen(String uid) {
    this._uid = uid;
  }

  @override
  State<SettingScreen> createState() => new SettingScreenState(_uid);
}

class SettingScreenState extends State<SettingScreen> {
  final _passwordForm = new GlobalKey<FormState>();
  TextEditingController _newPassword = new TextEditingController();
  TextEditingController _enteredOldPassword = new TextEditingController();
  String _oldpassword;
  bool _wantsToChangePassword = false;
  bool _wantsToChangeAutoFill = false;
  bool _isAutoLoginEnabled = false;
  String _uid;

  SettingScreenState(String uid) {
    this._uid = uid;
    grabLocalStorage(); //initally grabbing the local storage
  }

  //will actually connect and change the data
  void connectAndChange() async {
    bool isReconnectionNecessary = false;
    final user = await FirebaseAuth.instance.currentUser(); //from FirebaseAuth
    print(user);
    final userData = Firestore.instance
        .collection("Users")
        .document(_uid); // from Cloud Firestore

    //grab the local storage and get local user info contents
    final appDirectory = await getApplicationDocumentsDirectory();
    File localUserInfo = File(appDirectory.path + "/user.json");
    Map userInfo = json.decode(await localUserInfo.readAsString());

    //if password field is altered start updating password
    if (_newPassword.text != "") {
      //if firebaseAuth password is not updated then DO NOT UPDATE ANYWHERE ELSE
      user.updatePassword(_newPassword.text).then((dummy_val) {
        userInfo['password'] = _newPassword.text;
        userData.updateData({'password': _newPassword.text});
      }).catchError((onError) {
        //catching ERROR RECENT LOGIN REQUIRED
        if (onError.toString().contains("RECENT")) {
          isReconnectionNecessary = true;
          showDialog(
              context: context,
              builder: (context) {
                if (Platform.isAndroid) {
                  return AlertDialog(
                    title: Container(
                      height: MediaQuery.of(context).size.height / 15,
                      child: Text(
                        "Connecting...",
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                    content: Text(
                      'This will automatically dissapear when we connect you back to the servers and change your credentials',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                } else {
                  return CupertinoAlertDialog(
                    title: Container(
                      height: MediaQuery.of(context).size.height * 15,
                      child: Text(
                        "Connecting...",
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                    content: Text(
                      'This will automatically dissapear when we connect you back to the servers and change your credentials',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }
              });
          //sign user back in and try changing details again
          AuthCredential userCred = EmailAuthProvider.getCredential(
              email: userInfo['username'], password: 'pitch123');
          user.reauthenticateWithCredential(userCred).then((onValue) {
            Navigator.of(context).pop();
            connectAndChange();
          });
        }
      });
    }
    if (!isReconnectionNecessary) {
      userInfo['password'] = _newPassword.text;
      localUserInfo.writeAsStringSync(json.encode(userInfo));
      grabLocalStorage();
      //shows a success screen
      showDialog(
          context: context,
          builder: (context) {
            return SingleActionPopup("We were able to change your details",
                "Success!", Colors.black);
          });
    }
  }

  //function is responsible for handling changes
  void changeDetails() async {
    //check if network is working
    Connectivity().checkConnectivity().then((connectionState) {
      if (connectionState == ConnectivityResult.none) {
        throw Exception("Phone is not connected to internet");
      } else {
        connectAndChange();
      }
    }).catchError((error) {
      //show error output with try again features
      showDialog(
          context: context,
          builder: (context) {
            return ErrorPopup(error.toString().substring(10), () {
              Navigator.of(context).pop();
              changeDetails();
            });
          });
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
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(), //goes back a screen
          ),
        ),
        body: ListView(
          children: <Widget>[
            _wantsToChangePassword
                ? Card(
                    child: Column(children: [
                    ListTile(
                      leading: Icon(Icons.lock, color: Colors.black),
                      title: Text(
                        "Change Password",
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _wantsToChangePassword = !_wantsToChangePassword;
                          });
                        },
                      ),
                    ),
                    Form(
                      key: _passwordForm,
                      child: Column(
                        children: <Widget>[
                          Container(
                              width: screenWidth * 0.8,
                              child: TextFormField(
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
                                  })),
                          Container(
                              width: screenWidth * 0.8,
                              child: TextFormField(
                                controller: _newPassword,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Lato'),
                                obscureText: true,
                                decoration: new InputDecoration(
                                    labelText: "Enter New Password"),
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
                              )),
                          FlatButton(
                            child: Text(
                              "Apply",
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  color: Colors.blue),
                            ),
                            onPressed: () {
                              if (_passwordForm.currentState.validate()) {
                                changeDetails();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ]))
                : GestureDetector(
                    onTap: () => setState(
                        () => _wantsToChangePassword = !_wantsToChangePassword),
                    child: Container(
                      height: screenHeight * 0.10,
                      child: Card(
                          child: ListTile(
                        leading: Icon(Icons.lock, color: Colors.black),
                        title: Text(
                          "Change Password",
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                    ),
                  ),
            _wantsToChangeAutoFill
                ? Card(
                    child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.radio_button_checked,
                            color: Colors.black),
                        title: Text(
                          "Change Autofill Settings",
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              _wantsToChangeAutoFill = !_wantsToChangeAutoFill;
                            });
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                              value: _isAutoLoginEnabled,
                              onChanged: (val) async {
                                final documents =
                                    await getApplicationDocumentsDirectory();
                                final path = documents.path + "/user.json";
                                Map userFile =
                                    json.decode(File(path).readAsStringSync());
                                userFile['auto'] = _isAutoLoginEnabled;
                                File(path)
                                    .writeAsStringSync(json.encode(userFile));
                                setState(() =>
                                    _isAutoLoginEnabled = !_isAutoLoginEnabled);
                              },
                            ),
                            Text(
                              _isAutoLoginEnabled
                                  ? "Autofill is enabled"
                                  : "Autofill is disabled",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  color: _isAutoLoginEnabled
                                      ? Colors.blue
                                      : Colors.red),
                            )
                          ],
                        ),
                      )
                    ],
                  ))
                : GestureDetector(
                    onTap: () {
                      setState(() =>
                          _wantsToChangeAutoFill = !_wantsToChangeAutoFill);
                    },
                    child: Card(
                        child: ListTile(
                      leading:
                          Icon(Icons.radio_button_checked, color: Colors.black),
                      title: Text(
                        "Change Autofill Settings",
                        style: TextStyle(fontSize: 20),
                      ),
                    )),
                  )
          ],
        ));
  }
}
