import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/Internet.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_details.dart';

import 'find_movie_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Movie> _searchedList = List();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    checkConn();
  }

  Future<void> checkConn() async {
    if (!await Internet().checkConnection()) {
      setState(() {
        Repo.connected = false;
      });
      return null;
    }
    setState(() {
      Repo.connected = true;
    });
  }

  void updateList(String input) {
    setState(() {
      this._searchQuery = input;

      this._searchedList.clear();
      Repo.movieListenable.value.forEach((movie) {
        if (movie.title.toLowerCase().contains(input.toLowerCase())) {
          _searchedList.add(movie);
        }
      });

      this._searchedList.sort((a, b) => a.title.compareTo(b.title));
    });
  }

  void _pushDetailScreen(Movie clickedMovie) {
    Navigator.push(context,
        PageRoutes.sharedAxis(() => MovieDetailScreen(movie: clickedMovie)));
  }

  void _pushFindScreen(String query) {
    Navigator.pop(context);
    Navigator.push(
        context, PageRoutes.sharedAxis(() => FindMovieScreen(query: query)));
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
      leading: Container(
        height: double.infinity,
        child: _movieIcon(this._searchedList[index].category),
      ),
      title: Text(
        this._searchedList[index].title,
        style: TextStyle(
            color: Colours.primaryColor, fontSize: Repo.currFontsize - 4),
      ),
      subtitle: Text(
        DateFormat("dd MMM. yyyy")
                .format(this._searchedList[index].date)
                .toString() +
            " - " +
            this._searchedList[index].rating.toString(),
        style: TextStyle(fontSize: Repo.currFontsize - 6),
      ),
      onTap: () => _pushDetailScreen(this._searchedList[index]),
    );
  }

  Widget _appbar() {
    return AppBar(
      centerTitle: true,
      title: TextField(
        style: TextStyle(fontSize: Repo.currFontsize - 2),
        textInputAction: TextInputAction.search,
        autofocus: true,
        onChanged: (input) => updateList(input),
        onSubmitted: (input) => updateList(input),
        onEditingComplete: () => {},
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          hintText: 'Search for movies',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_searchQuery != "" && _searchedList.isNotEmpty) {
      return Scaffold(
        appBar: _appbar(),
        body: Theme(
          data: Theme.of(context).copyWith(accentColor: Colours.primaryColor),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: this._searchedList.length,
            itemBuilder: (context, index) {
              return _movieTile(index);
            },
          ),
        ),
      );
    } else if (_searchQuery != "" && _searchedList.isEmpty) {
      return Scaffold(
        appBar: _appbar(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text(
                "No results found . . .",
                style: TextStyle(fontSize: Repo.currFontsize + 2),
              ),
              SizedBox(height: 20),
              Repo.connected
                  ? RaisedButton(
                      color: Colours.primaryColor,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(
                        "Find movie",
                        style: TextStyle(
                            fontSize: Repo.currFontsize + 2,
                            color: Colours.white),
                      ),
                      onPressed: () => _pushFindScreen(_searchQuery),
                    )
                  : Container(),
            ])),
      );
    } else {
      return Scaffold(
        appBar: _appbar(),
        body: Center(
          child: Text(
            "Enter a movie title above",
            style: TextStyle(fontSize: Repo.currFontsize + 2),
          ),
        ),
      );
    }
  }
}
