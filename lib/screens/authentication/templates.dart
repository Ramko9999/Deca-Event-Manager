import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//login template
class LoginTemplate extends StatefulWidget{

  LoginTemplate();
  
  @override
  State<LoginTemplate> createState(){
    return LoginTemplateState();
  }
}

class LoginTemplateState extends State<LoginTemplate>{
  final _loginFormKey = GlobalKey<FormState>();
  String _username;
  String _password;

  LoginTemplateState();

  Widget build(BuildContext context){
    return Form(key: _loginFormKey,
     child:
    Column(children: <Widget>[
      TextFormField(
        validator:(val){
          setState(() {
            _username = val;
          });
          bool dotIsNotIn = _username.indexOf(".") == -1;
          bool atIsNotIn = _username.indexOf("@") == -1;
          if (dotIsNotIn || atIsNotIn){
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
        validator: (val){
          setState(() {
           _password = val; 
          });
          bool hasLengthLessThan8 = _password.length < 8;
          if(hasLengthLessThan8){
            return "Password less than 8";
          }
          return null;
        },
        textAlign: TextAlign.center,
        obscureText: true,
        decoration: new InputDecoration(
          icon: Icon(Icons.lock),
          labelText: "Password"
        ),
      ),
      RaisedButton(child: Text("Login"), onPressed: (){
        //logging into firebase test
        if(_loginFormKey.currentState.validate()){
          try{
            FirebaseAuth.instance.signInWithEmailAndPassword(email:_username, password: _password);
            print("Logged in Succesfully");
          }
          catch(error, stackTrace){
            print(error);
          }
        }
      }),

    ],),);
  }

  
}