import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => new SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  final _settingsForm = new GlobalKey<FormState>();
  String _username;
  String _password;
  String _oldpassword;
  bool _isAutoLoginEnabled;

  void changeDetails() {}

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_left),
            onPressed: () => Navigator.of(context).pop(), //goes back a screen
          ),
        ),
        body: Form(
          key: _settingsForm,
          child: Column(
            children: <Widget>[
              TextFormField(
                textAlign: TextAlign.center,
                decoration: new InputDecoration(
                  labelText: "Change Email",
                ),
                validator: (val) {
                  //check if email is valid or even entered
                  return null;
                },
              ),
              TextFormField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  decoration: new InputDecoration(
                    labelText: "Enter Old Password",
                  ),
                  validator: (val) {
                    return null;
                  }),
              TextFormField(
                textAlign: TextAlign.center,
                obscureText: true,
                decoration:
                    new InputDecoration(labelText: "Enter New Password"),
                validator: (val) {
                  return null;
                },
              ),
              Checkbox(
                value: true,
                onChanged: (bool) => print(bool),
              )
            ],
          ),
        ));
  }
}
