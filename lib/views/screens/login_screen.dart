import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/views/screens/startscreen.dart';
import 'package:movie_gems/views/screens/register_screen.dart';
import 'package:movie_gems/views/screens/forgot_password_screen.dart';
import 'package:overlay_support/overlay_support.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkForUser();
  }

  Future<void> checkForUser() async {
    if (await FirebaseAuthentication().checkForUser()) {
      _pushHomepage();
    }
  }

  Future<void> siginIn() async {
    if (this._emailController.value.text == "" ||
        this._passwordController.value.text == "") {
      showSimpleNotification(Text("Please fill in all inputs."),
          background: Colours.error);
      return;
    }
    if (!await Internet().checkConnection()) return;
    if (await FirebaseAuthentication().emailSignIn(
            this._emailController.value.text,
            this._passwordController.value.text) ==
        true) {
      _pushHomepage();
    } else {
      this._emailController.value = TextEditingValue.empty;
      this._passwordController.value = TextEditingValue.empty;
      showSimpleNotification(Text("Invalid credentials."),
          background: Colours.error);
    }
  }

  Future<void> signInAnonymous() async {
    if (await Internet().checkConnection()) return;
    await FirebaseAuthentication().anonymouslySignIn();
    _pushHomepage();
  }

  void _pushHomepage() {
    Navigator.of(context).pop();
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
      cursorColor: Colours.primaryColor,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
      decoration: InputDecoration(
          labelText: 'email',
          labelStyle: TextStyle(color: Colours.primaryColor),
          focusColor: Colours.primaryColor,
          hoverColor: Colours.primaryColor,
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: InputBorder.none,
          fillColor: Colours.shadow,
          filled: true),
    );
  }

  Widget _passwordField() {
    final node = FocusScope.of(context);
    return TextField(
      cursorColor: Colours.primaryColor,
      controller: _passwordController,
      obscureText: true,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => {node.unfocus(), siginIn()},
      decoration: InputDecoration(
          labelText: 'password',
          labelStyle: TextStyle(color: Colours.primaryColor),
          focusColor: Colours.primaryColor,
          hoverColor: Colours.primaryColor,
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
        child: Text('Forgot Password ?', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _registerLabel() {
    return FlatButton(
      child: Text('Don\'t have an account? Register',
          style: TextStyle(fontSize: 16)),
      onPressed: () => {
        Navigator.of(context).pop(),
        Navigator.push(
            context,
            PageRoutes.sharedAxis(
                () => RegisterScreen(), SharedAxisTransitionType.horizontal)),
      },
    );
  }

  Widget _anonymousLabel() {
    return FlatButton.icon(
      label: Text(
        'Sign in anonymously',
        style: TextStyle(fontSize: 14),
      ),
      icon: Icon(Icons.fingerprint),
      onPressed: () => signInAnonymous(),
    );
  }

  Widget _signinButton() {
    return Container(
      width: 500.0,
      child: RawMaterialButton(
        elevation: 5,
        padding: EdgeInsets.all(12.0),
        fillColor: Colours.primaryColor,
        textStyle: TextStyle(
            color: Colours.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Sansita'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Text('LOGIN'),
        onPressed: () => siginIn(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(children: <Widget>[
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(height: 50),
          Container(
            height: MediaQuery.of(context).size.height / 3.8,
            child: SvgPicture.asset('assets/img/login.svg'),
          ),
          SizedBox(height: 30),
          _title(),
          SizedBox(height: 30),
          Center(
            child: _emailField(),
          ),
          SizedBox(height: 30),
          Center(
            child: _passwordField(),
          ),
          SizedBox(height: 20),
          _forgotPasswordLabel(),
          SizedBox(height: 30),
          _signinButton(),
          SizedBox(height: 5),
          _anonymousLabel(),
          SizedBox(height: 30),
          _registerLabel(),
        ])),
      )
    ])));
  }
}
