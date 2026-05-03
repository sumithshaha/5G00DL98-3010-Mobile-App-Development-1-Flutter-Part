// lib/screens/home_screen.dart
//
// Movie list. The starter code's logic is preserved verbatim — fetch the
// JSON in initState, decode into a List<Movie>, render in a ListView.builder
// with a CircularProgressIndicator while loading.
//
// What I added: each ListTile is now tappable and pushes the details
// screen via Navigator.push, passing the Movie object through the
// constructor. That's the data-passing pattern from Unit 6.
//
// Small aesthetic touches: I show the poster as a leading thumbnail
// (Image.network with errorBuilder fallback) and the year as a trailing
// small chip — both come "for free" because the extended Movie model
// already carries those fields.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../movie.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.movieUri});
  final String title;
  final String movieUri;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAndShow();
  }

  Future<void> _loadAndShow() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _movies = await _loadMovies();
    } catch (e) {
      _error = e.toString();
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<List<Movie>> _loadMovies() async {
    final response = await http.get(Uri.parse(widget.movieUri));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final movies = jsonDecode(response.body) as List;
    return List.generate(
      movies.length,
      (i) => Movie.fromJson(movies[i] as Map<String, dynamic>),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _isLoading ? null : _loadAndShow,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 16),
              Text('Could not load movies:\n$_error',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadAndShow,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _movies.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: _PosterThumb(url: movie.posterUrl),
          title: Text(movie.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(movie.director,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: movie.year == null
              ? null
              : Chip(
                  label: Text(movie.year!,
                      style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailsScreen(movie: movie),
              ),
            );
          },
        );
      },
    );
  }
}

/// Small poster thumbnail. The OMDB data sometimes uses `http://` URLs
/// which break on iOS App Transport Security; in that case the fallback
/// renders a movie icon instead. Same pattern for missing/null URLs.
class _PosterThumb extends StatelessWidget {
  final String? url;
  const _PosterThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 48,
        height: 72,
        child: url == null
            ? _placeholder(cs)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(cs),
                loadingBuilder: (ctx, child, progress) =>
                    progress == null ? child : _placeholder(cs),
              ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) => Container(
        color: cs.secondaryContainer,
        alignment: Alignment.center,
        child: Icon(Icons.movie, color: cs.onSecondaryContainer),
      );
}
