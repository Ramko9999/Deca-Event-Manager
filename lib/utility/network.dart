import 'dart:io';

import 'package:http/http.dart';

//a class to implement a broader way of checking connection
class ConnectionStream {
//a stream that continously opens and destroys a socket to listen to whether the network truly exists
  Stream<int> startConnectionChecker() async* {
    int val = 200;
    final InternetAddress targetAddress = new InternetAddress('8.8.4.4');
    final int port = 79;

    //only yields a value if the value is a different value
    while (true) {
      try {
        Socket s = await Socket.connect(targetAddress, port,
            timeout: Duration(seconds: 15));
        s.destroy();
        if (val != 200) {
          val = 200;
          yield val;
        }
      } catch (e) {
        if (val != 404) {
          val = 404;
          yield val;
        }
      }
    }
  }

  
}
