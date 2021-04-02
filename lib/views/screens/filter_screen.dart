import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key key}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int _category = 3;
  RangeValues _ratingRange = RangeValues(0, 10);
  String _mpaa = "All";
  DateTimeRange _dateRange = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 7)), end: DateTime.now());
  String _order = "desc";
  String _orderOn = "title";
  bool _rangeUpdated = false;
  bool _orderUpdated = false;
  List<String> _genres = List();

  void updateList() {
    setState(() {
      Repo.movieListenable.value = List.of(Repo.movieList);
      if (_category != 3) {
        Repo.movieListenable.value = Repo.movieListenable.value
            .where((movie) => movie.category == _category)
            .toList();
      }
      if (_ratingRange != RangeValues(0, 10)) {
        Repo.movieListenable.value = Repo.movieListenable.value
            .where((movie) =>
                movie.rating >= _ratingRange.start &&
                movie.rating <= _ratingRange.end)
            .toList();
      }
      if (_mpaa != "All") {
        Repo.movieListenable.value = Repo.movieListenable.value
            .where((movie) => movie.rated == _mpaa)
            .toList();
      }
      if (_rangeUpdated == true) {
        Repo.movieListenable.value = Repo.movieListenable.value
            .where((movie) =>
                movie.date.isAfter(_dateRange.start) &&
                movie.date.isBefore(_dateRange.end))
            .toList();
      }
      if (_genres.isNotEmpty) {
        List<Movie> list = List();
        _genres.forEach((genre) {
          Repo.movieListenable.value.forEach((movie) {
            if (movie.genre.toLowerCase().contains(genre)) {
              list.add(movie);
            }
          });
        });
        Repo.movieListenable.value = list;
      }
      if (_orderUpdated == true) {
        List<Movie> list = Repo.movieListenable.value;
        if (_order == "desc") {
          switch (_orderOn) {
            case "title":
              list.sort((a, b) => b.title.compareTo(a.title));
              break;
            case "date":
              list.sort((a, b) => b.date.compareTo(a.date));
              break;
            case "rating":
              list.sort((a, b) => b.rating.compareTo(a.rating));
              break;
          }
        } else if (_order == "asc") {
          switch (_orderOn) {
            case "title":
              list.sort((a, b) => a.title.compareTo(b.title));
              break;
            case "date":
              list.sort((a, b) => a.date.compareTo(b.date));
              break;
            case "rating":
              list.sort((a, b) => a.rating.compareTo(b.rating));
              break;
          }
        }
        Repo.movieListenable.value = List();
        Repo.movieListenable.value = list;
      }
    });
    Navigator.pop(context);
  }

  Widget _underTitle(String title) {
    return Text(
      title,
      style:
          TextStyle(fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
    );
  }

  Widget _selectOrder() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _underTitle("Order:"),
          Row(
            children: [
              DropdownButton(
                value: _order,
                dropdownColor: Colours.primaryColor,
                style: TextStyle(
                  fontSize: Repo.currFontsize - 3,
                  fontFamily: "Raleway",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                items: [
                  DropdownMenuItem(
                    child: Text("Descending"),
                    value: "desc",
                  ),
                  DropdownMenuItem(
                    child: Text("Ascending"),
                    value: "asc",
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _order = value;
                    _orderUpdated = true;
                  });
                },
              ),
              SizedBox(width: 20),
              Text("On", style: TextStyle(fontSize: Repo.currFontsize)),
              SizedBox(width: 20),
              DropdownButton(
                value: _orderOn,
                dropdownColor: Colours.primaryColor,
                style: TextStyle(
                  fontSize: Repo.currFontsize - 3,
                  fontFamily: "Raleway",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                items: [
                  DropdownMenuItem(
                    child: Text("Title"),
                    value: "title",
                  ),
                  DropdownMenuItem(
                    child: Text("Date"),
                    value: "date",
                  ),
                  DropdownMenuItem(
                    child: Text("Rating"),
                    value: "rating",
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _orderOn = value;
                    _orderUpdated = true;
                  });
                },
              ),
            ],
          )
        ]);
  }

  Widget _selectCategory() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _underTitle("Category:"),
          DropdownButton(
              value: _category,
              dropdownColor: Colours.primaryColor,
              style: TextStyle(
                fontSize: Repo.currFontsize - 3,
                fontFamily: "Raleway",
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              items: [
                DropdownMenuItem(
                  child: Text("All"),
                  value: 3,
                ),
                DropdownMenuItem(
                  child: Text("Normal"),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text("Favorite"),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text("Movie Gem"),
                  value: 2,
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              })
        ]);
  }

  Widget _ratingSlider() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _underTitle("Rating:"),
          SizedBox(height: 10.0),
          SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
                thumbColor: Colours.primaryColor,
                overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                activeTickMarkColor: Colours.primaryColor,
                inactiveTickMarkColor: Colours.primaryColor,
                valueIndicatorColor: Colours.primaryColor,
                activeTrackColor: Colours.accentColor,
                valueIndicatorTextStyle: TextStyle(
                  color: Colours.white,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: RangeSlider(
                  values: _ratingRange,
                  min: 0,
                  max: 10,
                  divisions: 100,
                  labels: RangeLabels(
                    _ratingRange.start.toStringAsFixed(1),
                    _ratingRange.end.toStringAsFixed(1),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _ratingRange = values;
                    });
                  },
                ),
              ))
        ]);
  }

  Widget _selectMPAA() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _underTitle("Rated:"),
          DropdownButton(
              value: _mpaa,
              dropdownColor: Colours.primaryColor,
              style: TextStyle(
                fontSize: Repo.currFontsize - 3,
                fontFamily: "Raleway",
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              items: [
                DropdownMenuItem(
                  child: Text("All"),
                  value: "All",
                ),
                DropdownMenuItem(
                  child: Text("G"),
                  value: "G",
                ),
                DropdownMenuItem(
                  child: Text("PG"),
                  value: "PG",
                ),
                DropdownMenuItem(
                  child: Text("PG-13"),
                  value: "PG-13",
                ),
                DropdownMenuItem(
                  child: Text("R"),
                  value: "R",
                ),
                DropdownMenuItem(
                  child: Text("NC-17"),
                  value: "NC-17",
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _mpaa = value;
                });
              })
        ]);
  }

  Widget _selectDateRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _underTitle("From: " +
            DateFormat("dd MMM. yyyy")
                .format(this._dateRange.start)
                .toString() +
            " - " +
            DateFormat("dd MMM. yyyy").format(this._dateRange.end).toString()),
        SizedBox(
          height: 10.0,
        ),
        RaisedButton(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          onPressed: () => _showDateRange(context),
          child: Text(
            'Change range',
            style: TextStyle(
              color: Colours.white,
              fontWeight: FontWeight.bold,
              fontSize: Repo.currFontsize,
            ),
          ),
          color: Colours.primaryColor,
        ),
      ],
    );
  }

  Future _showDateRange(BuildContext context) async {
    DateTimeRange picked = await showDateRangePicker(
      initialEntryMode: DatePickerEntryMode.input,
      context: context,
      helpText: 'When were the movies watched',
      initialDateRange: this._dateRange,
      firstDate: DateTime(1900),
      lastDate: this._dateRange.end,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                background: Colours.gold,
                primary: Colours.primaryColor,
                onPrimary: Colours.white,
                surface: Colours.white,
                onSurface: Colours.primaryColor,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: false,
                focusColor: Colours.primaryColor,
                hoverColor: Colours.primaryColor,
              )),
          child: child,
        );
      },
    );
    if (picked != null && picked != this._dateRange) {
      setState(() {
        this._dateRange = picked;
        this._rangeUpdated = true;
      });
    }
  }

  Widget _checkboxTile(String value) {
    return CheckboxListTile(
      title: Text(
        value.toUpperCase(),
        style: TextStyle(fontSize: Repo.currFontsize - 2),
      ),
      value: _genres.contains(value),
      contentPadding: EdgeInsets.zero,
      activeColor: Colours.accentColor,
      onChanged: (newValue) {
        if (newValue == true) {
          setState(() {
            _genres.add(value);
          });
        } else if (newValue == false) {
          setState(() {
            _genres.remove(value);
          });
        }
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _selectGenres() {
    List<String> genres = [
      "action",
      "adventure",
      "comedy",
      "crime",
      "drama",
      "fantasy",
      "historical",
      "horror",
      "mystery",
      "sci-fi",
      "political",
      "romance",
      "triller",
      "western",
      "animation",
      "musical",
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _underTitle("Genres:"),
        Column(
          children: genres.map<Widget>((item) {
            return _checkboxTile(item);
          }).toList(),
        ),
      ],
    );
  }

  Widget _applyButton() {
    return RaisedButton(
      padding: EdgeInsets.fromLTRB(25, 12, 25, 12),
      color: Colours.primaryColor,
      child: Text(
        "Apply Filters",
        style: TextStyle(
          fontSize: Repo.currFontsize,
          color: Colours.white,
        ),
      ),
      onPressed: () => this.updateList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Filters',
          style: TextStyle(fontSize: Repo.currFontsize),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(accentColor: Colours.primaryColor),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25),
                _selectOrder(),
                SizedBox(height: 20),
                _selectCategory(),
                SizedBox(height: 20),
                _ratingSlider(),
                SizedBox(height: 20),
                _selectMPAA(),
                SizedBox(height: 20),
                _selectDateRange(context),
                SizedBox(height: 20),
                _selectGenres(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _applyButton(),
    );
  }
}
