import 'package:connectivity/connectivity.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/global.dart';
import 'package:deca_app/utility/network.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:deca_app/screens/profile/profile_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

//login template
class LoginTemplate extends StatefulWidget {
  LoginTemplate();

  @override
  State<LoginTemplate> createState() {
    return _LoginTemplateState();
  }
}

class _LoginTemplateState extends State<LoginTemplate> {
  //variables to change UI based on state

  final _loginFormKey = GlobalKey<FormState>();

  TextEditingController _username = new TextEditingController();
  TextEditingController _password = new TextEditingController();

  bool _desiresAutoLogin = false;
  bool _isLogginIn = false;

  _LoginTemplateState() {
    autoLogin();
  }

  //will auto fill the user's information in the controllers
  void autoLogin() async {
    final appDirectory =
        await getApplicationDocumentsDirectory(); //get app directory

    //check whether the file exists
    if (File(appDirectory.path + "/user.json").existsSync()) {
      Map userInfo = json.decode(File(appDirectory.path + "/user.json")
          .readAsStringSync()); //read data from file

      //alter UI with the autofill information
      setState(() {
        _desiresAutoLogin = userInfo['auto'];

        if (_desiresAutoLogin) {
          _username.text = userInfo['username'];
          _password.text = userInfo['password'];
        }
      });
    } else {
      Global.userDataFile = File(appDirectory.path + "/user.json");
    }
  }

