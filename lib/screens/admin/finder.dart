

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/admin/searcher.dart';
import 'package:flutter/material.dart';

class FinderScreen extends StatelessWidget {
  Map eventData;
  FinderScreen(Map e) {
    this.eventData = e;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Manual Search"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Finder(eventData));
  }
}

class Finder extends StatefulWidget {
  Map eventMetaData;

  Finder(Map e) {
    this.eventMetaData = e;
  }

  State<Finder> createState() {
    return FinderState(eventMetaData);
  }
}

class FinderState extends State<Finder> {
  Map eventMetaData;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  bool hasSearched = false;
  bool isCardTapped = false;
  Map recentCardInfo;
  List<DocumentSnapshot> userDocs;

  FinderState(Map e) {
    this.eventMetaData = e;
  }
  @override
  void initState() {
    super.initState();
    _firstName.addListener(() {
      this.build(context);
    });
    _lastName.addListener(() {
      this.build(context);
    });
    Firestore.instance.collection("Users").getDocuments().then((documents) {
      setState(() => userDocs = documents.documents);
    });
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth,
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: screenWidth * 0.5,
                  child: TextField(
                    controller: _firstName,
                    decoration: InputDecoration(labelText: "First Name"),
                    
                  ),
                ),
                Container(
                  width: screenWidth * 0.5,
                  child: TextField(
                    controller: _lastName,
                    decoration: InputDecoration(labelText: "Last Name"),
                  ),
                ),
              ],
            ),
            Flexible(
                child: userDocs == null ? CircularProgressIndicator() : getList())
          ]),
        ),

        if(isCardTapped)
        GestureDetector(
          onTap: (){
            Firestore.instance.collection("Users").getDocuments().then((documents) {
            setState((){ 
              userDocs = documents.documents;
              isCardTapped = false;
            });
            
          });
          },
          child: Container(
            color: Colors.black45,
            child: FinderPopup(recentCardInfo)
          ),
        )
      
      ],
    );
  }

  MaxList getData() {
    List<Map> userList = [];
    //turn this into map with uid and names
    for (int i = 0; i < userDocs.length; i++) {
      Map userData = userDocs[i].data;
      userList.add(userData);
    }
    Searcher searcher = new Searcher(userList, _firstName.text, _lastName.text);
    MaxList relevanceList = searcher.search();
    return relevanceList;
  }

  Widget getList() {
    MaxList list = getData();
    Node current = list.head;
    return ListView.builder(
        shrinkWrap: true,
        itemCount: list.getSize(),
        itemBuilder: (context, i) {
          if (list.getSize() == 0) {
            return CircularProgressIndicator();
          }
          Map userInfo = current.element['info'];
          GestureDetector c = GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  isCardTapped = true;
                  recentCardInfo = userInfo;
                });
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.black),
                  title: Text(
                    userInfo['first_name'] + " " + userInfo['last_name'],
                    style: TextStyle(fontFamily: 'Lato', fontSize: 20),
                  ),
                  subtitle: Text(
                    userInfo['gold_points'].toString(),
                    style: TextStyle(fontFamily: 'Lato', fontSize: 15),
                  ),
                  trailing: Icon(Icons.add, color: Colors.black),
                ),
              ));
          current = current.next;
          return c;
        });
  }
}

class FinderPopup extends StatefulWidget {
  Map userData;

  FinderPopup(Map u) {
    this.userData = u;
  }
  State<FinderPopup> createState() {
    return FinderPopupState(userData);
  }
}

class FinderPopupState extends State<FinderPopup> {
  TextEditingController pointController = new TextEditingController();
  bool wantsToAdd = true;
  Map userData;

  FinderPopupState(Map u) {
    pointController.text = 0.toString();
    userData = u;

  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: Text('Edit Gold Points'),
      content: Row(
        children: <Widget>[
          FlatButton(
            child: wantsToAdd
                ? Text(
                    "+",
                    style: TextStyle(color: Colors.blue, fontSize: 24),
                  )
                : Text("-", style: TextStyle(color: Colors.red, fontSize: 24)),
            onPressed: () {
              setState(() => wantsToAdd = !wantsToAdd);
            },
          ),
          Container(
            width: screenWidth * 0.10,
            child: TextField(
              keyboardType: TextInputType.number,
              controller: pointController,
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Submit", style: TextStyle(color: Colors.blue)),
          onPressed: () {
            String userUID = userData['uid'];
            int operand = wantsToAdd ? 1 : -1;
            int points = int.parse(pointController.text);
            Firestore.instance.collection("Users").document(userUID).updateData({'gold_points': FieldValue.increment(operand * points)}).then((confirmation){
              Scaffold.of(context).showSnackBar(
                SnackBar(content: 
                Text("Succesfully added ${(operand * points).toString()} to ${userData['first_name']}", style: 
                TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  color: Colors.white
                ),),
                backgroundColor: Colors.green,)
              );
            });
          },
        )
      ],
    );
  }
}



