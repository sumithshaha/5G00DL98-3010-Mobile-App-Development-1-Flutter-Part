// lib/screens/team_profile_screen.dart
//
// The single screen of the app. Responsibilities:
//   - Holds a PageController for swipeable member navigation.
//   - Tracks _currentIndex so the prev/next arrows know where they are.
//   - Composes TeamHeader + PageView<MemberCard> + nav row + dot indicator.
//
// This is "Option 1: widget manages its own state" from Unit 3, slide 10:
// only this screen cares about which member is currently shown, so the
// state lives here, not higher up.

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/team.dart';
import '../utils/app_logger.dart';
import '../widgets/member_card.dart';
import '../widgets/platform_button.dart';
import '../widgets/team_header.dart';

class TeamProfileScreen extends StatefulWidget {
  final Team team;
  const TeamProfileScreen({super.key, required this.team});

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    log.d('TeamProfileScreen.initState — ${widget.team.size} members');
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    log.d('TeamProfileScreen.dispose — disposing PageController');
    _pageController.dispose();
    super.dispose();
  }

  // ───── navigation handlers ─────
  void _previous() {
    if (_currentIndex == 0) {
      log.w('Previous tapped at first member — ignoring');
      return;
    }
    log.i('Previous: $_currentIndex → ${_currentIndex - 1}');
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_currentIndex == widget.team.size - 1) {
      log.w('Next tapped at last member — ignoring');
      return;
    }
    log.i('Next: $_currentIndex → ${_currentIndex + 1}');
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
  // ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Profile'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About this team',
            onPressed: () => _showAboutSheet(context),
          ),
        ],
      ),

      // SafeArea keeps content out of notches and home-indicator zones.
      body: SafeArea(
        // SingleChildScrollView protects against content overflow on tiny
        // phones and on landscape orientation.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              TeamHeader(team: team),
              const SizedBox(height: 16),

              // ── Swipeable member cards ──
              // Use MediaQuery to size the PageView relative to screen height
              // so the card never gets squashed on small screens.
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.62,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: team.size,
                  onPageChanged: (i) {
                    setState(() => _currentIndex = i);
                    log.d('PageView swiped to index $i: ${team.members[i].name}');
                  },
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MemberCard(member: team.members[i]),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── Dot indicator ──
              SmoothPageIndicator(
                controller: _pageController,
                count: team.size,
                effect: WormEffect(
                  dotHeight: 9,
                  dotWidth: 9,
                  activeDotColor: theme.colorScheme.primary,
                  dotColor: theme.colorScheme.outlineVariant,
                ),
              ),

              const SizedBox(height: 12),

              // ── Prev / Next row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlatformIconButton(
                    icon: Icons.arrow_back_ios_new,
                    semanticLabel: 'Previous member',
                    onPressed: _currentIndex == 0 ? null : _previous,
                  ),
                  Text(
                    '${_currentIndex + 1} / ${team.size}',
                    style: theme.textTheme.titleMedium,
                  ),
                  PlatformIconButton(
                    icon: Icons.arrow_forward_ios,
                    semanticLabel: 'Next member',
                    primary: true,
                    onPressed:
                        _currentIndex == team.size - 1 ? null : _next,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // FAB jumps back to the first member — handy after browsing.
      floatingActionButton: _currentIndex == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                log.i('FAB: jump to first member');
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              },
              icon: const Icon(Icons.first_page),
              label: const Text('First'),
            ),
    );
  }

  // ───── About sheet ─────
  // Triggered from the AppBar's info icon. Demonstrates a third interaction
  // pattern (modal bottom sheet) and uses extra Material widgets
  // (ListTile, Divider).
  void _showAboutSheet(BuildContext context) {
    log.i('About sheet opened');
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.team.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(widget.team.description,
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              const Divider(),
              ...widget.team.members.map(
                (m) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(m.name),
                  subtitle: Text('${m.role} · ${m.homeCountry}'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
