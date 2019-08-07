import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_first_app/screens/profile/profile_screen.dart';

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
  String _username;
  String _password;
  Firestore _fireStore = Firestore.instance; //database connection
  _LoginTemplateState();

  String fieldMustNotBeEmpty(val) {
    if (val == "") {
      return "Field is empty";
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
          .listen((onData) => print(onData.documents[0]['first_name']));

      //changes screen to profile screen
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => new ProfileScreen(userId)));
    } catch (error, stackTrace) {
      print(error);
    }
  }

  Widget build(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: <Widget>[
          TextFormField(
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
          TextFormField(
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
          RaisedButton(
              child: Text("Login"),
              onPressed: () {
                //logging into firebase test
                if (_loginFormKey.currentState.validate()) {
                  tryToLogin();
                }
              }),
        ],
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
      child: new Form(
          key: _registrationFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(labelText: "First Name"),
                validator: (val) {
                  fieldMustNotBeEmpty(val);
                  setState(() => _firstName = val);
                  return null;
                },
              ),
              TextFormField(
                textAlign: TextAlign.center,
                decoration: new InputDecoration(labelText: 'Last Name'),
                validator: (val) {
                  fieldMustNotBeEmpty(val);
                  setState(() => _lastName = val);
                  return null;
                },
              ),
              TextFormField(
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
              TextFormField(
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
              RaisedButton(
                child: Text("REGISTER"),
                onPressed: tryToRegister,
              )
            ],
          )),
    );
  }
}
