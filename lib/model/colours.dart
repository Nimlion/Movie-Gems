import 'package:flutter/material.dart';

class Colours {
  // Basics
  static final Color white = Color(0xFFFFFFFF);
  static final Color background = Color(0xFF222222);
  static final Color gold = Color(0xFFFFD700);
  static final Color error = Color(0xFFC70039);

  // Personal
  static final String colorKey = "colorTheme";
  static String currentColor = "Indiana";
  static Color primaryColor = Color(0xFF536DFE);
  static Color accentColor = Color(0xFF8C9EFF);
  static Color specialColor = Color(0xFFFF8a65);

  // Shadows
  static final Color shadow = Color(0xFF222222).withOpacity(0.2);
  static final Color lightShadow = Color(0xFFFFFFFF).withOpacity(0.2);

  static void updateUserColours(String key) {
    Colours.currentColor = key;
    switch (key) {
      case "Indiana":
        Colours.primaryColor = Color(0xFF536DFE);
        Colours.accentColor = Color(0xFF8C9EFF);
        break;
      case "Miami":
        Colours.primaryColor = Color(0xFF673AB7);
        Colours.accentColor = Color(0xFF7C4DFF);
        break;
      case "Orange":
        Colours.primaryColor = Color(0xFFf48b29);
        Colours.accentColor = Color(0xFFffab73);
        break;
      case "Woods":
        Colours.primaryColor = Color(0xFF00af91);
        Colours.accentColor = Color(0xFF025955);
        break;
      case "Summer":
        Colours.primaryColor = Color(0xFFff005c);
        Colours.accentColor = Color(0xFF810034);
        break;
      case "Barbie":
        Colours.primaryColor = Color(0xFFf875aa);
        Colours.accentColor = Color(0xFFf25287);
        break;
      default:
        Colours.primaryColor = Color(0xFF536DFE);
        Colours.accentColor = Color(0xFF8C9EFF);
    }
  }
}
