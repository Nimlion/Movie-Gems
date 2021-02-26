import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/controller/TMDBController.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_details.dart';
import 'package:movie_gems/views/widgets/movie_overlay.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';

class HomePage extends StatefulWidget {
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends State<HomePage> {
  DocumentReference movies = FirebaseFirestore.instance
      .collection('movies')
      .doc(FirebaseAuthentication().auth.currentUser.uid);
  Future<List<TMDBCondensedMovie>> fututurePopular;
  Future<List<TMDBCondensedMovie>> futurePlaying;
  Future<List<TMDBCondensedMovie>> futureSimilair;
  List<Movie> movieList = List();
  String latestMovie;

  @override
  void initState() {
    super.initState();
    TMDBController tmdb = TMDBController();
    fututurePopular = tmdb.fetchPopular();
    futurePlaying = tmdb.fetchPlaying();

    getFirstMovie();
    getRecommendations();
  }

  Future<void> getRecommendations() async {
    await Future.delayed(Duration(milliseconds: 150));
    if (mounted) {
      setState(() {
        this.futureSimilair =
            TMDBController().fetchSimilarMovies(this.latestMovie);
      });
    }
  }

  Future<void> getFirstMovie() async {
    await movies.snapshots().forEach((element) {
      movieList = List();
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
          movieMap.value['actors'],
          movieMap.value['poster'],
          movieMap.value['awards'],
          movieMap.value['imdbRating'],
          movieMap.value['imdbID'],
          movieMap.value['production'],
        ));
      }

      movieList.sort((a, b) => b.date.compareTo(a.date));
      this.latestMovie = movieList.first.imdbID;

      setState(() {
        this.latestMovie = movieList.first.imdbID;
      });
    });
  }

  void _showOverlay(BuildContext context, dynamic movie) {
    if (movie is TMDBMovie) {
      Navigator.of(context).push(MovieOverlay(movie));
    } else if (movie is TMDBCondensedMovie) {
      Navigator.of(context).push(FilmOverlay(movie));
    }
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
              fontSize: 35,
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
                  child: Image.network(
                    "https://image.tmdb.org/t/p/w342${movie.poster}",
                    fit: BoxFit.cover,
                  ),
                )),
            onTap: () => {
              _showOverlay(context, movie),
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

  void _pushDetailScreen(Movie clickedMovie) {
    Navigator.push(context,
        PageRoutes.sharedAxis(() => MovieDetailScreen(movie: clickedMovie)));
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
                    child: Image.network(
                      movie.poster,
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
                child: Image.network(
                  "https://image.tmdb.org/t/p/w780${movie.backdrop}",
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
            _showOverlay(context, movie),
          },
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 290.0,
          child: Column(
            children: [
              rowTitle("Top movies"),
              StreamBuilder(
                  stream: this.fututurePopular.asStream(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError) {
                      return PageFiller("Error");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<TMDBCondensedMovie> list = snapshot.data;
                    return Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return moviePoster(index, list[index]);
                          }),
                    );
                  }),
            ],
          )),
      Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 320.0,
          child: Column(
            children: [
              SizedBox(height: 30),
              rowTitle("Now playing"),
              StreamBuilder(
                  stream: this.futurePlaying.asStream(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError) {
                      return PageFiller("Error");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<TMDBCondensedMovie> list = snapshot.data;
                    return Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return moviePoster(index, list[index]);
                          }),
                    );
                  }),
            ],
          )),
      Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 320.0,
          child: Column(
            children: [
              SizedBox(height: 30),
              rowTitle("Recent movies"),
              StreamBuilder<DocumentSnapshot>(
                  stream: movies.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return PageFiller("Error");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    DocumentSnapshot querydoc = snapshot.data;
                    if (querydoc == null || querydoc.data().entries.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movieList.take(10).length,
                            itemBuilder: (context, index) {
                              return collectionPoster(index, movieList[index]);
                            }),
                      );
                    }
                  }),
            ],
          )),
      this.futureSimilair == null
          ? Container(
              child: Column(
              children: [
                SizedBox(height: 30),
                rowTitle("Recommendations"),
                Center(child: CircularProgressIndicator()),
              ],
            ))
          : StreamBuilder<List<TMDBCondensedMovie>>(
              stream: this.futureSimilair.asStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TMDBCondensedMovie>> snapshot) {
                if (snapshot.hasError) {
                  return PageFiller("Error");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List<TMDBCondensedMovie> list = snapshot.data;
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(height: 30),
                  rowTitle("Recommendations"),
                  Column(
                    children: list.take(10).map<Widget>((item) {
                      return _recommendation(item);
                    }).toList(),
                  ),
                ]);
              }),
      SizedBox(height: 35),
    ]));
  }
}
