import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/tree_model.dart';

class PohonTipsCard extends StatelessWidget {
  final TreeModel tree;
  const PohonTipsCard({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tree.healthColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tree.healthColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tree.healthColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              switch (tree.healthStatus) {
                'healthy' => Icons.tips_and_updates_rounded,
                'wilting' => Icons.warning_rounded,
                _ => Icons.info_outline_rounded,
              },
              color: tree.healthColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (tree.healthStatus) {
                    'healthy' => 'Tips untuk Pohonmu',
                    'wilting' => '⚠️ Pohonmu Butuh Bantuan!',
                    _ => 'Perhatian',
                  },
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: tree.healthColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tree.healthTip,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 460.ms).slideY(begin: 0.1);
  }
}
