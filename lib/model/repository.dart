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

  // Font size
  static final String fontKey = 'fontsize';
  static double currFontsize;
  static double smallFont = 16;
  static double giantFont = 28;

  // User settings
  static final String latEpiFirstKey = 'latestEpisFirst';
  static bool latestEpisodesFirst = true;

  // Passing of variables
  static List<Movie> movieList = List();
  static ValueNotifier<List<Movie>> movieListenable =
      ValueNotifier<List<Movie>>(List());
}
