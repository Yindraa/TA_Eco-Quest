import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../quiz/daily_quiz_screen.dart';

class TantanganHarianCard extends StatelessWidget {
  final Future<Map<String, dynamic>?> todayAttemptFuture;

  const TantanganHarianCard({super.key, required this.todayAttemptFuture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: todayAttemptFuture,
        builder: (context, snap) {
          final isDone = snap.data != null;
          final score =
              (snap.data?['score'] as num?)?.toInt() ?? 0;
          final total =
              (snap.data?['total_questions'] as num?)?.toInt() ?? 5;
          final exp =
              (snap.data?['exp_earned'] as num?)?.toInt() ?? 0;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DailyQuizScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDone
                      ? [
                          const Color(0xFF27AE60),
                          const Color(0xFF2ECC71),
                        ]
                      : [
                          const Color(0xFFF39C12),
                          const Color(0xFFE67E22),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDone
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFF39C12))
                        .withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon area
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        isDone ? '✅' : '🧩',
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tantangan Harian',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDone
                              ? 'Selesai · $score/$total benar · +$exp EXP'
                              : 'Jawab 5 soal, raih hingga 50 EXP!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        if (isDone) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score / total,
                              minHeight: 5,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // CTA
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isDone ? 'Lihat' : 'Mulai',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
