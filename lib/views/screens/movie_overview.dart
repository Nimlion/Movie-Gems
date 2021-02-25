import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/filter_screen.dart';
import 'package:movie_gems/views/screens/movie_details.dart';
import 'package:movie_gems/views/screens/search_screen.dart';
import 'package:overlay_support/overlay_support.dart';

class MoviesPage extends StatefulWidget {
  _MovieOverview createState() => _MovieOverview();
}

class _MovieOverview extends State<MoviesPage> {
  DocumentReference movies = FirebaseFirestore.instance
      .collection('movies')
      .doc(FirebaseAuthentication().auth.currentUser.uid);

  @override
  void initState() {
    super.initState();
    getMovies();
  }

  Future<void> getMovies() async {
    await movies.snapshots().forEach((element) {
      Repo.movieListenable.value = List();
      for (var movieMap in element.data().entries) {
        Repo.movieListenable.value.add(Movie.fromOMDB(
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

      setState(() {
        Repo.movieListenable.value.sort((a, b) => b.date.compareTo(a.date));
        Repo.movieList = List.of(Repo.movieListenable.value);
      });
    });
  }

  showDeleteDialog(BuildContext context, Movie movie) {
    Widget cancelBtn = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget deleteBtn = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        _deleteMovie(movie);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Delete " + movie.title + " ?"),
      content: Text(
          "You're about to delete a movie, which can't be undone. Are your sure?"),
      actions: [
        cancelBtn,
        deleteBtn,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _toggleCategory(Movie movie) {
    if (movie.category == 2) {
      movie.category = 0;
    } else {
      movie.category++;
    }

    return movies
        .update({movie.title.toLowerCase(): movie.toMap()})
        .then((value) => {})
        .catchError((error) => print("Failed to delete movie: $error"));
  }

  Future<void> _deleteMovie(Movie movie) {
    return movies
        .update({movie.title.toLowerCase(): FieldValue.delete()})
        .then((value) => {
              showSimpleNotification(Text("movie succesfully deleted"),
                  background: Colours.primaryColor),
              Navigator.of(context).pop()
            })
        .catchError((error) => print("Failed to delete movie: $error"));
  }

  void _pushDetailScreen(Movie clickedMovie) {
    Navigator.push(context,
        PageRoutes.sharedAxis(() => MovieDetailScreen(movie: clickedMovie)));
  }

  void _pushFilterScreen() {
    Navigator.push(context, PageRoutes.fromBottom(() => FilterScreen()));
  }

  void _pushSearchScreen() {
    Navigator.push(context, PageRoutes.fromBottom(() => SearchScreen()));
  }

  Widget _filterInfoBar(int amount) {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          amount == 1
              ? Text(
                  amount.toString() + ' movie',
                  style: TextStyle(
                      fontSize: Repo.currFontsize - 3,
                      fontWeight: FontWeight.w100),
                )
              : Text(
                  amount.toString() + ' movies',
                  style: TextStyle(
                      fontSize: Repo.currFontsize - 3,
                      fontWeight: FontWeight.w100),
                ),
          InkWell(
              onTap: () => {
                    this._pushFilterScreen(),
                  },
              child: Row(
                children: [
                  Text(
                    "Filter",
                    style: TextStyle(fontSize: Repo.currFontsize - 2),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.filter_list_alt)
                ],
              )),
          InkWell(
              onTap: () => {
                    this._pushSearchScreen(),
                  },
              child: Row(
                children: [
                  Text(
                    "Search",
                    style: TextStyle(fontSize: Repo.currFontsize - 2),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.search)
                ],
              )),
        ],
      ),
    );
  }

  Widget _movieIcon(int number) {
    Widget _icon;
    switch (number) {
      case 0:
        _icon = Icon(Icons.favorite_border);
        break;
      case 1:
        _icon = Icon(Icons.favorite, color: Colors.red);
        break;
      case 2:
        _icon =
            Icon(Icons.local_activity, color: Color.fromRGBO(255, 215, 0, 1));
        break;
      default:
        _icon = Icon(Icons.favorite_border);
    }
    return _icon;
  }

  Widget _movieTile(int index) {
    return ListTile(
      leading: Padding(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Icon(Icons.movie),
      ),
      title: Text(
        Repo.movieListenable.value[index].title,
        style: TextStyle(color: Colours.primaryColor),
      ),
      subtitle: Text(DateFormat("dd MMM. yyyy")
              .format(Repo.movieListenable.value[index].date)
              .toString() +
          " - " +
          Repo.movieListenable.value[index].rating.toString()),
      trailing: IconButton(
        icon: _movieIcon(Repo.movieListenable.value[index].category),
        onPressed: () => {_toggleCategory(Repo.movieListenable.value[index])},
      ),
      onTap: () => _pushDetailScreen(Repo.movieListenable.value[index]),
      onLongPress: () =>
          showDeleteDialog(context, Repo.movieListenable.value[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Repo.movieListenable.value.length == 0) {
      return SafeArea(
        child: Center(
          child: Text(
            "Please add a movie below",
            style: TextStyle(fontSize: Repo.currFontsize + 5),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: Repo.movieListenable,
      builder: (BuildContext context, List<Movie> value, Widget child) {
        return Column(children: [
          Container(
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
            child: _filterInfoBar(Repo.movieListenable.value.length),
          ),
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: Repo.movieListenable.value.length,
                  itemBuilder: (context, index) {
                    return _movieTile(index);
                  }))
        ]);
      },
    );
  }
}
