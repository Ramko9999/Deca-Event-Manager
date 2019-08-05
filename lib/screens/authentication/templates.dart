import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

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

  void tryToLogin() async {
    try {
      AuthResult authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _username, password: _password);
      var user = authResult.user;
      String userIdToken = user.uid;

      //it is adding but not able to grab the auto id and check if user is already there
      if(await _fireStore.collection("Users").document(userIdToken) != null){
            await _fireStore.collection("Users").add({'username':_username, 'password': _password, 'uid': userIdToken});
            print("Succesfully added");
      }
      else{
        print("Already added");
      }

      
      

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

  void tryToRegister() {
    if (_registrationFormKey.currentState.validate()) {
      try {
        FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _username, password: _password);
      } catch (error, stackTrace) {
        print(error);
      }
    }
  }

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
