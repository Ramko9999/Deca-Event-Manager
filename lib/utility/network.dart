

import 'package:http/http.dart' as http;
import 'dart:io';


//a class to implement a broader way of checking connection
class ConnectionStream{

//a stream that continously opens and destroys a socket to listen to whether the network truly exists
Stream<int> startConnectionChecker() async *{
 int val = 200;


  //only yields a value if the value is a different value
  while(true){
    
    try{
     //make a request to youtube
      http.get('https://www.youtube.com').timeout(
        Duration(seconds: 7), 
        onTimeout: ()=> throw SocketException("SocketException: Weak Connection"));
     
     //check whether request is recieved
     if(val != 200){
       val = 200;
       yield val;
     }
    }
    catch(e){
      print("Error: is $e");
      if(e.toString().contains('SocketException'))
      {
         if(val != 404)
         {
          val = 404;
          yield val;
        }

      }

       
      }
    }
    }
    
  
  //Method is used for checking for a connection one time
  Future<String> quickCheckConnection() async{
    
    try{
     await http.get("https://www.youtube.com");
     return 'Success';
    }
    catch(e){
      if(e.toString().contains("Socket")){
        return "Failure";
      }
    }
     
  }
}


