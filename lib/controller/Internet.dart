import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:movie_gems/model/colours.dart';
import 'package:overlay_support/overlay_support.dart';

class Internet {
  Future<bool> checkConnection() async {
    try {
      Response response = await http
          .get('https://www.google.com')
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        return true;
      } else {
        showSimpleNotification(Text("No internet connection available."),
            background: Colours.error);
        return false;
      }
    } catch (e) {
      showSimpleNotification(Text("No internet connection available."),
          background: Colours.error);
      return false;
    }
  }
}
