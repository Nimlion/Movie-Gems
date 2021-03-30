import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/TMDBSeries.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';

class SerieOverlay extends ModalRoute<void> {
  TMDBCondensedSerie serie;

  SerieOverlay(TMDBCondensedSerie serie) {
    this.serie = serie;
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.8);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  Widget serieOverlay(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.6,
          child: Image.network(
            "https://image.tmdb.org/t/p/w1280${serie.backdrop}",
            fit: BoxFit.cover,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(25, 50, 25, 25),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              Text(
                serie.name,
                style: TextStyle(fontSize: Repo.currFontsize + 5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                serie.overview,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .color
                        .withOpacity(0.7),
                    fontSize: Repo.currFontsize - 2),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                "First air date: " +
                    DateFormat("dd MMM. yyyy")
                        .format(DateTime.parse(serie.firstAirDate))
                        .toString(),
                style: TextStyle(fontSize: Repo.currFontsize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              RaisedButton(
                color: Colours.accentColor,
                onPressed: () => Internet().launchURL(
                    "https://www.themoviedb.org/tv/" + serie.id.toString()),
                child: Text(
                  'TMDB site',
                  style: TextStyle(
                    fontSize: Repo.currFontsize,
                    color: Colours.white,
                  ),
                ),
              ),
              SizedBox(height: 15),
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
          ),
        ),
      ],
    );
  }

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
    return Center(child: SingleChildScrollView(child: serieOverlay(context)));
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
