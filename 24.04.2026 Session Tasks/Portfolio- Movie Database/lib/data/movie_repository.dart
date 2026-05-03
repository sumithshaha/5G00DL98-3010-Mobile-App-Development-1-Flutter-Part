// lib/data/movie_repository.dart
//
// Repository pattern: a single class the UI talks to, that internally
// coordinates HTTP and SQLite. The UI doesn't need to know whether a
// movie came from the network or the cache — it just asks for movies.
//
// Strategy:
//   1. On first run, the local DB is empty. We fetch from HTTP, dump
//      the result into SQLite, and return it.
//   2. On subsequent runs, we serve the SQLite cache immediately
//      (instant load, works offline) and optionally re-fetch in the
//      background to refresh.
//   3. Search always goes through SQLite — instant, works offline.
//
// This is a much better UX than the original http_demo, which always
// showed a spinner and broke completely without a network connection.

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../movie.dart';
import 'movie_database.dart';

class MovieRepository {
  MovieRepository({required this.movieUri, http.Client? client})
      : _client = client ?? http.Client();

  final String movieUri;
  final http.Client _client;
  final MovieDatabase _db = MovieDatabase();

  /// Get all cached movies. If the cache is empty, fetch from HTTP first.
  /// Returns the cached list either way.
  Future<List<Movie>> loadInitial() async {
    final cached = await _db.all();
    if (cached.isNotEmpty) return cached;
    return await refreshFromNetwork();
  }

  /// Force a fresh HTTP fetch and update the cache.
  Future<List<Movie>> refreshFromNetwork() async {
    final response = await _client.get(Uri.parse(movieUri));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List;
    final movies = list
        .map((j) => Movie.fromJson(j as Map<String, dynamic>))
        .toList(growable: false);
    await _db.upsertMany(movies);
    return _db.all(); // re-read so we get the canonical sorted ordering
  }

  /// Search the local cache by title (case-insensitive contains). Empty
  /// query returns everything.
  Future<List<Movie>> search(String query) => _db.searchByTitle(query);
}
