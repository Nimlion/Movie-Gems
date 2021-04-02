import 'dart:async';
import 'dart:convert';

// Necessary imports
import 'package:http/http.dart' as http;

class TVMazeController {
  Future<TVMazeResponse> fetchSerieData(String movieTitle) async {
    final endpoint =
        await http.get('http://api.tvmaze.com/search/shows?q=$movieTitle');

    if (endpoint.statusCode == 200) {
      if (endpoint.body != "[]") {
        return TVMazeResponse.fromJson(
            json.decode(json.encode(json.decode(endpoint.body)[0])));
      }
    }
    return null;
  }

  Future<TVMazeEpisodes> fetchSerieEpisodes(String id) async {
    final endpoint = await http.get('http://api.tvmaze.com/shows/$id/episodes');

    if (endpoint.statusCode == 200) {
      if (json.decode(endpoint.body) is! Map &&
          json.decode(endpoint.body).isNotEmpty) {
        var body = TVMazeEpisodes.fromJson(json.decode(endpoint.body));
        return body;
      }
    }
    return null;
  }
}

class TVMazeResponse {
  double score;
  Map<String, dynamic> show;

  TVMazeResponse({this.score, this.show});

  factory TVMazeResponse.fromJson(Map<String, dynamic> json) {
    return TVMazeResponse(
      score: json['score'],
      show: json['show'],
    );
  }
}

class TVMazeEpisodes {
  List<dynamic> episodes;

  TVMazeEpisodes({this.episodes});

  factory TVMazeEpisodes.fromJson(List<dynamic> json) {
    return TVMazeEpisodes(
      episodes: json,
    );
  }
}
