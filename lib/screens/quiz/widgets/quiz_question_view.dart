import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class QuizQuestionView extends StatelessWidget {
  final Map<String, dynamic> question;
  final int currentIndex;
  final int totalQuestions;
  final int score;
  final int comboCount;
  final String? selectedAnswer;
  final bool answered;
  final ValueChanged<String> onSelectAnswer;
  final VoidCallback onNext;

  const QuizQuestionView({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.score,
    required this.comboCount,
    required this.selectedAnswer,
    required this.answered,
    required this.onSelectAnswer,
    required this.onNext,
  });

  String get _correct => question['correct_answer'] as String? ?? 'A';
  bool get _isLastQuestion => currentIndex + 1 >= totalQuestions;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('A', question['option_a'] as String? ?? ''),
      ('B', question['option_b'] as String? ?? ''),
      ('C', question['option_c'] as String? ?? ''),
      ('D', question['option_d'] as String? ?? ''),
    ];

    return Stack(
      children: [
        // ── Floating particle background ─────────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.09,
              child: Stack(
                children: [
                  Positioned(
                    top: 55,
                    left: 14,
                    child: _Particle('🌿', 24, 0, 3600),
                  ),
                  Positioned(
                    top: 130,
                    right: 20,
                    child: _Particle('🌱', 18, 400, 4200),
                  ),
                  Positioned(
                    top: 230,
                    left: 8,
                    child: _Particle('♻️', 22, 200, 3800),
                  ),
                  Positioned(
                    top: 340,
                    right: 16,
                    child: _Particle('🌍', 26, 700, 4500),
                  ),
                  Positioned(
                    top: 440,
                    left: 28,
                    child: _Particle('💚', 16, 100, 3300),
                  ),
                  Positioned(
                    top: 510,
                    right: 26,
                    child: _Particle('🌿', 14, 900, 4000),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Foreground content ────────────────────────────────────────────
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Counter + combo + score row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fieldFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Soal ${currentIndex + 1} / $totalQuestions',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (comboCount >= 2)
                    _ComboBadge(key: ValueKey(comboCount), count: comboCount)
                  else
                    Text(
                      '$score benar',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Question card with category badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryBadge(category: question['category'] as String?),
                    const SizedBox(height: 12),
                    Text(
                      question['question'] as String? ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E2A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Options
              ...options.map(
                (opt) => _OptionCard(
                  letter: opt.$1,
                  text: opt.$2,
                  correct: _correct,
                  selected: selectedAnswer,
                  answered: answered,
                  onTap: answered ? null : () => onSelectAnswer(opt.$1),
                ),
              ),

              // Explanation + Next (after answering)
              if (answered) ...[
                const SizedBox(height: 16),
                _ExplanationCard(
                  explanation: question['explanation'] as String? ?? '',
                  ecoFact: question['eco_fact'] as String? ?? '',
                  isCorrect: selectedAnswer == _correct,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isLastQuestion ? 'Lihat Hasil  →' : 'Lanjut  →',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Floating particle ────────────────────────────────────────────────────────

class _Particle extends StatelessWidget {
  final String emoji;
  final double size;
  final int delayMs;
  final int durationMs;

  const _Particle(this.emoji, this.size, this.delayMs, this.durationMs);

  @override
  Widget build(BuildContext context) {
    return Text(emoji, style: TextStyle(fontSize: size))
        .animate(delay: delayMs.ms, onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -10,
          duration: durationMs.ms,
          curve: Curves.easeInOut,
        );
  }
}

// ─── Category badge ───────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String? category;
  const _CategoryBadge({required this.category});

  ({String label, Color color, String emoji}) get _info => switch (category ??
      'general') {
    'pilah_sampah' => (
      label: 'Pilah Sampah',
      color: const Color(0xFF1A5C38),
      emoji: '🗂️',
    ),
    'lingkungan' => (
      label: 'Lingkungan',
      color: const Color(0xFF2471A3),
      emoji: '🌍',
    ),
    'daur_ulang' => (
      label: 'Daur Ulang',
      color: const Color(0xFF16A085),
      emoji: '♻️',
    ),
    'b3' => (
      label: 'B3 Berbahaya',
      color: const Color(0xFFE74C3C),
      emoji: '⚠️',
    ),
    'lokal' => (label: 'Lokal', color: const Color(0xFF8E44AD), emoji: '📍'),
    _ => (label: 'Umum', color: Colors.grey, emoji: '📚'),
  };

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
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
}

// ─── Combo badge ──────────────────────────────────────────────────────────────

class _ComboBadge extends StatelessWidget {
  final int count;
  const _ComboBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                '${count}x Combo!',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 200.ms);
  }
}

// ─── Option card ──────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final String letter;
  final String text;
  final String correct;
  final String? selected;
  final bool answered;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.letter,
    required this.text,
    required this.correct,
    required this.selected,
    required this.answered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == letter;
    final isCorrect = letter == correct;

    Color bg = Colors.white;
    Color border = Colors.grey[300]!;
    Color letterBg = Colors.grey[200]!;
    Color letterFg = Colors.grey[600]!;
    Widget? trailing;

    if (answered) {
      if (isCorrect) {
        bg = const Color(0xFFE8F8F1);
        border = const Color(0xFF27AE60);
        letterBg = const Color(0xFF27AE60);
        letterFg = Colors.white;
        trailing = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF27AE60),
          size: 22,
        );
      } else if (isSelected) {
        bg = const Color(0xFFFEEBEA);
        border = const Color(0xFFE74C3C);
        letterBg = const Color(0xFFE74C3C);
        letterFg = Colors.white;
        trailing = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFE74C3C),
          size: 22,
        );
      }
    } else if (isSelected) {
      bg = AppColors.fieldFill;
      border = AppColors.primary;
      letterBg = AppColors.primary;
      letterFg = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: letterBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: letterFg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E2A),
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }
}

// ─── Explanation card ─────────────────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  final String explanation;
  final String ecoFact;
  final bool isCorrect;

  const _ExplanationCard({
    required this.explanation,
    required this.ecoFact,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Answer verdict + explanation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? const Color(0xFFE8F8F1)
                : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCorrect
                  ? const Color(0xFF27AE60).withValues(alpha: 0.4)
                  : Colors.orange.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCorrect ? '✅' : '💡',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect ? 'Benar!' : 'Jawabannya salah',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? const Color(0xFF27AE60)
                            : Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      explanation,
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
        ),
        // Eco fact teaser
        if (ecoFact.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2471A3).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌎', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ecoFact,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF2471A3),
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}
