import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/movie.dart';
import 'package:movie_gems/model/repository.dart';
import 'dart:ui' as ui;

class AwardsScreen extends StatefulWidget {
  AwardsScreen({Key key}) : super(key: key);

  @override
  _AwardsScreenState createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  int laterListLen = 0;
  int seriesLen = 0;

  Widget _title(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Repo.currFontsize + 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _awardTile(
      IconData icon, String topText, String bottomText, bool active) {
    TextStyle style = TextStyle(
        fontSize: 8 + (0.5 * Repo.currFontsize),
        fontWeight: FontWeight.bold,
        color: active
            ? Theme.of(context).textTheme.bodyText1.color
            : Theme.of(context).textTheme.bodyText1.color.withOpacity(0.3));
    Color tileColor = Theme.of(context).brightness == Brightness.light
        ? Colours.white
        : Colours.background.withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: active ? tileColor : tileColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colours.background.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(-1, 2),
                ),
              ]
            : [],
      ),
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            icon,
            size: 20 + Repo.currFontsize,
            color: active
                ? Theme.of(context).textTheme.bodyText1.color
                : Theme.of(context).textTheme.bodyText1.color.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(topText, style: style),
                Text(bottomText, style: style)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statsTile(String label, int amount, String bottomText) {
    TextStyle smStyle = TextStyle(
        fontSize: Repo.currFontsize - 8,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.6));
    TextStyle xlStyle = TextStyle(
        fontSize: 42 + (0.1 * Repo.currFontsize),
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyText1.color);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colours.white
            : Colours.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colours.background.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 3,
            offset: Offset(-1, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label.toString(), style: xlStyle),
                SizedBox(height: 5),
                Text(bottomText, style: smStyle)
              ],
            ),
          ),
          SizedBox(width: 25),
          Expanded(
            flex: 2,
            child: CustomPaint(
              size: Size(300, 300),
              painter: MyPainter(amount),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colours.background.withOpacity(0.1)
          : Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Column(children: <Widget>[
                        SizedBox(height: 50),
                        _title("Awards"),
                        SizedBox(height: 15),
                        GridView.count(
                          childAspectRatio: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          crossAxisCount: 2,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          shrinkWrap: true,
                          children: [
                            _awardTile(Icons.movie, "50", "movies",
                                Repo.movieListenable.value.length >= 50),
                            _awardTile(Icons.movie, "100", "movies",
                                Repo.movieListenable.value.length >= 100),
                            _awardTile(
                                Icons.local_activity,
                                "10",
                                "gems",
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
                            StreamBuilder<DocumentSnapshot>(
                              stream: Repo.watchlistDoc.snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return CircularProgressIndicator();
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                this.laterListLen = snapshot.data.data() != null
                                    ? snapshot.data.data().entries.length
                                    : 0;
                                return _awardTile(Icons.access_time, "10",
                                    "watchlist", this.laterListLen >= 10);
                              },
                            ),
                            _awardTile(Icons.settings, "settings", "adjusted",
                                Repo.customized),
                            _awardTile(
                                Icons.mark_email_read,
                                "email",
                                "verified",
                                FirebaseAuth
                                    .instance.currentUser.emailVerified),
                            _awardTile(Icons.vpn_key, "secret", "found",
                                Repo.easterEgg),
                          ],
                        ),
                        SizedBox(height: 30),
                        _title("Stats"),
                        SizedBox(height: 15),
                        GridView.count(
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          crossAxisCount: 1,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          shrinkWrap: true,
                          children: [
                            _statsTile(
                                Repo.movieListenable.value.length.toString(),
                                Repo.movieListenable.value.length,
                                "movies"),
                            StreamBuilder<DocumentSnapshot>(
                              stream: Repo.watchlistDoc.snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return CircularProgressIndicator();
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                this.laterListLen = snapshot.data.data() != null
                                    ? snapshot.data.data().entries.length
                                    : 0;

                                return _statsTile(this.laterListLen.toString(),
                                    this.laterListLen, "watchlist");
                              },
                            ),
                            StreamBuilder<DocumentSnapshot>(
                              stream: Repo.seriesDoc.snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return CircularProgressIndicator();
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                var seriesLength = snapshot.data.data() != null
                                    ? snapshot.data.data().entries.length
                                    : 0;

                                return _statsTile(seriesLength.toString(),
                                    seriesLength, "series");
                              },
                            ),
                            _statsTile(
                                Repo.movieListenable.value
                                    .where((Movie e) => e.category == 2)
                                    .length
                                    .toString(),
                                Repo.movieListenable.value
                                    .where((Movie e) => e.category == 2)
                                    .length,
                                "gems"),
                            _statsTile(
                                Repo.movieListenable.value
                                    .where((Movie e) => e.category == 1)
                                    .length
                                    .toString(),
                                Repo.movieListenable.value
                                    .where((Movie e) => e.category == 1)
                                    .length,
                                "favorites"),
                            _statsTile(
                                (Repo.movieListenable.value
                                            .map((Movie e) => e.rating)
                                            .reduce((value, element) =>
                                                value + element) /
                                        Repo.movieListenable.value.length)
                                    .toStringAsFixed(1),
                                ((Repo.movieListenable.value
                                                .map((Movie e) => e.rating)
                                                .reduce((value, element) =>
                                                    value + element) /
                                            Repo.movieListenable.value.length) *
                                        10)
                                    .toInt(),
                                "avg rating"),
                          ],
                        ),
                        SizedBox(height: 15),
                      ]),
                      childCount: 1,
                    ),
                  ),
                ]),
          ),
          Positioned(
            right: 25,
            top: MediaQuery.of(context).padding.top + 25,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colours.white
                    : Colours.background,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colours.background.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(-1, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Icon(
                  Icons.close,
                  size: 35,
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  int amount = 0;

  MyPainter(this.amount);

  @override
  void paint(Canvas canvas, Size size) {
    if (amount > 100) amount = 100;

    final paint = Paint()
      ..color = Colours.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = ui.Gradient.linear(
        Offset(0, size.height - 20),
        Offset(size.width, size.height - amount),
        [
          Colours.accentColor,
          Colours.primaryColor,
        ],
      );

    Path path = Path();

    path.addPolygon([
      Offset(0, size.height - 20),
      Offset(50, size.height - (20 + (0.4 * amount))),
      Offset(100, size.height),
      Offset(size.width, size.height - amount)
    ], false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
