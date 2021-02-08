import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_details.dart';
import 'package:movie_gems/views/screens/page_filler.dart';

class MoviePage extends StatefulWidget {
  MovieOverview createState() => MovieOverview();
}

class MovieOverview extends State<MoviePage> {
  CollectionReference movies = FirebaseFirestore.instance.collection('movies');
  List<Movie> movieList = new List();

  void _pushDetailScreen(Movie clickedMovie) {
    Navigator.push(context,
        PageRoutes.sharedAxis(() => MovieDetailScreen(movie: clickedMovie)));
  }

  Widget _filterInfoBar(int amount) {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            amount.toString() + ' movies found',
            style: TextStyle(
                fontSize: Repo.currFontsize - 3, fontWeight: FontWeight.w100),
          ),
          InkWell(
              onTap: () => log("Filter"),
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
              onTap: () => log("Search"),
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
        _icon = new Icon(Icons.favorite_border);
        break;
      case 1:
        _icon = new Icon(Icons.favorite, color: Colors.red);
        break;
      case 2:
        _icon = new Icon(Icons.local_activity,
            color: Color.fromRGBO(255, 215, 0, 1));
        break;
      default:
        _icon = new Icon(Icons.favorite_border);
    }
    return _icon;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: movies.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return PageFiller("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return PageFiller("Loading . . .");
          }

          QueryDocumentSnapshot querydoc;
          for (var element in snapshot.data.docs) {
            if (element.id == FirebaseAuthentication().auth.currentUser.uid) {
              querydoc = element;
              break;
            }
          }

          if (querydoc == null || querydoc.data().entries.isEmpty) {
            return new SafeArea(
              child: new Center(
                child: Text(
                  "Please add a movie below",
                  style: TextStyle(fontSize: Repo.currFontsize + 5),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            movieList = new List();
            for (var movieMap in querydoc.data().entries) {
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

            return Column(children: [
              Container(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.1),
                child: Column(children: [
                  _filterInfoBar(movieList.length),
                ]),
              ),
              Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: movieList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return ListTile(
                          leading: Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: Icon(Icons.movie),
                          ),
                          title: Text(
                            movieList[index].title,
                            style: TextStyle(color: Colours.primaryColor),
                          ),
                          subtitle: new Text(DateFormat("dd MMM. yyyy")
                                  .format(movieList[index].date)
                                  .toString() +
                              " - " +
                              movieList[index].rating.toString()),
                          trailing: IconButton(
                            icon: _movieIcon(movieList[index].category),
                            onPressed: () => {},
                          ),
                          onTap: () => _pushDetailScreen(movieList[index]),
                          onLongPress: () => {
                            movieList.sort((a, b) => b.title.compareTo(a.title))
                          },
                          dense: false,
                        );
                      }))
            ]);
          }
        });
  }
}
