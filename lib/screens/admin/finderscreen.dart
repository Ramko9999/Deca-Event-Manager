import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deca_app/screens/admin/searcher.dart';
import 'package:deca_app/screens/admin/templates.dart';
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'finder.dart';

class FinderScreen extends StatefulWidget {
  State<FinderScreen> createState() {
    return FinderScreenState();
  }
}

class FinderScreenState extends State<FinderScreen> {
  Map eventMetadata;
  bool isInfo = false;
  bool isManualEnter;

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    eventMetadata = container.eventMetadata;
    isManualEnter = container.isManualEnter;
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: new AppBar(
          title: AutoSizeText(
            "Add Members to \'" + eventMetadata['event_name'] + "\'",
            maxLines: 1,
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (eventMetadata['enter_type'] == 'ME') {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                setState(() {
                  isInfo = true;
                });
              },
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          Column(
            children: <Widget>[
              if (eventMetadata['enter_type'] == 'QE')
                Center(
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: ActionChip(
                        avatar: Icon(MdiIcons.qrcode),
                        label: Text('Add with QR Code'),
                        onPressed: () => {Navigator.pop(context)}),
                  ),
                ),
              Expanded(
                child: Center(
                  child: Finder(
                    //call back function argument
                    (BuildContext context, StateContainerState stateContainer,
                        Map userInfo) {
                      stateContainer.setUserData(userInfo);
                      if (stateContainer.eventMetadata['enter_type'] == 'QE') {
                        stateContainer.updateGP(userInfo['uid']);
                        Scaffold.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text(
                            "Succesfully added ${stateContainer.eventMetadata['gold_points'].toString()} to ${userInfo['first_name']}",
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: Sizer.getTextSize(sW, sH, 20),
                                color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ));
                      } else {
                        stateContainer.setIsCardTapped(true);
                      }
                    },
                    //alert widget argument, optional
                    a: GestureDetector(
                      onTap: () {
                        container.setIsCardTapped(false);
                      },
                      child: Container(child: ManualEnterPopup()),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (StateContainer.of(context).isThereConnectionError)
            ConnectionError(),
          if (isInfo)
            GestureDetector(
              onTap: () {
                setState(() {
                  isInfo = false;
                });
              },
              child: Container(
                width: sW,
                height: sH,
                decoration: new BoxDecoration(color: Colors.black45),
                child: Align(
                    alignment: Alignment.center, child: new EventInfoUI()),
              ),
            )
        ]));
    ;
  }
}
