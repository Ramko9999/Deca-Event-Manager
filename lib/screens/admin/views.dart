import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/db/databasemanager.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:flutter/material.dart';


class EventView extends StatelessWidget{

  String eventName;
  Map usersMap;
  DocumentSnapshot eventSnap;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  EventView(String eventName, DocumentSnapshot eventSnap){
    this.eventName = eventName;
    this.eventSnap = eventSnap;
  }


  /*
  The method filters the users who have been to event from the overall users gives access
  to the UIDs for change
  */

  Widget getRelevantUsers(BuildContext context, Map usersMap){

    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    List usersList = this.eventSnap.data['attendees'];

    //grab a list of all that are common to the total users and the event attendees with their uids
    List<Map> relevantUserInfo = [];
    for(String user in usersList){
      if(usersMap.containsKey(user)){
        relevantUserInfo.add({user: usersMap[user]});
      }
    }

    if(relevantUserInfo.length == 0){
      return Text("No one has attended this event");
    }
    
    return ListView.builder(
      itemCount: relevantUserInfo.length,
      itemBuilder: (context, index){

        String user = relevantUserInfo[index].keys.toList()[0];
        
        return Dismissible(
                background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
                key: UniqueKey(),
                onDismissed: (DismissDirection d) async {

                  //delete the actual user from the event
                  await eventSnap.reference.updateData({"attendees": FieldValue.arrayRemove([user])});

                  //delete the event from the user
                  DocumentSnapshot userSnapsot = await Firestore.instance.collection("Users").document(relevantUserInfo[index][user]).get();


                  Map eventsList = userSnapsot.data['events'];
                  int eventPoints = eventsList[eventSnap.data['event_name']];

                  eventsList.remove(eventSnap.data['event_name']);

                  userSnapsot.reference.updateData({'events': eventsList, 'gold_points': FieldValue.increment(-1 * eventPoints)}).then((val)=>
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                    content: Text(
                      "$user removed from ${eventSnap.data['event_name']} ",
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: Sizer.getTextSize(sW, sH, 18),
                          color: Colors.white),
                    ),
                    duration: Duration(milliseconds: 250),
                  ),
                    )
                  );

                },
                child: ListTile(
                leading: Icon(Icons.person, color: Colors.black),
                title: Text(
                  user,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: Sizer.getTextSize(sW, sH, 20)),
                ),
              ),
        );

      }
    );

  }

  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("$eventName's attendees"),
      ),
      
      body: FutureBuilder(
        future: DataBaseManagement.userAggregator.get(),
        builder: (context, snapshot){
          
          if(snapshot.hasData){
            Map usersMap = snapshot.data['users'];
           

            return getRelevantUsers(context, usersMap);


          }
          else{
            return Text("Loading...");
          }
        },
      )
     

    );
  }
}


class GroupView extends StatelessWidget{
  String groupName;
  Map usersMap;
  DocumentSnapshot groupSnap;

  GroupView(String g, DocumentSnapshot s){
    this.groupName  = g;
    this.groupSnap =  s;
  }

  GlobalKey<ScaffoldState> _scaffoldKey=  new GlobalKey<ScaffoldState>();


  /*
  The method filters the users who are in groups from the overall users gives access
  to the UIDs for change
  */

  Widget getRelevantUsers(BuildContext context, Map usersMap){

    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    List usersList = this.groupSnap.data['members'];

    //grab a list of all that are common to the total users and the event attendees with their uids
    List<Map> relevantUserInfo = [];
    for(String user in usersList){
      if(usersMap.containsKey(user)){
        relevantUserInfo.add({user: usersMap[user]});
      }
    }

    if(relevantUserInfo.length == 0){
      return Center(
        child: Text("Quite lonely in here...")
        );
    }
    
    return ListView.builder(
      itemCount: relevantUserInfo.length,
      itemBuilder: (context, index){

        String user = relevantUserInfo[index].keys.toList()[0];
        
        return Dismissible(
                background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
                key: UniqueKey(),
                onDismissed: (DismissDirection d) async {

                  //delete the actual user from the event
                  await groupSnap.reference.updateData({"members": FieldValue.arrayRemove([user])});

                  //delete the event from the user
                  DocumentReference userSnapsot = Firestore.instance.collection("Users").document(relevantUserInfo[index][user]);

                  //show confirmation after removing the group from the user value
                  userSnapsot.updateData({'groups': FieldValue.arrayRemove([this.groupName])}).then((val)=>
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                    content: Text(
                      "$user removed from ${this.groupName} ",
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: Sizer.getTextSize(sW, sH, 18),
                          color: Colors.white),
                    ),
                    duration: Duration(milliseconds: 250),
                  ),
                    )
                  );

                },
                child: ListTile(
                leading: Icon(Icons.person, color: Colors.black),
                title: Text(
                  user,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: Sizer.getTextSize(sW, sH, 20)),
                ),
              ),
        );

      }
    );

  }

  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("$groupName's attendees"),
      ),
      
      body: FutureBuilder(
        future: DataBaseManagement.userAggregator.get(),
        builder: (context, snapshot){
          
          if(snapshot.hasData){

            //grab all the users from the Aggreagtor so its 1 read
            Map usersMap = snapshot.data['users'];
            return getRelevantUsers(context, usersMap);
          }
          else{
            return Text("Loading...");
          }
        },
      )
     

    );
  }

}