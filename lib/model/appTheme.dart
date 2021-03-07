import 'package:flutter/material.dart';
import 'package:movie_gems/model/colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primarySwatch: Colors.indigo,
      accentColor: Colors.indigoAccent,
      primaryColor: Colours.white,
      brightness: Brightness.light,
      fontFamily: 'Sansita',
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colours.shadow,
        filled: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo[400],
      ));

  static final ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      primarySwatch: Colors.indigo,
      accentColor: Colors.indigoAccent,
      primaryColor: Colours.background,
      brightness: Brightness.dark,
      fontFamily: 'Sansita',
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colours.white,
        filled: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo[400],
      ));
}
