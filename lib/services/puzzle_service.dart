import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/puzzle_model.dart';

class PuzzleService {
  final _supabase = Supabase.instance.client;

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  // ── Puzzle data (hardcode; rotasi harian) ──────────────────────────────────

  static const List<PuzzleImage> _puzzles = [
    PuzzleImage(
      id: 'puzzle_1',
      title: 'Pantai Bersih Manado',
      imagePath: 'assets/puzzle/pantai_bersih.jpg',
      funFact:
          'Mangrove di pesisir Manado mampu menyerap karbon 5x lebih efektif '
          'dibanding hutan hujan tropis biasa.',
    ),
    PuzzleImage(
      id: 'puzzle_2',
      title: 'Daur Ulang Plastik',
      imagePath: 'assets/puzzle/daur_ulang.jpg',
      funFact:
          '1 ton plastik yang didaur ulang menghemat sekitar 7,4 m³ ruang '
          'tempat pembuangan akhir (TPA).',
    ),
    PuzzleImage(
      id: 'puzzle_3',
      title: 'Aksi Bersih Pantai',
      imagePath: 'assets/puzzle/bersih_pantai.jpg',
      funFact:
          'Sampah plastik membutuhkan 400–1000 tahun untuk terurai secara alami '
          'di lingkungan laut.',
    ),
  ];

  /// Puzzle untuk hari ini — rotasi berdasarkan hari dalam setahun.
  PuzzleImage getTodayPuzzle() {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _puzzles[dayOfYear % _puzzles.length];
  }

  // ── Supabase queries ───────────────────────────────────────────────────────

  /// Ambil attempt hari ini dari Supabase.
  /// Mengembalikan null jika belum bermain.
  Future<Map<String, dynamic>?> getTodayAttempt() async {
    try {
      return await _supabase
          .from('puzzle_attempts')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('puzzle_date', _today)
          .maybeSingle();
    } catch (e) {
      debugPrint('getTodayAttempt error: $e');
      return null;
    }
  }

  /// Submit hasil puzzle via RPC complete_puzzle.
  Future<Map<String, dynamic>> submitPuzzle({
    required int stars,
    required int gridSize,
    required int seconds,
  }) async {
    try {
      final puzzle = getTodayPuzzle();
      final raw = await _supabase.rpc('complete_puzzle', params: {
        'p_user_id':   _supabase.auth.currentUser!.id,
        'p_puzzle_id': puzzle.id,
        'p_grid_size': gridSize,
        'p_stars':     stars,
        'p_seconds':   seconds,
        'p_date':      _today,
      });

      if (raw is Map) return Map<String, dynamic>.from(raw);

      debugPrint('submitPuzzle: unexpected return type ${raw.runtimeType}');
      return {'exp_earned': calculateExp(stars, gridSize), 'success': false};
    } catch (e) {
      debugPrint('submitPuzzle error: $e');
      // Kembalikan EXP lokal agar result screen tetap tampil benar
      return {'exp_earned': calculateExp(stars, gridSize), 'success': false};
    }
  }

  // ── Kalkulasi lokal ────────────────────────────────────────────────────────

  /// EXP reward berdasarkan bintang DAN tingkat kesulitan (gridSize).
  /// Difficulty lebih tinggi → reward lebih besar.
  int calculateExp(int stars, int gridSize) {
    final (three, two, one) = switch (gridSize) {
      3 => (40, 25, 10), // Mudah  3×3
      4 => (50, 30, 15), // Sedang 4×4
      _ => (65, 40, 20), // Sulit  5×5
    };
    return switch (stars) {
      3 => three,
      2 => two,
      _ => one,
    };
  }

  int calculateStars(int seconds, int gridSize) {
    final thresholds = switch (gridSize) {
      3 => (60, 120),
      4 => (90, 180),
      _ => (120, 240),
    };
    if (seconds < thresholds.$1) return 3;
    if (seconds < thresholds.$2) return 2;
    return 1;
  }
}
