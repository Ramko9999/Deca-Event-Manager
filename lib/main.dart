import 'package:flutter/material.dart';
import 'package:flutter_first_app/utility/background_image.dart';
import 'package:flutter_first_app/screens/authentication/templates.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool _isLoginButtonClicked = false;


  void createNewLoginTemplate(){
    print("In createNewLoginTemplate");
    
    setState((){
      _isLoginButtonClicked = !_isLoginButtonClicked;
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
        home: Scaffold(
            body: new Stack(
      children: [
        new BackgroundImage('assets/backgrounds/blue_green_grad.png'),
        new Column(children: [
          Container(child: Image.asset('assets/logos/deca_logo_blue_bg.png', height:150, width: 150, fit: BoxFit.cover,),
          ),
          Center(
            child: Container(
              width: 200,
              child: new RaisedButton(child:Text('LOGIN'), textColor: Colors.white, color: Colors.transparent, onPressed:createNewLoginTemplate,
            ),
          )
        ),
        //handles pulling up the login template
        if (_isLoginButtonClicked) new LoginTemplate()
        ]),
      ],
    )));
  }
}


