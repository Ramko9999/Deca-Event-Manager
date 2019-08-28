
import 'package:deca_app/utility/InheritedInfo.dart';
import 'package:flutter/material.dart';

//UI should simply be a list that contains notifications

class NotificationUI extends StatefulWidget{
  NotificationUI();
    
  
  State<NotificationUI> createState(){
    return NotificationUIState();
  }
}

class NotificationUIState extends State<NotificationUI>{
  NotificationUIState();

  void initState(){
    super.initState();
  }
  

  Widget build(BuildContext context){
    
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight/1.1,
      width: screenWidth,
      child: getListItems(StateContainer.of(context).notifications));
  }

  Widget getListItems(documents){
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, i){
        return Card(
          child: ListTile(
            title: Text(documents[i]['notification']['title'], style: TextStyle(fontFamily: 'Lato'),),
            subtitle: Text(documents[i]['notification']['body'], style: TextStyle(fontFamily: 'Lato'),),
          ),
        );
      },
    );
    
  }
}