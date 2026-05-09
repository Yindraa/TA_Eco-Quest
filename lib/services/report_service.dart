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

  /// Ambil laporan pending + claimed untuk ditampilkan di peta misi.
  Future<List<Map<String, dynamic>>> getMissionReports() async {
    return await _supabase
        .from('reports')
        .select(
          'report_id, user_id, solver_id, latitude, longitude, '
          'waste_size, image_url, status, description, created_at',
        )
        .inFilter('status', ['pending', 'claimed'])
        .order('created_at', ascending: false);
  }

  /// Hitung total laporan milik user (untuk ProfilScreen).
  Future<int> getMyReportsCount() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('reports')
        .select('report_id')
        .eq('user_id', userId);
    return (data as List).length;
  }

  /// Ambil semua laporan milik user dengan filter status opsional.
  Future<List<Map<String, dynamic>>> getMyReports({
    String? status,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    const cols =
        'report_id, status, waste_size, created_at, '
        'image_url, resolved_image_url, description';
    if (status != null) {
      return await _supabase
          .from('reports')
          .select(cols)
          .eq('user_id', userId)
          .eq('status', status)
          .order('created_at', ascending: false);
    }
    return await _supabase
        .from('reports')
        .select(cols)
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  /// Ambil misi pending Kecil yang tersedia untuk diambil user.
  Future<List<Map<String, dynamic>>> getAvailableMissions({
    int limit = 3,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('reports')
        .select('report_id, waste_size, created_at, latitude, longitude')
        .eq('status', 'pending')
        .eq('waste_size', 'Kecil')
        .neq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
  }

  /// Ambil misi yang sedang aktif (diklaim) oleh user saat ini.
  Future<List<Map<String, dynamic>>> getMyActiveMissions() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('reports')
        .select(
          'report_id, waste_size, image_url, created_at, latitude, longitude',
        )
        .eq('solver_id', userId)
        .eq('status', 'claimed')
        .order('created_at', ascending: false)
        .limit(3);
  }

  /// Claim misi via RPC (atomic, bypass RLS, cek status=pending).
  Future<void> claimMission(String reportId) async {
    final raw = await _supabase.rpc(
      'claim_mission',
      params: {'p_report_id': reportId},
    );
    final result =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    if (result['success'] != true) {
      final msg = result['message'] as String? ?? '';
      throw Exception(switch (msg) {
        'already_claimed' => 'Misi ini sudah diklaim pengguna lain.',
        'own_report' => 'Kamu tidak bisa mengklaim laporan milikmu sendiri.',
        _ => 'Gagal mengambil misi. Coba lagi.',
      });
    }
  }

  /// Upload foto sesudah ke Supabase Storage.
  Future<String> uploadResolvedImage(Uint8List imageBytes) async {
    final userId = _supabase.auth.currentUser!.id;
    final fileName =
        'resolved/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage
        .from('report-images')
        .uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _supabase.storage.from('report-images').getPublicUrl(fileName);
  }

  /// Selesaikan misi via RPC (atomic, bypass RLS, cek solver=current user).
  /// EXP diberikan saat operator validasi, bukan di sini.
  Future<void> resolveReport({
    required String reportId,
    required String resolvedImageUrl,
  }) async {
    final raw = await _supabase.rpc(
      'resolve_mission',
      params: {
        'p_report_id': reportId,
        'p_resolved_image_url': resolvedImageUrl,
      },
    );
    final result =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    if (result['success'] != true) {
      throw Exception(
        'Gagal menyelesaikan misi. Pastikan misi masih aktif milikmu.',
      );
    }
  }
}
