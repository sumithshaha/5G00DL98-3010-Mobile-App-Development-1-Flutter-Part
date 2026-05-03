// lib/screens/home_screen.dart
//
// Home screen for the portfolio task. The structure is:
//
//   - on init, kick off loadInitial() to populate the cache and show movies
//   - a search bar at the top; every keystroke triggers a SQLite query
//   - a refresh button in the AppBar to force re-fetch from HTTP
//   - tap a movie → push DetailsScreen with the Movie via constructor
//
// I'm using setState rather than a Provider/ChangeNotifier here because
// the state lives entirely in this screen and isn't shared. Unit 7's
// Provider section is genuinely useful when state is shared across
// multiple screens (the SelectedMovie pattern); here it would be
// unnecessary indirection.

import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../movie.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.repository});

  final String title;
  final MovieRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<Movie> _movies = const [];
  bool _loading = false;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _movies = await widget.repository.loadInitial();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      _movies = await widget.repository.refreshFromNetwork();
      // Re-apply the current search filter after the refresh.
      if (_searchCtrl.text.isNotEmpty) {
        _movies = await widget.repository.search(_searchCtrl.text);
      }
    } catch (e) {
      _error = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _onSearchChanged(String query) async {
    final results = await widget.repository.search(query);
    if (!mounted) return;
    setState(() => _movies = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh from network',
            onPressed: _refreshing ? null : _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              key: const Key('search_field'),
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Search by title',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 16),
              Text('No cached data and the network failed:\n$_error',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _initialLoad,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_movies.isEmpty) {
      return const Center(child: Text('No movies match your search.'));
    }
    return ListView.separated(
      itemCount: _movies.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final movie = _movies[i];
        return ListTile(
          key: Key('movie_tile_${movie.imdbId ?? i}'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: _Thumb(url: movie.posterUrl),
          title: Text(movie.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            movie.genre ?? movie.director,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: movie.imdbRating == null
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(movie.imdbRating!),
                  ],
                ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailsScreen(movie: movie),
            ),
          ),
        );
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  const _Thumb({required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 48,
        height: 72,
        child: url == null
            ? _ph(cs)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _ph(cs),
                loadingBuilder: (ctx, child, p) =>
                    p == null ? child : _ph(cs),
              ),
      ),
    );
  }

  Widget _ph(ColorScheme cs) => Container(
        color: cs.secondaryContainer,
        alignment: Alignment.center,
        child: Icon(Icons.movie, color: cs.onSecondaryContainer),
      );
}
