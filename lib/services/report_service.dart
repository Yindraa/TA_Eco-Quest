import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final _supabase = Supabase.instance.client;

  /// Upload foto laporan ke Supabase Storage menggunakan bytes
  /// agar kompatibel di Android maupun web.
  Future<String> uploadImage(Uint8List imageBytes) async {
    final userId = _supabase.auth.currentUser!.id;
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage
        .from('report-images')
        .uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return _supabase.storage
        .from('report-images')
        .getPublicUrl(fileName);
  }

  Future<void> createReport({
    required double latitude,
    required double longitude,
    required String wasteSize,
    required String imageUrl,
    String? description,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('reports').insert({
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'waste_size': wasteSize,
      'image_url': imageUrl,
      'description': description,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getMyRecentReports({
    int limit = 5,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('reports')
        .select('report_id, status, waste_size, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
  }
}
