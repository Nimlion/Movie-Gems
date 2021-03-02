class Serie {
  String title;
  DateTime startdate;
  int category;
  String status;
  String tvMazeURL;
  String premiered;
  String type;
  String genres;
  int tvMazeID;
  int tmdbID;
  String imdbID;

  Serie({
    this.title,
    this.startdate,
    this.category,
    this.status,
    this.tvMazeURL,
    this.premiered,
    this.type,
    this.genres,
    this.tvMazeID,
    this.tmdbID,
    this.imdbID,
  });

  Serie.fromOMDB(
    String title,
    DateTime startdate,
    int category,
    String status,
    String tvMazeURL,
    String premiered,
    String type,
    String genres,
    int tvMazeID,
    int tmdbID,
    String imdbID,
  ) {
    this.title = title;
    this.startdate = startdate;
    this.category = category;
    this.status = status;
    this.tvMazeURL = tvMazeURL;
    this.premiered = premiered;
    this.type = type;
    this.genres = genres;
    this.tvMazeID = tvMazeID;
    this.tmdbID = tmdbID;
    this.imdbID = imdbID;
  }

  @override
  String toString() {
    return "{title: " +
        title.toString() +
        ", " +
        "startdate: " +
        startdate.toString() +
        ", " +
        "category: " +
        category.toString() +
        ", " +
        "status: " +
        status.toString() +
        ", " +
        "tvMazeURL: " +
        tvMazeURL.toString() +
        ", " +
        "premiered: " +
        premiered.toString() +
        ", " +
        "type: " +
        type.toString() +
        ", " +
        "genres: " +
        genres.toString() +
        ", " +
        "tvMazeID: " +
        tvMazeID.toString() +
        ", " +
        "tmdbID: " +
        tmdbID.toString() +
        ", " +
        "imdbID: " +
        imdbID.toString() +
        "}";
  }

  factory Serie.fromJson(Map<String, dynamic> parsedJson) {
    return Serie.fromOMDB(
      parsedJson['title'],
      DateTime.fromMillisecondsSinceEpoch(
          (parsedJson['startdate'].microsecondsSinceEpoch)),
      parsedJson['category'],
      parsedJson['status'],
      parsedJson['tvMazeURL'],
      parsedJson['premiered'],
      parsedJson['type'],
      parsedJson['genres'],
      parsedJson['tvMazeID'],
      parsedJson['tmdbID'],
      parsedJson['imdbID'],
    );
  }

  Map<String, dynamic> toMap() => {
        "title": this.title,
        "startdate": this.startdate,
        "category": this.category,
        "status": this.status,
        "tvMazeURL": this.tvMazeURL,
        "premiered": this.premiered,
        "type": this.type,
        "genres": this.genres,
        "tvMazeID": this.tvMazeID,
        "tmdbID": this.tmdbID,
        "imdbID": this.imdbID,
      };
}
