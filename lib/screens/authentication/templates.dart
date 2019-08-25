import 'package:connectivity/connectivity.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/error_popup.dart';
import 'package:deca_app/utility/single_action_popup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

//login template
class LoginTemplate extends StatefulWidget {
  LoginTemplate();

  @override
  State<LoginTemplate> createState() {
    return _LoginTemplateState();
  }
}

class _LoginTemplateState extends State<LoginTemplate> {
  final _loginFormKey = GlobalKey<FormState>();
  TextEditingController _username = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  bool _desiresAutoLogin = false;
  bool _isLogginIn = false;

  _LoginTemplateState() {
    autoLogin();
  }

  void autoLogin() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    //check to see if the file for the json object is there
    if (await File(appDirectory.path + "/user.json").exists()) {
      Map userInfo = json
          .decode(await File(appDirectory.path + "/user.json").readAsString());
      setState(() {
        _desiresAutoLogin = userInfo['auto'];
        if (_desiresAutoLogin) {
          _username.text = userInfo['username'];
          _password.text = userInfo['password'];
        }
      });
    }
  }

  //try executing the actual login process
  void executeLogin() async {
    final container = StateContainer.of(context);
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _username.text, password: _password.text)
        .then((authResult) async {
      String userId =
          authResult.user.uid; //used to query for the user data in firestore
      container.setUID(userId);

      final appDirectory = await getApplicationDocumentsDirectory();

      //write to json file
      final userStorageFile = File(appDirectory.path + "/user.json");
      Map jsonInformation = {
        'auto': _desiresAutoLogin,
        'username': _username.text,
        'password': _password.text
      };
      userStorageFile.writeAsStringSync(json.encode(jsonInformation));
      //changes screen to profile screen
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => new ProfileScreen()));
    }).catchError((error) {
      setState(() => _isLogginIn = false);
      //if credentials are invalid then throw the error
      if (error.toString().contains("INVALID") ||
          error.toString().contains("WRONG") ||
          error.toString().contains("NOT_FOUND")) {
        showDialog(
            context: context,
            builder: (context) {
              return ErrorPopup("Invalid Credentials", () {
                Navigator.of(context).pop();
                tryToLogin();
              });
            });
      }
    });
  }

  //grabs login information from cloud firestore
  void tryToLogin() async {
    setState(() {
      _isLogginIn = true;
    });
    Connectivity().checkConnectivity().then((connectionState) {
      if (connectionState == ConnectivityResult.none) {
        throw Exception("Phone is not connected to wifi");
      } else {
        executeLogin();
      }
    }).catchError((error) {
      setState(() => _isLogginIn = false);
      //checking the type of error
      //wifi error
      if (error.toString().contains("Phone")) {
        showDialog(
            context: context,
            builder: (context) {
              return ErrorPopup("Phone is not connected to Wifi", () {
                Navigator.of(context).pop();
                tryToLogin();
              });
            });
      }
    });

    //grabbing the information from firebase auth
  }

  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth * 0.8,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  child: Text(
                    "Login",
                    style: new TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 32 * textScaleFactor,
                    ),
                  ),
                ),
              ),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Container(
                        width: screenWidth - 100,
                        //make this a TextField if using controller
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _username,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * textScaleFactor),
                          validator: (val) {
                            if (val != "") {
                              setState(() {
                                _username.text = val;
                              });
                            }

                            bool dotIsNotIn = _username.text.indexOf(".") == -1;
                            bool atIsNotIn = _username.text.indexOf("@") == -1;
                            if (dotIsNotIn || atIsNotIn) {
                              return "Invalid Email Type";
                            }
                            return null;
                          },
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration(
                            icon: Icon(Icons.mail),
                            labelText: "Email",
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth - 100,
                      //make this a TextField if using controller
                      child: TextFormField(
                        controller: _password,
                        style: TextStyle(
                            fontFamily: 'Lato', fontSize: 18 * textScaleFactor),
                        validator: (val) {
                          if (val == "") {
                            return "Field is empty";
                          }
                          setState(() {
                            _password.text = val;
                          });
                          bool hasLengthLessThan8 = _password.text.length < 8;
                          if (hasLengthLessThan8) {
                            return "Password less than 8";
                          }
                          return null;
                        },
                        textAlign: TextAlign.center,
                        obscureText: true,
                        decoration: new InputDecoration(
                            icon: Icon(Icons.lock), labelText: "Password"),
                      ),
                    ),
                    Container(
                      child: FlatButton(
                        child: !_desiresAutoLogin
                            ? Text("Enable Auto-Login",
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    color: Colors.blue,
                                    fontSize: 18 * textScaleFactor))
                            : Text("Disable Auto-Login",
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    color: Colors.red,
                                    fontSize: 18 * textScaleFactor)),
                        onPressed: () => setState(
                            () => _desiresAutoLogin = !_desiresAutoLogin),
                      ),
                    ),
                    Padding(
                      padding: new EdgeInsets.all(20.0),
                      child: ButtonTheme(
                          minWidth: 150,
                          height: screenHeight * 0.07,
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: Container(
                              child: Text(
                                "Login",
                                style: new TextStyle(
                                    fontSize: 20 * textScaleFactor,
                                    fontFamily: 'Lato'),
                              ),
                            ),
                            onPressed: () {
                              //logging into firebase test
                              if (_loginFormKey.currentState.validate()) {
                                tryToLogin();
                              }
                            },
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLogginIn)
          Container(
              width: screenWidth * 0.8,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.23),
                child: CircularProgressIndicator(),
              )),
      ],
    );
  }
}

