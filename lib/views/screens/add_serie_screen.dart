import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/TMDBSeries.dart';
import 'package:movie_gems/controller/TVMazeController.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';
import 'package:overlay_support/overlay_support.dart';

class AddSerieScreen extends StatefulWidget {
  @override
  _AddSerieScreenState createState() => _AddSerieScreenState();
}

class _AddSerieScreenState extends State<AddSerieScreen> {
  String _titleValue = '';
  DateTime _dateValue = DateTime.now();
  int _category = 0;
  int _status = 0;
  bool _firstDocumentAdded = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _addDocument() async {
    if (!mounted || _firstDocumentAdded) return;
    Repo.seriesDoc.snapshots().listen((DocumentSnapshot element) {
      if (element.exists == false) {
        Repo.seriesDoc.set({});
        addSerie();
      }
    });
    return;
  }

  Future<void> addSerie() async {
    if (this._titleValue == '') {
      showSimpleNotification(Text("Invalid movie title."),
          background: Colours.error);
      return;
    }
    TVMazeResponse tvMazeObject;
    TMDBCondensedSerie tmdbObject;
    await TVMazeController()
        .fetchSerieData(_titleValue)
        .then((response) => tvMazeObject = response);
    await TMDBSeriesController()
        .fetchSerieTMDBData(_titleValue)
        .then((response) => tmdbObject = response);

    if (_firstDocumentAdded == true) {
      return;
    } else if (tvMazeObject == null || tmdbObject == null) {
      showSimpleNotification(Text("serie could not be found"),
          background: Colors.red);
    } else {
      Repo.seriesDoc
          .update({
            firebaseProof(tvMazeObject.show["name"]): {
              "title": tvMazeObject.show["name"],
              "startdate": this._dateValue,
              "category": this._category,
              "status": this._status,
              "tvMazeURL": tvMazeObject.show["url"],
              "premiered": tvMazeObject.show["premiered"],
              "type": tvMazeObject.show["type"],
              "genres": tvMazeObject.show["genres"].join(', '),
              "tvMazeID": tvMazeObject.show["id"],
              "tmdbID": tmdbObject.id,
              "imdbID": tvMazeObject.show["externals"]["imdb"],
            }
          })
          .then((value) => {
                showSimpleNotification(Text("serie succesfully added"),
                    background: Colours.primaryColor),
                setState(() => {
                      _firstDocumentAdded = true,
                    }),
                Navigator.pop(context),
              })
          .catchError((error) => {
                if (error.message == "Some requested document was not found.")
                  {
                    _addDocument(),
                  }
                else
                  {
                    showSimpleNotification(Text("failed to add serie"),
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
            "Serie title:",
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
                fillColor: Colors.transparent,
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
          "Started watching: " +
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
      helpText: 'When did you start watching',
      initialDate: this._dateValue,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != this._dateValue && mounted) {
      setState(() {
        this._dateValue = picked;
      });
    }
  }

  Widget _selectCategory() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Category:",
            style: TextStyle(
                fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
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
                  child: Text("Great"),
                  value: 1,
                ),
                DropdownMenuItem(child: Text("Fantastic!"), value: 2),
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

  Widget _selectStatus() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Status:",
            style: TextStyle(
                fontSize: Repo.currFontsize, fontWeight: FontWeight.bold),
          ),
          DropdownButton(
            value: _status,
            dropdownColor: Colours.primaryColor,
            style: TextStyle(
              fontSize: Repo.currFontsize,
              fontFamily: "Raleway",
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
            items: [
              DropdownMenuItem(
                child: Text(
                  "Watching",
                ),
                value: 0,
              ),
              DropdownMenuItem(
                child: Text(
                  "Queued",
                ),
                value: 1,
              ),
              DropdownMenuItem(
                child: Text(
                  "Finished",
                ),
                value: 2,
              ),
            ],
            onChanged: (int value) {
              setState(() {
                _status = value;
              });
            },
          ),
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
                addSerie(),
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Add a serie',
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
                    _selectStatus(),
                    SizedBox(height: 20),
                    _addButton(),
                    SizedBox(height: 30),
                  ])),
        ),
      ),
    );
  }
}
