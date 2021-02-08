import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageFiller extends StatelessWidget {
  PageFiller(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            this.text,
            style: TextStyle(fontSize: 34),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}
