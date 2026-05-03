// lib/widgets/member_card.dart
//
// Pure-display widget for a single TeamMember. Stateless — the parent
// (TeamProfileScreen) decides which member to show and passes it in.
//
// This follows the "Option 2: parent manages the state" pattern from the
// previous unit (Stateful and Stateless Widgets, slide 11). The card
// itself owns no state; it just renders what it's given.

import 'package:flutter/material.dart';
import '../models/team_member.dart';

class MemberCard extends StatelessWidget {
  final TeamMember member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      // Material 3 elevation.
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ───────── Photo ─────────
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _MemberPhoto(asset: member.imageAsset),
              ),
            ),
            const SizedBox(height: 16),

            // ───────── Name ─────────
            Text(member.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),

            // ───────── Role chip + country ─────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  avatar: Icon(Icons.work_outline,
                      size: 16, color: cs.onSecondaryContainer),
                  label: Text(member.role),
                  backgroundColor: cs.secondaryContainer,
                  labelStyle: TextStyle(color: cs.onSecondaryContainer),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public, size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(member.homeCountry,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ───────── Short intro ─────────
            Text(member.shortIntro, style: theme.textTheme.bodyMedium),

            // ───────── Hobbies (only if present) ─────────
            if (member.hobbies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: member.hobbies
                    .map((h) => Chip(
                          label: Text(h),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],

            // ───────── Motto ─────────
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote, size: 18, color: cs.tertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.motto,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: cs.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny helper that loads the asset image and falls back to an avatar icon
/// if the file isn't there yet (so the app still runs before you've added
/// real photos to assets/images/).
class _MemberPhoto extends StatelessWidget {
  final String asset;
  const _MemberPhoto({required this.asset});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return Container(
          color: cs.primaryContainer,
          alignment: Alignment.center,
          child: Icon(
            Icons.person_outline,
            size: 80,
            color: cs.onPrimaryContainer,
          ),
        );
      },
    );
  }
}
