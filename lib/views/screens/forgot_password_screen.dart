import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/login_screen.dart';
import 'package:overlay_support/overlay_support.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _emailValue = '';

  Future<void> _resetPassword() async {
    if (this._emailValue == "") {
      showSimpleNotification(Text("Please fill in all inputs."),
          background: Colours.error);
      return;
    }
    if (!await Internet().checkConnection()) return;
    if (await FirebaseAuthentication().resetPassword(this._emailValue) ==
        true) {
      showSimpleNotification(Text("Reset email send."),
          background: Colours.primaryColor);
      Navigator.pop(context);
      Navigator.push(
          context,
          PageRoutes.sharedAxis(
              () => LoginScreen(), SharedAxisTransitionType.horizontal));
    } else {
      showSimpleNotification(
          Text("Sorry, something went wrong. Try again later."),
          background: Colours.error);
    }
  }

  Widget _title() {
    return Text(
      "PASSWORD FORGOTTEN",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Repo.currFontsize + 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyText1.color,
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      cursorColor: Colours.primaryColor,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) => this._emailValue = value,
      textInputAction: TextInputAction.send,
      onEditingComplete: () => _resetPassword(),
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colours.primaryColor),
          hoverColor: Colours.primaryColor,
          labelText: 'email',
          focusColor: Colours.primaryColor,
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
      child: Text('Remembered your password? Login',
          style: TextStyle(fontSize: Repo.currFontsize - 5)),
    );
  }

  Widget _resetButton() {
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
        child: Text('SEND EMAIL'),
        onPressed: () => _resetPassword(),
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
                  height: 250,
                  child: SvgPicture.asset('assets/img/password.svg'),
                ),
                SizedBox(height: 30),
                _title(),
                SizedBox(height: 50),
                Center(
                  child: _emailField(),
                ),
                SizedBox(height: 50),
                _resetButton(),
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
