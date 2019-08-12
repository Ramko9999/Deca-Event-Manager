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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body:
        Stack(
            children: [
              new Column(
                children: [
                  Spacer(flex: 1),
                  Flexible(
                    flex: 4,
                    child:
                      Align(
                        alignment: Alignment(0.0, -0.6),
                        child:
                          Image.asset(
                              'assets/logos/DECA-Here-We-Go-1024x583.png',
                            fit: BoxFit.cover
                          ),

                      )
                  ),
                  Spacer(flex: 2),
                  Flexible(
                  flex: 4,
                  child:
                    Container(
                      child:
                        Align(
                            alignment: Alignment.bottomCenter,
                            child:
                              Column(
                                children: [
                                  Container(
                                    width: 350,
                                    height: 50,
                                    child:  new RaisedButton(
                                      child: Text('Sign In',
                                          style: new TextStyle(
                                            fontSize: 20.0,
                                          )),
                                      textColor: Colors.white,
                                      color: Colors.blue,
                                      onPressed: createNewLoginTemplate,
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                      )
                                  ),
                                  Container(
                                    height: 15,
                                  ),
                                  Container(
                                      width: 350,
                                      height: 50,
                                      child:  new RaisedButton(
                                          child: Text('Sign Up',
                                              style: new TextStyle(
                                                fontSize: 20.0,
                                              )),
                                        textColor: Colors.black,
                                        color: Colors.white,
                                        onPressed: createNewRegisterTemplate,
                                        shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30)
                                        )
                                      )
                                  )]
                              )
                          )
                    )
                  ),
                ]),
          //handles pulling up the login template
        if (_isLoginButtonClicked)
          Stack(children: [
            GestureDetector(
              child: Container(color: Colors.black45),
              onTap: () {
                setState(() {
                  _isLoginButtonClicked = false;
                });
              },
            ),
            SingleChildScrollView(
              child: Padding(
                padding: new EdgeInsets.only(top: 100, bottom: 75),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: new LoginTemplate(),
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                  ),
                ),
              ),
            ),
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
                  padding: EdgeInsetsDirectional.only(top: 70),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        child: new RegisterTemplate(),
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white),
                      )),
                ),
              )
            ],
          )
      ]
    )
    );
  }
}
