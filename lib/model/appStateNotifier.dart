import 'package:flutter/material.dart';

class AppStateNotifier extends ChangeNotifier {
  bool darkModeOn = false;

  void updateTheme(bool isDarkModeOn) {
    this.darkModeOn = isDarkModeOn;
    notifyListeners();
  }
}
