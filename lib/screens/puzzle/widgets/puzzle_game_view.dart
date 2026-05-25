import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/puzzle_model.dart';
import '../../../services/puzzle_service.dart';

class PuzzleGameView extends StatefulWidget {
  final PuzzleImage puzzle;
  final void Function(int stars, int elapsedSeconds) onCompleted;

  const PuzzleGameView({
    super.key,
    required this.puzzle,
    required this.onCompleted,
  });

  @override
  State<PuzzleGameView> createState() => _PuzzleGameViewState();
}

class _PuzzleGameViewState extends State<PuzzleGameView> {
  ui.Image? _image;
  bool _loading = true;
  List<int> _order = [];
  int _elapsedSeconds = 0;
  bool _showPreview = false;
  bool _solved = false;
  Timer? _timer;
  int _previewUsed = 0;
  static const _maxPreview = 3;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final data = await rootBundle.load(widget.puzzle.imagePath);
    final bytes = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    final image = await completer.future;

    final n = widget.puzzle.pieceCount;
    final order = List.generate(n, (i) => i)..shuffle();

    if (!mounted) return;
    setState(() {
      _image = image;
      _order = order;
      _loading = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _elapsedSeconds++);
    });
  }

  void _swap(int fromPos, int toPos) {
    if (fromPos == toPos || _solved) return;
    HapticFeedback.selectionClick();
    setState(() {
      final temp = _order[fromPos];
      _order[fromPos] = _order[toPos];
      _order[toPos] = temp;
    });
    _checkWin();
  }

  void _checkWin() {
    for (int i = 0; i < _order.length; i++) {
      if (_order[i] != i) return;
    }
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() => _solved = true);

    final stars = PuzzleService().calculateStars(
      _elapsedSeconds,
      widget.puzzle.gridSize,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) widget.onCompleted(stars, _elapsedSeconds);
    });
  }

  void _togglePreview() {
    if (_previewUsed >= _maxPreview && !_showPreview) return;
    setState(() {
      _showPreview = !_showPreview;
      if (_showPreview) _previewUsed++;
    });
    if (_showPreview) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showPreview) setState(() => _showPreview = false);
      });
    }
  }

  String get _timerText {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final gridSize = widget.puzzle.gridSize;
    final boardSize = MediaQuery.of(context).size.width - 40;
    final pieceSize = boardSize / gridSize;

    return Stack(
      children: [
        Column(
          children: [
            // Controls row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  // Timer chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timerText,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Preview button
                  GestureDetector(
                    onTap: _togglePreview,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _previewUsed >= _maxPreview
                            ? Colors.grey[200]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: _previewUsed >= _maxPreview
                                ? Colors.grey
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Lihat (${_maxPreview - _previewUsed}x)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _previewUsed >= _maxPreview
                                  ? Colors.grey
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title + grid info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.puzzle.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E2A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$gridSize×$gridSize  ·  ${_order.where((v) => _order.indexOf(v) == v).length}/${_order.length} benar',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Puzzle board — AnimatedContainer untuk glow saat selesai (Step 5)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: boardSize,
                height: boardSize,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_solved ? 16 : 0),
                  boxShadow: _solved
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ]
                      : [],
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemCount: _order.length,
                  itemBuilder: (context, position) {
                    final pieceIndex = _order[position];
                    final isCorrect = pieceIndex == position;

                    return DragTarget<int>(
                      onAcceptWithDetails: (details) => _swap(details.data, position),
                      builder: (ctx, candidateData, _) {
                        final isHighlighted = candidateData.isNotEmpty;
                        // Step 4: extract piece widget untuk snap animation
                        Widget pieceChild = AnimatedContainer(
                          key: ValueKey('piece_${position}_$pieceIndex'),
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isHighlighted
                                  ? AppColors.primary
                                  : isCorrect
                                      ? AppColors.primary.withValues(
                                          alpha: 0.4,
                                        )
                                      : Colors.white,
                              width: isHighlighted
                                  ? 2.5
                                  : isCorrect
                                      ? 1.5
                                      : 1.0,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _PiecePainter(
                                    image: _image!,
                                    pieceIndex: pieceIndex,
                                    gridSize: gridSize,
                                  ),
                                ),
                              ),
                              if (isCorrect)
                                Positioned(
                                  right: 3,
                                  top: 3,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                        // Bounce animation saat piece masuk posisi benar
                        if (isCorrect) {
                          pieceChild = pieceChild
                              .animate()
                              .scale(
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(1.0, 1.0),
                                duration: 350.ms,
                                curve: Curves.elasticOut,
                              );
                        }
                        return Draggable<int>(
                          data: position,
                          maxSimultaneousDrags: _solved ? 0 : 1,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: pieceSize,
                              height: pieceSize,
                              child: CustomPaint(
                                painter: _PiecePainter(
                                  image: _image!,
                                  pieceIndex: pieceIndex,
                                  gridSize: gridSize,
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: pieceChild,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        // Preview overlay
        if (_showPreview)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showPreview = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.puzzle.imagePath,
                          width: boardSize,
                          height: boardSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ketuk untuk tutup · Hilang otomatis dalam 3 detik',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PiecePainter extends CustomPainter {
  final ui.Image image;
  final int pieceIndex;
  final int gridSize;

  const _PiecePainter({
    required this.image,
    required this.pieceIndex,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pW = image.width.toDouble() / gridSize;
    final pH = image.height.toDouble() / gridSize;
    final col = pieceIndex % gridSize;
    final row = pieceIndex ~/ gridSize;

    final src = Rect.fromLTWH(col * pW, row * pH, pW, pH);
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_PiecePainter old) =>
      old.pieceIndex != pieceIndex || old.image != image;
}
