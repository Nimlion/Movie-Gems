import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/firebase_auth.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';

class AwardsScreen extends StatefulWidget {
  AwardsScreen({Key key}) : super(key: key);

  @override
  _AwardsScreenState createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  DocumentReference watchlist = FirebaseFirestore.instance
      .collection('watchlist')
      .doc(FirebaseAuthentication().auth.currentUser.uid);
  DocumentReference series = FirebaseFirestore.instance
      .collection('series')
      .doc(FirebaseAuthentication().auth.currentUser.uid);
  int laterListLen = 1;
  int seriesLen = 1;

  @override
  void initState() {
    super.initState();
    // getWatchlistLength();
    // getSeriesLength();
  }
  /*
   StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return new ListTile(
              title: new Text(document.data()['full_name']),
              subtitle: new Text(document.data()['company']),
            );
          }).toList(),
        );
      },
    );
   */

  // Future<void> getWatchlistLength() async {
  //   if (mounted) {
  //     await watchlist.snapshots().forEach((element) {
  //       if (element.data() == null) {
  //         return;
  //       }
  //       setState(() {
  //         laterListLen = element.data().entries.length;
  //       });
  //     });
  //   }
  // }

  // Future<void> getSeriesLength() async {
  //   if (mounted) {
  //     await series.snapshots().forEach((element) {
  //       if (element.data() == null) {
  //         return;
  //       }
  //       setState(() {
  //         seriesLen = element.data().entries.length;
  //       });
  //     });
  //   }
  // }

  Future<void> getLenghts2() async {}

  Widget _title(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Repo.currFontsize + 15,
        letterSpacing: 4,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Theme.of(context).textTheme.bodyText1.color,
      ),
    );
  }

  Widget _awardTile(IconData icon, String amount, String text, bool active) {
    return Column(
      children: [
        Icon(
          icon,
          size: 50 + Repo.currFontsize,
          color: active
              ? Colours.primaryColor
              : Colours.primaryColor.withOpacity(0.3),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: Repo.currFontsize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = active
                  ? Theme.of(context).textTheme.bodyText1.color
                  : Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.3),
          ),
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: Repo.currFontsize - 4,
              color: active
                  ? Theme.of(context).textTheme.bodyText1.color
                  : Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.3)),
        )
      ],
    );
  }

  Widget _awardRow(List<Widget> widgets) {
    return Column(
      children: [
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widgets,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var safePadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colours.background.withOpacity(0.2)
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - safePadding,
            ),
            child: Center(
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colours.white
                        : Colours.background,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.only(top: 20, bottom: 30),
                  child: Column(children: [
                    _title("Awards"),
                    _awardRow([
                      _awardTile(Icons.movie, "10", "movies",
                          Repo.movieListenable.value.length >= 10),
                      _awardTile(Icons.movie, "50", "movies",
                          Repo.movieListenable.value.length >= 50),
                      _awardTile(Icons.movie, "100", "movies",
                          Repo.movieListenable.value.length >= 100),
                    ]),
                    _awardRow([
                      _awardTile(
                          Icons.local_activity,
                          "10",
                          "movie gems",
                          Repo.movieListenable.value
                                  .where((Movie e) => e.category == 2)
                                  .length >=
                              10),
                      _awardTile(
                          Icons.favorite,
                          "20",
                          "favorites",
                          Repo.movieListenable.value
                                  .where((Movie e) => e.category == 1)
                                  .length >=
                              20),
                      _awardTile(Icons.access_time, "10", "watchlist",
                          laterListLen >= 10),
                    ]),
                    _awardRow([
                      _awardTile(Icons.settings, "settings", "adjusted",
                          Repo.customized),
                      _awardTile(Icons.mark_email_read, "email", "verified",
                          FirebaseAuth.instance.currentUser.emailVerified),
                      _awardTile(
                          Icons.vpn_key, "secret", "found", Repo.easterEgg),
                    ]),
                    SizedBox(height: 30),
                    _title("Stats"),
                    _awardRow(
                      [
                        _awardTile(
                            Icons.movie,
                            Repo.movieListenable.value.length.toString(),
                            "movies",
                            true),
                        StreamBuilder<DocumentSnapshot>(
                          stream: watchlist.snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return CircularProgressIndicator();
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            return _awardTile(
                                Icons.access_time,
                                snapshot.data.data().entries.length.toString(),
                                "watchlist",
                                true);
                          },
                        ),
                        StreamBuilder<DocumentSnapshot>(
                          stream: series.snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return CircularProgressIndicator();
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            return _awardTile(
                                Icons.live_tv,
                                snapshot.data.data().entries.length.toString(),
                                "series",
                                true);
                          },
                        ),
                      ],
                    ),
                    _awardRow(
                      [
                        _awardTile(
                            Icons.local_activity,
                            Repo.movieListenable.value
                                .where((Movie e) => e.category == 2)
                                .length
                                .toString(),
                            "movie gems",
                            true),
                        _awardTile(
                            Icons.movie,
                            Repo.movieListenable.value
                                .where((Movie e) => e.category == 1)
                                .length
                                .toString(),
                            "favorites",
                            true),
                      ],
                    ),
                  ]),
                ),
                Positioned(
                  right: 30,
                  top: 30,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 40,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
