// lib/movie.dart
//
// Extended Movie model. The starter code only pulled Title and Director
// out of the JSON, but the source data has plenty more (Year, Genre, Plot,
// Actors, Poster URL, imdbRating, …). For this exercise I'm reading all
// the fields the details screen will display.
//
// I'm careful with nullability: the JSON sometimes has "N/A" as a string
// for missing fields, and I prefer to treat that the same as missing —
// so I normalize "N/A" to null on the way in.

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

  Movie({
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

  /// Reads from the OMDB-style JSON used in the unit's sample data.
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

  /// Round-trip back to JSON. Useful for tests and for future caching
  /// (the portfolio task will store these in SQLite via toJson).
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

  /// Genre is a comma-separated string in the source data ("Action, Drama").
  /// Splitting it once here keeps the UI code simple.
  List<String> get genreList =>
      (genre ?? '').split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();

  List<String> get actorList =>
      (actors ?? '').split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
}
