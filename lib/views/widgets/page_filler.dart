import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/model/repository.dart';

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
            style: TextStyle(
                fontSize:
                    Repo.currFontsize != null ? Repo.currFontsize + 10 : 35),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}
