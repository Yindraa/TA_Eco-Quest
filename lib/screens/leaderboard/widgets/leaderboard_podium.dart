import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/avatar_options.dart';
import '../../../core/theme.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<Map<String, dynamic>> topThree;
  final String currentUserId;

  const LeaderboardPodium({
    super.key,
    required this.topThree,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // #2 — slides in from left, delay 0
          Expanded(
            child: _PodiumColumn(
              entry: second,
              rank: 2,
              podiumHeight: 80,
              currentUserId: currentUserId,
            )
                .animate()
                .slideY(
                  begin: 0.5,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
          ),
          const SizedBox(width: 8),
          // #1 — tallest, slight delay for dramatic effect
          Expanded(
            child: _PodiumColumn(
              entry: first,
              rank: 1,
              podiumHeight: 108,
              currentUserId: currentUserId,
            )
                .animate(delay: 120.ms)
                .slideY(
                  begin: 0.6,
                  end: 0,
                  duration: 550.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
          ),
          const SizedBox(width: 8),
          // #3 — slides in from right, slight delay
          Expanded(
            child: _PodiumColumn(
              entry: third,
              rank: 3,
              podiumHeight: 60,
              currentUserId: currentUserId,
            )
                .animate(delay: 60.ms)
                .slideY(
                  begin: 0.5,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final Map<String, dynamic>? entry;
  final int rank;
  final double podiumHeight;
  final String currentUserId;

  const _PodiumColumn({
    required this.entry,
    required this.rank,
    required this.podiumHeight,
    required this.currentUserId,
  });

  Color get _podiumColor => switch (rank) {
        1 => const Color(0xFFF9C74F),
        2 => const Color(0xFFB0BEC5),
        _ => const Color(0xFFBCAAA4),
      };

  String get _medal => switch (rank) {
        1 => '🥇',
        2 => '🥈',
        _ => '🥉',
      };

  @override
  Widget build(BuildContext context) {
    if (entry == null) return const SizedBox();

    final name = entry!['full_name'] as String? ?? 'Pengguna';
    final points = (entry!['total_points'] as num?)?.toInt() ?? 0;
    final isMe = entry!['id'] == currentUserId;
    final avatarId = (entry!['avatar_id'] as num?)?.toInt() ?? 0;
    final firstName = name.split(' ').first;
    final avatarRadius = rank == 1 ? 28.0 : 22.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            buildAvatarWidget(
              avatarId: avatarId,
              radius: avatarRadius,
              borderColor: isMe
                  ? Colors.white
                  : _podiumColor.withValues(alpha: 0.6),
              borderWidth: isMe ? 2.5 : 1.5,
            ),
            if (isMe)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.lightGreenAccent[700],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(_medal, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          firstName,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2E2A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          '$points EXP',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: podiumHeight,
          decoration: BoxDecoration(
            color: _podiumColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: _podiumColor.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
