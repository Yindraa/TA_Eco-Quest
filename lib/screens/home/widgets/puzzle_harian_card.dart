import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../puzzle/puzzle_screen.dart';

class PuzzleHarianCard extends StatelessWidget {
  final Future<Map<String, dynamic>?> todayAttemptFuture;
  final bool compact;

  const PuzzleHarianCard({
    super.key,
    required this.todayAttemptFuture,
    this.compact = false,
  });

  void _openPuzzle(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PuzzleScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: todayAttemptFuture,
      builder: (context, snap) {
        final isDone = snap.data != null;
        final stars = (snap.data?['stars'] as num?)?.toInt() ?? 0;
        final exp = (snap.data?['exp_earned'] as num?)?.toInt() ?? 0;

        return compact
            ? _buildCompact(context, isDone, stars, exp)
            : _buildFull(context, isDone, stars, exp);
      },
    );
  }

  // ── Full-width (tampilan lama) ─────────────────────────────────────────────

  Widget _buildFull(
    BuildContext context,
    bool isDone,
    int stars,
    int exp,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _openPuzzle(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: _decoration(isDone),
          child: Row(
            children: [
              _iconBox(isDone ? '✅' : '🖼️'),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puzzle Harian',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDone
                          ? '${'⭐' * stars}  ·  +$exp EXP'
                          : 'Susun gambar lingkungan, raih hingga 50 EXP!',
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
                          value: stars / 3,
                          minHeight: 5,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _ctaChip(isDone ? 'Lihat' : 'Main'),
            ],
          ),
        ),
      ),
    );
  }

  // ── Compact (half-width, side-by-side) ────────────────────────────────────

  Widget _buildCompact(
    BuildContext context,
    bool isDone,
    int stars,
    int exp,
  ) {
    return GestureDetector(
      onTap: () => _openPuzzle(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _decoration(isDone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconBox(isDone ? '✅' : '🖼️', size: 44, iconSize: 22),
            const SizedBox(height: 12),
            Text(
              'Puzzle\nHarian',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isDone ? '+$exp EXP · ${'⭐' * stars}' : 'Susun gambar!',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            _ctaChip(isDone ? 'Lihat' : 'Main', fontSize: 11),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  BoxDecoration _decoration(bool isDone) => BoxDecoration(
        gradient: LinearGradient(
          colors: isDone
              ? [const Color(0xFF1A5C38), const Color(0xFF27AE60)]
              : [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDone
                    ? const Color(0xFF1A5C38)
                    : const Color(0xFF1565C0))
                .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  Widget _iconBox(String emoji, {double size = 52, double iconSize = 26}) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: iconSize)),
        ),
      );

  Widget _ctaChip(String label, {double fontSize = 12}) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize == 12 ? 12 : 10,
          vertical: fontSize == 12 ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
}
