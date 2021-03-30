import 'package:flutter/material.dart';
import 'package:movie_gems/controller/TMDBMovies.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:movie_gems/controller/OMDBController.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';

Future<void> _addDocument(BuildContext context, String title, bool released,
    DateTime releaseDate) async {
  DocumentSnapshot element = await FirebaseFirestore.instance
      .collection('watchlist')
      .doc(FirebaseAuthentication().auth.currentUser.uid)
      .snapshots()
      .first;
  if (element.exists == false) {
    FirebaseFirestore.instance
        .collection('watchlist')
        .doc(FirebaseAuthentication().auth.currentUser.uid)
        .set({});
    addWatchLaterFilm(context, title, released, releaseDate);
  }
}

Future<void> addWatchLaterFilm(BuildContext context, String title,
    bool released, DateTime releaseDate) async {
  if (title == '') {
    showSimpleNotification(Text("Invalid movie title."),
        background: Colours.error);
    return;
  }
  OMDBResponse omdbObject;
  TMDBMovie tmdbObject;
  await OMDBController()
      .fetchSpecificOMDBData(title, releaseDate.year)
      .then((omdbResponse) async => {
            omdbObject = omdbResponse,
            await TMDBMovieController()
                .fetchTMDBData(omdbResponse.imdbID)
                .then((tmdbResponse) => tmdbObject = tmdbResponse)
          });

  if (omdbObject == null || tmdbObject == null) {
    showSimpleNotification(Text("Movie could not be found"),
        background: Colors.red);
  } else {
    FirebaseFirestore.instance
        .collection('watchlist')
        .doc(FirebaseAuthentication().auth.currentUser.uid)
        .update({
          firebaseProof(omdbObject.title): {
            "addedOn": DateTime.now(),
            "releaseDate": releaseDate,
            "released": released,
            "title": omdbObject.title,
            "tmdbID": tmdbObject.id,
            "imdbID": omdbObject.imdbID,
          }
        })
        .then((value) => {
              showSimpleNotification(Text("movie succesfully added"),
                  background: Colours.primaryColor),
              Navigator.pop(context),
            })
        .catchError((error) => {
              if (error.message == "Some requested document was not found.")
                {
                  _addDocument(context, title, true, releaseDate),
                }
              else
                {
                  showSimpleNotification(Text("failed to add movie"),
                      background: Colors.red)
                }
            });
  }
}

Widget movieOverlay(BuildContext context, String title, String overview,
    String url, DateTime releaseDate) {
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
                SizedBox(height: 30),
                RaisedButton(
                  color: Colours.accentColor,
                  child: Text(
                    "Add to watchlist",
                    style: TextStyle(
                      fontSize: Repo.currFontsize,
                      color: Colours.white,
                    ),
                  ),
                  onPressed: () =>
                      {addWatchLaterFilm(context, title, true, releaseDate)},
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
            )),
      ),
    ],
  );
}

class MovieOverlay extends ModalRoute<void> {
  TMDBMovie movie;

  MovieOverlay(TMDBMovie movie) {
    this.movie = movie;
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
                this.movie.backdrop, DateTime.parse(this.movie.releaseDate))));
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
  TMDBCondensedMovie film;

  FilmOverlay(TMDBCondensedMovie movie) {
    this.film = movie;
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
      child: movieOverlay(context, this.film.title, this.film.overview,
          this.film.backdrop, DateTime.parse(this.film.releaseDate)),
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
