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
  bool _isLoginButtonClicked = false;
  bool _isRegisterButtonClicked = false;

  void createNewLoginTemplate() {
    setState(() {
      _isLoginButtonClicked = !_isLoginButtonClicked;
      _isRegisterButtonClicked = false;
    });
  }

  void createNewRegisterTemplate() {
    setState(() {
      _isRegisterButtonClicked = !_isRegisterButtonClicked;
      _isLoginButtonClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(children: [
                          Container(
                              width: screenWidth * 0.85,
                              height: screenHeight * 0.08,
                              child: new RaisedButton(
                                child: Text('Sign In',
                                    style: new TextStyle(
                                      fontSize: 20.0,
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
                                        fontSize: 20.0,
                                      )),
                                  textColor: Colors.black,
                                  color: Colors.white,
                                  onPressed: createNewRegisterTemplate,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))))
                        ])))),
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
            Stack(
              children: <Widget>[
                GestureDetector(
                  child: Container(color: Colors.black45),
                  onTap: () {
                    setState(() {
                      _isRegisterButtonClicked = false;
                    });
                  },
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.only(top: screenHeight * 0.10),
                    child: Align(
                        alignment: Alignment.bottomCenter,
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
                  ),
                )
              ],
            )
        ]));
  }
}
