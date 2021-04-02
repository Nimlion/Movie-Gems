import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'movie.dart';

/*
* This is a local memory of the app and all its settings
* Programmer: Hosam Darwish
*/

class Repo {
  // Theme
  static final String darkKey = 'darktheme';
  static bool darkModeOn = true;

  // Internet connection
  static bool connected = true;

  // Settings adjusted
  static String settingsKey = "customized";
  static bool customized = false;

  // Easter egg found
  static String easterEggKey = "secret";
  static bool easterEgg = false;

  // Font size
  static final String fontKey = 'fontsize';
  static double currFontsize;
  static double smallFont = 16;
  static double giantFont = 28;

  // User settings
  static final String latEpiFirstKey = 'latestEpisFirst';
  static bool latestEpisodesFirst = true;

  // FireStore locations
  static DocumentReference watchlistDoc;
  static DocumentReference seriesDoc;
  static DocumentReference moviesDoc;

  static List<Movie> movieList = List();
  static ValueNotifier<List<Movie>> movieListenable =
      ValueNotifier<List<Movie>>(List());
}
