import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/controller/themeController.dart';
import 'package:movie_gems/model/appStateNotifier.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/views/screens/startscreen.dart';
import 'package:movie_gems/views/screens/register_screen.dart';
import 'package:movie_gems/views/screens/forgot_password_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _emailValue = '';
  String _passwordValue = '';
  UserCredential userCredential;

  @override
  void initState() {
    super.initState();
    checkForUser();
  }

  Future<void> checkForUser() async {
    if (await FirebaseAuthentication().checkForUser() == true) {
      _pushHomepage();
    }
  }

  Future<void> siginIn() async {
    if (await FirebaseAuthentication()
            .emailSignIn(this._emailValue, this._passwordValue) ==
        true) {
      _pushHomepage();
    } else {
      this._emailValue = '';
      this._passwordValue = '';
      showSimpleNotification(Text("Invalid credentials."),
          background: Colours.error);
    }
  }

  void _pushHomepage() {
    // Navigator.of(context).pop();
    Navigator.push(
        context,
        PageRoutes.sharedAxis(
            () => StartScreen(), SharedAxisTransitionType.horizontal));
  }

  Widget _title() {
    return Text(
      "SIGN IN",
      style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colours.primaryColor),
    );
  }

  Widget _emailField() {
    final node = FocusScope.of(context);
    return TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) => this._emailValue = value,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
      decoration: InputDecoration(
          labelText: 'email',
          focusColor: Colours.primaryColor,
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: InputBorder.none,
          fillColor: Colours.shadow,
          filled: true),
    );
  }

  Widget _passwordField() {
    final node = FocusScope.of(context);
    return TextField(
      obscureText: true,
      onChanged: (value) => this._passwordValue = value,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => {node.unfocus(), siginIn()},
      decoration: InputDecoration(
          labelText: 'password',
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: InputBorder.none,
          fillColor: Colours.shadow,
          filled: true),
    );
  }

  Widget _forgotPasswordLabel() {
    return Container(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              PageRoutes.sharedAxis(() => ForgotPasswordScreen(),
                  SharedAxisTransitionType.horizontal));
        },
        child: Text('Forgot Password ?', style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _registerLabel() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            PageRoutes.sharedAxis(
                () => RegisterScreen(), SharedAxisTransitionType.horizontal));
      },
      child: Text('Don\'t have an account? Register',
          style: TextStyle(fontSize: 14)),
    );
  }

  Widget _signinButton() {
    return new Container(
      width: 500.0,
      child: new RawMaterialButton(
          elevation: 5,
          padding: EdgeInsets.all(12.0),
          fillColor: Colours.primaryColor,
          textStyle: TextStyle(
              color: Colours.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'Sansita'),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          child: Text('LOGIN'),
          onPressed: () => {
                siginIn(),
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new SafeArea(
            child: new Stack(children: <Widget>[
      Positioned(
        top: 10,
        right: 10,
        child: Switch(
          activeColor: Colours.primaryColor,
          value:
              Provider.of<AppStateNotifier>(context, listen: false).darkModeOn,
          onChanged: (boolValue) {
            setState(() {
              ThemeController().updateTheme(boolValue, context);
            });
          },
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(height: 50),
          Container(
            height: 250,
            child: SvgPicture.asset('assets/img/login.svg'),
          ),
          SizedBox(height: 30),
          _title(),
          SizedBox(height: 50),
          Center(
            child: _emailField(),
          ),
          SizedBox(height: 50),
          Center(
            child: _passwordField(),
          ),
          SizedBox(height: 20),
          _forgotPasswordLabel(),
          SizedBox(height: 40),
          _signinButton(),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
            child: _registerLabel(),
          ),
        ])),
      )
    ])));
  }
}
