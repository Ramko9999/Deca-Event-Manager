import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/admin/finder.dart';
import 'package:deca_app/screens/db/databasemanager.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:deca_app/utility/transition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


//a scaffold where Admins can create groups
class CreateGroupUI extends StatefulWidget {
  CreateGroupUI();

  State<CreateGroupUI> createState() {
    return _CreateGroupUIState();
  }
}

//state of the scaffold
class _CreateGroupUIState extends State<CreateGroupUI> {
  TextEditingController _groupName = TextEditingController();
  bool _hasCreatedGroup = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _CreateGroupUIState();

  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Add Users to a Group"),
      ),
      body: Stack(
        children: <Widget>[
          
          
          //add people to a group on callback
          Finder((BuildContext context, StateContainerState stateContainer,
              Map userData) async {
            
            DocumentSnapshot document = await Firestore.instance
                .collection("Users")
                .document(userData['uid'])
                .get();

            List data = document.data['groups'].toList();
            
            //check if the person is already in the group
            if (data.contains(stateContainer.group)) {
              //display a scaffold snackbar to show the user that the user is already in the group
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(
                  "${userData['first_name']} is already in ${stateContainer.group}",
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: Sizer.getTextSize(sW, sH, 18),
                      color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
                action: SnackBarAction(
                  label: "REMOVE",
                  textColor: Colors.amber,
                  onPressed:

                      //choice to remove the user from the group
                      () {
                  

                    //remove user from firestore and show confirmation
                    Firestore.instance
                        .collection("Users")
                        .document(userData['uid'])
                        .updateData({'groups': FieldValue.arrayRemove([stateContainer.group])}).then((_) {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                            "${userData['first_name']} removed from ${stateContainer.group}",
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: Sizer.getTextSize(sW, sH, 18),
                                color: Colors.white),
                          ),
                          duration: Duration(milliseconds: 250),
                        ),
                      );
                    });
                  },
                ),
              ));
            }
            //add the person to the group
            else {
      
              document.reference.updateData({'groups': FieldValue.arrayUnion([stateContainer.group])});

              //show snackbar alerting the admin that the user has been added to the group
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(
                  "Added ${userData['first_name']} to ${stateContainer.group}",
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: Sizer.getTextSize(sW, sH, 18),
                      color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 250),
              ));
            }
          }),
          
          if (!_hasCreatedGroup)
            Container(
                color: Colors.black45,
                child: Center(
                  child: GestureDetector(
                    onTap: () =>
                        FocusScope.of(context).requestFocus(FocusNode()),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      width: sW * 0.7,
                      height: sH * 0.3,
                      child: Center(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Add a New Group",
                                  style: TextStyle(
                                      fontSize: Sizer.getTextSize(sW, sH, 17),
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: sW * 0.6,
                                    child: TextField(
                                      controller: _groupName,
                                      style: TextStyle(
                                          fontSize:
                                              Sizer.getTextSize(sW, sH, 17)),
                                      decoration: InputDecoration(
                                        labelText: "Group Name",
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  child: Text('Update',
                                      style: new TextStyle(
                                          fontSize:
                                              Sizer.getTextSize(sW, sH, 17),
                                          fontFamily: 'Lato')),
                                  textColor: Colors.white,
                                  color: Color.fromRGBO(46, 204, 113, 1),
                                  onPressed: () async {
                                    
                                    if (_groupName.text != null) {
                                     
                                     DocumentSnapshot groupRef = await DataBaseManagement.groupAggregator.get();


                                      //create a map of the documents by the first name field
                                      List groups = groupRef.data['group_list'];
                                      
                                      if (!groups.contains(_groupName.text)) {
                                        Firestore.instance
                                            .collection("Groups").document(_groupName.text).setData({"name": _groupName.text});
                                     

                                        
                                        await DataBaseManagement.groupAggregator.updateData({"group_list": FieldValue.arrayUnion([_groupName.text])});
                                        
                                        StateContainer.of(context)
                                            .setGroup(_groupName.text);

                                        setState(() => _hasCreatedGroup = true);
                                      } else {
                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "${_groupName.text} already exists",
                                            style: TextStyle(
                                                fontFamily: 'Lato',
                                                fontSize: Sizer.getTextSize(
                                                    sW, sH, 17),
                                                color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 1),
                                        ));
                                      }
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          if (StateContainer.of(context).isThereConnectionError)
            ConnectionError()
        ],
      ),
    );
  }
}

class GroupEditor extends StatefulWidget {
  State<GroupEditor> createState() {
    return GroupEditorState();
  }
}

class GroupEditorState extends State<GroupEditor> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Editing ${StateContainer.of(context).group}"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {Navigator.pop(context)}),
      ),
      body: Stack(
        children: <Widget>[
          Finder((BuildContext context, StateContainerState stateContainer,
              Map userData) async {
            
            DocumentSnapshot document = await Firestore.instance
                .collection("Users")
                .document(userData['uid'])
                .get();

            List data = document.data['groups'].toList();
            
            //check if the person is already in the group
            if (data.contains(stateContainer.group)) {
              //display a scaffold snackbar to show the user that the user is already in the group
              _scaffoldKey.currentState.showSnackBar(
                
                SnackBar(
                content: Text(
                  "${userData['first_name']} is already in ${stateContainer.group}",
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: Sizer.getTextSize(sW, sH, 18),
                      color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
                action: SnackBarAction(
                  label: "REMOVE",
                  textColor: Colors.amber,
                  onPressed:

                      //choice to remove the user from the group
                      () {
                  

                    //remove user from firestore and show confirmation
                    Firestore.instance
                        .collection("Users")
                        .document(userData['uid'])
                        .updateData({'groups': FieldValue.arrayRemove([stateContainer.group])}).then((_) {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                            "${userData['first_name']} removed from ${stateContainer.group}",
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: Sizer.getTextSize(sW, sH, 18),
                                color: Colors.white),
                          ),
                          duration: Duration(milliseconds: 250),
                        ),
                      );
                    });
                  },
                ),
              ));
            }
            //add the person to the group
            else {
      
              document.reference.updateData({'groups': FieldValue.arrayUnion([stateContainer.group])});

              //show snackbar alerting the admin that the user has been added to the group
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(
                  "Added ${userData['first_name']} to ${stateContainer.group}",
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: Sizer.getTextSize(sW, sH, 18),
                      color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 250),
              ));
            }
          }),
          if (StateContainer.of(context).isThereConnectionError)
            ConnectionError()
        ],
      ),
    );
  }
}

