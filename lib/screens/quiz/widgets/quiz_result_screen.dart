import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int expEarned;
  final bool alreadyCompletedBeforeStart;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.expEarned,
    required this.alreadyCompletedBeforeStart,
  });

  @override
  Widget build(BuildContext context) {
    final isPerfect = score == total;
    final isGood = score >= (total * 0.6).ceil();

    final (emoji, title, subtitle) = isPerfect
        ? ('🏆', 'Sempurna!', 'Luar biasa! Semua jawaban benar!')
        : isGood
            ? ('🎉', 'Bagus!', 'Kamu hampir sempurna!')
            : ('💪', 'Terus Berlatih!', 'Setiap hari makin pintar!');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 80))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2E2A),
            ),
          ).animate().fadeIn(delay: 200.ms),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 28),

          // Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '$score / $total',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'jawaban benar',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: score / total,
                  minHeight: 10,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPerfect
                        ? Colors.amber
                        : isGood
                            ? AppColors.primary
                            : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          if (expEarned > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: Colors.amber, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    '+$expEarned EXP diperoleh!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOutBack),

          if (alreadyCompletedBeforeStart)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'EXP hanya diberikan satu kali per hari',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[500]),
              ),
            ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
}