  //try executing the actual login process
  void executeLogin() async {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _username.text, password: _password.text)
        .then((authResult) async /*sign in callback */ {
      String userId =
          authResult.user.uid; //used to query for the user data in firestore

      Global.uid = userId;

      final appDirectory = await getApplicationDocumentsDirectory();

      //write to json file

      final userStorageFile = File(appDirectory.path + "/user.json");

      //setting the state container file to the userStorageFile

      Global.userDataFile = userStorageFile;

      assert(Global.userDataFile != null);

      Map jsonInformation = {
        'auto': _desiresAutoLogin,
        'username': _username.text,
        'password': _password.text
      };

      await Global.userDataFile.writeAsString(
          json.encode(jsonInformation)); //update file information

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
              return SingleActionPopup(
                  "Invalid Credentials", "Error", Colors.black);
            });
      }

      //if network times out, throw error
      else if (error.toString().contains("NETWORK")) {
        showDialog(
            context: context,
            builder: (context) {
              return ErrorPopup(
                  "Network timed out, please check your wifi connection", () {
                Navigator.of(context).pop();
                setState(() {
                  _isLogginIn = true;
                });
                executeLogin();
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

    Connectivity()
        .checkConnectivity()
        .then((connectionState) /*check whether phone is connected to wifi */ {
      if (connectionState == ConnectivityResult.none) {
        //connection is not established
        throw Exception("Phone is not connected to wifi");
      } else {
        executeLogin();
      }
    }).catchError((error) {
      setState(() => _isLogginIn = false);

      //wifi exception
      if (error.toString().contains("Phone")) {
        //show error in UI
        showDialog(
            context: context,
            builder: (context) {
              return ErrorPopup("Phone is not connected to Wifi",
                  () /*actions */ {
                Navigator.of(context).pop();
                tryToLogin();
              });
            });
      }
    });

    //grabbing the information from firebase auth
  }

  Widget build(BuildContext context) {
    //used to set relative sizing based on a pixel 2 phone
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth * 0.8,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: 15 * screenHeight / pixelTwoHeight),
                child: Container(
                  child: Text(
                    "Login",
                    style: new TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 32 * screenWidth / pixelTwoWidth,
                    ),
                  ),
                ),
              ),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 15 * screenHeight / pixelTwoHeight),
                      child: Container(
                        width: screenWidth * 0.75,
                        //make this a TextField if using controller
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _username,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * screenWidth / pixelTwoWidth),
                          validator: (val) {
                            if (val != "") {
                              setState(() {
                                _username.text = val;
                              });
                            }

                            bool dotIsNotIn = _username.text.indexOf(".") == -1;
                            bool atIsNotIn = _username.text.indexOf("@") == -1;

                            //validate email locally

                            if (dotIsNotIn || atIsNotIn) {
                              return "Invalid Email Type";
                            }

                            return null;
                          },
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration(
                            icon: Icon(Icons.mail),
                            labelText: "E-mail",
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.75,
                      //make this a TextField if using controller
                      child: TextFormField(
                        controller: _password,
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 18 * screenWidth / pixelTwoWidth),
                        validator: (val) /* check whether the form is valid */ {
                          if (val == "") {
                            return "Field is empty";
                          }

                          setState(() {
                            _password.text = val;
                          });

                          //validate password length
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
                                    fontSize: 18 * screenWidth / pixelTwoWidth))
                            : Text("Disable Auto-Login",
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    color: Colors.red,
                                    fontSize:
                                        18 * screenWidth / pixelTwoWidth)),
                        onPressed: () => setState(
                            () => _desiresAutoLogin = !_desiresAutoLogin),
                      ),
                    ),
                    Padding(
                      padding: new EdgeInsets.all(
                          20.0 * screenHeight / pixelTwoHeight),
                      child: ButtonTheme(
                          minWidth: 150 * screenWidth / pixelTwoWidth,
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
                                    fontSize: 20 * screenWidth / pixelTwoWidth,
                                    fontFamily: 'Lato'),
                              ),
                            ),
                            onPressed: () {
                              //logging into firebase
                              if (_loginFormKey.currentState.validate() &&
                                  !_isLogginIn) {
                                     ConnectionStream cs = new ConnectionStream();

            cs.quickCheckConnection().then((status)=> print("Status is $status"));
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
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  //executes the actual registration
  void executeRegistration() async {
    final appDirectory = await getApplicationDocumentsDirectory();

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _username, password: _password)
        .then((result) async /* create user callback */ {
      String userId =
          result.user.uid; //grabds user's unique id from Firebase Auth

      Global.uid = userId;
      //write to json file
      final userStorageFile = File(appDirectory.path + "/user.json");

      //create local storage map

      Map jsonInformation = {
        'auto': true,
        'username': _username,
        'password': _password
      };

      userStorageFile
          .writeAsStringSync(json.encode(jsonInformation)); //write to file

      //persist file referenece
      Global.userDataFile = userStorageFile;

      assert(Global.userDataFile != null);

      String messagingToken = await _firebaseMessaging.getToken();

      //creating a new user in Firestore
      Firestore.instance.collection("Users").document(userId).setData({
        "first_name": _firstName,
        "last_name": _lastName,
        "gold_points": 0,
        "events": {},
        "groups": [],
        "uid": userId,
        "device-token": messagingToken
      }).then((_) /* call back for creating a users document*/ {
        setState(() => _isTryingToRegister = false);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen())); //go to profile screen
      });
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

      //catch a network timed out error
      if (error.toString().contains("NETWORK")) {
        showDialog(
            context: context,
            builder: (context) {
              return ErrorPopup(
                  "Network timed out, please check your wifi connection", () {
                Navigator.of(context).pop();
                setState(() {
                  _isTryingToRegister = true;
                });
                executeRegistration();
              });
            });
      }
    });
  }

  //handles registration of user
  void tryToRegister() async {
    //checking to make sure multiple attempts at registering doesn't occur
    if (!_isTryingToRegister) {
      setState(() => _isTryingToRegister = true);

      if (_registrationFormKey.currentState
          .validate()) /*check whether form is valid */ {
        Connectivity().checkConnectivity().then(
            (connectionState) /* check whether connection is established */ {
          if (connectionState == ConnectivityResult.none) {
            throw Exception("Phone is not connected to wifi");
          } else {

           
            executeRegistration();
          }
        }).catchError((connectionError) {
          setState(() => _isTryingToRegister = false);

          //show error on UI
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
  }

  Widget build(BuildContext context) {
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth * 0.8,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: screenHeight / 45),
                child: Container(
                    child: Text("Register",
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 32 * screenWidth / pixelTwoWidth))),
              ),
              new Form(
                  key: _registrationFormKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight / 60),
                        child: Container(
                          width: screenWidth * 0.75,
                          child: TextFormField(
                            style: new TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 18 * screenWidth / pixelTwoWidth),
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
                        width: screenWidth * 0.75,
                        child: TextFormField(
                          style: new TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * screenWidth / pixelTwoWidth),
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
                        width: screenWidth * 0.75,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: new TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * screenWidth / pixelTwoWidth),
                          validator: (val) {
                            if (val == "") {
                              return "Field is empty";
                            }
                            setState(() {
                              _username = val;
                            });

                            //validate email
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
                            labelText: "E-mail",
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.75,
                        child: TextFormField(
                          style: new TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18 * screenWidth / pixelTwoWidth),
                          validator: (val) {
                            //validate password
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
                        padding: new EdgeInsets.all(screenHeight / 45),
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
                                      fontSize:
                                          20 * screenWidth / pixelTwoWidth,
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

class ForgotPasswordTemplate extends StatefulWidget {
  State<ForgotPasswordTemplate> createState() {
    return ForgotPasswordTemplateState();
  }
}

class ForgotPasswordTemplateState extends State<ForgotPasswordTemplate> {
  TextEditingController email = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEmailSent = false;

  //sends reset email
  void sendEmail() {
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: this.email.text)
        .then((_) {
      setState(() => _isEmailSent = true);
    }).catchError((error) {
      if (error.toString().contains("USER_NOT")) {
        showDialog(
            context: context,
            builder: (context) {
              return SingleActionPopup("This email is not in our system",
                  "Auth Error", Colors.black);
            });
      }
    });
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        width: screenWidth * 0.8,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.06),
            child: Container(
              child: Text(
                "Forgot Password",
                style: new TextStyle(
                  fontFamily: 'Lato',
                  fontSize: Sizer.getTextSize(screenWidth, screenHeight, 32),
                ),
              ),
            ),
          ),
          if (_isEmailSent)
            Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.03, bottom: screenHeight * 0.06),
              child: Container(
                child: Text(
                  "We have sent an email to ${email.text}. It should have instructions on how to reset your password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Lato",
                      fontSize:
                          Sizer.getTextSize(screenWidth, screenHeight, 14)),
                ),
              ),
            ),
          if (!_isEmailSent)
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.03),
                  child: Container(
                    child: Text(
                      "Provide us your email address, so that we send you an email to reset your password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Lato",
                          fontSize:
                              Sizer.getTextSize(screenWidth, screenHeight, 15)),
                    ),
                  ),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              bottom: screenHeight * 0.06,
                              top: screenHeight * 0.06),
                          width: screenWidth * 0.75,
                          child: TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                icon: Icon(Icons.email), labelText: "Email"),
                            validator: (val) {
                              bool isThereAnAt = val.contains('@');
                              bool isThereADot = val.contains(".");
                              if (val.length == 0) {
                                return "No Email";
                              }
                              if (!isThereADot || !isThereAnAt) {
                                return "Invalid Email";
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    )),
                FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      sendEmail();
                    }
                  },
                  child: Text(
                    "Send Email",
                    style: TextStyle(
                        fontFamily: "Lato",
                        fontSize:
                            Sizer.getTextSize(screenWidth, screenHeight, 16)),
                  ),
                  textColor: Colors.blue,
                )
              ],
            ),
        ]));
  }
}
