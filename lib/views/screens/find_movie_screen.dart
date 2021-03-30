import 'package:flutter/material.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/OMDBController.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';

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

  Widget _heading(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: Repo.currFontsize - 5,
        fontWeight: FontWeight.w100,
        color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.75),
      ),
    );
  }

  Widget _subText(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style:
          TextStyle(fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
    );
  }

  Widget _generalInfo(OMDBResponse film) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.network(film.poster),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heading("released:"),
              _subText(film.released),
              SizedBox(height: 10),
              _heading("runtime:"),
              _subText(film.runtime),
              SizedBox(height: 10),
              _heading("director:"),
              _subText(film.director),
              SizedBox(height: 10),
              _heading("MPAA rating:"),
              _subText(film.rated),
            ],
          ),
        )),
      ],
    );
  }

  Widget _description(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Repo.currFontsize - 2,
        color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.8),
      ),
    );
  }

  Widget _headline(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Repo.currFontsize - 2,
        color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.8),
      ),
    );
  }

  Widget _clause(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Repo.currFontsize + 2,
        fontWeight: FontWeight.bold,
      ),
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
        onPressed: () => {});
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
            return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    _title(film.title),
                    SizedBox(height: 30),
                    _generalInfo(film),
                    SizedBox(height: 20),
                    _description(film.plot),
                    SizedBox(height: 20),
                    film.awards != "" && film.awards != null
                        ? Column(children: [
                            _headline("Awards"),
                            SizedBox(height: 5),
                            _clause(film.awards),
                          ])
                        : SizedBox(),
                    SizedBox(height: 20),
                    film.genre != "" && film.genre != null
                        ? Column(
                            children: [
                              _headline("Genre"),
                              SizedBox(height: 5),
                              _clause(film.genre),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: 20),
                    film.boxOffice != "" && film.boxOffice != null
                        ? Column(
                            children: [
                              _headline("Box Office"),
                              SizedBox(height: 5),
                              _clause(film.boxOffice),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: 20),
                    film.imdbRating != "" && film.imdbRating != null
                        ? Column(
                            children: [
                              _headline("IMDB Rating"),
                              SizedBox(height: 5),
                              _clause(film.imdbRating),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: 20),
                    film.language != "" && film.language != null
                        ? Column(
                            children: [
                              _headline("Language"),
                              SizedBox(height: 5),
                              _clause(film.language),
                            ],
                          )
                        : SizedBox(),
                    film.imdbID != "" && film.imdbID != null
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
