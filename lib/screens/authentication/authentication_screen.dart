import 'package:deca_app/utility/format.dart';
import 'package:deca_app/utility/transistion.dart';
import 'package:flutter/material.dart';
import 'package:deca_app/screens/authentication/templates.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthenticationScreenState();
  }
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  
  //boolean values control which template will be shown
  bool _isLoginButtonClicked = false;
  bool _isRegisterButtonClicked = false;
  bool _isForgotPasswordClicked = false;

  void createNewLoginTemplate() {

    
    
    //affirm that the other templates shall not show up

    
    setState(() {
      _isLoginButtonClicked = true;
      _isRegisterButtonClicked = false;
      _isForgotPasswordClicked = false;
    });
    
  }

  void createNewRegisterTemplate() {
    
    setState(() {
      _isRegisterButtonClicked = true;
      _isLoginButtonClicked = false;
      _isForgotPasswordClicked = false;
    });
  }

  void createNewForgotPasswordTemplate() {
   
    setState(() {
      _isForgotPasswordClicked = true;
      _isLoginButtonClicked = false;
      _isRegisterButtonClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
   
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
     
        backgroundColor: Colors.white,
        body: Stack(children: [
          new Column(children: [
            Spacer(flex: 1),
            Flexible(
                flex: 4,
                child: Align(
                  alignment: Alignment(0.0, -0.6),
                  child: Container(
                    width: screenWidth - 50,
                    child: Image.asset(
                        'assets/logos/DECA-Here-We-Go-1024x583.png',
                        fit: BoxFit.cover),
                  ),
                )),
            Spacer(flex: 2),
            Flexible(
                flex: 4,
                child: Container(
                    
                        child: Column(children: [
                          Container(
                              width: screenWidth * 0.85,
                              height: screenHeight * 0.08,
                              child: new RaisedButton(
                                child: Text('Sign In',
                                    style: new TextStyle(
                                      fontSize: Sizer.getTextSize(screenWidth, screenHeight, 20),
                                    )),
                                textColor: Colors.white,
                                color: Colors.blue,
                                onPressed: createNewLoginTemplate,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              )),
                          Container(
                            height: 15,
                          ),
                          Container(
                              width: screenWidth * 0.85,
                              height: screenHeight * 0.08,
                              child: new RaisedButton(
                                  child: Text('Sign Up',
                                      style: new TextStyle(
                                        fontSize: Sizer.getTextSize(screenWidth, screenHeight, 20),
                                      )),
                                  textColor: Colors.black,
                                  color: Colors.white,
                                  onPressed: createNewRegisterTemplate,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30)))),
                          FlatButton(
                            textColor: Colors.blue,
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: Sizer.getTextSize(
                                    screenWidth, screenHeight, 16),
                              ),
                            ),
                            onPressed: createNewForgotPasswordTemplate,
                          )
                        ]))),
          ]),
          //handles pulling up the login template
          if (_isLoginButtonClicked)
            Stack(children: [
              GestureDetector(
                child: Container(
                  
                  color: Colors.black45,
                  width: screenWidth,
                  height: screenHeight,
                ),
                onTap: () {
                  
                  setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _isLoginButtonClicked = false;
                  });
                },
              ),
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      child: Container(
                        child: new LoginTemplate(),
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white),
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ),
                ),
              )
            ]),
          
          if (_isRegisterButtonClicked)
            Stack(children: <Widget>[
              GestureDetector(
                child: Container(color: Colors.black45),
                onTap: () {
                  setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _isRegisterButtonClicked = false;
                  });
                },
              ),
              Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                    child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    child: new RegisterTemplate(),
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                  ),
                )),
              )
            ]),

          if (_isForgotPasswordClicked)
            
            Stack(
              children: <Widget>[
                GestureDetector(
                  child: Container(color: Colors.black45),
                  onTap: () {
                    setState(() {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _isForgotPasswordClicked = false;
                    });
                  },
                ),
                Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                      child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Container(
                      child: ForgotPasswordTemplate(),
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                    ),
                  )),
                ),
              ],
            )
        ]));
  }
}
