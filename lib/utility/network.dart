import 'dart:io';

import 'package:http/http.dart';

//a class to implement a broader way of checking connection
class ConnectionStream{


Stream<int> startConnectionChecker() async *{
 int val = 200;
  
  while(true){
    try{
    Response res = await get("https://www.youtube.com");
    if(res.statusCode != val){
      val = res.statusCode;
      yield val;
    }
    }
    catch(e){
      if(e.toString().contains("Socket") || e.toString().contains("SSL")){
        yield 404;
      }
    }
    }
    
  }

  Future<String> quickCheckConnection() async{
    
    try{
     await get("https://www.youtube.com");
     return 'Success';
    }
    catch(e){
      if(e.toString().contains("Socket")){
        return "Failure";
      }
    }
     
  }
}


