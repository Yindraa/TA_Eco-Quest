import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpTransaction {
  final int id;
  final String source;
  final String sourceLabel;
  final int expAmount;
  final DateTime createdAt;

  const ExpTransaction({
    required this.id,
    required this.source,
    required this.sourceLabel,
    required this.expAmount,
    required this.createdAt,
  });

  factory ExpTransaction.fromMap(Map<String, dynamic> map) => ExpTransaction(
        id: (map['id'] as num).toInt(),
        source: map['source'] as String,
        sourceLabel: map['source_label'] as String,
        expAmount: (map['exp_amount'] as num).toInt(),
        createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      );
}

class ExpService {
  final _supabase = Supabase.instance.client;

  Future<List<ExpTransaction>> getHistory({int limit = 50}) async {
    try {
      final rows = await _supabase
          .from('exp_transactions')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).map((r) => ExpTransaction.fromMap(r)).toList();
    } catch (e) {
      debugPrint('ExpService.getHistory error: $e');
      return [];
    }
  }
}
