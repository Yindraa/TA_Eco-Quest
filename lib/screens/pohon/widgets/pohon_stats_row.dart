import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/tree_model.dart';

class PohonStatsRow extends StatelessWidget {
  final TreeModel tree;
  const PohonStatsRow({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.eco_rounded,
          iconBg: AppColors.fieldFill,
          iconColor: AppColors.primary,
          label: 'Level Pohon',
          value: 'Level ${tree.treeLevel}',
          sub: tree.levelName,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.water_rounded,
          iconBg: const Color(0xFFEBF5FB),
          iconColor: const Color(0xFF2471A3),
          label: 'Terakhir Disiram',
          value: tree.timeAgoWatered(),
          sub: 'via laporan valid',
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 340.ms);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: Colors.grey[500])),
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
            Text(sub,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}