//Register Template Class
class RegisterTemplate extends StatefulWidget {
  @override
  State<RegisterTemplate> createState() {
    return _RegisterTemplateState();
  }
}

class _RegisterTemplateState extends State<RegisterTemplate> {
  String _firstName;
  String _lastName;
  String _username;
  String _password;
  bool _isTryingToRegister = false; //used to give progress bar animation
  final _registrationFormKey = GlobalKey<FormState>();

  //executes the actual registration
  void executeRegistration() async {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _username, password: _password)
        .then((result) async {
      String userId =
          result.user.uid; //grabds user's unique id from Firebase Auth
      final container = StateContainer.of(context);
      container.setUID(userId);

      //creating a new user in Firestore
      await Firestore.instance.collection("Users").document(userId).setData({
        "first_name": _firstName,
        "last_name": _lastName,
        "username": _username,
        "password": _password,
        "gold_points": 0,
        "events":{},
        "groups": ['none'],
        "uid": userId
      });

      setState(() => _isTryingToRegister = false);
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfileScreen()));

      //catching invalid email error
    }).catchError((error) {
      setState(() => _isTryingToRegister = false);
      //if email already exists throw an error popup
      if (error.toString().contains("ALREADY")) {
        showDialog(
            context: context,
            builder: (context) {
              return SingleActionPopup(
                  "Email is already in use", "ERROR!", Colors.red);
            });
      }
    });
  }

  //handles registration of user
  void tryToRegister() async {
    setState(() => _isTryingToRegister = true);
    if (_registrationFormKey.currentState.validate()) {
      Connectivity().checkConnectivity().then((connectionState) {
        if (connectionState == ConnectivityResult.none) {
          throw Exception("Phone is not connected to wifi");
        } else {
          executeRegistration();
        }
      }).catchError((connectionError) {
        setState(() => _isTryingToRegister = false);
        if (connectionError.toString().contains("wifi")) {
          showDialog(
              context: context,
              builder: (context) {
                return ErrorPopup("Phone is not connected to wifi", () {
                  Navigator.of(context).pop();
                  tryToRegister();
                });
              });
        }
      });
    } else {
      setState(() => _isTryingToRegister = false);
    }
  }

  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth * 0.8,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                    child: Text("Register",
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 32 * textScaleFactor))),
              ),
              new Form(
                  key: _registrationFormKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: screenWidth - 100,
                          child: TextFormField(
                            style: new TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 18 * textScaleFactor),
                            textAlign: TextAlign.center,
                            decoration:
                                InputDecoration(labelText: "First Name"),
                            validator: (val) {
                              if (val == "") {
                                return "Field is empty";
                              }
                              setState(() => _firstName = val);
                              return null;
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth - 100,
                        child: TextFormField(
                          style: new TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * textScaleFactor),
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration(
                            labelText: 'Last Name',
                          ),
                          validator: (val) {
                            if (val == "") {
                              return "Field is empty";
                            }
                            setState(() => _lastName = val);
                            return null;
                          },
                        ),
                      ),
                      Container(
                        width: screenWidth - 100,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: new TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * textScaleFactor),
                          validator: (val) {
                            if (val == "") {
                              return "Field is empty";
                            }
                            setState(() {
                              _username = val;
                            });
                            bool dotIsNotIn = _username.indexOf(".") == -1;
                            bool atIsNotIn = _username.indexOf("@") == -1;
                            if (dotIsNotIn || atIsNotIn) {
                              return "Invalid Email Type";
                            }
                            return null;
                          },
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration(
                            icon: Icon(Icons.mail),
                            labelText: "Email",
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth - 100,
                        child: TextFormField(
                          style: new TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * textScaleFactor),
                          validator: (val) {
                            if (val == "") {
                              return "Field is empty";
                            }
                            setState(() {
                              _password = val;
                            });
                            bool hasLengthLessThan8 = _password.length < 8;
                            if (hasLengthLessThan8) {
                              return "Password less than 8";
                            }
                            return null;
                          },
                          textAlign: TextAlign.center,
                          obscureText: true,
                          decoration: new InputDecoration(
                              icon: Icon(Icons.lock), labelText: "Password"),
                        ),
                      ),
                      Padding(
                        padding: new EdgeInsets.all(20.0),
                        child: ButtonTheme(
                            minWidth: 150.0,
                            height: screenHeight * 0.07,
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                child: Text(
                                  "Register",
                                  style: new TextStyle(
                                      fontSize: 20 * textScaleFactor,
                                      fontFamily: 'Lato'),
                                ),
                              ),
                              onPressed: tryToRegister,
                            )),
                      )
                    ],
                  )),
            ],
          ),
        ),
        if (_isTryingToRegister) //to add the progress indicator
          Container(
              width: screenWidth * 0.8,
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.27),
                child: CircularProgressIndicator(),
              ))
      ],
    );
  }
}
