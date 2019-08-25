import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/admin/searcher.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class FinderScreen extends StatelessWidget {
  FinderScreen();

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
        body: Finder());
  }
}

class Finder extends StatefulWidget {
  Finder();

  State<Finder> createState() {
    return FinderState();
  }
}

class FinderState extends State<Finder> {
  Map eventMetaData;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  bool hasSearched = false;
  bool isCardTapped;
  Map recentCardInfo;
  List<DocumentSnapshot> userDocs;

  FinderState();

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
    final container = StateContainer.of(context);
    eventMetaData = container.eventMetadata;
    isCardTapped = container.isCardTapped;
    Firestore.instance.collection("Users").getDocuments().then((documents) {
      setState(() => userDocs = documents.documents);
    });

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TextField(
                        controller: _firstName,
                        decoration: InputDecoration(labelText: "First Name"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _lastName,
                      decoration: InputDecoration(labelText: "Last Name"),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
                child: userDocs == null
                    ? CircularProgressIndicator()
                    : getList(context)),
          ]),
        ),
        if (isCardTapped)
          GestureDetector(
            onTap: () {
              userDocs = container.setIsCardTapped(false);
            },
            child: Container(child: FinderPopup()),
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

  Widget getList(BuildContext context) {
    MaxList list = getData();
    final infoContainer = StateContainer.of(context);
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
                  infoContainer.setUserData(userInfo);
                  if (infoContainer.eventMetadata['enter_type'] == 'QE') {
                    infoContainer.updateGP(userInfo['uid']);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Succesfully added ${eventMetaData['gold_points'].toString()} to ${userInfo['first_name']}",
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ));
                  } else {
                    infoContainer.setIsCardTapped(true);
                    recentCardInfo = userInfo;
                  }
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
  FinderPopup();
  State<FinderPopup> createState() {
    return FinderPopupState();
  }
}

class FinderPopupState extends State<FinderPopup> {
  TextEditingController pointController = new TextEditingController();
  Map userData;

  FinderPopupState() {
    pointController.text = 0.toString();
  }

  void addGPManual() {}

  void addGPQuick() {}

  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    userData = container.userData;
    double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: AutoSizeText(
        "Add GP to " + userData['first_name'],
        maxLines: 1,
      ),
      content: Container(
        width: screenWidth * 0.10,
        child: TextField(
          style: TextStyle(fontFamily: 'Lato'),
          textAlign: TextAlign.center,
          decoration: new InputDecoration(
            labelText: "GP",
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(color: Colors.blue),
            ),
          ),
          keyboardType: TextInputType.number,
          controller: pointController,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Submit", style: TextStyle(color: Colors.blue)),
          onPressed: () {
            String userUID = userData['uid'];
            int points = int.parse(pointController.text);
            container.updateGP(userUID, points);
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                "Succesfully added ${points.toString()} to ${userData['first_name']}",
                style: TextStyle(
                    fontFamily: 'Lato', fontSize: 20, color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ));
            container.setIsCardTapped(false);
          },
        )
      ],
    );
  }
}