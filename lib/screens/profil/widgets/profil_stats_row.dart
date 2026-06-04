import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/streak_utils.dart';
import '../../../models/user_model.dart';

class ProfilStatsRow extends StatelessWidget {
  final UserModel profile;
  final int reportsCount;

  const ProfilStatsRow({
    super.key,
    required this.profile,
    required this.reportsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.star_rounded,
            label: 'Total EXP',
            value: '${profile.totalPoints}',
            color: Colors.amber,
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            label: getStreakInfo(profile.currentStreak).label,
            value: '${profile.currentStreak} hari',
            color: getStreakInfo(profile.currentStreak).color,
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.flag_rounded,
            label: 'Laporan',
            value: '$reportsCount',
            color: const Color(0xFF2471A3),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2E2A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
