import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/puzzle_model.dart';

class PuzzleResultView extends StatefulWidget {
  final int stars;
  final int elapsedSeconds;
  final int expEarned;
  final PuzzleImage puzzle;
  final VoidCallback onClose;

  const PuzzleResultView({
    super.key,
    required this.stars,
    required this.elapsedSeconds,
    required this.expEarned,
    required this.puzzle,
    required this.onClose,
  });

  @override
  State<PuzzleResultView> createState() => _PuzzleResultViewState();
}

class _PuzzleResultViewState extends State<PuzzleResultView> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _timeText {
    final m = widget.elapsedSeconds ~/ 60;
    final s = widget.elapsedSeconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Puzzle thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.puzzle.imagePath,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 20),

              Text(
                'Puzzle Selesai! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2E2A),
                ),
              ).animate(delay: 100.ms).fadeIn(),

              Text(
                widget.puzzle.title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ).animate(delay: 150.ms).fadeIn(),

              const SizedBox(height: 24),

              // Stars row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < widget.stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color:
                          i < widget.stars ? Colors.amber : Colors.grey[300],
                      size: 44,
                    ),
                  ),
                ),
              )
                  .animate(delay: 200.ms)
                  .scale(curve: Curves.elasticOut, duration: 500.ms),

              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip(Icons.timer_outlined, _timeText, 'Waktu'),
                  const SizedBox(width: 12),
                  _statChip(Icons.star_rounded, '${widget.stars}/3', 'Bintang'),
                ],
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              // EXP + Coins row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            '+${widget.expEarned}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text('EXP',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            '+${widget.expEarned}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                          Text('Eco Coins',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.amber[700])),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 350.ms).fadeIn().scale(curve: Curves.elasticOut),

              const SizedBox(height: 28),

              // Fun fact
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
                      widget.puzzle.funFact,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF1A2E2A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 420.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate(delay: 480.ms).fadeIn(),
            ],
          ),
        ),

        // Confetti
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          colors: const [
            Color(0xFF1A5C38),
            Colors.amber,
            Color(0xFF27AE60),
            Colors.orange,
            Colors.lightBlue,
          ],
          numberOfParticles: 30,
          gravity: 0.3,
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2E2A),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
