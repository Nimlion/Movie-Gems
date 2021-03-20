import 'dart:async';
import 'dart:convert';

// Necessary imports
import 'package:http/http.dart' as http;
import 'package:movie_gems/controller/TMDBSeries.dart';
import 'package:movie_gems/env.dart';

class TMDBMovieController {
  String apiKey = ENV().tmdb;

  Future<TMDBCast> fetchMovieCast(String id) async {
    final endpoint = await http.get(
        'https://api.themoviedb.org/3/movie/$id/credits?api_key=$apiKey&language=en-US');

    if (endpoint.statusCode == 200) {
      return TMDBCast.fromJson(json.decode(endpoint.body));
    } else {
      throw Exception('Failed to load cast of movie');
    }
  }

  Future<TMDBMovie> fetchTMDBData(String imdbId) async {
    final endpoint = await http
        .get('https://api.themoviedb.org/3/movie/$imdbId?api_key=$apiKey');

    if (endpoint.statusCode == 200) {
      return TMDBMovie.fromJson(json.decode(endpoint.body));
    } else {
      throw Exception('Failed to load movie');
    }
  }

  Future<List<TMDBCondensedMovie>> fetchSimilarMovies(String imdbId) async {
    final endpoint = await http.get(
        'https://api.themoviedb.org/3/movie/$imdbId/similar?api_key=$apiKey&language=en-US&page=1');

    if (endpoint.statusCode == 200) {
      return retrieveListOfCondensedMovies(json.decode(endpoint.body));
    } else {
      throw Exception('Failed to similar movies');
    }
  }

  List<TMDBCondensedMovie> retrieveListOfCondensedMovies(
      Map<String, dynamic> obj) {
    List<TMDBCondensedMovie> list = List();
    obj.forEach((String key, entry) {
      if (key == "results") {
        entry.forEach((entry) {
          if (entry != null) {
            var movie = TMDBCondensedMovie.fromJson(entry);
            list.add(movie);
          }
        });
      }
    });
    return list;
  }

  Future<List<TMDBCondensedMovie>> fetchPopular() async {
    final endpoint = await http.get(
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=en-US&page=1');

    if (endpoint.statusCode == 200) {
      return retrieveListOfCondensedMovies(json.decode(endpoint.body));
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<TMDBCondensedMovie>> fetchPlaying() async {
    final endpoint = await http.get(
        'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey&language=en-US&page=1');

    if (endpoint.statusCode == 200) {
      return retrieveListOfCondensedMovies(json.decode(endpoint.body));
    } else {
      throw Exception('Failed to load playing movies');
    }
  }
}

class TMDBMovie {
  bool adult;
  String backdrop;
  Object collection;
  int budget;
  Object genres;
  String homepage;
  int id;
  String imdbId;
  String originalLanguage;
  String originalTitle;
  String overview;
  double popularity;
  String poster;
  List prodCompanies;
  List prodCountries;
  String releaseDate;
  int revenue;
  int runtime;
  Object spokenLanguages;
  String status;
  String tagline;
  String title;
  bool video;
  double voteAvg;
  int votecount;

  TMDBMovie(
      {this.adult,
      this.backdrop,
      this.collection,
      this.budget,
      this.genres,
      this.homepage,
      this.id,
      this.imdbId,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.popularity,
      this.poster,
      this.prodCompanies,
      this.prodCountries,
      this.releaseDate,
      this.revenue,
      this.runtime,
      this.spokenLanguages,
      this.status,
      this.tagline,
      this.title,
      this.video,
      this.voteAvg,
      this.votecount});

  factory TMDBMovie.fromJson(Map<String, dynamic> json) {
    return TMDBMovie(
      adult: json['adult'],
      backdrop: json['backdrop_path'],
      collection: json['belongs_to_collection'],
      budget: json['budget'],
      genres: json['genres'],
      homepage: json['homepage'],
      id: json['id'],
      imdbId: json['imdb_id'],
      originalLanguage: json['original_language'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      popularity: json['popularity'],
      poster: json['poster_path'],
      prodCompanies: json['production_companies'],
      prodCountries: json['production_countries'],
      releaseDate: json['release_date'],
      revenue: json['revenue'],
      runtime: json['runtime'],
      spokenLanguages: json['spoken_languages'],
      status: json['status'],
      tagline: json['tagline'],
      title: json['title'],
      video: json['video'],
      voteAvg: json['vote_average'],
      votecount: json['vote_count'],
    );
  }
}

class TMDBCondensedMovie {
  bool adult;
  String backdrop;
  Object genres;
  int id;
  String originalLanguage;
  String originalTitle;
  String overview;
  String poster;
  String releaseDate;
  String title;
  bool video;
  double voteAvg;
  int votecount;

  TMDBCondensedMovie(
      {this.adult,
      this.backdrop,
      this.genres,
      this.id,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.poster,
      this.releaseDate,
      this.title,
      this.video,
      this.voteAvg,
      this.votecount});

  factory TMDBCondensedMovie.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return TMDBCondensedMovie(
      adult: json['adult'],
      backdrop: json['backdrop_path'],
      genres: json['genres'],
      id: json['id'],
      originalLanguage: json['original_language'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      poster: json['poster_path'],
      releaseDate: json['release_date'],
      title: json['title'],
      video: json['video'],
      voteAvg: (json['vote_average']).toDouble(),
      votecount: json['vote_count'],
    );
  }
}
