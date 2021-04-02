import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/startscreen.dart';
import 'package:movie_gems/views/screens/login_screen.dart';
import 'package:overlay_support/overlay_support.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _emailValue = '';
  String _passwordValue = '';
  String _confirmPasswordValue = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> registerUser() async {
    if (this._emailValue == "" ||
        this._passwordValue == "" ||
        this._confirmPasswordValue == "") {
      showSimpleNotification(Text("Please fill in all inputs."),
          background: Colours.error);
      return;
    }
    if (!await Internet().checkConnection()) return;
    FirebaseAuthentication().signOut();
    if (_passwordValue == _confirmPasswordValue) {
      await FirebaseAuthentication()
          .register(this._emailValue, this._passwordValue);
      if (await FirebaseAuthentication().checkForUser() == true) {
        _pushHomepage();
      }
    } else {
      showSimpleNotification(Text("Passwords don't match."),
          background: Colours.error);
    }
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
      "REGISTER",
      style: TextStyle(
        fontSize: Repo.currFontsize + 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyText1.color,
      ),
    );
  }

  Widget _emailField() {
    final node = FocusScope.of(context);
    return TextField(
      cursorColor: Colours.primaryColor,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) => this._emailValue = value,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colours.primaryColor),
          hoverColor: Colours.primaryColor,
          focusColor: Colours.primaryColor,
          labelText: 'email',
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
      obscureText: true,
      onChanged: (value) => this._passwordValue = value,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colours.primaryColor),
          hoverColor: Colours.primaryColor,
          focusColor: Colours.primaryColor,
          labelText: 'password',
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: InputBorder.none,
          fillColor: Colours.shadow,
          filled: true),
    );
  }

  Widget _confirmPasswordField() {
    final node = FocusScope.of(context);
    return TextField(
      cursorColor: Colours.primaryColor,
      obscureText: true,
      onChanged: (value) => this._confirmPasswordValue = value,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => {node.unfocus(), registerUser()},
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colours.primaryColor),
          hoverColor: Colours.primaryColor,
          focusColor: Colours.primaryColor,
          labelText: 'password',
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: InputBorder.none,
          fillColor: Colours.shadow,
          filled: true),
    );
  }

  Widget _loginLabel() {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            PageRoutes.sharedAxis(
                () => LoginScreen(), SharedAxisTransitionType.horizontal));
      },
      child: Text('Already have an account? Login',
          style: TextStyle(fontSize: Repo.currFontsize - 5)),
    );
  }

  Widget _registerButton() {
    return Container(
      width: 500.0,
      child: RawMaterialButton(
        elevation: 5,
        padding: EdgeInsets.all(12.0),
        fillColor: Colours.primaryColor,
        textStyle: TextStyle(
            color: Colours.white,
            fontSize: Repo.currFontsize,
            fontWeight: FontWeight.w500,
            fontFamily: 'Sansita'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Text('Register'),
        onPressed: () => registerUser(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(accentColor: Colours.primaryColor),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                Container(
                  height: 200,
                  child: SvgPicture.asset('assets/img/register.svg'),
                ),
                SizedBox(height: 30),
                _title(),
                SizedBox(height: 50),
                Center(
                  child: _emailField(),
                ),
                SizedBox(height: 30),
                Center(
                  child: _passwordField(),
                ),
                SizedBox(height: 30),
                Center(
                  child: _confirmPasswordField(),
                ),
                SizedBox(height: 40),
                _registerButton(),
                SizedBox(height: 15),
                _loginLabel(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
