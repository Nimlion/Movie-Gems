import 'dart:async';
import 'dart:convert';

// Necessary imports
import 'package:http/http.dart' as http;
import 'package:movie_gems/env.dart';

class TMDBSeriesController {
  String apiKey = ENV().tmdb;

  Future<TMDBCast> fetchSerieCast(String id) async {
    final endpoint = await http.get(
        'https://api.themoviedb.org/3/tv/$id/aggregate_credits?api_key=$apiKey&language=en-US');

    if (endpoint.statusCode == 200) {
      return TMDBCast.fromJson(json.decode(endpoint.body));
    }
    return null;
  }

  Future<TMDBCondensedSerie> fetchSerieTMDBData(String query) async {
    final endpoint = await http.get(
        'https://api.themoviedb.org/3/search/tv?api_key=$apiKey&language=en-US&page=1&query=$query&include_adult=true');

    if (endpoint.statusCode == 200) {
      if ((json.decode(endpoint.body)["results"] as List).toList().isNotEmpty) {
        return TMDBCondensedSerie.fromJson(
            json.decode(json.encode(json.decode(endpoint.body)["results"][0])));
      }
    }
    return null;
  }

  Future<TMDBSerie> tmdbFetchSerieDetails(String id) async {
    final endpoint = await http.get(
        'https://api.themoviedb.org/3/tv/$id?api_key=$apiKey&language=en-US');

    if (endpoint.statusCode == 200) {
      return TMDBSerie.fromJson(json.decode(endpoint.body));
    }
    return null;
  }

  List<TMDBCondensedSerie> retrieveListOfCondensedSeries(
      Map<String, dynamic> map) {
    List<TMDBCondensedSerie> list = List();
    map.forEach((String key, entry) {
      if (key == "results") {
        entry.forEach((entry) {
          if (entry != null) {
            var serie = TMDBCondensedSerie.fromJson(entry);
            list.add(serie);
          }
        });
      }
    });
    return list;
  }

  Future<List<TMDBCondensedSerie>> fetchPopularSeries() async {
    final endpoint = await http.get(
        'http://api.themoviedb.org/3/tv/popular?api_key=$apiKey&language=en-US');

    if (endpoint.statusCode == 200) {
      return retrieveListOfCondensedSeries(json.decode(endpoint.body));
    }
    return null;
  }
}

class TMDBCast {
  List cast;
  List crew;
  int id;

  TMDBCast({
    this.cast,
    this.crew,
    this.id,
  });

  factory TMDBCast.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return TMDBCast(
      cast: json['cast'],
      crew: json['crew'],
      id: json['id'],
    );
  }
}

class TMDBSerie {
  String backdropPath;
  List createdBy;
  List episodeRunTime;
  String firstAirDate;
  List genres;
  String homepage;
  int id;
  bool inProduction;
  List languages;
  String lastAirDate;
  Map lastEpisodeToAir;
  String name;
  Map nextEpisodeToAir;
  List networks;
  int numberOfEpisodes;
  int numberOfSeasons;
  List originCountry;
  String originalLanguage;
  String originalName;
  String overview;
  double popularity;
  String posterPath;
  List productionCompanies;
  List productionCountries;
  List seasons;
  List spokenLanguages;
  String status;
  String tagline;
  String type;
  double voteAverage;
  int voteCount;

  TMDBSerie({
    this.backdropPath,
    this.createdBy,
    this.episodeRunTime,
    this.firstAirDate,
    this.genres,
    this.homepage,
    this.id,
    this.inProduction,
    this.languages,
    this.lastAirDate,
    this.lastEpisodeToAir,
    this.name,
    this.nextEpisodeToAir,
    this.networks,
    this.numberOfEpisodes,
    this.numberOfSeasons,
    this.originCountry,
    this.originalLanguage,
    this.originalName,
    this.overview,
    this.popularity,
    this.posterPath,
    this.productionCompanies,
    this.productionCountries,
    this.seasons,
    this.spokenLanguages,
    this.status,
    this.tagline,
    this.type,
    this.voteAverage,
    this.voteCount,
  });

  factory TMDBSerie.fromJson(Map<String, dynamic> json) {
    return TMDBSerie(
      backdropPath: json['backdrop_path'],
      createdBy: json['created_by'],
      episodeRunTime: json['episode_run_time'],
      firstAirDate: json['first_air_date'],
      genres: json['genres'],
      homepage: json['homepage'],
      id: json['id'],
      inProduction: json['in_production'],
      languages: json['languages'],
      lastAirDate: json['last_air_date'],
      lastEpisodeToAir: json['last_episode_to_air'],
      name: json['name'],
      nextEpisodeToAir: json['next_episode_to_air'],
      networks: json['networks'],
      numberOfEpisodes: json['number_of_episodes'],
      numberOfSeasons: json['number_of_seasons'],
      originCountry: json['origin_country'],
      originalLanguage: json['original_language'],
      originalName: json['original_name'],
      overview: json['overview'],
      popularity: json['popularity'],
      posterPath: json['poster_path'],
      productionCompanies: json['production_companies'],
      productionCountries: json['production_countries'],
      seasons: json['seasons'],
      spokenLanguages: json['spoken_languages'],
      status: json['status'],
      tagline: json['tagline'],
      type: json['type'],
      voteAverage: json['vote_average'],
      voteCount: json['vote_count'],
    );
  }
}

class TMDBCondensedSerie {
  String backdrop;
  String firstAirDate;
  Object genreIds;
  int id;
  String name;
  Object originCountry;
  String originalLanguage;
  String originalName;
  String overview;
  double popularity;
  String posterPath;
  double voteAvg;
  int votecount;

  TMDBCondensedSerie(
      {this.backdrop,
      this.firstAirDate,
      this.genreIds,
      this.id,
      this.name,
      this.originCountry,
      this.originalLanguage,
      this.originalName,
      this.overview,
      this.popularity,
      this.posterPath,
      this.voteAvg,
      this.votecount});

  factory TMDBCondensedSerie.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return TMDBCondensedSerie(
      backdrop: json['backdrop_path'],
      firstAirDate: json['first_air_date'],
      genreIds: json['genre_ids'],
      id: json['id'],
      name: json['name'],
      originCountry: json['origin_country'],
      originalLanguage: json['original_language'],
      originalName: json['original_name'],
      overview: json['overview'],
      popularity: json['popularity'],
      posterPath: json['poster_path'],
      voteAvg: (json['vote_average']).toDouble(),
      votecount: json['vote_count'],
    );
  }
}
