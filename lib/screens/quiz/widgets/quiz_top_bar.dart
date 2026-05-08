import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class QuizTopBar extends StatelessWidget {
  final bool showProgress;
  final List<bool?> answerHistory; // null=belum, true=benar, false=salah
  final int currentIndex;
  final int totalQuestions;

  const QuizTopBar({
    super.key,
    this.showProgress = false,
    this.answerHistory = const [],
    this.currentIndex = 0,
    this.totalQuestions = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              Expanded(
                child: Text(
                  'Tantangan Harian 🧩',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: List.generate(totalQuestions, (i) {
                  final Color segColor;
                  final double height;

                  if (i < answerHistory.length && answerHistory[i] != null) {
                    // Answered
                    segColor = answerHistory[i]!
                        ? const Color(0xFF4DD97A) // hijau terang
                        : const Color(0xFFFF7070); // merah terang
                    height = 7;
                  } else if (i == currentIndex) {
                    // Soal sekarang
                    segColor = Colors.white;
                    height = 9;
                  } else {
                    // Belum
                    segColor = Colors.white.withValues(alpha: 0.3);
                    height = 7;
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: height,
                        decoration: BoxDecoration(
                          color: segColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: i == currentIndex
                              ? [
                                  BoxShadow(
                                    color:
                                        Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
