import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_gems/controller/TVMazeController.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:movie_gems/model/serie.dart';
import 'package:movie_gems/views/widgets/page_filler.dart';

class EpisodesScreen extends StatefulWidget {
  final Serie serie;

  EpisodesScreen({Key key, @required this.serie}) : super(key: key);

  _EpisodesOverview createState() => _EpisodesOverview(serie);
}

class _EpisodesOverview extends State<EpisodesScreen> {
  Serie serie;
  Future<TVMazeEpisodes> serieEpisodes;

  _EpisodesOverview(this.serie);

  @override
  void initState() {
    super.initState();
    getEpisodes();
  }

  Future<void> getEpisodes() async {
    serieEpisodes =
        TVMazeController().fetchSerieEpisodes(serie.tvMazeID.toString());
  }

  Widget _episodeDetails(dynamic episode) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          Text(
            episode["summary"] != null && episode["summary"] != ""
                ? episode["name"]
                : "Soon to be announced",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colours.primaryColor,
              fontSize: Repo.currFontsize + 3,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Season " +
                episode["season"].toString() +
                " - Episode " +
                episode["number"].toString(),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: Repo.currFontsize,
            ),
          ),
          SizedBox(height: 15),
          Text(
            episode["summary"] != null && episode["summary"] != ""
                ? episode["summary"].replaceAll(exp, '')
                : "Not available yet.",
            style: TextStyle(
              fontFamily: "Raleway",
              fontSize: Repo.currFontsize - 6,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Aired on " +
                DateFormat("dd MMMM yyyy")
                    .format(DateTime.parse(episode["airdate"]))
                    .toString(),
            style: TextStyle(
              fontFamily: "Raleway",
              fontSize: Repo.currFontsize - 6,
              color:
                  Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TVMazeEpisodes>(
      future: this.serieEpisodes,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          var episodes = Repo.latestEpisodesFirst
              ? List.from(snapshot.data.episodes.reversed)
              : List.from(snapshot.data.episodes);

          return Scaffold(
            appBar: AppBar(
              title: Text("Episodes of " + serie.title),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: episodes.map<Widget>((episode) {
                  return episode["airdate"] != ""
                      ? episodes.last != episode
                          ? Column(children: [
                              _episodeDetails(episode),
                              Divider(
                                thickness: 1.5,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                              ),
                            ])
                          : _episodeDetails(episode)
                      : Container();
                }).toList(),
              ),
            ),
          );
        }
        return PageFiller("Loading . . .");
      },
    );
  }
}
