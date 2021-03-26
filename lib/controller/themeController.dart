import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:movie_gems/model/appStateNotifier.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  loadPrefs(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(Repo.darkKey) != null) {
      Repo.darkModeOn = prefs.getBool(Repo.darkKey);

      Provider.of<AppStateNotifier>(context, listen: false)
          .updateTheme(prefs.getBool(Repo.darkKey));
    } else {
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark
          ? updateTheme(true, context)
          : updateTheme(false, context);
    }
  }

  updateTheme(bool themeBool, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Repo.darkModeOn = themeBool;
    prefs.setBool(Repo.darkKey, Repo.darkModeOn);

    Provider.of<AppStateNotifier>(context, listen: false)
        .updateTheme(themeBool);
  }
}
