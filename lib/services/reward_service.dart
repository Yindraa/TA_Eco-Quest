import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reward_model.dart';

class RewardService {
  final _supabase = Supabase.instance.client;

  Future<List<RewardModel>> getRewards() async {
    final data = await _supabase
        .from('rewards')
        .select()
        .eq('is_active', true)
        .order('cost_coins');
    return (data as List).map((m) => RewardModel.fromMap(m)).toList();
  }

  Future<List<RedemptionModel>> getMyRedemptions() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('redemptions')
        .select('*, rewards(name, category)')
        .eq('user_id', userId)
        .order('redeemed_at', ascending: false);
    return (data as List).map((m) => RedemptionModel.fromMap(m)).toList();
  }

  /// Mengembalikan set reward_id yang sudah ditukarkan user (status != rejected).
  /// Dipakai untuk menonaktifkan tombol "Tukar" pada gelar yang sudah dimiliki.
  Future<Set<String>> getRedeemedIds() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('redemptions')
        .select('reward_id')
        .eq('user_id', userId)
        .neq('status', 'rejected');
    return (data as List).map((m) => m['reward_id'] as String).toSet();
  }

  Future<Map<String, dynamic>> redeemReward(String rewardId) async {
    try {
      final raw = await _supabase.rpc('redeem_reward', params: {
        'p_user_id': _supabase.auth.currentUser!.id,
        'p_reward_id': rewardId,
      });
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return {'success': false};
    } catch (e) {
      debugPrint('redeemReward error: $e');
      return {'success': false};
    }
  }
}
