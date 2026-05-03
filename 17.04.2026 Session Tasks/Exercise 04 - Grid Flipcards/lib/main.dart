// lib/main.dart
//
// GridView Exercise / Demo — Flip Card Grid
//
// What I'm building: a 3-column GridView where every cell is a card that
// flips when tapped. Face-down side shows "Tap to flip"; face-up side shows
// an avatar (or a placeholder icon if the asset image is missing).
//
// The flip itself is a 3D rotation around the Y axis. I do it with a
// TweenAnimationBuilder driving a Matrix4 rotateY transform — that's the
// most idiomatic way in pure Flutter without pulling in an extra package
// like flip_card. Drop in real avatar JPGs at assets/images/avatar1.jpg
// through avatar12.jpg to see the full demo; missing files fall back to
// a colorful gradient + person icon so the app runs out of the box.

import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const FlipGridApp());

class FlipGridApp extends StatelessWidget {
  const FlipGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flip Card Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const FlipGridScreen(),
    );
  }
}

class FlipGridScreen extends StatefulWidget {
  const FlipGridScreen({super.key});

  @override
  State<FlipGridScreen> createState() => _FlipGridScreenState();
}

class _FlipGridScreenState extends State<FlipGridScreen> {
  // 12 cards, indexed 0..11. We track which ones are currently flipped.
  // Using a Set<int> instead of List<bool> because membership testing
  // is what we actually do, and it makes "reset all" a one-liner.
  final Set<int> _flipped = {};

  static const int _cardCount = 12;

  void _toggleCard(int index) {
    setState(() {
      if (_flipped.contains(index)) {
        _flipped.remove(index);
      } else {
        _flipped.add(index);
      }
    });
  }

  void _resetAll() => setState(_flipped.clear);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Card Grid'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Reset all cards',
            icon: const Icon(Icons.refresh),
            onPressed: _resetAll,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        // GridView.builder builds children lazily — same memory-efficiency
        // story as ListView.builder, but with a 2D delegate.
        child: GridView.builder(
          itemCount: _cardCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,        // 3 columns
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,    // slightly taller than square
          ),
          itemBuilder: (context, index) {
            return FlipCard(
              isFlipped: _flipped.contains(index),
              onTap: () => _toggleCard(index),
              // 1-based filenames feel more natural in assets/.
              imageAsset: 'assets/images/avatar${index + 1}.jpg',
              cardNumber: index + 1,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────── Flip Card ───────────────────────────
// Encapsulates the flip animation. Stateless because the flipped/not-flipped
// decision is owned by the parent (Option 2 from Unit 3 — parent manages
// state). This makes "Reset all" trivial: clear the parent's set, every
// card rebuilds with isFlipped=false.

class FlipCard extends StatelessWidget {
  final bool isFlipped;
  final VoidCallback onTap;
  final String imageAsset;
  final int cardNumber;

  const FlipCard({
    super.key,
    required this.isFlipped,
    required this.onTap,
    required this.imageAsset,
    required this.cardNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // TweenAnimationBuilder watches `end` and animates from the previous
      // value whenever it changes. Tapping flips isFlipped, which flips
      // `end` between 0 and pi, and Flutter handles the in-between frames.
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: isFlipped ? math.pi : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
        builder: (context, angle, _) {
          // At angle > pi/2 we've crossed the halfway point and should
          // be looking at the back of the card. Show the avatar then.
          final showFront = angle <= math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            // Matrix4.identity().rotateY rotates around the Y axis.
            // setEntry(3, 2, 0.001) adds a touch of perspective so the
            // rotation looks 3D rather than a flat scale.
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? _CardBack(number: cardNumber)
                // Back side is rotated 180° so its content reads
                // right-side-up after the parent rotation.
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFront(imageAsset: imageAsset),
                  ),
          );
        },
      ),
    );
  }
}

// "Tap to flip" face. Calling it _CardBack because it's what you see
// before flipping — the back of a real-world card.
class _CardBack extends StatelessWidget {
  final int number;
  const _CardBack({required this.number});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primaryContainer],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap to flip',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '#$number',
              style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// Avatar face. Falls back to a gradient + person icon if the asset is
// missing, so the demo runs without pre-supplied images.
class _CardFront extends StatelessWidget {
  final String imageAsset;
  const _CardFront({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.tertiaryContainer, cs.secondaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.person, size: 56, color: cs.onSecondaryContainer),
        ),
      ),
    );
  }
}
