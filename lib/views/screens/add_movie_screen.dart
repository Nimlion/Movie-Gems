import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/OMDBController.dart';
import 'package:movie_gems/controller/TMDBMovies.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';
import 'package:overlay_support/overlay_support.dart';

class AddMovieScreen extends StatefulWidget {
  final String title;

  AddMovieScreen({Key key, this.title}) : super(key: key);

  @override
  _AddMovieScreenState createState() => _AddMovieScreenState(title);
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  String _titleValue = "";
  DateTime _dateValue = DateTime.now();
  double _rating = 5;
  int _category = 0;

  _AddMovieScreenState(String title) {
    this._titleValue = title != null ? title : "";
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _addDocument() async {
    if (!mounted) return;
    DocumentSnapshot element = await Repo.moviesDoc.snapshots().first;
    if (element.exists == false) {
      Repo.moviesDoc.set({});
      addMovie();
    }
  }

  Future<void> addMovie() async {
    if (this._titleValue == '') {
      showSimpleNotification(Text("Invalid movie title."),
          background: Colours.error);
      return;
    }
    OMDBResponse omdbObject;
    TMDBMovie tmdbObject;
    await OMDBController()
        .fetchOMDBData(_titleValue)
        .then((omdbResponse) async => {
              omdbObject = omdbResponse,
              if (omdbObject != null)
                await TMDBMovieController()
                    .fetchTMDBData(omdbResponse.imdbID)
                    .then((tmdbResponse) => tmdbObject = tmdbResponse)
            });

    if (omdbObject == null || tmdbObject == null) {
      showSimpleNotification(Text("Movie could not be found"),
          background: Colors.red);
    } else {
      Repo.moviesDoc
          .update({
            firebaseProof(omdbObject.title): {
              "title": omdbObject.title,
              "rating": this._rating,
              "date": this._dateValue,
              "category": this._category,
              "rated": omdbObject.rated,
              "runtime": omdbObject.runtime,
              "director": omdbObject.director,
              "poster": omdbObject.poster,
              "awards": omdbObject.awards,
              "genre": omdbObject.genre,
              "production": omdbObject.production,
              "imdbRating": omdbObject.imdbRating,
              "imdbID": omdbObject.imdbID,
              "tmdbID": tmdbObject.id,
            }
          })
          .then((value) => {
                showSimpleNotification(Text("Movie succesfully added."),
                    background: Colours.primaryColor),
                Navigator.pop(context),
              })
          .catchError((error) => {
                if (error.message == "Some requested document was not found.")
                  {
                    _addDocument(),
                  }
                else
                  {
                    showSimpleNotification(Text("failed to add movie"),
                        background: Colors.red)
                  }
              });
    }
  }

  Widget _titleField() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Movie title:",
            style: TextStyle(
                fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            style: TextStyle(fontSize: Repo.currFontsize - 2),
            autofocus: this._titleValue == "",
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.none,
            onChanged: (value) => this._titleValue = value,
            textInputAction: TextInputAction.done,
            controller: TextEditingController(text: this._titleValue),
            decoration: InputDecoration(
              hintText: 'title',
              contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              border: InputBorder.none,
              fillColor: Colors.transparent,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colours.primaryColor)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colours.primaryColor)),
            ),
          )
        ]);
  }

  Widget _dateColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Current date: " +
              DateFormat("dd MMM. yyyy").format(this._dateValue).toString(),
          style: TextStyle(
              fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10.0,
        ),
        RaisedButton(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          onPressed: () => _selectDate(context),
          child: Text(
            'Change date',
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

  Future _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      helpText: 'When was the movie watched',
      initialDate: this._dateValue,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != this._dateValue && mounted)
      setState(() {
        this._dateValue = picked;
      });
  }

  Widget _selectCategory() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Category:",
            style: TextStyle(
              fontSize: Repo.currFontsize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
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
                  child: Text("Normal"),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text("Favorite"),
                  value: 1,
                ),
                DropdownMenuItem(child: Text("Movie Gem"), value: 2),
              ],
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _category = value;
                  });
                }
              })
        ]);
  }

  Widget _ratingSlider() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Rating:",
            style: TextStyle(
                fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
              thumbColor: Colours.primaryColor,
              overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
              activeTickMarkColor: Colours.primaryColor,
              activeTrackColor: Colours.accentColor,
              inactiveTickMarkColor: Colours.primaryColor,
              valueIndicatorColor: Colours.primaryColor,
              valueIndicatorTextStyle: TextStyle(
                color: Colours.white,
              ),
            ),
            child: Slider(
              value: _rating,
              min: 0,
              max: 10,
              divisions: 100,
              label: _rating.toStringAsFixed(1),
              onChanged: (value) {
                if (mounted) {
                  setState(
                    () {
                      this._rating = num.parse(value.toStringAsFixed(1));
                    },
                  );
                }
              },
            ),
          )
        ]);
  }

  Widget _addButton() {
    return Container(
      width: 150.0,
      child: RawMaterialButton(
          elevation: 5,
          padding: EdgeInsets.all(12.0),
          fillColor: Colours.primaryColor,
          textStyle: TextStyle(
              color: Colours.white,
              fontSize: Repo.currFontsize,
              fontWeight: FontWeight.w500,
              fontFamily: 'Sansita'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Text('Add'),
          onPressed: () => {
                addMovie(),
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Add a movie',
        style: TextStyle(fontSize: Repo.currFontsize),
      )),
      body: Theme(
        data: Theme.of(context).copyWith(accentColor: Colours.primaryColor),
        child: SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    _titleField(),
                    SizedBox(height: 20),
                    _dateColumn(),
                    SizedBox(height: 20),
                    _selectCategory(),
                    SizedBox(height: 20),
                    _ratingSlider(),
                    SizedBox(height: 30),
                    _addButton(),
                    SizedBox(height: 20),
                  ])),
        ),
      ),
    );
  }
}
