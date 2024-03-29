import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Future<void> _changeEmail() async {
    final node = FocusScope.of(context);
    node.unfocus();
    if (!await Internet().checkConnection()) return;
    FirebaseAuthentication().updateEmail(_email);
  }

  void _deleteAnonymousAccount() async {
    if (!await Internet().checkConnection()) return;
    await FirebaseAuthentication().deleteAnonymousAccount();
    _pushLoginScreen();
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
    this._email = FirebaseAuth.instance.currentUser == null
        ? ""
        : FirebaseAuth.instance.currentUser.email;

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
              ..text = FirebaseAuth.instance.currentUser != null
                  ? FirebaseAuth.instance.currentUser.email
                  : "",
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

  Widget _aboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Text(
          "About",
          style: TextStyle(fontSize: Repo.currFontsize + 15),
        ),
        SizedBox(height: 10),
        Text(
          "This product uses the TMDb API but is not endorsed or certified by TMDb.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Repo.currFontsize - 3,
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.only(top: 15),
          child: SvgPicture.asset(
            'assets/img/tmdbLogo.svg',
          ),
        ),
        SizedBox(height: 20),
        RaisedButton(
          color: Colours.accentColor,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Text(
            "website",
            style: TextStyle(
                fontSize: Repo.currFontsize - 2, color: Colours.white),
          ),
          onPressed: () => Internet().launchURL("https://www.themoviedb.org/"),
        ),
        SizedBox(height: 50),
        Text(
          "This product uses the TVMaze API but is not endorsed or certified by TVMaze.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Repo.currFontsize - 3,
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.only(top: 15),
          child:
              Image.network("https://static.tvmaze.com/images/api/tvm_api.png"),
        ),
        SizedBox(height: 20),
        RaisedButton(
          color: Colours.accentColor,
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Text(
            "website",
            style: TextStyle(
                fontSize: Repo.currFontsize - 2, color: Colours.white),
          ),
          onPressed: () => Internet().launchURL("https://www.tvmaze.com/"),
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
      body: Theme(
        data: Theme.of(context).copyWith(accentColor: Colours.primaryColor),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userEmail != null && userEmail != ""
                  ? _updateEmail()
                  : Container(),
              userEmail != null && userEmail != ""
                  ? _actionBlock(
                      "Reset password",
                      "Don’t like your password? Change your password by getting a link in your mail to change it.",
                      "Reset password",
                      Colours.primaryColor,
                      () => _resetPassword(),
                    )
                  : Container(),
              FirebaseAuth.instance.currentUser != null &&
                      FirebaseAuth.instance.currentUser.email != "" &&
                      FirebaseAuth.instance.currentUser.email != null
                  ? FirebaseAuth.instance.currentUser.emailVerified
                      ? Container()
                      : _actionBlock(
                          "Verify your email",
                          "Verifying your email can help you get your account back. In case you forget your password.",
                          "Verify email",
                          Colours.primaryColor,
                          () => _verifyEmail())
                  : Container(),
              userEmail != null && userEmail != ""
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
              _aboutSection(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
