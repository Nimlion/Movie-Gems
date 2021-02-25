import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Movie> _searchedList = List();
  String _searchQuery = "";

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

  Widget _movieTile(int index) {
    return ListTile(
      leading: _movieIcon(this._searchedList[index].category),
      title: Text(
        this._searchedList[index].title,
        style: TextStyle(color: Colours.primaryColor),
      ),
      subtitle: new Text(DateFormat("dd MMM. yyyy")
              .format(this._searchedList[index].date)
              .toString() +
          " - " +
          this._searchedList[index].rating.toString()),
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
            border: InputBorder.none, hintText: 'Search for movies'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_searchQuery != "" && _searchedList.isNotEmpty) {
      return Scaffold(
        appBar: _appbar(),
        body: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: this._searchedList.length,
            itemBuilder: (context, index) {
              return _movieTile(index);
            }),
      );
    } else if (_searchQuery != "" && _searchedList.isEmpty) {
      return Scaffold(
        appBar: _appbar(),
        body: Center(
          child: Text(
            "No results found . . .",
            style: TextStyle(fontSize: Repo.currFontsize + 2),
          ),
        ),
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
