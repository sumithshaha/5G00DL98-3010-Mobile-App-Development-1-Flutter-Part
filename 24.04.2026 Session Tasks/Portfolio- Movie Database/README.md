# Portfolio Task — Movie Database App

This extends `http_demo` from class with:

1. **Local SQLite cache** — movies are stored after first fetch.
2. **Search bar** — queries titles via SQL (case-insensitive `LIKE`).
3. **Detail screen** — shows poster, plot, actors, genre, rating, etc.
4. **Tests** — `test/movie_test.dart` for `Movie.fromJson`/`toJson`,
   `test/navigation_test.dart` for navigation between screens.

## Architecture

Three layers, same idea as the unit's database service pattern:

```
lib/
├── main.dart                         ← MaterialApp + Repository wiring
├── movie.dart                        ← Model (JSON ↔ object ↔ SQL)
├── data/
│   ├── movie_database.dart           ← SQLite cache (sqflite)
│   └── movie_repository.dart         ← Coordinates HTTP + cache
└── screens/
    ├── home_screen.dart              ← List + search bar
    └── details_screen.dart           ← Poster, plot, chips, metadata
```

The repository is the single point the screens talk to. It hides
whether a result came from the cache or the network, which means
the home screen has zero `if (online) … else …` branching.

## Running

```bash
flutter pub get
flutter run
```

Search filters the local cache instantly. The refresh button in the
AppBar re-fetches from the JSON URL and updates the cache.

## Running the tests

```bash
flutter test
```

Should print "All tests passed!" and show 12 passing tests:

- 11 unit tests in `test/movie_test.dart` covering `fromJson`,
  `toJson`, the round-trip property, the SQLite `toDbMap`/`fromDbRow`
  pair, and edge cases like `"N/A"` handling.
- 3 widget tests in `test/navigation_test.dart` covering tap-to-details
  navigation, back-button return, and search filtering.

The widget tests use a fake `MovieRepository` so they don't hit the
real network or open SQLite — they're fully deterministic and run in
under a second.
