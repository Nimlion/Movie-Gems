import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/OMDBController.dart';
import 'package:movie_gems/controller/TMDBMovies.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';
import 'package:overlay_support/overlay_support.dart';

import 'movie_overview.dart';

class FindMovieScreen extends StatefulWidget {
  final String query;

  FindMovieScreen({Key key, @required this.query}) : super(key: key);

  @override
  _FindMovieScreenState createState() => _FindMovieScreenState(query);
}

class _FindMovieScreenState extends State<FindMovieScreen> {
  String query;
  _FindMovieScreenState(this.query);
  Future<OMDBResponse> movie;

  @override
  void initState() {
    super.initState();
    this.movie = OMDBController().fetchOMDBData(query);
  }

  Future<void> _addDocument(BuildContext context) async {
    DocumentSnapshot element = await Repo.watchlistDoc.snapshots().first;
    if (element.exists == false) {
      Repo.watchlistDoc.set({});
      _addWatchLaterFilm(context);
    }
  }

  Future<void> _addWatchLaterFilm(BuildContext context) async {
    TMDBMovie tmdbObject;
    OMDBResponse omdbObject;
    await movie.then((omdbResponse) async => {
          omdbObject = omdbResponse,
          await TMDBMovieController()
              .fetchTMDBData(omdbResponse.imdbID)
              .then((tmdbResponse) => tmdbObject = tmdbResponse)
        });

    if (omdbObject == null || tmdbObject == null) {
      showSimpleNotification(Text("Movie could not be found"),
          background: Colors.red);
    } else {
      DateFormat format = DateFormat("dd MMM yyyy");
      DateTime releasedate = format.parse(omdbObject.released);
      Repo.watchlistDoc
          .update({
            firebaseProof(omdbObject.title): {
              "addedOn": DateTime.now(),
              "releaseDate": releasedate,
              "released": releasedate.isBefore(DateTime.now()),
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
                    _addDocument(context),
                  }
                else
                  {
                    showSimpleNotification(Text("failed to add movie"),
                        background: Colors.red)
                  }
              });
    }
  }

  Widget _title(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Repo.currFontsize + 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _description(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Repo.currFontsize,
        color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.8),
      ),
    );
  }

  Widget _headlineBlock(String title, String text) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Repo.currFontsize - 2,
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 5),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Repo.currFontsize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _showIMDBBtn(OMDBResponse film) {
    return RaisedButton(
        color: Colours.accentColor,
        padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
        child: Text(
          "Show IMDB page",
          style: TextStyle(
            fontSize: Repo.currFontsize,
            color: Colours.white,
          ),
        ),
        onPressed: () => {
              Internet().launchURL("https://www.imdb.com/title/" + film.imdbID)
            });
  }

  Widget _watchLaterBtn() {
    return RaisedButton(
        color: Colours.primaryColor,
        padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
        child: Text(
          "Add to watchlist",
          style: TextStyle(
            fontSize: Repo.currFontsize,
            color: Colours.white,
          ),
        ),
        onPressed: () => _addWatchLaterFilm(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search result",
          style: TextStyle(fontSize: Repo.currFontsize),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: this.movie.asStream(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              return PageFiller("Failed to load movie");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            OMDBResponse film = snapshot.data;

            if (film == null) {
              return Center(
                  child: Center(
                      child: Text(
                "0 Movies were found.",
                style: TextStyle(fontSize: Repo.currFontsize + 10),
              )));
            }
            return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    film.poster != "" &&
                            film.poster != "N/A" &&
                            film.poster != null
                        ? Image.network(
                            film.poster.replaceFirst("SX300", "SX900"),
                            height:
                                (MediaQuery.of(context).size.width - 50) * 1.4,
                            fit: BoxFit.fill,
                          )
                        : Image.asset(
                            "assets/img/empty-landscape.jpg",
                            fit: BoxFit.cover,
                          ),
                    SizedBox(height: 20),
                    film.title != null && film.title != "N/A"
                        ? _title(film.title)
                        : Container(),
                    SizedBox(height: 20),
                    _description(film.plot),
                    film.released != null && film.released != "N/A"
                        ? _headlineBlock("Release date:", film.released)
                        : SizedBox(),
                    film.awards != null && film.awards != "N/A"
                        ? _headlineBlock("Awards", film.awards)
                        : SizedBox(),
                    film.genre != null && film.genre != "N/A"
                        ? _headlineBlock("Genre", film.genre)
                        : SizedBox(),
                    film.runtime != null && film.runtime != "N/A"
                        ? _headlineBlock("runtime:", film.runtime)
                        : SizedBox(),
                    film.imdbRating != null && film.imdbRating != "N/A"
                        ? _headlineBlock("IMDB", film.imdbRating)
                        : SizedBox(),
                    film.rated != null && film.rated != "N/A"
                        ? _headlineBlock("MPAA rating:", film.rated)
                        : SizedBox(),
                    film.director != null && film.director != "N/A"
                        ? _headlineBlock("director:", film.director)
                        : SizedBox(),
                    film.actors != null && film.actors != "N/A"
                        ? _headlineBlock("Actors", film.actors)
                        : SizedBox(),
                    film.writer != null && film.writer != "N/A"
                        ? _headlineBlock("Writer", film.writer)
                        : SizedBox(),
                    film.boxOffice != null && film.boxOffice != "N/A"
                        ? _headlineBlock("Box Office", film.boxOffice)
                        : SizedBox(),
                    film.production != null && film.production != "N/A"
                        ? _headlineBlock("Production", film.production)
                        : SizedBox(),
                    film.language != null && film.language != "N/A"
                        ? _headlineBlock("Language", film.language)
                        : SizedBox(),
                    film.imdbID != null && film.imdbID != "N/A"
                        ? Column(children: [
                            SizedBox(height: 40),
                            _showIMDBBtn(film),
                            SizedBox(height: 30),
                            _watchLaterBtn(),
                          ])
                        : Column(
                            children: [
                              SizedBox(height: 40),
                              _watchLaterBtn(),
                            ],
                          ),
                    SizedBox(height: 30),
                  ],
                ));
          }),
    );
  }
}
