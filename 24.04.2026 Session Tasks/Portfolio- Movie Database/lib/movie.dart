// lib/movie.dart
//
// Movie model for the portfolio task. Same shape as Exercise 2 (so the
// fromJson/toJson round-trips work the same way and the unit tests will
// pass), with one addition: a SQLite serializer pair (toDbMap /
// Movie.fromDbRow) so we can cache movies in a local database.
//
// I'm keeping the JSON keys (capital-T "Title", "Director", etc.) for
// the OMDB-shaped JSON, but using lowercase column names in the SQLite
// table so SQL stays readable.
//
// `imdbId` is the natural primary key — every movie has a unique IMDb ID,
// so we can use it both as the SQLite primary key and as the de-duplication
// key when the HTTP layer pulls a fresh list and we want to avoid
// inserting the same movie twice.

class Movie {
  final String title;
  final String director;
  final String? year;
  final String? rated;
  final String? released;
  final String? runtime;
  final String? genre;
  final String? actors;
  final String? plot;
  final String? language;
  final String? country;
  final String? posterUrl;
  final String? imdbRating;
  final String? imdbId;

  const Movie({
    required this.title,
    required this.director,
    this.year,
    this.rated,
    this.released,
    this.runtime,
    this.genre,
    this.actors,
    this.plot,
    this.language,
    this.country,
    this.posterUrl,
    this.imdbRating,
    this.imdbId,
  });

  // ─────────── JSON (network) ───────────

  factory Movie.fromJson(Map<String, dynamic> json) {
    String? clean(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty || s == 'N/A') return null;
      return s;
    }

    return Movie(
      title: json['Title'] as String? ?? 'Unknown',
      director: json['Director'] as String? ?? 'Unknown',
      year: clean(json['Year']),
      rated: clean(json['Rated']),
      released: clean(json['Released']),
      runtime: clean(json['Runtime']),
      genre: clean(json['Genre']),
      actors: clean(json['Actors']),
      plot: clean(json['Plot']),
      language: clean(json['Language']),
      country: clean(json['Country']),
      posterUrl: clean(json['Poster']),
      imdbRating: clean(json['imdbRating']),
      imdbId: clean(json['imdbID']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Title': title,
        'Director': director,
        if (year != null) 'Year': year,
        if (rated != null) 'Rated': rated,
        if (released != null) 'Released': released,
        if (runtime != null) 'Runtime': runtime,
        if (genre != null) 'Genre': genre,
        if (actors != null) 'Actors': actors,
        if (plot != null) 'Plot': plot,
        if (language != null) 'Language': language,
        if (country != null) 'Country': country,
        if (posterUrl != null) 'Poster': posterUrl,
        if (imdbRating != null) 'imdbRating': imdbRating,
        if (imdbId != null) 'imdbID': imdbId,
      };

  // ─────────── SQLite (local cache) ───────────

  /// Serializer for the SQLite table. Lowercase column names because that's
  /// the SQL convention. We always include all columns (NULL is a valid
  /// SQLite value) so updates can clear fields.
  Map<String, Object?> toDbMap() => {
        'imdb_id': imdbId,
        'title': title,
        'director': director,
        'year': year,
        'rated': rated,
        'released': released,
        'runtime': runtime,
        'genre': genre,
        'actors': actors,
        'plot': plot,
        'language': language,
        'country': country,
        'poster_url': posterUrl,
        'imdb_rating': imdbRating,
      };

  factory Movie.fromDbRow(Map<String, Object?> row) {
    return Movie(
      title: (row['title'] as String?) ?? 'Unknown',
      director: (row['director'] as String?) ?? 'Unknown',
      year: row['year'] as String?,
      rated: row['rated'] as String?,
      released: row['released'] as String?,
      runtime: row['runtime'] as String?,
      genre: row['genre'] as String?,
      actors: row['actors'] as String?,
      plot: row['plot'] as String?,
      language: row['language'] as String?,
      country: row['country'] as String?,
      posterUrl: row['poster_url'] as String?,
      imdbRating: row['imdb_rating'] as String?,
      imdbId: row['imdb_id'] as String?,
    );
  }

  // ─────────── derived getters used by the UI ───────────

  List<String> get genreList => (genre ?? '')
      .split(',')
      .map((g) => g.trim())
      .where((g) => g.isNotEmpty)
      .toList();

  List<String> get actorList => (actors ?? '')
      .split(',')
      .map((a) => a.trim())
      .where((a) => a.isNotEmpty)
      .toList();

  // ─────────── equality (used by tests) ───────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Movie &&
        other.title == title &&
        other.director == director &&
        other.year == year &&
        other.rated == rated &&
        other.released == released &&
        other.runtime == runtime &&
        other.genre == genre &&
        other.actors == actors &&
        other.plot == plot &&
        other.language == language &&
        other.country == country &&
        other.posterUrl == posterUrl &&
        other.imdbRating == imdbRating &&
        other.imdbId == imdbId;
  }

  @override
  int get hashCode => Object.hash(
        title, director, year, rated, released, runtime, genre,
        actors, plot, language, country, posterUrl, imdbRating, imdbId,
      );
}
