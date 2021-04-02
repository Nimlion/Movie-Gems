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

class AddWatchLaterScreen extends StatefulWidget {
  @override
  _AddWatchLaterState createState() => _AddWatchLaterState();
}

class _AddWatchLaterState extends State<AddWatchLaterScreen> {
  String _titleValue = '';
  DateTime _releaseDate = DateTime.now();
  bool _released = true;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _addDocument() async {
    if (!mounted) return;
    DocumentSnapshot element = await Repo.watchlistDoc.snapshots().first;
    if (element.exists == false) {
      Repo.watchlistDoc.set({});
      addWatchLaterFilm();
    }
  }

  Future<void> addWatchLaterFilm() async {
    if (this._titleValue == '') {
      showSimpleNotification(Text("Invalid movie title."),
          background: Colours.error);
      return;
    }
    if (!this._released && this._releaseDate.isBefore(DateTime.now())) {
      showSimpleNotification(Text("Movie is already released."),
          background: Colours.error);
      return;
    }
    OMDBResponse omdbObject;
    TMDBMovie tmdbObject;
    this._released
        ? await OMDBController()
            .fetchOMDBData(_titleValue)
            .then((omdbResponse) async => {
                  omdbObject = omdbResponse,
                  if (omdbObject != null)
                    {
                      await TMDBMovieController()
                          .fetchTMDBData(omdbResponse.imdbID)
                          .then((tmdbResponse) => tmdbObject = tmdbResponse)
                    }
                })
        : await OMDBController()
            .fetchSpecificOMDBData(_titleValue, this._releaseDate.year)
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
      Repo.watchlistDoc
          .update({
            firebaseProof(omdbObject.title): {
              "addedOn": DateTime.now(),
              "releaseDate": this._releaseDate,
              "released": this._released,
              "title": omdbObject.title,
              "tmdbID": tmdbObject.id,
              "imdbID": omdbObject.imdbID,
            }
          })
          .then((value) => {
                showSimpleNotification(
                    Text("Movie succesfully added to watchlist."),
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
              autofocus: true,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => this._titleValue = value,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'title',
                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colours.primaryColor)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colours.primaryColor)),
              ))
        ]);
  }

  Widget _releasedField() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            "Released:",
            style: TextStyle(
                fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(children: [
            Transform.scale(
              scale: 1.2,
              child: Switch(
                activeColor: Colours.primaryColor,
                value: _released,
                onChanged: (bool value) {
                  setState(() {
                    this._released = value;
                  });
                },
              ),
            ),
            this._released
                ? Text(
                    "Released",
                    style: TextStyle(
                        fontSize: Repo.currFontsize,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.8)),
                  )
                : Text(
                    "Unreleased",
                    style: TextStyle(
                        fontSize: Repo.currFontsize,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.8)),
                  ),
          ])
        ]);
  }

  Widget _releaseDateColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 20),
        Text(
          "Release date: " +
              DateFormat("dd MMM. yyyy").format(this._releaseDate).toString(),
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
                fontWeight: FontWeight.bold, fontSize: Repo.currFontsize),
          ),
          color: Colours.primaryColor,
        ),
      ],
    );
  }

  Future _selectDate(BuildContext context) async {
    var now = DateTime(2018, 1, 13);
    var endDate = DateTime(now.year + 5, now.month, now.day);

    final DateTime picked = await showDatePicker(
      context: context,
      helpText: 'When was the movie watched',
      initialDate: this._releaseDate,
      firstDate: DateTime(1900),
      lastDate: endDate,
    );
    if (picked != null && picked != this._releaseDate && mounted)
      setState(() {
        this._releaseDate = picked;
      });
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
            fontFamily: 'Sansita',
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Text('Add'),
          onPressed: () => {
                addWatchLaterFilm(),
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Add a movie to watch later',
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
                    _releasedField(),
                    !this._released ? _releaseDateColumn() : Container(),
                    SizedBox(height: 20),
                    _addButton(),
                  ])),
        ),
      ),
    );
  }
}
