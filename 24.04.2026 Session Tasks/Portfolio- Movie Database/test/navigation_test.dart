// test/navigation_test.dart
//
// Widget tests that verify navigation between HomeScreen and DetailsScreen.
// The portfolio task asks for "test cases for navigating between the main
// and detail screens" — that's what this file covers.
//
// Strategy: I bypass the real network and SQLite by constructing
// HomeScreen with a fake repository that returns hardcoded movies. That
// keeps the test deterministic, fast, and not dependent on the test
// runner having a working SQLite or internet connection.
//
// The pattern:
//   1. pumpWidget with the fake-repo home screen.
//   2. await tester.pumpAndSettle() so the initial Future resolves.
//   3. Tap the first ListTile.
//   4. pumpAndSettle for the navigation animation.
//   5. expect the DetailsScreen's distinctive widgets to be present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_db/data/movie_repository.dart';
import 'package:movie_db/movie.dart';
import 'package:movie_db/screens/home_screen.dart';

/// In-memory test double that satisfies the same shape as MovieRepository
/// without ever touching HTTP or SQLite. We only override the methods the
/// home screen actually calls.
class _FakeRepo implements MovieRepository {
  _FakeRepo(this._movies);
  final List<Movie> _movies;

  @override
  Future<List<Movie>> loadInitial() async => _movies;

  @override
  Future<List<Movie>> refreshFromNetwork() async => _movies;

  @override
  Future<List<Movie>> search(String query) async {
    if (query.isEmpty) return _movies;
    final q = query.toLowerCase();
    return _movies
        .where((m) => m.title.toLowerCase().contains(q))
        .toList(growable: false);
  }

  // Not used by the home screen but required by the interface.
  @override
  String get movieUri => 'fake://test';
  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _avatar = Movie(
  title: 'Avatar',
  director: 'James Cameron',
  year: '2009',
  genre: 'Action, Adventure, Fantasy',
  plot: 'A paraplegic marine on the moon Pandora.',
  imdbRating: '7.9',
  imdbId: 'tt0499549',
);

const _matrix = Movie(
  title: 'The Matrix',
  director: 'Lana & Lilly Wachowski',
  year: '1999',
  genre: 'Action, Sci-Fi',
  plot: 'A computer hacker learns the truth.',
  imdbRating: '8.7',
  imdbId: 'tt0133093',
);

void main() {
  // Default flutter_test viewport is 800x600 (logical pixels), too small for
  // a SliverAppBar-based DetailsScreen — buttons at the bottom land off-screen
  // and tap() silently fails to hit them. Bumping the surface to 800x1600
  // gives every test enough vertical room. Each test calls _setUpViewport
  // and registers a teardown so the override doesn't leak between tests.
  void setUpLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets(
      'tapping a movie tile pushes the details screen with that movie',
      (tester) async {
    setUpLargeViewport(tester);
    final repo = _FakeRepo([_avatar, _matrix]);

    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(title: 'Movies', repository: repo),
    ));
    // Resolve the initial loadInitial() future.
    await tester.pumpAndSettle();

    // The home screen should show both movies.
    expect(find.text('Avatar'), findsOneWidget);
    expect(find.text('The Matrix'), findsOneWidget);

    // Tap the Avatar tile.
    await tester.tap(find.text('Avatar'));
    await tester.pumpAndSettle();

    // We should now be on the details screen for Avatar.
    // The plot is one of the distinctive things only the details screen
    // shows, so finding it confirms the navigation worked AND the
    // correct Movie was passed through the constructor.
    expect(find.text('A paraplegic marine on the moon Pandora.'),
        findsOneWidget);
    // Director shows up too.
    expect(find.text('James Cameron'), findsOneWidget);
  });

  testWidgets('Back button on details returns to the list', (tester) async {
    setUpLargeViewport(tester);
    final repo = _FakeRepo([_avatar]);

    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(title: 'Movies', repository: repo),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Avatar'));
    await tester.pumpAndSettle();

    // Confirm we're on details.
    expect(find.text('A paraplegic marine on the moon Pandora.'),
        findsOneWidget);

    // The details screen has a "Back to list" FilledButton. Scroll it into
    // view first — on a smaller viewport or a future layout change it could
    // sit below the fold, and tap() silently fails on off-screen widgets.
    await tester.ensureVisible(find.text('Back to list'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to list'));
    await tester.pumpAndSettle();

    // Back on the home screen — the search field should be visible again.
    expect(find.byKey(const Key('search_field')), findsOneWidget);
    // The Avatar tile should be on screen again.
    expect(find.text('Avatar'), findsOneWidget);
    // The plot text from the details screen should NOT be present anymore.
    expect(find.text('A paraplegic marine on the moon Pandora.'),
        findsNothing);
  });

  testWidgets('search filters the visible movies', (tester) async {
    setUpLargeViewport(tester);
    final repo = _FakeRepo([_avatar, _matrix]);

    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(title: 'Movies', repository: repo),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Avatar'), findsOneWidget);
    expect(find.text('The Matrix'), findsOneWidget);

    // Type "matrix" into the search field.
    await tester.enterText(find.byKey(const Key('search_field')), 'matrix');
    await tester.pumpAndSettle();

    // Only The Matrix should remain.
    expect(find.text('Avatar'), findsNothing);
    expect(find.text('The Matrix'), findsOneWidget);
  });
}
