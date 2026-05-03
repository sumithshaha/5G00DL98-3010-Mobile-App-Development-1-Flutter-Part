// lib/screens/details_screen.dart
//
// Movie details. Receives the Movie via constructor (forward data passing
// from the home screen). Renders a hero poster, title, director, year,
// rating chip, plot, genre/actor chip rows, and metadata.
//
// Wrapped in CustomScrollView with SliverAppBar so the poster collapses
// nicely as the user scrolls — same pattern I used in the Restaurant App
// last week. Plain Scaffold + AppBar would also work, this is just nicer.

import 'package:flutter/material.dart';
import '../movie.dart';

class DetailsScreen extends StatelessWidget {
  final Movie movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _HeroPoster(url: movie.posterUrl),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + year ──
                  Text(movie.title, style: theme.textTheme.headlineSmall),
                  if (movie.year != null) ...[
                    const SizedBox(height: 4),
                    Text(movie.year!,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onSurfaceVariant)),
                  ],

                  const SizedBox(height: 12),

                  // ── Rating + runtime + rated row ──
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (movie.imdbRating != null)
                        _Pill(
                          icon: Icons.star,
                          label: '${movie.imdbRating} / 10',
                          color: Colors.amber.shade800,
                        ),
                      if (movie.runtime != null)
                        _Pill(
                          icon: Icons.timer_outlined,
                          label: movie.runtime!,
                          color: cs.tertiary,
                        ),
                      if (movie.rated != null)
                        _Pill(
                          icon: Icons.theaters,
                          label: movie.rated!,
                          color: cs.secondary,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Director ──
                  _Section(title: 'Director', body: Text(movie.director)),

                  // ── Plot ──
                  if (movie.plot != null)
                    _Section(
                      title: 'Plot',
                      body: Text(
                        movie.plot!,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ),

                  // ── Genre chips ──
                  if (movie.genreList.isNotEmpty)
                    _Section(
                      title: 'Genre',
                      body: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: movie.genreList
                            .map((g) => Chip(label: Text(g)))
                            .toList(),
                      ),
                    ),

                  // ── Actor chips ──
                  if (movie.actorList.isNotEmpty)
                    _Section(
                      title: 'Actors',
                      body: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: movie.actorList
                            .map((a) => Chip(
                                  avatar: const Icon(Icons.person, size: 16),
                                  label: Text(a),
                                ))
                            .toList(),
                      ),
                    ),

                  // ── Metadata block ──
                  if (movie.released != null ||
                      movie.language != null ||
                      movie.country != null ||
                      movie.imdbId != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (movie.released != null)
                            _MetaRow(label: 'Released', value: movie.released!),
                          if (movie.language != null)
                            _MetaRow(label: 'Language', value: movie.language!),
                          if (movie.country != null)
                            _MetaRow(label: 'Country', value: movie.country!),
                          if (movie.imdbId != null)
                            _MetaRow(label: 'IMDb ID', value: movie.imdbId!),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Back button ──
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to list'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────── private layout helpers ───────────

class _HeroPoster extends StatelessWidget {
  final String? url;
  const _HeroPoster({required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (url == null) {
      return Container(
        color: cs.primaryContainer,
        alignment: Alignment.center,
        child: Icon(Icons.movie, size: 96, color: cs.onPrimaryContainer),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: cs.primaryContainer,
            alignment: Alignment.center,
            child: Icon(Icons.movie, size: 96, color: cs.onPrimaryContainer),
          ),
        ),
        // Gradient overlay so the title text in the SliverAppBar stays
        // legible regardless of the poster's brightness.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
