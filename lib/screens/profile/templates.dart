import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DynamicProfileUI extends StatelessWidget {
  String _uid;
  String _firstName;
  String _lastName;
  int _goldPoints;
  String _memberLevel;
  List _groups;

  DynamicProfileUI(uid) {
    this._uid = uid;
  }

  Widget build(BuildContext context) {
    return StreamBuilder(
        //connecting to firebase and gathering user data
        stream: Firestore.instance
            .collection('Users')
            .where("uid", isEqualTo: _uid)
            .snapshots(),
        builder: (context, snapshot) {
          //if data has been updated
          if (snapshot.hasData) {
            //grab the data and populate the fields as such
            DocumentSnapshot userInfo = snapshot.data.documents[0];
            _firstName = userInfo.data['first_name'] as String;
            _lastName = userInfo.data['last_name'] as String;
            _goldPoints = userInfo.data['gold_points'];
            //setting memberLevel based on gold points
            if (_goldPoints < 75) {
              _memberLevel = "Not a member yet!";
            }
            else if (_goldPoints < 125) {
              _memberLevel = "Member";
            }
            else if (_goldPoints < 200) {
              _memberLevel = "Silver";
            }
            else{
              _memberLevel = "Gold";
            }

            _groups = userInfo.data['groups'];

            //setting the new UI
            return Center(
                child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: Text(
                    _firstName + ". " + _lastName[0],
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: 36, decoration: TextDecoration.underline),
                  ),
                ),
                Container(
                  padding: new EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 0.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Gold Points: ",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontSize: 24,
                              )),
                          Spacer(),
                          Text(_goldPoints.toString(),
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: 24,
                                  color: Color.fromARGB(255, 249, 166, 22)))
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text("Member Status: ",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontSize: 24,
                              )),
                          Spacer(),
                          Text(_memberLevel,
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontSize: 24,
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ));
          } else {
            return Text("Loading...");
          }
        });
  }
}
