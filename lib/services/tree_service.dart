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
}
