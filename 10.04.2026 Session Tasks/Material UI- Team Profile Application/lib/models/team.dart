// lib/models/team.dart
//
// A Team groups a name + description + list of TeamMembers. Also immutable.

import 'package:flutter/foundation.dart';
import 'team_member.dart';

@immutable
class Team {
  final String name;
  final String tagline;
  final String description;
  final List<TeamMember> members;

  const Team({
    required this.name,
    required this.tagline,
    required this.description,
    required this.members,
  });

  int get size => members.length;
}
