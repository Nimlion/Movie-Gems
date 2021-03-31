import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/model/watchlater.dart';
import 'package:movie_gems/views/screens/movie_details.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:movie_gems/views/screens/add_movie_screen.dart';

class WatchLaterPage extends StatefulWidget {
  _WatchLaterOverview createState() => _WatchLaterOverview();
}

class _WatchLaterOverview extends State<WatchLaterPage> {
  DocumentReference laterList = FirebaseFirestore.instance
      .collection('watchlist')
      .doc(FirebaseAuthentication().auth.currentUser.uid);
  List<WatchLater> toWatchList = List();

  @override
  void initState() {
    super.initState();
    getWatchList();
  }

  Future<void> getWatchList() async {
    if (mounted) {
      await laterList.snapshots().forEach((element) {
        if (element.data() == null) return;
        toWatchList.clear();
        for (var movieMap in element.data().entries) {
          toWatchList.add(WatchLater.fromOMDB(
            movieMap.value['title'],
            movieMap.value['released'],
            movieMap.value['releaseDate'].toDate(),
            movieMap.value['addedOn'].toDate(),
            movieMap.value['tmdbID'],
            movieMap.value['imdbID'],
          ));
        }
        if (mounted) {
          setState(() {
            toWatchList.sort((a, b) => a.compareTo(b));
          });
        }
      });
    }
  }

  Future<void> _pushDetailScreen(Movie clickedMovie) async {
    if (!await Internet().checkConnection()) return;
    Navigator.push(context,
        PageRoutes.sharedAxis(() => MovieDetailScreen(movie: clickedMovie)));
  }

  void _pushAddScreen(WatchLater clickedMovie) {
    var amount = Repo.movieListenable.value.length;
    Navigator.push(
        context,
        PageRoutes.fadeScale(() => AddMovieScreen(
              title: clickedMovie.title,
            ))).whenComplete(() => Repo.movieListenable.value.length > amount
        ? laterList.update({
            firebaseProof(clickedMovie.title): FieldValue.delete()
          }).catchError(
            (error) => print("Failed to delete movie from watchlist: $error"))
        : showSimpleNotification(Text("Watched movie has not been deleted."),
            background: Colours.primaryColor));
  }

  Widget _toWatchTile(int index) {
    Movie movie = Movie(
        title: toWatchList[index].title,
        rating: 0.0,
        date: toWatchList[index].addedOn,
        category: 0,
        rated: "Not Rated",
        runtime: "",
        genre: "",
        director: "",
        poster: "",
        awards: "",
        imdbRating: "",
        imdbID: toWatchList[index].imdbID,
        tmdbID: toWatchList[index].tmdbID,
        production: "");

    IconData tileIcon = Icons.movie;
    String tileText = "Queued since: " +
        DateFormat("dd MMM. yyyy")
            .format(this.toWatchList[index].addedOn)
            .toString() +
        " - Released";
    if (!toWatchList[index].released &&
        toWatchList[index].releaseDate.isBefore(DateTime.now())) {
      tileIcon = Icons.local_movies_outlined;
      tileText = "Released since: " +
          DateFormat("MMMM yyyy")
              .format(this.toWatchList[index].releaseDate)
              .toString();
    } else if (!this.toWatchList[index].released) {
      tileIcon = Icons.access_time_outlined;
      tileText = "Released in: " +
          DateFormat("MMMM yyyy")
              .format(this.toWatchList[index].releaseDate)
              .toString();
    }

    return ListTile(
      leading: Container(
        height: double.infinity,
        child: Icon(tileIcon),
      ),
      title: Text(
        this.toWatchList[index].title,
        style: TextStyle(
            color: Colours.primaryColor, fontSize: Repo.currFontsize - 4),
      ),
      subtitle: Text(
        tileText,
        style: TextStyle(fontSize: Repo.currFontsize - 6),
      ),
      trailing: IconButton(
        icon: Icon(Icons.check_circle_outline_outlined),
        onPressed: () => _pushAddScreen(this.toWatchList[index]),
      ),
      onTap: () => {_pushDetailScreen(movie)},
      onLongPress: () => {showDeleteDialog(context, this.toWatchList[index])},
      dense: Repo.currFontsize < 20,
    );
  }

  showDeleteDialog(BuildContext context, WatchLater film) async {
    if (!await Internet().checkConnection()) return;
    Widget cancelBtn = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(fontSize: Repo.currFontsize),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget deleteBtn = FlatButton(
      child: Text(
        "Delete",
        style: TextStyle(fontSize: Repo.currFontsize),
      ),
      onPressed: () {
        _deleteMovie(film);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        "Delete " + film.title + " ?",
        style: TextStyle(fontSize: Repo.currFontsize + 3),
      ),
      content: Text(
        "You're about to delete a movie, which can't be undone. Are your sure?",
        style: TextStyle(fontSize: Repo.currFontsize),
      ),
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

  Future<void> _deleteMovie(WatchLater film) {
    return laterList
        .update({firebaseProof(film.title): FieldValue.delete()})
        .then((value) => {
              showSimpleNotification(Text("To watch movie removed."),
                  background: Colours.primaryColor),
              Navigator.of(context).pop()
            })
        .catchError(
            (error) => print("Failed to delete movie from watchlist: $error"));
  }

  @override
  Widget build(BuildContext context) {
    if (toWatchList.length == 0) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Center(
            child: Text(
              "Please add a movie to watch later below",
              style: TextStyle(fontSize: Repo.currFontsize + 5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: toWatchList.length + 1,
        itemBuilder: (context, index) {
          if (index == toWatchList.length) return SizedBox(height: 20);
          return _toWatchTile(index);
        });
  }
}
