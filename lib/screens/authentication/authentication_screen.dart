import 'package:flutter/material.dart';
import 'package:flutter_first_app/utility/background_image.dart';
import 'package:flutter_first_app/screens/authentication/templates.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthenticationScreenState();
  }
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool _isLoginButtonClicked = false;
  bool _isRegisterButtonClicked = false;

  void createNewLoginTemplate() {
    print("In createNewLoginTemplate");

    setState(() {
      _isLoginButtonClicked = !_isLoginButtonClicked;
      _isRegisterButtonClicked = false;
    });
  }

  void createNewRegisterTemplate() {
    print("In Create new Register Template");
    setState(() {
      _isRegisterButtonClicked = !_isRegisterButtonClicked;
      _isLoginButtonClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: new Stack(
      children: [
        new BackgroundImage('assets/backgrounds/blue_green_grad.png'),
        new SingleChildScrollView(
            child: new Column(children: [
          Container(
            child: Image.asset(
              'assets/logos/deca_logo_blue_bg.png',
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 245, 0, 0),
            child: Center(
              child: Container(
                width: 200,
                child: new RaisedButton(
                  child: Text('Sign In'),
                  textColor: Colors.white,
                  color: Colors.transparent,
                  onPressed: createNewLoginTemplate,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Container(
                  width: 200,
                  child: new RaisedButton(
                      child: Text('Sign Up'),
                      textColor: Colors.white,
                      color: Colors.transparent,
                      onPressed: createNewRegisterTemplate,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)))),
            ),
          ),

          //handles pulling up the login template
        ])),
        
        if (_isLoginButtonClicked)
          Stack(
                children: [
                  GestureDetector(
                    child:Container(color:Colors.black45),
                    onTap: (){
                      setState(() {
                        _isLoginButtonClicked = false;
                      });
                    },
                  )
                  ,
                  SingleChildScrollView(
                child: Padding(
                  padding: new EdgeInsets.only(top:100, bottom: 75),
                  child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: new LoginTemplate(),
                    decoration:new BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white
                    ) ,),
                ),
              ),
            ),
                ]),
        if(_isRegisterButtonClicked)
          
          Stack(children: <Widget>[
            GestureDetector(
              child:Container(color: Colors.black45),
              onTap: (){
                setState((){
                  _isRegisterButtonClicked = false;
                });
              },
            )
            ,
            SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: 70),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: new RegisterTemplate(),
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:Colors.white),
                        
                        
                  )),
            ),
          )
          ],)
         
      ],
    ));
  }
}
