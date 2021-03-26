import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/OMDBController.dart';
import 'package:movie_gems/controller/TMDBMovies.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';
import 'package:overlay_support/overlay_support.dart';

class AddMovieScreen extends StatefulWidget {
  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  String _titleValue = '';
  DateTime _dateValue = DateTime.now();
  double _rating = 5;
  int _category = 0;
  DocumentReference moviesdoc = FirebaseFirestore.instance
      .collection("movies")
      .doc(FirebaseAuthentication().auth.currentUser.uid);

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _addDocument() async {
    if (!mounted) return;
    await moviesdoc.snapshots().forEach((DocumentSnapshot element) {
      if (element.exists == false) {
        FirebaseFirestore.instance
            .collection("movies")
            .doc(FirebaseAuthentication().auth.currentUser.uid)
            .set({});
        addMovie();
      }
    });
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
              await TMDBMovieController()
                  .fetchTMDBData(omdbResponse.imdbID)
                  .then((tmdbResponse) => tmdbObject = tmdbResponse)
            });

    if (omdbObject == null || tmdbObject == null) {
      showSimpleNotification(Text("Movie could not be found"),
          background: Colors.red);
    } else {
      moviesdoc
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
                showSimpleNotification(Text("movie succesfully added"),
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
    final node = FocusScope.of(context);
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
              autofocus: true,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => this._titleValue = value,
              textInputAction: TextInputAction.done,
              onEditingComplete: () => node.nextFocus(),
              decoration: InputDecoration(
                hintText: 'title',
                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                border: InputBorder.none,
                fillColor: Colours.shadow,
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colours.primaryColor)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colours.primaryColor)),
              ))
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
          onPressed: () => _selectDate(context),
          child: Text(
            'Change date',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: Repo.currFontsize),
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
    return (Scaffold(
        appBar: AppBar(
            title: Text(
          'Add a movie',
          style: TextStyle(fontSize: Repo.currFontsize),
        )),
        body: SafeArea(
          child: Stack(children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    SizedBox(height: 20),
                    _titleField(),
                    SizedBox(height: 30),
                    _dateColumn(),
                    SizedBox(height: 30),
                    _selectCategory(),
                    SizedBox(height: 30),
                    _ratingSlider(),
                    SizedBox(height: 50),
                    _addButton(),
                    SizedBox(height: 30),
                  ])),
            )
          ]),
        )));
  }
}
