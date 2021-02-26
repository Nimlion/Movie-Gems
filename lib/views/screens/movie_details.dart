import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/TMDBController.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  MovieDetailScreen({Key key, @required this.movie}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(movie);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final Movie movie;

  final cur = NumberFormat("#,##0", "nl_NL");
  Future<TMDBMovie> futureResponse;

  _MovieDetailScreenState(this.movie);

  @override
  void initState() {
    super.initState();
    futureResponse = TMDBController().fetchTMDBData(movie.imdbID);
  }

  Widget _movieIcon(int number) {
    Widget _icon;
    switch (number) {
      case 0:
        _icon = Icon(Icons.favorite_border);
        break;
      case 1:
        _icon = Icon(Icons.favorite);
        break;
      case 2:
        _icon = Icon(Icons.local_activity);
        break;
      default:
        _icon = Icon(Icons.favorite_border);
    }
    return _icon;
  }

  Widget _hero(String image) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.5,
          child: Image.network(
            "https://image.tmdb.org/t/p/w1280$image",
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _title(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: Repo.currFontsize + 10),
      ),
    );
  }

  Widget _subtitle(String title) {
    return Column(children: [
      SizedBox(height: 25),
      Container(
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color:
                  Theme.of(context).textTheme.subtitle1.color.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: Repo.currFontsize + 4),
        ),
      )
    ]);
  }

  Widget _overview(String overview) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        overview,
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
            fontSize: Repo.currFontsize),
      ),
    );
  }

  Widget _categoryIcon() {
    return Positioned(
      top: 215,
      right: 25,
      child: Card(
        color: Colours.accentColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        elevation: 10.0,
        child: Container(
          width: 60,
          height: 60,
          child: Center(child: _movieIcon(movie.category)),
        ),
      ),
    );
  }

  Widget _textBar(String title, String text) {
    return Column(children: [
      SizedBox(height: 25),
      Container(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.7),
                        fontSize: (Repo.currFontsize - 4)),
                  )),
              SizedBox(height: 15),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: Repo.currFontsize,
                    ),
                  )),
            ],
          ))
    ]);
  }

  Widget _pill(String title, String subtitle) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
          border: Border.all(
            color: Colours.primaryColor,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Column(children: [
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: Repo.currFontsize - 2,
              color: Colours.primaryColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Repo.currFontsize + 2,
                color: Colours.primaryColor),
          ),
          SizedBox(height: 20),
        ]));
  }

  Widget _ratingpill(String title, String subtitle) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
          border: Border.all(
            color: Colours.primaryColor,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Column(children: [
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: Repo.currFontsize - 2,
              color: Colours.primaryColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 20),
              Text(
                subtitle,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Repo.currFontsize + 2,
                    color: Colours.primaryColor),
              ),
              IconButton(
                  icon: Icon(
                    Icons.star,
                    color: Colours.gold,
                  ),
                  onPressed: null)
            ],
          ),
          SizedBox(height: 20),
        ]));
  }

  Widget _pillBar(String title1, String text1, String title2, String text2) {
    return Column(children: [
      SizedBox(height: 20),
      Container(
          alignment: Alignment.centerLeft,
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _pill(title1, text1)),
                SizedBox(width: 25),
                Expanded(child: _pill(title2, text2)),
              ],
            ),
          ]))
    ]);
  }

  Widget _ratingPillBar(
      String title1, String text1, String title2, String text2) {
    return Column(children: [
      SizedBox(height: 20),
      Container(
          alignment: Alignment.centerLeft,
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _ratingpill(title1, text1)),
                SizedBox(width: 25),
                Expanded(child: _ratingpill(title2, text2)),
              ],
            ),
          ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TMDBMovie>(
      future: futureResponse,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          var response = snapshot.data;
          return Scaffold(
              body: SafeArea(
                  child: Stack(children: <Widget>[
            _hero(response.backdrop),
            Positioned(
                child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )),
            Positioned(
                top: 250,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colours.background.withOpacity(0.9),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 20.0),
                      ],
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 25, right: 25, top: 0),
                      child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                        SizedBox(height: 30),
                        _title(response.title),
                        SizedBox(height: 15),
                        _overview(response.overview),
                        movie.director != null
                            ? _textBar("Director", movie.director.toString())
                            : SizedBox(),
                        movie.actors != null
                            ? _textBar("Actors", movie.actors.toString())
                            : SizedBox(),
                        response.prodCompanies != null
                            ? _textBar(
                                "Production Companies",
                                response.prodCompanies
                                    .map((e) => e["name"].toString() + " ")
                                    .toString()
                                    .replaceAll("(", "")
                                    .replaceAll(")", ""))
                            : SizedBox(),
                        response.prodCountries != null
                            ? _textBar(
                                "Production Countries",
                                response.prodCountries
                                    .map((e) => e["name"].toString() + " ")
                                    .toString()
                                    .replaceAll("(", "")
                                    .replaceAll(")", ""))
                            : SizedBox(),
                        movie.genre != null
                            ? _textBar("Genre", movie.genre.toString())
                            : SizedBox(),
                        movie.awards != null || response.tagline != "N/A"
                            ? _textBar("Awards", movie.awards.toString())
                            : SizedBox(),
                        response.tagline != null || response.tagline != ""
                            ? _textBar(
                                "Tagline", "\"" + response.tagline + "\"")
                            : SizedBox(),
                        movie.date != null
                            ? _textBar(
                                "Watched on",
                                DateFormat("dd MMMM yyyy")
                                    .format(movie.date)
                                    .toString())
                            : SizedBox(),
                        _subtitle("Statistics"),
                        _pillBar("rated", movie.rated, "runtime",
                            response.runtime.toString() + " MIN"),
                        _pillBar(
                            "released",
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(response.releaseDate))
                                .toString(),
                            "status",
                            response.status),
                        _subtitle("Ratings"),
                        _ratingPillBar("yours", movie.rating.toString(), "imdb",
                            movie.imdbRating),
                        _subtitle("Financials"),
                        _pillBar("budget", "\$" + cur.format(response.budget),
                            "revenue", "\$" + cur.format(response.revenue)),
                        SizedBox(height: 30),
                      ])),
                    ))),
            _categoryIcon(),
          ])));
        }
        return PageFiller("Loading . . .");
      },
    );
  }
}
