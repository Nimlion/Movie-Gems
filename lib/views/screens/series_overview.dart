import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/model/serie.dart';
import 'package:movie_gems/views/screens/episode_overview.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';
import 'package:movie_gems/views/screens/serie_details.dart';
import 'package:overlay_support/overlay_support.dart';

class SeriesPage extends StatefulWidget {
  _SeriesOverview createState() => _SeriesOverview();
}

class _SeriesOverview extends State<SeriesPage> {
  DocumentReference series = FirebaseFirestore.instance
      .collection('series')
      .doc(FirebaseAuthentication().auth.currentUser.uid);
  List<Serie> seriesList = List();

  @override
  void initState() {
    super.initState();
    getSeries();
  }

  void _pushSerieDetailPage(Serie serie) {
    Navigator.push(
        context, PageRoutes.sharedAxis(() => SerieDetailScreen(serie: serie)));
  }

  void _pushEpisodesPage(Serie serie) {
    Navigator.push(
        context, PageRoutes.sharedAxis(() => EpisodesScreen(serie: serie)));
  }

  Future<void> getSeries() async {
    await series.snapshots().forEach((element) {
      if (element.data() == null) return;
      this.seriesList = List();
      for (var seriesMap in element.data().entries) {
        seriesList.add(Serie.fromOMDB(
          seriesMap.value['title'],
          seriesMap.value['startdate'].toDate(),
          seriesMap.value['category'],
          seriesMap.value['status'],
          seriesMap.value['tvMazeURL'],
          seriesMap.value['premiered'],
          seriesMap.value['type'],
          seriesMap.value['genres'],
          seriesMap.value['tvMazeID'],
          seriesMap.value['tmdbID'],
          seriesMap.value['imdbID'],
        ));
      }
      if (mounted) {
        setState(() {
          seriesList.sort((a, b) => a.title.compareTo(b.title));
        });
      }
    });
  }

  Future<void> _deleteSerie(Serie serie) {
    return series
        .update({firebaseProof(serie.title): FieldValue.delete()})
        .then((value) => {
              showSimpleNotification(Text("serie succesfully deleted"),
                  background: Colours.primaryColor),
              Navigator.of(context).pop()
            })
        .catchError((error) => print("Failed to delete serie: $error"));
  }

  showDeleteDialog(BuildContext context, Serie serie) {
    Widget cancelBtn = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget deleteBtn = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        _deleteSerie(serie);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Delete " + serie.title + " ?"),
      content: Text(
          "You're about to delete a serie, which can't be undone. Are your sure?"),
      actions: [
        cancelBtn,
        deleteBtn,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _serieTile(int index) {
    return ListTile(
      leading: Padding(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Icon(Icons.live_tv_outlined),
      ),
      title: Text(
        seriesList[index].title,
        style: TextStyle(color: Colours.primaryColor),
      ),
      subtitle: Text(
        DateFormat("dd MMM. yyyy")
                .format(seriesList[index].startdate)
                .toString() +
            " - " +
            seriesList[index].type,
        style: TextStyle(fontFamily: "Raleway"),
      ),
      trailing: IconButton(
        icon: Icon(Icons.playlist_play),
        onPressed: () => {_pushEpisodesPage(seriesList[index])},
      ),
      onTap: () => {_pushSerieDetailPage(seriesList[index])},
      onLongPress: () => showDeleteDialog(context, seriesList[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (seriesList.length == 0) {
      return SafeArea(
        child: Center(
          child: Text(
            "Please add a serie below",
            style: TextStyle(fontSize: Repo.currFontsize + 5),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: seriesList.length,
        itemBuilder: (context, index) {
          return _serieTile(index);
        });
  }
}
