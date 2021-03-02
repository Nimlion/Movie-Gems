import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/TMDBController.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/model/serie.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class SerieDetailScreen extends StatefulWidget {
  final Serie serie;
  SerieDetailScreen({Key key, @required this.serie}) : super(key: key);

  @override
  _SerieDetailScreenState createState() => _SerieDetailScreenState(serie);
}

class _SerieDetailScreenState extends State<SerieDetailScreen> {
  final Serie serie;

  Future<TMDBSerie> futureDetails;
  Future<TMDBCast> futureCast;

  _SerieDetailScreenState(this.serie);

  @override
  void initState() {
    super.initState();
    futureDetails =
        TMDBController().tmdbFetchSerieDetails(serie.tmdbID.toString());
    futureCast = TMDBController().fetchSerieCast(serie.tmdbID.toString());
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showSimpleNotification(Text("Could not open URL"),
          background: Colors.red);
      throw 'Could not launch $url';
    }
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
          ? Image.network(
              "https://image.tmdb.org/t/p/w500$image",
              fit: BoxFit.cover,
            )
          : Image.asset(
              "assets/img/empty-landscape.jpg",
              fit: BoxFit.cover,
            ),
      expandedHeight: MediaQuery.of(context).size.width * 1.4,
    );
  }

  Widget _title(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: Repo.currFontsize + 15),
      ),
    );
  }

  Widget _webBtn(String url, String label) {
    return Column(
      children: [
        SizedBox(height: 20),
        RaisedButton(
          child: Text(
            label,
            style: TextStyle(
              fontSize: Repo.currFontsize,
              color: label == "IMDB" ? Colours.background : Colours.white,
            ),
          ),
          color: label == "IMDB" ? Colours.gold : Colours.primaryColor,
          padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
          onPressed: () => {_launchURL(url)},
        )
      ],
    );
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

  Widget _castBox(Map<dynamic, dynamic> crew) {
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
          crew["roles"].isNotEmpty &&
                  crew["roles"][0]["character"] != "" &&
                  crew["roles"][0]["character"] != null
              ? Text(
                  "aka " +
                      crew["roles"].map((role) => role["character"]).join(', '),
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
          crew["department"] != "" && crew["department"] != null
              ? Text(
                  crew["department"],
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TMDBSerie>(
      future: futureDetails,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          var response = snapshot.data;

          return Scaffold(
            body: CustomScrollView(slivers: <Widget>[
              _hero(response.posterPath),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25, top: 0),
                    child: Column(children: <Widget>[
                      SizedBox(height: 30),
                      _title(response.name),
                      SizedBox(height: 15),
                      _overview(response.overview),
                      SizedBox(height: 20),
                      response.createdBy != null &&
                              response.createdBy.isNotEmpty
                          ? Column(children: [
                              _textBar(
                                  "Created by",
                                  response.createdBy
                                      .map((creator) => creator["name"])
                                      .join(", ")),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.tagline != null && response.tagline != ""
                          ? Column(children: [
                              _textBar(
                                  "Tagline", "\"" + response.tagline + "\""),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.type != null && response.type != ""
                          ? Column(children: [
                              _textBar("Type", response.type),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.nextEpisodeToAir != null &&
                              response.nextEpisodeToAir.isNotEmpty
                          ? Column(children: [
                              _textBar(
                                  "Next episode released",
                                  DateFormat("dd MMMM yyyy")
                                      .format(DateTime.parse(response
                                          .nextEpisodeToAir["air_date"]))
                                      .toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      serie.genres != null && serie.genres != ""
                          ? Column(children: [
                              _textBar("Genres", serie.genres),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.episodeRunTime != null &&
                              response.episodeRunTime.isNotEmpty
                          ? Column(children: [
                              _textBar(
                                  "Runtime",
                                  response.episodeRunTime[0].toString() +
                                      " min"),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      serie.startdate != null
                          ? Column(children: [
                              _textBar(
                                  "Started watching",
                                  DateFormat("dd MMMM yyyy")
                                      .format(serie.startdate)
                                      .toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.firstAirDate != null &&
                              response.firstAirDate != ""
                          ? Column(children: [
                              _textBar(
                                  "First air date",
                                  DateFormat("dd MMMM yyyy")
                                      .format(
                                          DateTime.parse(response.firstAirDate))
                                      .toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.lastAirDate != null && response.lastAirDate != ""
                          ? Column(children: [
                              _textBar(
                                  "Last air date",
                                  DateFormat("dd MMMM yyyy")
                                      .format(
                                          DateTime.parse(response.lastAirDate))
                                      .toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.inProduction != null
                          ? Column(children: [
                              _textBar("In production",
                                  response.inProduction.toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.status != null && response.status != ""
                          ? Column(children: [
                              _textBar("Status", response.status.toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.networks != null && response.networks.isNotEmpty
                          ? Column(children: [
                              _textBar(
                                  "Networks",
                                  response.networks
                                      .map((network) => network["name"])
                                      .join(", ")
                                      .toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.numberOfSeasons != null
                          ? Column(children: [
                              _textBar("Number of seasons",
                                  response.numberOfSeasons.toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      response.numberOfEpisodes != null
                          ? Column(children: [
                              _textBar("Number of episodes",
                                  response.numberOfEpisodes.toString()),
                              SizedBox(height: 20)
                            ])
                          : SizedBox(),
                      Wrap(
                        spacing: 25,
                        runAlignment: WrapAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          response.homepage != null && response.homepage != ""
                              ? _webBtn(response.homepage, "Official site")
                              : Container(),
                          serie.imdbID != null && serie.imdbID != ""
                              ? _webBtn(
                                  "https://www.imdb.com/title/" + serie.imdbID,
                                  "IMDB")
                              : Container(),
                          serie.tvMazeURL != null && serie.tvMazeURL != ""
                              ? _webBtn(serie.tvMazeURL, "TVmaze")
                              : Container(),
                        ],
                      ),
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
                                              childAspectRatio: 0.50,
                                              crossAxisSpacing: 25,
                                              mainAxisSpacing: 25,
                                              crossAxisCount: 2,
                                              physics: BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              children: List.generate(
                                                  cast.cast.take(40).length,
                                                  (index) {
                                                return _castBox(
                                                    cast.cast[index]);
                                              }),
                                            ),
                                            SizedBox(height: 30),
                                          ],
                                        )
                                      : Container(),
                                  cast.crew.isNotEmpty
                                      ? Column(
                                          children: [
                                            _subTitle("Crew"),
                                            GridView.count(
                                              childAspectRatio: 0.50,
                                              crossAxisSpacing: 25,
                                              mainAxisSpacing: 25,
                                              crossAxisCount: 2,
                                              physics: BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              children: List.generate(
                                                  cast.crew.take(40).length,
                                                  (index) {
                                                return _crewBox(
                                                    cast.crew[index]);
                                              }),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ]);
                              }),
                    ]),
                  ),
                  childCount: 1,
                ),
              )
            ]),
          );
        }
        return PageFiller("Loading . . .");
      },
    );
  }
}