class EditGroupUI extends StatefulWidget {
  EditGroupUI();

  State<EditGroupUI> createState() {
    return _EditGroupUIState();
  }
}

class _EditGroupUIState extends State<EditGroupUI> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget buildGroupList(context, snapshot) {

    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    
    List groups = snapshot.data['group_list'];

    if(groups.length == 0){
      return Text("No Committees");
    }

    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: groups.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        String group = groups[int];

        return Dismissible(
          key: UniqueKey(),

          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),

          child: Card(
            child: ListTile(
              title: Text(group,
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Sizer.getTextSize(sW, sH, 20))),
              onTap: () {
                /*set the group in the persistenance so that the group data will be saved and will appear
                correctly */

                final container = StateContainer.of(context);
                container.setGroup(group);

                //push to the editor screen
                Navigator.of(context)
                    .push(NoTransition(builder: (context) => GroupEditor()));
              },
            ),
          ),

          //remove the group from Groups Collection as well remove all members of the group instantly
          onDismissed: (direction) async {
            //batch supports multiple writes in one operation
            WriteBatch batch = Firestore.instance.batch();

            //acquire all the user documents
            QuerySnapshot userSnapshot =
                await Firestore.instance.collection("Users").getDocuments();

            //iterate through all users and remove them from the group
            for (DocumentSnapshot userDoc in userSnapshot.documents) {
              List groupList = userDoc['groups'];

              //remove the group
              groupList = groupList.where((v) => v != group).toList();

              //replace the "groups" key in the user data to the new groupList
              Map userData = userDoc.data;
              userData['groups'] = groupList;

              //make change in the batch
              batch.setData(userDoc.reference, userData);
            }

            //commit batch and then delete the group from the groups collection
            batch.commit().then((_) {
              
              Firestore.instance.collection("Groups").document(group).delete().then((_) async {
                //display a snackbar alerting the user that the group has been deleted

                //remove from group aggregator
                await DataBaseManagement.groupAggregator.updateData({"group_list": FieldValue.arrayRemove([group])});

                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    "The group has been deleted",
                    style: TextStyle(fontFamily: 'Lato', color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ));
              });
            });
          },

          // a way to guarantee that the user truly wants to delete the group
          confirmDismiss: (direction) {
            return showDialog(
                context: context,
                builder: (context) {
                  return

                      //show native alert dialogs
                      Platform.isAndroid
                          ? AlertDialog(
                              content: Text(
                                  "Everyone will be kicked out of this group"),
                              title: Text("Are you sure?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                                FlatButton(
                                  child: Text("Don't Delete"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            )
                          : CupertinoAlertDialog(
                              content: Text(
                                  "Everyone will be kicked out of this group"),
                              title: Text("Are you sure?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                                FlatButton(
                                  child: Text("Don't Delete"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                });
          },
        );
      },
    );
  }

  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text("Edit Groups"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {Navigator.pop(context)}),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  FutureBuilder(
                    future: DataBaseManagement.groupAggregator.get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Center(
                          child: Container(
                            height: sH * 0.99,
                            width: sW,
                            child: buildGroupList(context, snapshot),
                          ),
                        );
                      } else {
                        return Text("Loading...");
                      }
                    },
                  ),
                ],
              ),
            ),
            if (StateContainer.of(context).isThereConnectionError)
              OfflineNotifier()
          ],
        ));
  }
}
