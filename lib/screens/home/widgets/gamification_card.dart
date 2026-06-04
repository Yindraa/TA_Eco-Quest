import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/streak_utils.dart';
import '../../../core/theme.dart';
import '../../../models/tree_model.dart';
import '../../../models/user_model.dart';

class GamificationCard extends StatelessWidget {
  final UserModel profile;
  final Future<TreeModel>? treeFuture;

  const GamificationCard({
    super.key,
    required this.profile,
    this.treeFuture,
  });

  @override
  Widget build(BuildContext context) {
    final info = getStreakInfo(profile.currentStreak);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D4F2E), Color(0xFF1A8A50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.eco_rounded,
                size: 90,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Baris atas: level + streak chip ──────────────────────
                Row(
                  children: [
                    _levelChip(),
                    const Spacer(),
                    _streakChip(info),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Nama level ───────────────────────────────────────────
                Text(
                  profile.levelName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                // ── EXP row ──────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.totalPoints} EXP',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    if (!profile.isMaxLevel)
                      Text(
                        '  ·  ${profile.pointsToNextLevel} EXP lagi ke level berikutnya',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── EXP progress bar ─────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: profile.levelProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    profile.isMaxLevel
                        ? '🎉 Level Tertinggi!'
                        : '${(profile.levelProgress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                // ── Streak section ───────────────────────────────────────
                if (profile.currentStreak > 0) ...[
                  const SizedBox(height: 14),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.15),
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  _streakSection(info),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Level chip ────────────────────────────────────────────────────────────

  Widget _levelChip() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.military_tech_rounded,
                color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              'Level ${profile.levelId}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  // ── Streak chip (atas) ────────────────────────────────────────────────────

  Widget _streakChip(StreakInfo info) {
    final emoji = _animatedEmoji(info.emoji, info.animLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: info.color.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: info.animLevel >= 2
            ? [
                BoxShadow(
                  color: info.color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          emoji,
          const SizedBox(width: 5),
          Text(
            '${profile.currentStreak} hari',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 1,
            height: 10,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: info.color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Streak section bawah (progress + danger) ──────────────────────────────

  Widget _streakSection(StreakInfo info) {
    final progress = getStreakProgress(profile.currentStreak);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${info.emoji}  Streak Harian',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const Spacer(),
            // Danger indicator dari tree data
            if (treeFuture != null)
              FutureBuilder<TreeModel>(
                future: treeFuture,
                builder: (context, snap) {
                  if (snap.data == null) return const SizedBox.shrink();
                  final notWateredYet = snap.data!.remainingWaterings == 2;
                  if (!notWateredYet) return const SizedBox.shrink();
                  return _dangerBadge();
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(info.color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          info.nextMilestoneDays == null
              ? '🏆 Streak maksimum tercapai!'
              : '${profile.currentStreak}/${info.nextMilestoneDays} hari menuju ${info.nextMilestoneLabel}',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  // ── Danger badge ──────────────────────────────────────────────────────────

  Widget _dangerBadge() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.red.withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 11),
            const SizedBox(width: 3),
            Text(
              'Siram hari ini!',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(duration: 700.ms, begin: 0.5);

  // ── Animated emoji ────────────────────────────────────────────────────────

  Widget _animatedEmoji(String emoji, int level) {
    final base = Text(emoji, style: const TextStyle(fontSize: 14));
    if (level == 0) return base;

    if (level == 1) {
      return base
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.25,
            duration: 1000.ms,
            curve: Curves.easeInOut,
          );
    }

    if (level == 2) {
      return base
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.35,
            duration: 700.ms,
            curve: Curves.easeInOut,
          )
          .shimmer(
            duration: 1200.ms,
            color: Colors.orangeAccent.withValues(alpha: 0.5),
          );
    }

    // Level 3 — Legenda
    return base
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.45,
          duration: 500.ms,
          curve: Curves.easeInOut,
        )
        .shimmer(
          duration: 800.ms,
          color: Colors.redAccent.withValues(alpha: 0.7),
        );
  }
}
