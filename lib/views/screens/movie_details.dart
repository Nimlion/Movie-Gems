import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/TMDBMovies.dart';
import 'package:movie_gems/controller/TMDBSeries.dart';
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
  Future<TMDBCast> futureCast;
  int castmembers = 6;
  int crewmembers = 6;

  _MovieDetailScreenState(this.movie);

  @override
  void initState() {
    super.initState();
    futureResponse = TMDBMovieController().fetchTMDBData(movie.imdbID);
    futureCast = TMDBMovieController().fetchMovieCast(movie.tmdbID.toString());
  }

  Widget _hero(String image) {
    return SliverAppBar(
      pinned: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colours.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: image != "" && image != null
          ? AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                "https://image.tmdb.org/t/p/w1280$image",
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              "assets/img/empty-landscape.jpg",
              fit: BoxFit.cover,
            ),
      expandedHeight: MediaQuery.of(context).size.width * 0.9,
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
                (text1 != null && text1 != "\$0")
                    ? Expanded(child: _pill(title1, text1))
                    : Container(),
                (text1 != null && text1 != "\$0")
                    ? SizedBox(width: 25)
                    : Container(),
                (text2 != null && text2 != "\$0")
                    ? Expanded(child: _pill(title2, text2))
                    : Container(),
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

  Widget _subTitle(String title) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: Repo.currFontsize + 10),
      ),
    );
  }

  Widget _castBox(Map<dynamic, dynamic> cast) {
    return Center(
      child: Column(
        children: [
          cast["profile_path"] != "" && cast["profile_path"] != null
              ? SizedBox(
                  height: 200,
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w185${cast["profile_path"]}',
                    fit: BoxFit.cover,
                  ),
                )
              : SizedBox(
                  height: 200,
                  width: 120,
                  child: Placeholder(),
                ),
          SizedBox(height: 15),
          Text(
            cast["name"],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Repo.currFontsize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          cast["character"] != null && cast["character"] != ""
              ? Text(
                  "as " + cast["character"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Repo.currFontsize - 5,
                    fontWeight: FontWeight.w100,
                    fontFamily: "Raleway",
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _increaseBtn(Function fun) {
    return RaisedButton(
      onPressed: fun,
      padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
      child: Text(
        "Load more",
        style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: Repo.currFontsize),
      ),
    );
  }

  Widget _crewBox(Map<dynamic, dynamic> crew) {
    return Center(
      child: Column(
        children: [
          crew["profile_path"] != "" && crew["profile_path"] != null
              ? SizedBox(
                  height: 200,
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w185${crew["profile_path"]}',
                    fit: BoxFit.cover,
                  ),
                )
              : SizedBox(
                  height: 200,
                  width: 120,
                  child: Placeholder(),
                ),
          SizedBox(height: 15),
          Text(
            crew["name"],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Repo.currFontsize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          crew["job"] != "" && crew["job"] != null
              ? Text(
                  crew["job"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Repo.currFontsize - 5,
                    fontWeight: FontWeight.w100,
                    fontFamily: "Raleway",
                  ),
                )
              : Container(),
          SizedBox(height: 5),
          crew["total_episode_count"] != "" &&
                  crew["total_episode_count"] != null
              ? Text(
                  "Episode count: " + crew["total_episode_count"].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Repo.currFontsize - 5,
                    fontWeight: FontWeight.w100,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .color
                        .withOpacity(0.8),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  String _categoryLabeler(int category) {
    switch (category) {
      case 0:
        return "Normal";
        break;
      case 1:
        return "Favorites";
        break;
      case 2:
        return "Movie Gems";
        break;
      default:
        return "Normal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TMDBMovie>(
      future: futureResponse,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          var response = snapshot.data;

          return Scaffold(
              body: CustomScrollView(slivers: <Widget>[
            _hero(response.backdrop),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25, top: 0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 30),
                      _title(response.title),
                      SizedBox(height: 15),
                      _overview(response.overview),
                      movie.director != null
                          ? _textBar("Director", movie.director.toString())
                          : SizedBox(),
                      response.prodCompanies != null &&
                              response.prodCompanies
                                      .map((con) => con["name"])
                                      .join(', ') !=
                                  ""
                          ? _textBar(
                              "Production Companies",
                              response.prodCompanies
                                  .map((com) => com["name"])
                                  .join(', '))
                          : SizedBox(),
                      response.prodCountries != null &&
                              response.prodCountries
                                      .map((con) => con["name"])
                                      .join(', ') !=
                                  ""
                          ? _textBar(
                              "Production Countries",
                              response.prodCountries
                                  .map((con) => con["name"])
                                  .join(', '))
                          : SizedBox(),
                      movie.genre != null
                          ? _textBar("Genre", movie.genre.toString())
                          : SizedBox(),
                      movie.category != null
                          ? _textBar(
                              "Category", _categoryLabeler(movie.category))
                          : SizedBox(),
                      movie.awards != null && movie.awards != "N/A"
                          ? _textBar("Awards", movie.awards.toString())
                          : SizedBox(),
                      response.tagline != null && response.tagline != ""
                          ? _textBar("Tagline", "\"" + response.tagline + "\"")
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
                      response.budget != null &&
                              response.revenue != null &&
                              response.budget != 0 &&
                              response.revenue != 0
                          ? Column(
                              children: [
                                _subtitle("Financials"),
                                _pillBar(
                                    "budget",
                                    "\$" + cur.format(response.budget),
                                    "revenue",
                                    "\$" + cur.format(response.revenue))
                              ],
                            )
                          : Container(),
                      SizedBox(height: 50),
                      this.futureCast == null
                          ? Container(
                              child: Column(
                              children: [
                                SizedBox(height: 30),
                                _title("Cast"),
                                Center(child: CircularProgressIndicator()),
                              ],
                            ))
                          : FutureBuilder<TMDBCast>(
                              future: this.futureCast,
                              builder: (BuildContext context,
                                  AsyncSnapshot<TMDBCast> snapshot) {
                                if (snapshot.hasError) {
                                  return PageFiller("Error");
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                TMDBCast cast = snapshot.data;
                                return Column(children: [
                                  cast.cast.isNotEmpty
                                      ? Column(
                                          children: [
                                            _subTitle("Cast"),
                                            GridView.count(
                                              childAspectRatio:
                                                  MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.portrait
                                                      ? 0.51
                                                      : 0.9,
                                              crossAxisSpacing: 25,
                                              mainAxisSpacing: 25,
                                              crossAxisCount:
                                                  MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.portrait
                                                      ? 2
                                                      : 3,
                                              physics: BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              children: List.generate(
                                                  cast.cast
                                                      .take(castmembers)
                                                      .length, (index) {
                                                return _castBox(
                                                    cast.cast[index]);
                                              }),
                                            ),
                                            cast.cast.length > castmembers
                                                ? _increaseBtn(() => {
                                                      setState(() {
                                                        castmembers += 6;
                                                      }),
                                                    })
                                                : Container(),
                                            SizedBox(height: 75),
                                          ],
                                        )
                                      : Container(),
                                  cast.crew.isNotEmpty
                                      ? Column(
                                          children: [
                                            _subTitle("Crew"),
                                            GridView.count(
                                              childAspectRatio:
                                                  MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.portrait
                                                      ? 0.51
                                                      : 0.9,
                                              crossAxisSpacing: 25,
                                              mainAxisSpacing: 25,
                                              crossAxisCount:
                                                  MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.portrait
                                                      ? 2
                                                      : 3,
                                              physics: BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              children: List.generate(
                                                  cast.crew
                                                      .take(crewmembers)
                                                      .length, (index) {
                                                return _crewBox(
                                                    cast.crew[index]);
                                              }),
                                            ),
                                            cast.crew.length > crewmembers
                                                ? _increaseBtn(() => {
                                                      setState(() {
                                                        crewmembers += 6;
                                                      }),
                                                    })
                                                : Container(),
                                            SizedBox(height: 20),
                                          ],
                                        )
                                      : Container(),
                                ]);
                              }),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
                childCount: 1,
              ),
            ),
          ]));
        }
        return PageFiller("Loading . . .");
      },
    );
  }
}
