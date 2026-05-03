// lib/data/movie_database.dart
//
// SQLite cache for movies. Singleton pattern same as the database_demo
// service from class.
//
// The schema is denormalized — one big movie table with all the OMDB fields
// as columns. That's fine for this dataset (a few hundred rows max) and
// keeps the queries simple. If we ever needed to query genres separately
// we'd normalize into movie/genre/movie_genre tables, but for the search
// bar we're building, a `WHERE title LIKE '%foo%'` over one table is
// exactly the right shape.
//
// `imdb_id` is the primary key. We use ConflictAlgorithm.replace on inserts
// so re-fetching the JSON list and re-inserting is idempotent — same
// imdb_id just overwrites the row.

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../movie.dart';

class MovieDatabase {
  static final MovieDatabase _instance = MovieDatabase._internal();
  factory MovieDatabase() => _instance;
  MovieDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'movies.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movie (
        imdb_id     TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        director    TEXT NOT NULL,
        year        TEXT,
        rated       TEXT,
        released    TEXT,
        runtime     TEXT,
        genre       TEXT,
        actors      TEXT,
        plot        TEXT,
        language    TEXT,
        country     TEXT,
        poster_url  TEXT,
        imdb_rating TEXT
      )
    ''');
    // Index on title for fast prefix/contains search.
    await db.execute('CREATE INDEX idx_movie_title ON movie(title COLLATE NOCASE)');
  }

  // ─────────── CRUD ───────────

  Future<void> upsertMany(List<Movie> movies) async {
    final db = await database;
    final batch = db.batch();
    for (final m in movies) {
      // Skip movies without an imdb_id — they can't be uniquely keyed.
      if (m.imdbId == null) continue;
      batch.insert(
        'movie',
        m.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Movie>> all() async {
    final db = await database;
    final rows = await db.query('movie', orderBy: 'title COLLATE NOCASE ASC');
    return rows.map(Movie.fromDbRow).toList(growable: false);
  }

  /// Case-insensitive title contains. Used by the search bar.
  Future<List<Movie>> searchByTitle(String query) async {
    if (query.isEmpty) return all();
    final db = await database;
    final rows = await db.query(
      'movie',
      where: 'title LIKE ? COLLATE NOCASE',
      whereArgs: ['%$query%'],
      orderBy: 'title COLLATE NOCASE ASC',
    );
    return rows.map(Movie.fromDbRow).toList(growable: false);
  }

  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM movie');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('movie');
  }
}
