import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/puzzle_model.dart';

class PuzzleAlreadyDone extends StatelessWidget {
  final int stars;
  final int expEarned;
  final PuzzleImage puzzle;

  const PuzzleAlreadyDone({
    super.key,
    required this.stars,
    required this.expEarned,
    required this.puzzle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        children: [
          // Trophy icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🧩', style: TextStyle(fontSize: 40)),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 20),

          Text(
            'Puzzle Hari Ini\nSudah Selesai!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2E2A),
              height: 1.3,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < stars ? Colors.amber : Colors.grey[300],
                  size: 40,
                ),
              ),
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .scale(curve: Curves.elasticOut),

          const SizedBox(height: 8),

          Text(
            _starsLabel(stars),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 20),

          // EXP card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  '+$expEarned EXP diperoleh',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2, end: 0),

          const SizedBox(height: 28),

          // Fun fact card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Fakta Lingkungan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  puzzle.funFact,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF1A2E2A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

          const SizedBox(height: 28),

          Text(
            'Puzzle baru tersedia besok. Tetap semangat! 🌱',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ).animate(delay: 450.ms).fadeIn(),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }

  String _starsLabel(int s) => switch (s) {
        3 => 'Sempurna! Selesai sangat cepat 🚀',
        2 => 'Bagus! Hampir sempurna 👍',
        _ => 'Berhasil diselesaikan! 💪',
      };
}
