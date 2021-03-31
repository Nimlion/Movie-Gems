class WatchLater implements Comparable {
  String title;
  bool released;
  DateTime releaseDate;
  DateTime addedOn;
  int tmdbID;
  String imdbID;

  WatchLater(
      {this.title, this.released, this.releaseDate, this.tmdbID, this.addedOn});

  @override
  int compareTo(other) {
    if (this == null || other == null) {
      return null;
    }

    if (this.released == other.released) {
      if (this.released) {
        return this.title.compareTo(other.title);
      } else {
        return this.releaseDate.compareTo(other.releaseDate);
      }
    }

    if (this.released) {
      return 1;
    }
    return -1;
  }

  WatchLater.fromOMDB(String title, bool released, DateTime releaseDate,
      DateTime addedOn, int tmdbID, String imdbID) {
    this.title = title;
    this.released = released;
    this.releaseDate = releaseDate;
    this.addedOn = addedOn;
    this.tmdbID = tmdbID;
    this.imdbID = imdbID;
  }

  @override
  String toString() {
    return "{title: " +
        title +
        ", " +
        "released: " +
        this.released.toString() +
        ", " +
        "releaseDate: " +
        this.releaseDate.toString() +
        ", " +
        "addedOn: " +
        this.addedOn.toString() +
        ", " +
        "tmdbID: " +
        this.tmdbID.toString() +
        ", " +
        "imdbID: " +
        this.imdbID.toString() +
        ", " +
        "}";
  }

  factory WatchLater.fromJson(Map<String, dynamic> parsedJson) {
    return WatchLater.fromOMDB(
      parsedJson['title'],
      parsedJson['released'],
      DateTime.fromMillisecondsSinceEpoch(
          (parsedJson['addedOn'].microsecondsSinceEpoch)),
      DateTime.fromMillisecondsSinceEpoch(
          (parsedJson['releaseDate'].microsecondsSinceEpoch)),
      parsedJson['tmdbID'],
      parsedJson['imdbID'],
    );
  }

  WatchLater.fromMap(Map<dynamic, dynamic> map)
      : title = map["title"].toString(),
        released = map['released'],
        releaseDate = map['releaseDate'],
        addedOn = map['addedOn'],
        tmdbID = map['tmdbID'],
        imdbID = map['imdbID'];

  Map<String, dynamic> toMap() => {
        "title": this.title,
        "released": this.released,
        "addedOn": this.addedOn,
        "releaseDate": this.releaseDate,
        "tmdbID": this.tmdbID,
        "imdbID": this.imdbID,
      };
}
