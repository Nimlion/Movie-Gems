import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_gems/controller/themeController.dart';
import 'package:movie_gems/model/appTheme.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'model/appStateNotifier.dart';

// Views
import 'views/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(),
      child: StartScreen(),
    ),
  );
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    setState(() {
      ThemeController().loadPrefs(context);
    });

    _loadPrefs();

    super.initState();
  }

  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // Get the current font size
      if (prefs.getDouble(Repo.fontKey) != null) {
        Repo.currFontsize = prefs.getDouble(Repo.fontKey);
      } else {
        Repo.currFontsize = 20;
      }
    });

    setState(() {
      // Get the current color theme
      if (prefs.getString(Colours.colorKey) != null) {
        Colours.updateUserColours(prefs.getString(Colours.colorKey));
      }
    });

    setState(() {
      // Get the latest episode first value
      if (prefs.getBool(Repo.latEpiFirstKey) != null) {
        Repo.latestEpisodesFirst = prefs.getBool(Repo.latEpiFirstKey);
      }
    });

    setState(() {
      // Get the settings value
      if (prefs.getBool(Repo.settingsKey) != null) {
        Repo.customized = prefs.getBool(Repo.settingsKey);
      }
    });

    setState(() {
      // Get the easter egg value
      if (prefs.getBool(Repo.easterEggKey) != null) {
        Repo.easterEgg = prefs.getBool(Repo.easterEggKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("An error occured while initializing FlutterFire");
          return Consumer<AppStateNotifier>(
              builder: (context, appState, child) {
            return MaterialApp(
              title: 'Error',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: appState.darkModeOn ? ThemeMode.dark : ThemeMode.light,
              home: PageFiller("Error"),
            );
          });
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return Consumer<AppStateNotifier>(
              builder: (context, appState, child) {
            return OverlaySupport(
                child: MaterialApp(
              title: 'Movie Gems',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: appState.darkModeOn ? ThemeMode.dark : ThemeMode.light,
              home: LoginScreen(),
            ));
          });
        }

        return Consumer<AppStateNotifier>(builder: (context, appState, child) {
          return MaterialApp(
            title: 'Loading',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.darkModeOn ? ThemeMode.dark : ThemeMode.light,
            home: PageFiller("Loading . . ."),
          );
        });
      },
    );
  }
}
