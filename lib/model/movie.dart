class Movie {
  String title;
  double rating;
  DateTime date;
  int category;
  String rated;
  String runtime;
  String genre;
  String director;
  String actors;
  String poster;
  String awards;
  String imdbRating;
  String imdbID;
  String production;

  Movie(
      {this.title,
      this.rating,
      this.date,
      this.category,
      this.rated,
      this.runtime,
      this.genre,
      this.director,
      this.actors,
      this.poster,
      this.awards,
      this.imdbRating,
      this.imdbID,
      this.production});

  Movie.fromOMDB(
      String title,
      double rating,
      DateTime date,
      int category,
      String rated,
      String runtime,
      String genre,
      String director,
      String actors,
      String poster,
      String awards,
      String imdbRating,
      String imdbID,
      String production) {
    this.title = title;
    this.rating = rating;
    this.date = date;
    this.category = category;
    this.rated = rated;
    this.runtime = runtime;
    this.genre = genre;
    this.director = director;
    this.actors = actors;
    this.poster = poster;
    this.awards = awards;
    this.imdbRating = imdbRating;
    this.imdbID = imdbID;
    this.production = production;
  }

  @override
  String toString() {
    return "{title: " +
        title +
        ", " +
        "rating: " +
        rating.toString() +
        ", " +
        "date: " +
        date.toString() +
        ", " +
        "category: " +
        category.toString() +
        ", " +
        "rated: " +
        rated.toString() +
        ", " +
        "runtime: " +
        runtime.toString() +
        ", " +
        "genre: " +
        genre.toString() +
        ", " +
        "director: " +
        director.toString() +
        ", " +
        "actors: " +
        actors.toString() +
        "poster: " +
        poster.toString() +
        ", " +
        "awards: " +
        awards.toString() +
        ", " +
        "imdbRating: " +
        imdbRating.toString() +
        ", " +
        "imdbID: " +
        imdbID.toString() +
        ", " +
        "production: " +
        production.toString() +
        "}";
  }

  factory Movie.fromJson(Map<String, dynamic> parsedJson) {
    return Movie.fromOMDB(
      parsedJson['title'],
      parsedJson['rating'],
      DateTime.fromMillisecondsSinceEpoch(
          (parsedJson['date'].microsecondsSinceEpoch)),
      parsedJson['category'],
      parsedJson['Rated'],
      parsedJson['Runtime'],
      parsedJson['Genre'],
      parsedJson['Director'],
      parsedJson['Actors'],
      parsedJson['Poster'],
      parsedJson['Awards'],
      parsedJson['imdbRating'],
      parsedJson['imdbID'],
      parsedJson['Production'],
    );
  }

  Movie.fromMap(Map<dynamic, dynamic> map)
      : title = map["title"].toString(),
        date = map["date"],
        rating = map["rating"],
        category = map["category"],
        rated = map['Rated'],
        runtime = map['Runtime'],
        genre = map['Genre'],
        director = map['Director'],
        actors = map['Actors'],
        poster = map['Poster'],
        awards = map['Awards'],
        imdbRating = map['imdbRating'],
        imdbID = map['imdbID'],
        production = map['Production'];

  Map<String, dynamic> toMap() => {
        "title": this.title,
        "rating": this.rating,
        "date": this.date,
        "category": this.category,
        "rated": this.rated,
        "runtime": this.runtime,
        "genre": this.genre,
        "director": this.director,
        "actors": this.actors,
        "poster": this.poster,
        "awards": this.awards,
        "imdbRating": this.imdbRating,
        "imdbID": this.imdbID,
        "production": this.production
      };
}
