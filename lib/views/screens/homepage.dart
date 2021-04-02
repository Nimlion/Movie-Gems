import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/TMDBMovies.dart';
import 'package:movie_gems/controller/TMDBSeries.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_details.dart';
import 'package:movie_gems/views/widgets/movie_overlay.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';
import 'package:movie_gems/views/widgets/serie_overlay.dart';

class HomePage extends StatefulWidget {
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends State<HomePage> {
  Future<List<TMDBCondensedMovie>> popularMovies;
  Future<List<TMDBCondensedSerie>> popularSeries;
  Future<List<TMDBCondensedMovie>> playingMovies;
  Future<List<TMDBCondensedMovie>> similairMovies;
  List<Movie> movieList = List();
  String latestMovie;

  @override
  void initState() {
    super.initState();
    callApis();
  }

  Future<void> callApis() async {
    if (!await Internet().checkConnection()) {
      setState(() {
        Repo.connected = false;
      });
      return null;
    }
    setState(() {
      Repo.connected = true;
    });

    TMDBMovieController tmdb = TMDBMovieController();

    setState(() {
      popularMovies = tmdb.fetchPopular();
      playingMovies = tmdb.fetchPlaying();
      popularSeries = TMDBSeriesController().fetchPopularSeries();
    });

    getFirstMovie();
    getRecommendations();
  }

  Future<void> getRecommendations() async {
    await Future.delayed(Duration(milliseconds: 150));
    if (mounted && this.latestMovie != null) {
      setState(() {
        this.similairMovies =
            TMDBMovieController().fetchSimilarMovies(this.latestMovie);
      });
    }
  }

  Future<void> getFirstMovie() async {
    if (mounted) {
      DocumentSnapshot element = await Repo.moviesDoc.snapshots().first;
      movieList = List();
      if (element.data() == null) {
        this.latestMovie = null;
        return;
      }
      for (var movieMap in element.data().entries) {
        movieList.add(Movie.fromOMDB(
          movieMap.value['title'],
          movieMap.value['rating'],
          movieMap.value['date'].toDate(),
          movieMap.value['category'],
          movieMap.value['rated'],
          movieMap.value['runtime'],
          movieMap.value['genre'],
          movieMap.value['director'],
          movieMap.value['poster'],
          movieMap.value['awards'],
          movieMap.value['imdbRating'],
          movieMap.value['imdbID'],
          movieMap.value['tmdbID'],
          movieMap.value['production'],
        ));
      }

      if (movieList != null && movieList.length != 0) {
        movieList.sort((a, b) => b.date.compareTo(a.date));
        this.latestMovie = movieList.first.imdbID;
        setState(() {
          this.latestMovie = movieList.first.imdbID;
        });
      }
    }
  }

  void _showMovieOverlay(BuildContext context, dynamic movie) {
    if (movie is TMDBMovie) {
      Navigator.of(context).push(MovieOverlay(movie));
    } else if (movie is TMDBCondensedMovie) {
      Navigator.of(context).push(FilmOverlay(movie));
    }
  }

  void _showSerieOverlay(BuildContext context, TMDBCondensedSerie serie) {
    Navigator.of(context).push(SerieOverlay(serie));
  }

  void _pushDetailScreen(Movie clickedMovie) {
    Navigator.push(context,
        PageRoutes.sharedAxis(() => MovieDetailScreen(movie: clickedMovie)));
  }

  Widget rowTitle(String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: Repo.currFontsize + 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget moviePoster(int index, TMDBCondensedMovie movie) {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Stack(children: <Widget>[
          GestureDetector(
            child: Container(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: movie.poster != null && movie.poster != ""
                      ? Image.network(
                          "https://image.tmdb.org/t/p/w342${movie.poster}",
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/img/empty-landscape.jpg",
                          fit: BoxFit.cover,
                        ),
                )),
            onTap: () => {
              _showMovieOverlay(context, movie),
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              (index + 1).toString() + ".",
              style: TextStyle(
                color: Colours.white,
                fontSize: 60,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0.0, 0.0),
                    blurRadius: 15,
                    color: Colours.background,
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  Widget seriePoster(int index, TMDBCondensedSerie serie) {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Stack(children: <Widget>[
          GestureDetector(
            child: Container(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: serie.posterPath != null && serie.posterPath != ""
                      ? Image.network(
                          "https://image.tmdb.org/t/p/w342${serie.posterPath}",
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/img/empty-landscape.jpg",
                          fit: BoxFit.cover,
                        ),
                )),
            onTap: () => _showSerieOverlay(context, serie),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              (index + 1).toString() + ".",
              style: TextStyle(
                color: Colours.white,
                fontSize: 60,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0.0, 0.0),
                    blurRadius: 15,
                    color: Colours.background,
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  Widget collectionPoster(int index, Movie movie) {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Stack(children: <Widget>[
          GestureDetector(
              child: Container(
                  padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: movie.poster != null && movie.poster != ""
                        ? Image.network(
                            movie.poster,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/img/empty-landscape.jpg",
                            fit: BoxFit.cover,
                          ),
                  )),
              onTap: () => _pushDetailScreen(movie)),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              (index + 1).toString() + ".",
              style: TextStyle(
                color: Colours.white,
                fontSize: 60,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0.0, 0.0),
                    blurRadius: 15,
                    color: Colours.background,
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  Widget _recommendation(TMDBCondensedMovie movie) {
    if (movie.backdrop != null && movie.title != null) {
      return Container(
        margin: EdgeInsets.only(bottom: 30, left: 20, right: 20),
        child: GestureDetector(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: movie.backdrop != null && movie.backdrop != ""
                    ? Image.network(
                        "https://image.tmdb.org/t/p/w780${movie.backdrop}",
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/img/empty-landscape.jpg",
                        fit: BoxFit.cover,
                      ),
              ),
              Center(
                child: Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      movie.title,
                      style: TextStyle(
                          fontSize: Repo.currFontsize, color: Colours.white),
                      textAlign: TextAlign.center,
                    )),
              ),
            ],
          ),
          onTap: () => {
            _showMovieOverlay(context, movie),
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _loadingPoster() {
    return Container(
      height: 220,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _noConnectionWidget() {
    return Container(
        height: 225,
        child: Center(
            child: Text(
          "No internet connection.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Repo.currFontsize + 10,
            color: Colours.error,
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    if (!Repo.connected) {
      return PageFiller("No internet connection.");
    } else if (this.playingMovies == null ||
        this.popularMovies == null ||
        this.popularSeries == null) {
      return Center(
        child: Transform.scale(
          scale: 1.8,
          child: CircularProgressIndicator(
            semanticsLabel: "Loading",
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(children: [
        SizedBox(height: 10),
        Container(
          height: 290,
          child: Column(
            children: [
              rowTitle("Now playing"),
              !Repo.connected
                  ? _noConnectionWidget()
                  : this.playingMovies == null
                      ? _loadingPoster()
                      : StreamBuilder(
                          stream: this.playingMovies.asStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasError) {
                              return Container(
                                  height: 225,
                                  child: Center(
                                      child: Text(
                                    "Something went wrong.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Repo.currFontsize + 15),
                                  )));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _loadingPoster();
                            }

                            List<TMDBCondensedMovie> list = snapshot.data;
                            return Expanded(
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return moviePoster(index, list[index]);
                                  }),
                            );
                          }),
            ],
          ),
        ),
        Container(
          height: 320,
          child: Column(
            children: [
              SizedBox(height: 30),
              rowTitle("Top movies"),
              !Repo.connected
                  ? _noConnectionWidget()
                  : this.popularMovies == null
                      ? _loadingPoster()
                      : StreamBuilder(
                          stream: this.popularMovies.asStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasError) {
                              return Container(
                                  height: 225,
                                  child: Center(
                                      child: Text(
                                    "Something went wrong.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Repo.currFontsize + 15),
                                  )));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _loadingPoster();
                            }

                            List<TMDBCondensedMovie> list = snapshot.data;
                            return Expanded(
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return moviePoster(index, list[index]);
                                  }),
                            );
                          }),
            ],
          ),
        ),
        Container(
          height: 320,
          child: Column(
            children: [
              SizedBox(height: 30),
              rowTitle("Top Series"),
              !Repo.connected
                  ? _noConnectionWidget()
                  : this.popularSeries == null
                      ? _loadingPoster()
                      : StreamBuilder(
                          stream: this.popularSeries.asStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasError) {
                              return Container(
                                  height: 225,
                                  child: Center(
                                      child: Text(
                                    "Something went wrong.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Repo.currFontsize + 15),
                                  )));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _loadingPoster();
                            }

                            List<TMDBCondensedSerie> list = snapshot.data;
                            return Expanded(
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return seriePoster(index, list[index]);
                                  }),
                            );
                          }),
            ],
          ),
        ),
        Container(
          height: 320,
          child: Column(
            children: [
              SizedBox(height: 30),
              rowTitle("Recent movies"),
              !Repo.connected
                  ? _noConnectionWidget()
                  : StreamBuilder<DocumentSnapshot>(
                      stream: Repo.moviesDoc.snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Container(
                              height: 225,
                              child: Center(
                                  child: Text(
                                "Something went wrong.",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: Repo.currFontsize + 15),
                              )));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _loadingPoster();
                        }

                        DocumentSnapshot querydoc = snapshot.data;

                        if (querydoc == null ||
                            querydoc.data() == null ||
                            querydoc.data().entries.isEmpty) {
                          return Container(
                              height: 225,
                              child: Center(
                                  child: Text(
                                "No movies added yet.",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: Repo.currFontsize + 15),
                              )));
                        } else {
                          return ValueListenableBuilder(
                              valueListenable: Repo.movieListenable,
                              builder: (BuildContext context, List<Movie> value,
                                  Widget child) {
                                Repo.movieListenable.value.clear();
                                for (var movieMap
                                    in snapshot.data.data().entries) {
                                  Repo.movieListenable.value.add(Movie.fromOMDB(
                                    movieMap.value['title'],
                                    movieMap.value['rating'],
                                    movieMap.value['date'].toDate(),
                                    movieMap.value['category'],
                                    movieMap.value['rated'],
                                    movieMap.value['runtime'],
                                    movieMap.value['genre'],
                                    movieMap.value['director'],
                                    movieMap.value['poster'],
                                    movieMap.value['awards'],
                                    movieMap.value['imdbRating'],
                                    movieMap.value['imdbID'],
                                    movieMap.value['tmdbID'],
                                    movieMap.value['production'],
                                  ));
                                }
                                Repo.movieListenable.value
                                    .sort((a, b) => b.date.compareTo(a.date));
                                movieList = Repo.movieListenable.value;
                                return Expanded(
                                  child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: movieList.take(10).length,
                                    itemBuilder: (context, index) {
                                      return collectionPoster(
                                          index, movieList[index]);
                                    },
                                  ),
                                );
                              });
                        }
                      })
            ],
          ),
        ),
        !Repo.connected || this.similairMovies == null
            ? Container()
            : StreamBuilder<List<TMDBCondensedMovie>>(
                stream: this.similairMovies.asStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<TMDBCondensedMovie>> snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                        height: 225,
                        child: Center(
                            child: Text(
                          "Something went wrong.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: Repo.currFontsize + 15),
                        )));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _loadingPoster();
                  }

                  List<TMDBCondensedMovie> list = snapshot.data;

                  if (list.isEmpty) {
                    return Container();
                  }
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(height: 30),
                    rowTitle("Recommendations"),
                    Column(
                      children: list.take(10).map<Widget>((item) {
                        return _recommendation(item);
                      }).toList(),
                    ),
                  ]);
                },
              ),
        SizedBox(height: 10),
      ]),
    );
  }
}
