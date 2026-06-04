import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tree_model.dart';

class TreeService {
  final _supabase = Supabase.instance.client;

  Future<TreeModel> getMyTree() async {
    final userId = _supabase.auth.currentUser!.id;

    // Coba ambil pohon yang ada
    final existing = await _supabase
        .from('virtual_trees')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) return TreeModel.fromMap(existing);

    // Fallback: buat pohon baru jika trigger DB belum jalan
    await _supabase.from('virtual_trees').insert({
      'user_id': userId,
      'tree_level': 1,
      'nutrition_points': 0,
      'health_status': 'healthy',
      'last_watered_at': DateTime.now().toIso8601String(),
    });

    final created = await _supabase
        .from('virtual_trees')
        .select()
        .eq('user_id', userId)
        .single();
    return TreeModel.fromMap(created);
  }

  /// Terapkan decay harian (idempotent — aman dipanggil tiap buka screen).
  Future<void> applyDecay() async {
    final userId = _supabase.auth.currentUser!.id;
    try {
      await _supabase
          .rpc('apply_tree_decay', params: {'p_user_id': userId});
    } catch (e) {
      debugPrint('applyDecay error: $e');
    }
  }

  /// Cek apakah user sudah menyiram pohon hari ini.
  Future<bool> hasWateredToday() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return true; // jangan tampilkan reminder jika belum login
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    try {
      final row = await _supabase
          .from('virtual_trees')
          .select('daily_water_date, daily_water_count')
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) return false;
      final waterDate = row['daily_water_date'] as String?;
      final waterCount = (row['daily_water_count'] as num?)?.toInt() ?? 0;
      return waterDate == today && waterCount > 0;
    } catch (e) {
      debugPrint('hasWateredToday error: $e');
      return true; // gagal cek → tidak tampilkan reminder
    }
  }

  /// Siram pohon. [currentStreak] dipakai untuk streak bonus (+25 jika ≥3).
  Future<Map<String, dynamic>> waterTree({int currentStreak = 0}) async {
    final userId = _supabase.auth.currentUser!.id;
    final todayUtc =
        DateTime.now().toUtc().toIso8601String().substring(0, 10);
    try {
      final raw = await _supabase.rpc('water_my_tree', params: {
        'p_user_id': userId,
        'p_date': todayUtc,
        'p_streak': currentStreak,
      });
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return {'success': false};
    } catch (e) {
      debugPrint('waterTree error: $e');
      return {'success': false};
    }
  }
}
