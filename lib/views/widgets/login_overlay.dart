import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/login_screen.dart';
import 'package:overlay_support/overlay_support.dart';

class LoginOverlay extends ModalRoute<void> {
  String _email = "";
  String _password = "";

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  void _pushLoginScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        PageRoutes.sharedAxis(() => LoginScreen()),
        (Route<dynamic> route) => false);
  }

  Future<void> siginIn(BuildContext context) async {
    // ignore: await_only_futures
    User user = await FirebaseAuth.instance.currentUser;
    try {
      AuthCredential credentials = EmailAuthProvider.credential(
          email: this._email, password: this._password);
      await user.reauthenticateWithCredential(credentials);
      await FirebaseAuthentication().deleteAccount();
      _pushLoginScreen(context);
    } catch (e) {
      showSimpleNotification(Text("Invalid credentials."),
          background: Colours.error);
    }
  }

  Widget _title(BuildContext context) {
    return Text(
      "SIGN IN",
      style: TextStyle(
          fontSize: Repo.currFontsize + 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyText1.color),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofocus: true,
      style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
      onChanged: (value) => {
        setState(() {
          _email = value;
        }),
      },
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colours.primaryColor),
          labelText: 'email',
          hoverColor: Colours.primaryColor,
          focusColor: Colours.primaryColor,
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: InputBorder.none,
          filled: true),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      obscureText: true,
      textInputAction: TextInputAction.send,
      style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
      onChanged: (value) => {
        setState(() {
          _password = value;
        }),
      },
      onSubmitted: (_) => siginIn(context),
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colours.primaryColor),
          labelText: 'password',
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: InputBorder.none,
          filled: true),
    );
  }

  Widget _signinButton(BuildContext context) {
    return Container(
      width: 150.0,
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
          child: Text('LOGIN'),
          onPressed: () => {
                siginIn(context),
              }),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
      child: Theme(
        data: Theme.of(context).copyWith(accentColor: Colours.primaryColor),
        child: SingleChildScrollView(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            margin: EdgeInsets.all(25),
            child: Column(
              children: [
                _title(context),
                SizedBox(height: 20),
                Center(
                  child: _emailField(context),
                ),
                SizedBox(height: 20),
                Center(
                  child: _passwordField(context),
                ),
                SizedBox(height: 20),
                _signinButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
