import 'dart:async';
import 'dart:convert';

// Necessary imports
import 'package:http/http.dart' as http;
import 'package:movie_gems/env.dart';

class OMDBController {
  String apiKey = ENV().omdb;

  Future<OMDBResponse> fetchOMDBData(String movieTitle) async {
    final response = await http.get(
        'https://www.omdbapi.com/?apikey=$apiKey&t=$movieTitle&type=movie');

    if (response.statusCode == 200) {
      OMDBResponse movie = OMDBResponse.fromJson(json.decode(response.body));
      if (movie.type == "movie") {
        return movie;
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to load movie');
    }
  }
}

class OMDBResponse {
  String title;
  String year;
  String rated;
  String released;
  String runtime;
  String genre;
  String director;
  String writer;
  String actors;
  String plot;
  String language;
  String country;
  String awards;
  String poster;
  Object ratings;
  String metascore;
  String imdbRating;
  String imdbVotes;
  String imdbID;
  String type;
  String dvd;
  String boxOffice;
  String production;
  String website;
  String reponse;

  OMDBResponse(
      {this.title,
      this.year,
      this.rated,
      this.released,
      this.runtime,
      this.genre,
      this.director,
      this.writer,
      this.actors,
      this.plot,
      this.language,
      this.country,
      this.awards,
      this.poster,
      this.ratings,
      this.metascore,
      this.imdbRating,
      this.imdbVotes,
      this.imdbID,
      this.type,
      this.dvd,
      this.boxOffice,
      this.production,
      this.website,
      this.reponse});

  factory OMDBResponse.fromJson(Map<String, dynamic> json) {
    return OMDBResponse(
      title: json['Title'],
      year: json['Year'],
      rated: json['Rated'],
      released: json['Released'],
      runtime: json['Runtime'],
      genre: json['Genre'],
      director: json['Director'],
      writer: json['Writer'],
      actors: json['Actors'],
      plot: json['Plot'],
      language: json['Language'],
      country: json['Country'],
      awards: json['Awards'],
      poster: json['Poster'],
      ratings: json['Ratings'],
      metascore: json['Metascore'],
      imdbRating: json['imdbRating'],
      imdbVotes: json['imdbVotes'],
      imdbID: json['imdbID'],
      type: json['Type'],
      dvd: json['DVD'],
      boxOffice: json['BoxOffice'],
      production: json['Production'],
      website: json['Website'],
      reponse: json['Response'],
    );
  }
}
