import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_first_app/screens/profile/profile_screen.dart';
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
  String _username = "";
  String _password = "";
  Firestore _fireStore = Firestore.instance; //database connection

  _LoginTemplateState() {
    print('created');
    //autoLogin();
  }

  String fieldMustNotBeEmpty(val) {
    if (val == "") {
      return "Field is empty";
    }
  }

  void autoLogin() async {
    final appDirectory = await getApplicationDocumentsDirectory();

    //check to see if the file for the json object is there
    if (await File(appDirectory.path + "/user.json").exists()) {
      Map userInfo = json
          .decode(await File(appDirectory.path + "/user.json").readAsString());
      _username = userInfo['username'];
      _password = userInfo['password'];

      try {
        AuthResult result = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _username, password: _password);
        print("Login Successfull");

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => new ProfileScreen(result.user.uid)));
      } catch (error) {
        print(error);
      }
    } else {
      print("File doesn't exist");
    }
  }

  //grabs login information from cloud firestore
  void tryToLogin() async {
    try {
      //grabbing the information from firebase auth
      AuthResult authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _username, password: _password);

      String userId =
          authResult.user.uid; //used to query for the user data in firestore

      //grabbing user information anf setting it to a variable
      _fireStore
          .collection("Users")
          .where("uid", isEqualTo: userId)
          .snapshots()
          .listen((onData) => print(onData.documents[0]['last_name']));

      final appDirectory = await getApplicationDocumentsDirectory();

      //check to see if json file exists
      if (!await File(appDirectory.path + "/user.json").exists()) {
        //write to json file
        final userStorageFile = File(appDirectory.path + "/user.json");
        Map jsonInformation = {'username': _username, 'password': _password};
        userStorageFile.writeAsString(json.encode(jsonInformation));
        print("Set the userInfo in local storage");
      }

      print(userId);
      //changes screen to profile screen
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => new ProfileScreen(userId)));
    } catch (error, stackTrace) {
      print(error);
    }
  }

  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: <Widget>[
            Container(
              width: 185,
              child: TextFormField(
                initialValue: _username,
                validator: (val) {
                  fieldMustNotBeEmpty(val);
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
                  icon: Icon(Icons.person),
                  labelText: "Username",
                ),
              ),
            ),
            Container(
              width: 185,
              child: TextFormField(
                initialValue: _password,
                validator: (val) {
                  fieldMustNotBeEmpty(val);
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
              padding: EdgeInsets.only(top: 25),
              child: RaisedButton(
                  child: Text("Login"),
                  onPressed: () {
                    //logging into firebase test
                    if (_loginFormKey.currentState.validate()) {
                      tryToLogin();
                    }
                  }),
            ),
          ],
        ),
      ),
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
  final _registrationFormKey = GlobalKey<FormState>();

  //handles registration of user
  void tryToRegister() async {
    if (_registrationFormKey.currentState.validate()) {
      try {
        //creating a new user in Firebase Auth
        AuthResult result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _username, password: _password);

        String userId = result.user.uid;

        //creating a new user in Firestore
        await Firestore.instance.collection("Users").add({
          "first_name": _firstName,
          "last_name": _lastName,
          "username": _username,
          "password": _password,
          "gold_points": 0,
          "groups": ['none'],
          "uid": userId
        });

        print("Succesfully registered user");
      } catch (error, stackTrace) {
        print(error);
      }
    }
  }

  //checks whether a field in the registration form is empty
  String fieldMustNotBeEmpty(val) {
    if (val == "") {
      return "Field is empty";
    }
  }

  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: new Form(
          key: _registrationFormKey,
          child: Column(
            children: <Widget>[
              Container(
                width: 185,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(labelText: "First Name"),
                  validator: (val) {
                    fieldMustNotBeEmpty(val);
                    setState(() => _firstName = val);
                    return null;
                  },
                ),
              ),
              Container(
                width: 185,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(labelText: 'Last Name'),
                  validator: (val) {
                    fieldMustNotBeEmpty(val);
                    setState(() => _lastName = val);
                    return null;
                  },
                ),
              ),
              Container(
                width: 185,
                child: TextFormField(
                  validator: (val) {
                    fieldMustNotBeEmpty(val);
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
                    icon: Icon(Icons.person),
                    labelText: "Username",
                  ),
                ),
              ),
              Container(
                width: 185,
                child: TextFormField(
                  validator: (val) {
                    fieldMustNotBeEmpty(val);
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
                padding: new EdgeInsets.only(top: 25),
                child: RaisedButton(
                  textColor: Colors.white,
                  child: Container(
                    child: Text("Register"),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.green]
                      ),
                      
                    ),
                  ),
                  onPressed: tryToRegister,
                  
                ),
              )
            ],
          )),
    );
  }
}
