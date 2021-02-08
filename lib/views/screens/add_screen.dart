import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/OMDBController.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:overlay_support/overlay_support.dart';

class AddScreen extends StatefulWidget {
  AddScreen({Key key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String _titleValue = '';
  DateTime _dateValue = DateTime.now();
  double _rating = 5;
  int _category = 0;
  DocumentReference moviesdoc = FirebaseFirestore.instance
      .collection("movies")
      .doc(FirebaseAuthentication().auth.currentUser.uid);

  Future<void> _addDocument() async {
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
    OMDBController().fetchOMDBData(_titleValue).then((response) => moviesdoc
        .update({
          this._titleValue.toLowerCase(): {
            "title": this._titleValue,
            "rating": this._rating,
            "date": this._dateValue,
            "category": this._category,
            "rated": response.rated,
            "runtime": response.runtime,
            "director": response.director,
            "actors": response.actors,
            "poster": response.poster,
            "awards": response.awards,
            "genre": response.genre,
            "production": response.production,
            "imdbRating": response.imdbRating,
            "imdbID": response.imdbID,
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
            }));
  }

  Widget _titleField() {
    final node = FocusScope.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Movie title:",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
              autofocus: true,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => this._titleValue = value,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => node.nextFocus(),
              decoration: InputDecoration(
                hintText: 'title',
                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                border: InputBorder.none,
                fillColor: Colours.shadow,
                enabledBorder: new UnderlineInputBorder(
                    borderSide: new BorderSide(color: Colours.primaryColor)),
                focusedBorder: new UnderlineInputBorder(
                    borderSide: new BorderSide(color: Colours.primaryColor)),
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10.0,
        ),
        RaisedButton(
          onPressed: () => _selectDate(context),
          child: Text(
            'Change date',
            style: TextStyle(fontWeight: FontWeight.bold),
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
    if (picked != null && picked != this._dateValue)
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          DropdownButton(
              value: _category,
              dropdownColor: Colours.primaryColor,
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
          Text(
            "Rating:",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
              thumbColor: Colours.primaryColor,
              overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
              activeTickMarkColor: Colours.primaryColor,
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
                setState(
                  () {
                    this._rating = num.parse(value.toStringAsFixed(1));
                  },
                );
              },
            ),
          )
        ]);
  }

  Widget _addButton() {
    return new Container(
      width: 150.0,
      child: new RawMaterialButton(
          elevation: 5,
          padding: EdgeInsets.all(12.0),
          fillColor: Colours.primaryColor,
          textStyle: TextStyle(
              color: Colours.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'Sansita'),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0)),
          child: Text('Add'),
          onPressed: () => {
                addMovie(),
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: new AppBar(title: new Text('Add a movie')),
        body: new SafeArea(
          child: new Stack(children: <Widget>[
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
