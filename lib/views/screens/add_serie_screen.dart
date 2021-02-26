import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/TMDBController.dart';
import 'package:movie_gems/controller/TVMazeController.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:overlay_support/overlay_support.dart';

class AddSerieScreen extends StatefulWidget {
  @override
  _AddSerieScreenState createState() => _AddSerieScreenState();
}

class _AddSerieScreenState extends State<AddSerieScreen> {
  String _titleValue = '';
  DateTime _dateValue = DateTime.now();
  int _category = 0;
  DocumentReference seriesDoc = FirebaseFirestore.instance
      .collection("series")
      .doc(FirebaseAuthentication().auth.currentUser.uid);

  Future<void> _addDocument() async {
    await seriesDoc.snapshots().forEach((DocumentSnapshot element) {
      if (element.exists == false) {
        seriesDoc.set({});
        addSerie();
      }
    });
  }

  Future<void> addSerie() async {
    TVMazeResponse tvMazeObject;
    TMDBCondensedSerie tmdbObject;
    await TVMazeController()
        .fetchSerieData(_titleValue)
        .then((response) => tvMazeObject = response);
    await TMDBController()
        .fetchSerieTMDBData(_titleValue)
        .then((response) => tmdbObject = response);

    if (tvMazeObject == null || tmdbObject == null) {
      showSimpleNotification(Text("serie could not be found"),
          background: Colors.red);
    } else {
      seriesDoc
          .update({
            this._titleValue.toLowerCase(): {
              "title": this._titleValue,
              "startdate": this._dateValue,
              "category": this._category,
              "status": tvMazeObject.show["status"],
              "tvMazeURL": tvMazeObject.show["url"],
              "premiered": tvMazeObject.show["premiered"],
              "type": tvMazeObject.show["type"],
              "genres": tvMazeObject.show["genres"].join(', '),
              "tvMazeID": tvMazeObject.show["id"],
              "tmdbID": tmdbObject.id,
            }
          })
          .then((value) => {
                showSimpleNotification(Text("serie succesfully added"),
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
      helpText: 'When did you start watching',
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
                  child: Text("Great"),
                  value: 1,
                ),
                DropdownMenuItem(child: Text("Fantastic!"), value: 2),
              ],
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              })
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
              fontSize: 20,
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
    return (Scaffold(
        appBar: AppBar(title: Text('Add a serie')),
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
                    SizedBox(height: 50),
                    _addButton(),
                    SizedBox(height: 30),
                  ])),
            )
          ]),
        )));
  }
}
