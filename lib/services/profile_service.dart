import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<UserModel> getCurrentProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('profiles')
        .select('*, levels(level_name, min_points, max_points)')
        .eq('id', userId)
        .single();
    return UserModel.fromMap(data);
  }

  Future<void> recordDailyActivity() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.rpc(
      'record_daily_activity',
      params: {'user_uuid': userId},
    );
  }

  Future<void> updateFullName(String newName) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('profiles')
        .update({'full_name': newName})
        .eq('id', userId);
  }

  Future<void> updateAvatar(int avatarId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('profiles')
        .update({'avatar_id': avatarId})
        .eq('id', userId);
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
