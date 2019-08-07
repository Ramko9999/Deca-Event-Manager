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
          if (_isLoginButtonClicked)
            new LoginTemplate(),
          if (_isRegisterButtonClicked)
            new RegisterTemplate(),

          Center(
            child: Container(
              width: 200,
              child: new RaisedButton(
                child: Text('LOGIN'),
                textColor: Colors.white,
                color: Colors.transparent,
                onPressed: createNewLoginTemplate,
              ),
            ),
          ),
          Center(
            child: Container(
                width: 200,
                child: new RaisedButton(
                  child: Text('REGISTER'),
                  textColor: Colors.white,
                  color: Colors.transparent,
                  onPressed: createNewRegisterTemplate,
                )),
          ),

          //handles pulling up the login template
        ])),
      ],
    ));
  }
}
