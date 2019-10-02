
import 'package:deca_app/screens/admin/finder.dart';
import 'package:deca_app/screens/admin/notification_sender.dart';
import 'package:deca_app/screens/admin/scanner.dart';
import 'package:deca_app/screens/profile/templates.dart';
import 'package:deca_app/screens/settings/setting_screen.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:deca_app/utility/transistion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';





class CreateGroupUI extends StatefulWidget {
  CreateGroupUI();

  State<CreateGroupUI> createState() {
    return _CreateGroupUIState();
  }
}

class _CreateGroupUIState extends State<CreateGroupUI> {
  TextEditingController _groupName = TextEditingController();
  bool _hasCreatedGroup = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _CreateGroupUIState();

  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Add Users to Group"),
      ),
      body: Stack(
        children: <Widget>[
          //add people to a group on callback
          Finder((BuildContext context, StateContainerState stateContainer,
              Map userData) {
            Firestore.instance
                .collection("Users")
                .document(userData['uid'])
                .get()
                .then((document) {
              List data = document.data['groups'].toList();
              //check if the person is already in the group
              if (data.contains(stateContainer.group)) {
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
                    onPressed: () {
                      //remove the group
                      data.remove(stateContainer.group);

                      //remove user from firestore and show confirmation
                      Firestore.instance
                          .collection("Users")
                          .document(userData['uid'])
                          .updateData({'groups': data}).then((_) {
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
                data.add(stateContainer.group);
                document.reference.updateData({'groups': data});
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
            });
          }),
          if (!_hasCreatedGroup)
            Container(
                color: Colors.black45,
                child: AlertDialog(
                  title: Text(
                    "Group Name",
                    style: TextStyle(fontSize: Sizer.getTextSize(sW, sH, 21)),
                  ),
                  content: TextField(
                    controller: _groupName,
                    style: TextStyle(fontSize: Sizer.getTextSize(sW, sH, 15)),
                    decoration: InputDecoration(
                      labelText: "Group Name",
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Create"),
                      textColor: Colors.blue,
                      onPressed: () async {
                        if (_groupName.text != null) {
                          QuerySnapshot groupSnap = await Firestore.instance
                              .collection("Groups")
                              .getDocuments();
                          
                          //create a map of the documents by the first name field
                          List groups = groupSnap.documents
                              .map((f) => f.data['name'])
                              .toList();

                          if (!groups.contains(_groupName.text)) {
                            Firestore.instance
                                .collection("Groups")
                                .add({'name': _groupName.text});
                            StateContainer.of(context)
                                .setGroup(_groupName.text);

                            setState(() => _hasCreatedGroup = true);
                          } else {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                "${_groupName.text} already exists",
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: Sizer.getTextSize(sW, sH, 18),
                                    color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ));
                          }
                        }
                      },
                    )
                  ],
                )),
          if (StateContainer.of(context).isThereConnectionError)
            ConnectionError()
        ],
      ),
    );
  }
}

class GroupEditor extends StatelessWidget {
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


          Finder(

            //finder callback function
            (BuildContext context, StateContainerState stateContainer,
              Map userData) {
            Firestore.instance
                .collection("Users")
                .document(userData['uid'])
                .get()
                .then((document) {
              List data = document.data['groups'].toList();
              //check if the person is already in the group
              if (data.contains(stateContainer.group)) {
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
                    onPressed: () {
                      //remove the group
                      data.remove(stateContainer.group);

                      //remove user from firestore and show confirmation
                      Firestore.instance
                          .collection("Users")
                          .document(userData['uid'])
                          .updateData({'groups': data}).then((_) {

                        //once data is updated display a snackbar
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
                data.add(stateContainer.group);
                document.reference.updateData({'groups': data});
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
            });
          }),
        if(StateContainer.of(context).isThereConnectionError)
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

  ListView buildGroupList(context, snapshot) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: snapshot.data.documents.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        DocumentSnapshot groups = snapshot.data.documents[int];

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
              title: Text(groups['name'],
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Sizer.getTextSize(sW, sH, 20))),
              onTap: () {

                /*set the group in the persistenance so that the group data will be saved and will appear
                correctly */

                final container = StateContainer.of(context);
                container.setGroup(groups['name']);
                
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
            QuerySnapshot userSnapshot = await  Firestore.instance.collection("Users").getDocuments();

            //iterate through all users and remove them from the group
            for(DocumentSnapshot userDoc in userSnapshot.documents){
              
              List groupList = userDoc['groups'];

              //remove the group
              groupList = groupList.where( (v)=>  v != groups['name'] ).toList();

              //replace the "groups" key in the user data to the new groupList
              Map userData = userDoc.data;
              userData['groups'] = groupList;
              
              //make change in the batch
              batch.setData(userDoc.reference, userData);
            }

            //commit batch and then delete the group from the groups collection
            batch.commit().then(
              
              (_)
              {

               groups.reference.delete().then(
                 
                 (_)
                 {
                   //display a snackbar alerting the user that the group has been deleted

                    _scaffoldKey.currentState.showSnackBar(
                      
                      SnackBar(
                        content: Text(
                          "The event has been deleted",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white
                          ),
                          ),
                        backgroundColor: Colors.green,
                        

                      )

                    );

                 }
               );


              }

             
              );
          },

        // a way to guarantee that the user truly wants to delete the group
        confirmDismiss: (direction){

          return showDialog(
            context: context,
            builder: (context){

              return AlertDialog(
                content: Text("Everyone will be kicked out of this group"),
                title: Text("Are you sure?"),
                actions: <Widget>[
                  FlatButton(
                    
                    child: Text("Delete", style: TextStyle(color: Colors.red),),
                    onPressed: ()=> Navigator.of(context).pop(true),

                  ),
                  FlatButton(
                    child: Text("Don't Delete"),
                    onPressed: ()=> Navigator.of(context).pop(),
                  ),
                ],
              );
            }
          );
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
          title: Text("Edit Committees"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {Navigator.pop(context)}),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: Firestore.instance.collection('Groups').snapshots(),
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

