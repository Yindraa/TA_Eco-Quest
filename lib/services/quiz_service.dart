import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final _supabase = Supabase.instance.client;

  // Gunakan tanggal lokal device agar konsisten dengan query
  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  Future<bool> hasCompletedToday() async {
    try {
      final result = await _supabase
          .from('daily_quiz_attempts')
          .select('attempt_id')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('quiz_date', _today)
          .maybeSingle();
      return result != null;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTodayAttempt() async {
    try {
      return await _supabase
          .from('daily_quiz_attempts')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('quiz_date', _today)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    final all = await _supabase.from('quiz_questions').select();
    final list = List<Map<String, dynamic>>.from(all)..shuffle();
    return list.take(5).toList();
  }

  Future<Map<String, dynamic>> submitQuiz({
    required int score,
    required int total,
  }) async {
    try {
      final raw = await _supabase.rpc('complete_daily_quiz', params: {
        'p_user_id': _supabase.auth.currentUser!.id,
        'p_score': score,
        'p_total': total,
        'p_date': _today, // kirim tanggal dari client
      });

      if (raw is Map) return Map<String, dynamic>.from(raw);

      // Fallback jika Supabase mengembalikan tipe tak terduga
      debugPrint('submitQuiz: unexpected return type ${raw.runtimeType}');
      return {'exp_earned': 0, 'success': false};
    } catch (e) {
      debugPrint('submitQuiz error: $e');
      return {'exp_earned': 0, 'success': false};
    }
  }
}
