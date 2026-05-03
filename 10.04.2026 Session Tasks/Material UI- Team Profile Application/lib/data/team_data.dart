// lib/data/team_data.dart
//
// ╔══════════════════════════════════════════════════════════════════════╗
// ║  REPLACE THE CONTENT BELOW WITH YOUR ACTUAL TEAM INFORMATION        ║
// ║                                                                      ║
// ║  Drop each member's photo into  assets/images/  and update the      ║
// ║  imageAsset path. If you don't have photos yet, leave the placeholder║
// ║  paths — the MemberCard widget falls back to an avatar icon when an ║
// ║  asset is missing, so the app still runs.                            ║
// ╚══════════════════════════════════════════════════════════════════════╝

import '../models/team.dart';
import '../models/team_member.dart';

const Team teamAurora = Team(
  name: 'Team Aurora',
  tagline: 'Built across borders.',
  description:
      'A small cross-border crew from TAMK (Tampere) and THWS (Würzburg) '
      'building cross-platform mobile apps in Flutter. We meet weekly on '
      'Teams and ship in two-week iterations.',
  members: <TeamMember>[
    TeamMember(
      name: 'Sumith Shaha',
      role: 'Mobile & Backend',
      homeCountry: 'Bangladesh → Finland',
      shortIntro:
          'Final-year Software Engineering student at TAMK. '
          'Likes Flutter, Riverpod, and quiet early mornings.',
      motto: 'Ship small, ship often.',
      imageAsset: 'assets/images/sumith.jpg',
      hobbies: ['Cycling', 'Coffee', 'Reading non-fiction'],
    ),
    TeamMember(
      name: 'Member Two',
      role: 'UI / UX',
      homeCountry: 'Germany',
      shortIntro:
          'THWS student focused on interaction design. '
          'Cares deeply about empty space and font pairings.',
      motto: 'Design is how it works.',
      imageAsset: 'assets/images/member2.jpg',
      hobbies: ['Sketching', 'Photography'],
    ),
    TeamMember(
      name: 'Member Three',
      role: 'Backend & QA',
      homeCountry: 'Germany',
      shortIntro:
          'THWS student who keeps the build green and the tests honest.',
      motto: 'If it isn\'t tested, it\'s broken.',
      imageAsset: 'assets/images/member3.jpg',
      hobbies: ['Hiking', 'Board games', 'Open-source'],
    ),
  ],
);
