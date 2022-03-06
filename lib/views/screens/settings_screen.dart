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
  Future<void> _updateFontSizePrefs(String repo, double value) async {
    if (mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setDouble(repo, value);
    }
  }

  Future<void> _updateThemeColourPrefs(String repo, String value) async {
    if (mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(repo, value);
    }
  }

  Future<void> _updateEpiOrderPrefs(String repo, bool value) async {
    if (mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool(repo, value);
    }
  }

  Future<void> _setCustomized() async {
    if (mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool(Repo.settingsKey, true);
      Repo.customized = true;
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
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6.0,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
            thumbColor: Colours.primaryColor,
            overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
            activeTickMarkColor: Colours.primaryColor,
            activeTrackColor: Colours.accentColor,
            inactiveTickMarkColor: Colours.primaryColor,
            valueIndicatorColor: Colours.primaryColor,
            valueIndicatorTextStyle: TextStyle(
              color: Colours.white,
            ),
          ),
          child: Slider(
            value: Repo.currFontsize,
            min: Repo.smallFont,
            max: Repo.giantFont,
            divisions: 6,
            label: Repo.currFontsize.toStringAsFixed(1),
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  Repo.currFontsize = value;
                  if (!Repo.customized) _setCustomized();
                });
                _updateFontSizePrefs(Repo.fontKey, value);
              }
            },
          ),
        )
      ],
    );
  }

  Widget _colorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        _heading("Color theme"),
        DropdownButton(
          value: Colours.currentColor,
          dropdownColor: Colours.primaryColor,
          style: TextStyle(
            fontSize: Repo.currFontsize - 3,
            fontFamily: "Raleway",
            color: Theme.of(context).textTheme.bodyText1.color,
          ),
          items: [
            DropdownMenuItem(
              child: Text(
                "Indiana",
              ),
              value: "Indiana",
            ),
            DropdownMenuItem(
              child: Text(
                "Miami",
              ),
              value: "Miami",
            ),
            DropdownMenuItem(
              child: Text(
                "Orange",
              ),
              value: "Orange",
            ),
            DropdownMenuItem(
              child: Text(
                "Woods",
              ),
              value: "Woods",
            ),
            DropdownMenuItem(
              child: Text(
                "Summer",
              ),
              value: "Summer",
            ),
            DropdownMenuItem(
              child: Text(
                "Barbie",
              ),
              value: "Barbie",
            ),
            DropdownMenuItem(
              child: Text(
                "Blood Bath",
              ),
              value: "BloodBath",
            ),
            DropdownMenuItem(
              child: Text(
                "Sunny",
              ),
              value: "Sunny",
            ),
            DropdownMenuItem(
              child: Text(
                "Lime",
              ),
              value: "Lime",
            ),
            DropdownMenuItem(
              child: Text(
                "Sky",
              ),
              value: "Sky",
            ),
            DropdownMenuItem(
              child: Text(
                "Old School",
              ),
              value: "OldSchool",
            ),
          ],
          onChanged: (value) {
            if (mounted) {
              setState(() {
                Colours.updateUserColours(value);
                if (!Repo.customized) _setCustomized();
              });
              _updateThemeColourPrefs(Colours.colorKey, value);
            }
          },
        ),
      ],
    );
  }

  Widget _epiOrderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        _heading("Episode order"),
        DropdownButton(
          value: Repo.latestEpisodesFirst,
          dropdownColor: Colours.primaryColor,
          style: TextStyle(
            fontSize: Repo.currFontsize - 3,
            fontFamily: "Raleway",
            color: Theme.of(context).textTheme.bodyText1.color,
          ),
          items: [
            DropdownMenuItem(
              child: Text(
                "Latest first",
              ),
              value: true,
            ),
            DropdownMenuItem(
              child: Text(
                "Oldest first",
              ),
              value: false,
            )
          ],
          onChanged: (bool value) {
            if (mounted) {
              setState(() {
                Repo.latestEpisodesFirst = value;
                if (!Repo.customized) _setCustomized();
              });
              _updateEpiOrderPrefs(Repo.latEpiFirstKey, value);
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
                  if (!Repo.customized) _setCustomized();
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
      body: Theme(
        data: Theme.of(context).copyWith(accentColor: Colours.primaryColor),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fontSizeSelector(),
              _colorSelector(),
              _epiOrderSelector(),
              _themeSelector(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
