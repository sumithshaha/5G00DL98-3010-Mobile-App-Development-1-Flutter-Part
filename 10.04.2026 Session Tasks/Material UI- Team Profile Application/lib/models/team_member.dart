// lib/models/team_member.dart
//
// Plain data class for one team member. Immutable — once a TeamMember is
// created it can't be mutated, which means I can hand the same instance to
// multiple widgets without worrying about anyone changing it underneath me.
//
// Marked with `@immutable` (via the `final` fields) so Flutter's analyzer
// helps catch accidental mutations.

import 'package:flutter/foundation.dart';

@immutable
class TeamMember {
  final String name;
  final String role;
  final String homeCountry;
  final String shortIntro;
  final String motto;
  final String imageAsset; // path under assets/images/

  /// Optional fun-facts list. Empty by default so the simple cases stay simple.
  final List<String> hobbies;

  const TeamMember({
    required this.name,
    required this.role,
    required this.homeCountry,
    required this.shortIntro,
    required this.motto,
    required this.imageAsset,
    this.hobbies = const <String>[],
  });

  @override
  String toString() => 'TeamMember($name, $role)';
}
