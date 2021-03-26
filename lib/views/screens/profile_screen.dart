import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/login_screen.dart';
import 'package:movie_gems/views/widgets/login_overlay.dart';
import 'package:overlay_support/overlay_support.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _email = "";
  String userEmail = FirebaseAuth.instance.currentUser.email;

  void _pushLoginOverlay() {
    Navigator.of(context).push(LoginOverlay());
  }

  void _pushLoginScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        PageRoutes.sharedAxis(() => LoginScreen()),
        (Route<dynamic> route) => false);
  }

  Future<void> _resetPassword() async {
    if (!await Internet().checkConnection()) return;
    await FirebaseAuthentication()
            .resetPassword(FirebaseAuth.instance.currentUser.email)
        ? showSimpleNotification(Text("Reset email send."),
            background: Colours.primaryColor)
        : showSimpleNotification(
            Text("Sorry, something went wrong. Please try again later."),
            background: Colours.error);
  }

  void _deleteAnonymousAccount() async {
    if (!await Internet().checkConnection()) return;
    await FirebaseFirestore.instance
        .collection("movies")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({"status": "account deleted"})
        .then((value) => print("movies deleted"))
        .catchError((e) => print(e));
    await FirebaseFirestore.instance
        .collection("series")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({"status": "account deleted"})
        .then((value) => print("series deleted"))
        .catchError((e) => print(e));
    await FirebaseAuth.instance.currentUser.delete();
    _pushLoginScreen();
  }

  Future<void> _changeEmail() async {
    final node = FocusScope.of(context);
    node.unfocus();
    if (!await Internet().checkConnection()) return;
    FirebaseAuthentication().updateEmail(_email);
  }

  Future<void> _deleteAccount() async {
    if (!await Internet().checkConnection()) return;
    userEmail != null ? _pushLoginOverlay() : _deleteAnonymousAccount();
  }

  Future<void> _verifyEmail() async {
    if (!await Internet().checkConnection()) return;
    await FirebaseAuthentication().emailVerifiedCheck()
        ? showSimpleNotification(Text("Verfication email send."),
            background: Colours.primaryColor)
        : showSimpleNotification(
            Text("Sorry, something went wrong. Please try again later."),
            background: Colours.error);
  }

  Widget _updateEmail() {
    final node = FocusScope.of(context);
    this._email = FirebaseAuth.instance.currentUser.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          "Email address",
          style: TextStyle(fontSize: Repo.currFontsize + 5),
        ),
        SizedBox(height: 5),
        TextField(
            cursorColor: Colours.primaryColor,
            style: TextStyle(
              color: Colours.background,
            ),
            controller: TextEditingController()
              ..text = FirebaseAuth.instance.currentUser.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => this._email = value,
            onSubmitted: (value) =>
                {FirebaseAuthentication().updateEmail(value), node.unfocus()},
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: 'email',
              contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              border: InputBorder.none,
            )),
        SizedBox(height: 15),
        RaisedButton(
          color: Colours.primaryColor,
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Text(
            "Update email",
            style: TextStyle(
                fontSize: Repo.currFontsize - 2, color: Colours.white),
          ),
          onPressed: () => _changeEmail(),
        ),
      ],
    );
  }

  Widget _actionBlock(String heading, String body, String btnText,
      Color btnColor, Function action) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          heading,
          style: TextStyle(fontSize: Repo.currFontsize + 5),
        ),
        SizedBox(height: 5),
        Text(body,
            style: TextStyle(
              fontSize: Repo.currFontsize - 5,
              color:
                  Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
            )),
        SizedBox(height: 15),
        RaisedButton(
          color: btnColor,
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Text(
            btnText,
            style: TextStyle(
                fontSize: Repo.currFontsize - 2, color: Colours.white),
          ),
          onPressed: action,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(fontSize: Repo.currFontsize),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userEmail != null ? _updateEmail() : Container(),
                userEmail != null
                    ? _actionBlock(
                        "Reset password",
                        "Don’t like your password? Change your password by getting a link in your mail to change it.",
                        "Reset password",
                        Colours.primaryColor,
                        () => _resetPassword(),
                      )
                    : Container(),
                userEmail != null
                    ? FirebaseAuth.instance.currentUser.emailVerified
                        ? Container()
                        : _actionBlock(
                            "Verify your email",
                            "Verifying your email can help you get your account back. In case you forget your password.",
                            "Verify email",
                            Colours.primaryColor,
                            () => _verifyEmail())
                    : Container(),
                userEmail != null
                    ? _actionBlock(
                        "Signout",
                        "Want to switch accounts? Or just wanna signout completely?",
                        "Signout",
                        Colours.specialColor,
                        () => {
                              FirebaseAuthentication().signOut(),
                              _pushLoginScreen(),
                            })
                    : Container(),
                _actionBlock(
                  "Delete account",
                  "Deleting your account will remove all of your content and data associated with it.",
                  "Delete my account",
                  Colours.error,
                  () => _deleteAccount(),
                ),
                SizedBox(height: 50),
              ],
            )));
  }
}
