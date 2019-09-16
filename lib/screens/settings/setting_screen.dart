
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/global.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class SettingScreen extends StatefulWidget {
  SettingScreen();

  @override
  State<SettingScreen> createState() => new SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  final _passwordForm = new GlobalKey<FormState>();
  TextEditingController _newPassword = new TextEditingController();
  TextEditingController _enteredOldPassword = new TextEditingController();
  String _oldpassword;
  bool _wantsToChangePassword = false;
  bool _wantsToChangeAutoFill = false;
  bool _isAutoLoginEnabled = false;

  SettingScreenState();

  void initState() {
    super.initState();
    if (mounted) {
      grabLocalStorage();
    }
  }

  //will actually connect and change the data
  void connectAndChange() async {
    final user = await FirebaseAuth.instance.currentUser(); //from FirebaseAuth

    //grab the local storage and get local user info contents

    Map userInfo = json.decode(Global.userDataFile.readAsStringSync());

    //if password field is altered start updating password
    if (_newPassword.text != "") {
      //if firebaseAuth password is not updated then DO NOT UPDATE ANYWHERE ELSE
      user.updatePassword(_newPassword.text).then((_) {
        userInfo['password'] = _newPassword.text;

        //shows a success screen
        showDialog(
            context: context,
            builder: (context) {
              return SingleActionPopup("We were able to change your details",
                  "Success!", Colors.black);
            });

        Global.userDataFile.writeAsStringSync(json.encode(userInfo));
        grabLocalStorage();
      }).catchError((onError) {
        //catching ERROR RECENT LOGIN REQUIRED
        if (onError.toString().contains("RECENT")) {
          showDialog(
              context: context,
              builder: (context) {
                return ConnectionError(
                    "We need to reconnect you to the servers and then change your credential");
              });

          assert(_oldpassword != null);

          //work around for expired auth tokens
          FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: userInfo['username'], password: _oldpassword)
              .then((result) async {
            //make sure a user is actually recognized
            assert(await FirebaseAuth.instance.currentUser() != null);

            Navigator.of(context).pop();

            connectAndChange();
          });
        }
      });
    }
  }

  //function is responsible for handling changes
  void changeDetails() async {
    //check if network is working
    try {
      if (StateContainer.of(context).isThereConnectionError) {
        throw Exception(
            "This action requires network connection, please turn on your wifi or cellular");
      } else {
        connectAndChange();
      }
    } catch (error) {
      
      //show error
      showDialog(
          context: context,
          builder: (context) {
            return ErrorPopup(error.toString().substring(10), () {
              Navigator.of(context).pop();
              changeDetails();
            });
          });
    }
  }

  //used to reupdate _oldpassword
  void grabLocalStorage() async {
    assert(Global.userDataFile.readAsStringSync() != null);

    Map userInfo = json.decode(Global.userDataFile.readAsStringSync());
    //fetch details from userDataFile
    _oldpassword = userInfo['password'];
    _isAutoLoginEnabled = userInfo['auto'];
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            onPressed: () {
              //remove focus at when exiting
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(FocusNode());
            }, //goes back a screen
          ),
        ),
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                _wantsToChangePassword
                    ? Card(
                        child: Column(children: [
                        ListTile(
                          leading: Icon(Icons.lock, color: Colors.black),
                          title: Text(
                            "Change Password",
                            style: TextStyle(
                                fontSize: 20 * screenWidth / pixelTwoWidth),
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
                                      style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize:
                                              18 * screenWidth / pixelTwoWidth),
                                      obscureText: true,
                                      decoration: new InputDecoration(
                                        labelText: "Enter Old Password",
                                      ),
                                      validator: (val) {
                                        //checks whether user intends to change the password
                                        if (_newPassword.text != "") {
                                          //check whether old password is correct or is nothing
                                          if (val != _oldpassword) {
                                            assert(_oldpassword != null);

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
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 18 * screenWidth / pixelTwoWidth),
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
                                      fontSize: 18 * screenWidth / pixelTwoWidth,
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
                          child: Card(
                              child: ListTile(
                            leading: Icon(Icons.lock, color: Colors.black),
                            title: Text(
                              "Change Password",
                              style: TextStyle(
                                  fontSize: 20 * screenWidth / pixelTwoWidth),
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
                              style: TextStyle(
                                  fontSize: 20 * screenWidth / pixelTwoWidth),
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
                                    Map userFile = json.decode(
                                        Global.userDataFile.readAsStringSync());

                                    userFile['auto'] = !userFile['auto'];

                                    Global.userDataFile
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
                                      fontSize: 18 * screenWidth / pixelTwoWidth,
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
                            style: TextStyle(
                                fontSize: 20 * screenWidth / pixelTwoWidth),
                          ),
                        )),
                      )
              ],
            ),
          if (StateContainer.of(context).isThereConnectionError)
            OfflineNotifier()
          
          ],
        ));
  }
}
