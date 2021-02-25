import 'package:flutter/cupertino.dart';

import 'movie.dart';

/*
* This is a local memory of the app and all its settings
* Programmer: Hosam Darwish
*/

class Repo {
  // Theme
  static bool darkModeOn = false;
  static final String darkKey = 'darktheme';

  // Font size
  static final String fontKey = 'fontsize';
  static double currFontsize;
  static double smallFont = 16;
  static double regularFont = 20;
  static double largeFont = 22;
  static double giantFont = 26;

  // Passing of variables
  static List<Movie> movieList = List();
  static ValueNotifier<List<Movie>> movieListenable =
      ValueNotifier<List<Movie>>(List());
}
