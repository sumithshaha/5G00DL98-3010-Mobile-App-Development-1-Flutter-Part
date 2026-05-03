// test/movie_test.dart
//
// Unit tests for Movie.fromJson and Movie.toJson, as the portfolio task
// asks for explicitly. Run with: flutter test test/movie_test.dart
//
// I'm covering the happy path (full JSON in, full Movie out), the
// "N/A" cleanup behavior (some OMDB fields use the literal string "N/A"
// for missing data), the round-trip property (fromJson(toJson(m)) == m),
// and a few edge cases.

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_db/movie.dart';

void main() {
  group('Movie.fromJson', () {
    test('parses a complete OMDB-shape JSON', () {
      final json = {
        'Title': 'Avatar',
        'Year': '2009',
        'Rated': 'PG-13',
        'Released': '18 Dec 2009',
        'Runtime': '162 min',
        'Genre': 'Action, Adventure, Fantasy',
        'Director': 'James Cameron',
        'Actors': 'Sam Worthington, Zoe Saldana, Sigourney Weaver',
        'Plot': 'A paraplegic marine...',
        'Language': 'English, Spanish',
        'Country': 'USA, UK',
        'Poster': 'http://example.com/avatar.jpg',
        'imdbRating': '7.9',
        'imdbID': 'tt0499549',
      };

      final m = Movie.fromJson(json);

      expect(m.title, 'Avatar');
      expect(m.year, '2009');
      expect(m.rated, 'PG-13');
      expect(m.released, '18 Dec 2009');
      expect(m.runtime, '162 min');
      expect(m.genre, 'Action, Adventure, Fantasy');
      expect(m.director, 'James Cameron');
      expect(m.actors, 'Sam Worthington, Zoe Saldana, Sigourney Weaver');
      expect(m.plot, 'A paraplegic marine...');
      expect(m.language, 'English, Spanish');
      expect(m.country, 'USA, UK');
      expect(m.posterUrl, 'http://example.com/avatar.jpg');
      expect(m.imdbRating, '7.9');
      expect(m.imdbId, 'tt0499549');
    });

    test('treats "N/A" as null for optional fields', () {
      final json = {
        'Title': 'Untitled',
        'Director': 'Unknown',
        'Year': 'N/A',
        'Plot': 'N/A',
        'Poster': 'N/A',
      };

      final m = Movie.fromJson(json);

      expect(m.year, isNull);
      expect(m.plot, isNull);
      expect(m.posterUrl, isNull);
    });

    test('treats empty string the same as missing', () {
      final m = Movie.fromJson({
        'Title': 'X',
        'Director': 'Y',
        'Genre': '',
      });
      expect(m.genre, isNull);
    });

    test('falls back to "Unknown" for missing required fields', () {
      final m = Movie.fromJson(<String, dynamic>{});
      expect(m.title, 'Unknown');
      expect(m.director, 'Unknown');
    });

    test('genreList splits the comma-separated genre string', () {
      final m = Movie.fromJson({
        'Title': 'X',
        'Director': 'Y',
        'Genre': 'Action, Drama, Sci-Fi',
      });
      expect(m.genreList, ['Action', 'Drama', 'Sci-Fi']);
    });

    test('genreList is empty when genre is null', () {
      final m = Movie.fromJson({'Title': 'X', 'Director': 'Y'});
      expect(m.genreList, isEmpty);
    });

    test('actorList trims whitespace around names', () {
      final m = Movie.fromJson({
        'Title': 'X',
        'Director': 'Y',
        'Actors': 'Sam Worthington,  Zoe Saldana ',
      });
      expect(m.actorList, ['Sam Worthington', 'Zoe Saldana']);
    });
  });

  group('Movie.toJson', () {
    test('serializes all populated fields back to OMDB-shape keys', () {
      const m = Movie(
        title: 'Avatar',
        director: 'James Cameron',
        year: '2009',
        rated: 'PG-13',
        runtime: '162 min',
        genre: 'Action',
        plot: 'A marine...',
        posterUrl: 'http://example.com/p.jpg',
        imdbRating: '7.9',
        imdbId: 'tt0499549',
      );

      final json = m.toJson();

      expect(json['Title'], 'Avatar');
      expect(json['Director'], 'James Cameron');
      expect(json['Year'], '2009');
      expect(json['Rated'], 'PG-13');
      expect(json['Runtime'], '162 min');
      expect(json['Genre'], 'Action');
      expect(json['Plot'], 'A marine...');
      expect(json['Poster'], 'http://example.com/p.jpg');
      expect(json['imdbRating'], '7.9');
      expect(json['imdbID'], 'tt0499549');
    });

    test('omits null-valued optional fields entirely', () {
      const m = Movie(title: 'X', director: 'Y');
      final json = m.toJson();

      expect(json.containsKey('Title'), isTrue);
      expect(json.containsKey('Director'), isTrue);
      expect(json.containsKey('Year'), isFalse);
      expect(json.containsKey('Genre'), isFalse);
      expect(json.containsKey('Plot'), isFalse);
      expect(json.containsKey('Poster'), isFalse);
    });
  });

  group('round-trip', () {
    test('fromJson(toJson(m)) preserves all fields', () {
      const original = Movie(
        title: 'The Matrix',
        director: 'Lana & Lilly Wachowski',
        year: '1999',
        rated: 'R',
        released: '31 Mar 1999',
        runtime: '136 min',
        genre: 'Action, Sci-Fi',
        actors: 'Keanu Reeves, Laurence Fishburne',
        plot: 'A computer hacker learns...',
        language: 'English',
        country: 'USA',
        posterUrl: 'http://example.com/matrix.jpg',
        imdbRating: '8.7',
        imdbId: 'tt0133093',
      );

      final restored = Movie.fromJson(original.toJson());

      expect(restored, equals(original));
    });

    test('round-trip with all-null optionals also works', () {
      const original = Movie(title: 'Bare', director: 'Minimum');
      final restored = Movie.fromJson(original.toJson());
      expect(restored, equals(original));
    });
  });

  group('SQLite serialization (toDbMap / fromDbRow)', () {
    test('round-trips through the lowercase-column map', () {
      const original = Movie(
        title: 'Inception',
        director: 'Christopher Nolan',
        year: '2010',
        runtime: '148 min',
        genre: 'Action, Sci-Fi, Thriller',
        plot: 'A thief who steals corporate secrets...',
        imdbId: 'tt1375666',
        imdbRating: '8.8',
        posterUrl: 'http://example.com/i.jpg',
      );

      final restored = Movie.fromDbRow(original.toDbMap());

      expect(restored, equals(original));
    });

    test('toDbMap uses lowercase column names', () {
      const m = Movie(title: 'X', director: 'Y', imdbId: 'tt1');
      final map = m.toDbMap();
      // Keys should be SQL-style, not OMDB-style.
      expect(map.containsKey('title'), isTrue);
      expect(map.containsKey('director'), isTrue);
      expect(map.containsKey('imdb_id'), isTrue);
      expect(map.containsKey('Title'), isFalse);
      expect(map.containsKey('imdbID'), isFalse);
    });
  });
}
