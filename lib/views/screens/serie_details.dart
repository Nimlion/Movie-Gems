import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/controller/TMDBController.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/model/serie.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';

class SerieDetailScreen extends StatefulWidget {
  final Serie serie;
  SerieDetailScreen({Key key, @required this.serie}) : super(key: key);

  @override
  _SerieDetailScreenState createState() => _SerieDetailScreenState(serie);
}

class _SerieDetailScreenState extends State<SerieDetailScreen> {
  final Serie serie;

  Future<TMDBSerie> futureResponse;

  _SerieDetailScreenState(this.serie);

  @override
  void initState() {
    super.initState();
    futureResponse =
        TMDBController().tmdbFetchSerieDetails(serie.tmdbID.toString());
  }

  Widget _hero(String image) {
    return Container(
        child: Image.network(
      "https://image.tmdb.org/t/p/w500$image",
      fit: BoxFit.cover,
    ));
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TMDBSerie>(
      future: futureResponse,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          var response = snapshot.data;

          return Scaffold(
            body: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                // Allows the user to reveal the app bar if they begin scrolling back
                // up the list of items.
                floating: false,
                pinned: true,
                // Display a placeholder widget to visualize the shrinking size.
                flexibleSpace: Image.network(
                  "https://image.tmdb.org/t/p/w500${response.posterPath}",
                  fit: BoxFit.cover,
                ),
                // Make the initial height of the SliverAppBar larger than normal.
                expandedHeight: 500,
              ),
              SliverList(
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildBuilderDelegate(
                  // The builder function returns a ListTile with a title that
                  // displays the index of the current item.
                  (context, index) => Container(
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
                          _title(response.name),
                          SizedBox(height: 15),
                          _overview(response.overview),
                          response.tagline != null || response.tagline != ""
                              ? _textBar(
                                  "Tagline", "\"" + response.tagline + "\"")
                              : SizedBox(),
                          SizedBox(height: 800),
                        ])),
                      )),
                  childCount: 1,
                ),
              )
            ]),
          );
          return Scaffold(
              body: SafeArea(
                  child: Container(
                      child: SingleChildScrollView(
                          //   slivers: [
                          //     SliverPersistentHeader(
                          //       pinned: true,
                          //       delegate: ImageHeader(response.posterPath),
                          //     ),
                          //     SliverList(delegate:
                          //         SliverChildDelegate((BuildContext context, int index) {
                          //       return Column(children: <Widget>[
                          //         SizedBox(height: 30),
                          //         _title(response.name),
                          //         SizedBox(height: 15),
                          //         _overview(response.overview),
                          //         response.tagline != null || response.tagline != ""
                          //             ? _textBar("Tagline", "\"" + response.tagline + "\"")
                          //             : SizedBox(),
                          //       ]);
                          //     }))
                          //   ],
                          // ))));
                          child: Column(children: <Widget>[
            _hero(response.posterPath),
          ])))));
        }
        return PageFiller("Loading . . .");
      },
    );
  }
}

class ImageHeader extends SliverPersistentHeaderDelegate {
  int index = 0;
  String image;

  ImageHeader(String image) {
    this.image = image;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(builder: (context, constraints) {
      index = 0;

      return Container(
          child: Image.network(
        "https://image.tmdb.org/t/p/w500$image",
        fit: BoxFit.cover,
      ));
    });
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 250.0;

  @override
  double get minExtent => 80.0;
}
