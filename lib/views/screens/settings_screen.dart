import 'package:flutter/material.dart';
import 'package:movie_gems/controller/themeController.dart';
import 'package:movie_gems/model/appStateNotifier.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _updateDoublePrefs(String repo, value) async {
    if (mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setDouble(Repo.fontKey, value);
    }
  }

  Widget _heading(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: Repo.currFontsize + 5),
    );
  }

  Widget _fontSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        _heading("Font Size"),
        DropdownButton(
          value: Repo.currFontsize,
          dropdownColor: Colours.primaryColor,
          style: TextStyle(
            fontSize: Repo.currFontsize - 3,
            fontFamily: "Raleway",
          ),
          items: [
            DropdownMenuItem(
              child: Text(
                "I am an ant",
              ),
              value: Repo.smallFont,
            ),
            DropdownMenuItem(
              child: Text(
                "Regular",
              ),
              value: Repo.regularFont,
            ),
            DropdownMenuItem(
              child: Text(
                "Large",
              ),
              value: Repo.largeFont,
            ),
            DropdownMenuItem(
              child: Text(
                "Grandma",
              ),
              value: Repo.giantFont,
            ),
          ],
          onChanged: (value) {
            if (mounted) {
              setState(() {
                Repo.currFontsize = value;
              });
              _updateDoublePrefs(Repo.fontKey, value);
            }
          },
        ),
      ],
    );
  }

  Widget _themeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          "Dark Theme",
          style: TextStyle(fontSize: Repo.currFontsize + 5),
        ),
        SizedBox(height: 5),
        Transform.scale(
            scale: 1.4,
            child: Switch(
              activeColor: Colours.primaryColor,
              value: Provider.of<AppStateNotifier>(context, listen: false)
                  .darkModeOn,
              onChanged: (boolValue) {
                setState(() {
                  ThemeController().updateTheme(boolValue, context);
                });
              },
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
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
                _fontSizeSelector(),
                _themeSelector(),
                SizedBox(height: 50),
              ],
            )));
  }
}
