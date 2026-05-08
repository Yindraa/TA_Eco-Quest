import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tree_model.dart';

class TreeService {
  final _supabase = Supabase.instance.client;

  Future<TreeModel> getMyTree() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('virtual_trees')
        .select()
        .eq('user_id', userId)
        .single();
    return TreeModel.fromMap(data);
  }

  Future<Map<String, dynamic>> waterTree() async {
    final userId = _supabase.auth.currentUser!.id;
    // Kirim tanggal UTC agar konsisten dengan DATE() di PostgreSQL
    final todayUtc =
        DateTime.now().toUtc().toIso8601String().substring(0, 10);
    try {
      final raw = await _supabase.rpc('water_my_tree', params: {
        'p_user_id': userId,
        'p_date': todayUtc,
      });
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return {'success': false};
    } catch (e) {
      debugPrint('waterTree error: $e');
      return {'success': false};
    }
  }
}
