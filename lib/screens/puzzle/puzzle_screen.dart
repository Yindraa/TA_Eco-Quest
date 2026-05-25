import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../models/puzzle_model.dart';
import '../../services/puzzle_service.dart';
import 'widgets/puzzle_already_done.dart';
import 'widgets/puzzle_game_view.dart';
import 'widgets/puzzle_result_view.dart';
import 'widgets/puzzle_top_bar.dart';

enum _Phase { loading, alreadyDone, difficulty, playing, result }

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final _service = PuzzleService();

  _Phase _phase = _Phase.loading;
  int _chosenGridSize = 3;
  int _stars = 0;
  int _elapsedSeconds = 0;
  int _expEarned = 0;

  int _savedStars = 0;
  int _savedExp = 0;

  @override
  void initState() {
    super.initState();
    _checkDaily();
  }

  Future<void> _checkDaily() async {
    final attempt = await _service.getTodayAttempt();
    if (!mounted) return;
    if (attempt != null) {
      setState(() {
        _savedStars = (attempt['stars'] as num?)?.toInt() ?? 0;
        _savedExp = (attempt['exp_earned'] as num?)?.toInt() ?? 0;
        _phase = _Phase.alreadyDone;
      });
    } else {
      setState(() => _phase = _Phase.difficulty);
    }
  }

  Future<void> _onCompleted(int stars, int seconds) async {
    final result = await _service.submitPuzzle(
      stars: stars,
      gridSize: _chosenGridSize,
      seconds: seconds,
    );

    final exp =
        (result['exp_earned'] as num?)?.toInt() ??
        _service.calculateExp(stars, _chosenGridSize);

    homeRefreshNotifier.value++;

    if (!mounted) return;
    setState(() {
      _stars = stars;
      _elapsedSeconds = seconds;
      _expEarned = exp;
      _phase = _Phase.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _service.getTodayPuzzle();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F6),
      body: switch (_phase) {
        _Phase.loading => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),

        _Phase.alreadyDone => Column(
            children: [
              const PuzzleTopBar(),
              Expanded(
                child: PuzzleAlreadyDone(
                  stars: _savedStars,
                  expEarned: _savedExp,
                  puzzle: puzzle,
                ),
              ),
            ],
          ),

        _Phase.difficulty => Column(
            children: [
              const PuzzleTopBar(),
              Expanded(child: _buildDifficultyChooser(puzzle)),
            ],
          ),

        _Phase.playing => Column(
            children: [
              const PuzzleTopBar(showTimer: true),
              Expanded(
                child: PuzzleGameView(
                  puzzle: puzzle.copyWith(gridSize: _chosenGridSize),
                  onCompleted: _onCompleted,
                ),
              ),
            ],
          ),

        _Phase.result => Column(
            children: [
              const PuzzleTopBar(),
              Expanded(
                child: PuzzleResultView(
                  stars: _stars,
                  elapsedSeconds: _elapsedSeconds,
                  expEarned: _expEarned,
                  puzzle: puzzle.copyWith(gridSize: _chosenGridSize),
                  onClose: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
      },
    );
  }

  Widget _buildDifficultyChooser(PuzzleImage puzzle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        children: [
          // Thumbnail puzzle hari ini
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  puzzle.imagePath,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Text(
                    puzzle.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

          const SizedBox(height: 24),

          Text(
            'Pilih Tingkat Kesulitan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2E2A),
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 6),

          Text(
            'Semakin sulit, semakin banyak EXP yang kamu dapatkan!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 24),

          // Difficulty buttons
          ...[
            _DifficultyOption(
              label: 'Mudah',
              grid: '3×3',
              pieces: '9 potongan',
              expRange: 'hingga 40 EXP',
              icon: '🌱',
              color: const Color(0xFF27AE60),
              delay: 200,
              isSelected: _chosenGridSize == 3,
              onTap: () => setState(() => _chosenGridSize = 3),
            ),
            const SizedBox(height: 10),
            _DifficultyOption(
              label: 'Sedang',
              grid: '4×4',
              pieces: '16 potongan',
              expRange: 'hingga 50 EXP',
              icon: '🌿',
              color: const Color(0xFF2471A3),
              delay: 270,
              isSelected: _chosenGridSize == 4,
              onTap: () => setState(() => _chosenGridSize = 4),
            ),
            const SizedBox(height: 10),
            _DifficultyOption(
              label: 'Sulit',
              grid: '5×5',
              pieces: '25 potongan',
              expRange: 'hingga 65 EXP',
              icon: '🔥',
              color: const Color(0xFFE67E22),
              delay: 340,
              isSelected: _chosenGridSize == 5,
              onTap: () => setState(() => _chosenGridSize = 5),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _phase = _Phase.playing),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                'Mulai Puzzle  →',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

// ── Difficulty option card ──────────────────────────────────────────────────

class _DifficultyOption extends StatelessWidget {
  final String label;
  final String grid;
  final String pieces;
  final String expRange;
  final String icon;
  final Color color;
  final int delay;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.label,
    required this.grid,
    required this.pieces,
    required this.expRange,
    required this.icon,
    required this.color,
    required this.delay,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : const Color(0xFF1A2E2A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          grid,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$pieces  ·  $expRange',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 300.ms).slideY(begin: 0.15, end: 0);
  }
}
