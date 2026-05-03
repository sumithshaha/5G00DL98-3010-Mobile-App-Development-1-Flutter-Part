// lib/widgets/team_header.dart
//
// Top section of the screen: team name, tagline, description, and a chip
// showing the member count. Stateless — the team is constant for the
// lifetime of the screen.

import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamHeader extends StatelessWidget {
  final Team team;

  const TeamHeader({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  team.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(
                avatar: Icon(Icons.group,
                    size: 16, color: cs.onPrimary),
                label: Text('${team.size} members'),
                backgroundColor: cs.primary,
                labelStyle: TextStyle(
                    color: cs.onPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            team.tagline,
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            team.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
