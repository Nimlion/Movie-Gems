import 'package:flutter/material.dart';
import 'package:movie_gems/controller/TMDBController.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/repository.dart';

Widget movieOverlay(
    BuildContext context, String title, String overview, String url) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      AspectRatio(
        aspectRatio: 1.6,
        child: Image.network(
          "https://image.tmdb.org/t/p/w1280$url",
          fit: BoxFit.cover,
        ),
      ),
      Center(
        child: Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: Repo.currFontsize + 5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  overview,
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.7),
                      fontSize: Repo.currFontsize),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                RaisedButton(
                  color: Colours.accentColor,
                  child: Text(
                    "Add to watchlist",
                    style: TextStyle(
                      fontSize: Repo.currFontsize,
                      color: Colours.white,
                    ),
                  ),
                  onPressed: () => {},
                ),
                SizedBox(height: 30),
                RaisedButton(
                  color: Colours.primaryColor,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Dismiss',
                    style: TextStyle(
                      fontSize: Repo.currFontsize,
                      color: Colours.white,
                    ),
                  ),
                ),
              ],
            )),
      ),
    ],
  );
}

class MovieOverlay extends ModalRoute<void> {
  TMDBResponse movie;

  MovieOverlay(TMDBResponse movie) {
    this.movie = movie;
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: movieOverlay(context, this.movie.title, this.movie.overview,
                this.movie.backdrop)));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class FilmOverlay extends ModalRoute<void> {
  TMDBCondensed film;

  FilmOverlay(TMDBCondensed movie) {
    this.film = movie;
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: movieOverlay(
          context, this.film.title, this.film.overview, this.film.backdrop),
    ));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
