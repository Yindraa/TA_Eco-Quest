import 'package:flutter/material.dart';

class TreeModel {
  final String treeId;
  final String userId;
  final int treeLevel;
  final int nutritionPoints;
  final String healthStatus;
  final DateTime lastWateredAt;
  final int dailyWaterCount;
  final DateTime? dailyWaterDate;

  const TreeModel({
    required this.treeId,
    required this.userId,
    required this.treeLevel,
    required this.nutritionPoints,
    required this.healthStatus,
    required this.lastWateredAt,
    this.dailyWaterCount = 0,
    this.dailyWaterDate,
  });

  factory TreeModel.fromMap(Map<String, dynamic> map) {
    return TreeModel(
      treeId: map['tree_id'] as String,
      userId: map['user_id'] as String,
      treeLevel: map['tree_level'] as int? ?? 1,
      nutritionPoints: map['nutrition_points'] as int? ?? 0,
      healthStatus: map['health_status'] as String? ?? 'healthy',
      lastWateredAt: DateTime.tryParse(
            map['last_watered_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      dailyWaterCount:
          (map['daily_water_count'] as num?)?.toInt() ?? 0,
      dailyWaterDate: map['daily_water_date'] != null
          ? DateTime.tryParse(map['daily_water_date'] as String? ?? '')
          : null,
    );
  }

  /// Jumlah siraman yang tersisa hari ini (maks 2)
  int get remainingWaterings {
    if (dailyWaterDate == null) return 2;
    final todayUtc = DateTime.now().toUtc();
    final wDateUtc = dailyWaterDate!.toUtc();
    final sameDay = todayUtc.year == wDateUtc.year &&
        todayUtc.month == wDateUtc.month &&
        todayUtc.day == wDateUtc.day;
    return sameDay ? (2 - dailyWaterCount).clamp(0, 2) : 2;
  }

  // ── Level Info ───────────────────────────────────────────────────────────

  String get levelName => switch (treeLevel) {
        1 => 'Bibit',
        2 => 'Bibit Muda',
        3 => 'Pohon Muda',
        _ => 'Pohon Dewasa',
      };

  String get emoji => switch (treeLevel) {
        1 => '🌱',
        2 => '🪴',
        3 => '🌿',
        _ => '🌳',
      };

  bool get isMaxLevel => treeLevel >= 4;

  int get _minPoints => switch (treeLevel) {
        1 => 0,
        2 => 100,
        3 => 300,
        _ => 600,
      };

  int get _maxPoints => switch (treeLevel) {
        1 => 100,
        2 => 300,
        3 => 600,
        _ => 9999,
      };

  double get nutritionProgress {
    if (isMaxLevel) return 1.0;
    final range = _maxPoints - _minPoints;
    if (range <= 0) return 1.0;
    return ((nutritionPoints - _minPoints) / range).clamp(0.0, 1.0);
  }

  int get pointsToNextLevel {
    if (isMaxLevel) return 0;
    return _maxPoints - nutritionPoints;
  }

  // ── Health Info ──────────────────────────────────────────────────────────

  String get healthLabel => switch (healthStatus) {
        'healthy' => 'Sehat ✨',
        'normal'  => 'Normal',
        'wilting' => 'Layu 🥀',
        _         => 'Tidak Diketahui',
      };

  String get healthDescription => switch (healthStatus) {
        'healthy' => 'Pohonmu tumbuh subur! Terus jaga aktivitasmu.',
        'normal'  => 'Pohonmu membutuhkan lebih banyak perhatian.',
        'wilting' => 'Pohonmu sedang layu! Segera aktif hari ini.',
        _         => '-',
      };

  String get healthTip => switch (healthStatus) {
        'healthy' =>
          'Kamu sedang hebat! Pertahankan streak harianmu dan terus '
              'laporkan sampah untuk membuat pohon semakin besar.',
        'normal' =>
          'Laporan sampah yang tervalidasi akan menambah nutrisi pohonmu. '
              'Aktif setiap hari agar streak tidak putus!',
        'wilting' =>
          'Strekmu terputus dan pohonmu mulai layu. Buka app hari ini dan '
              'laporkan sampah untuk menyelamatkan pohonmu!',
        _ => '',
      };

  Color get healthColor => switch (healthStatus) {
        'healthy' => const Color(0xFF27AE60),
        'normal'  => const Color(0xFFF39C12),
        'wilting' => const Color(0xFFE74C3C),
        _         => Colors.grey,
      };

  List<Color> get healthGradient => switch (healthStatus) {
        'healthy' => [const Color(0xFF0D4F2E), const Color(0xFF1A8A50)],
        'normal'  => [const Color(0xFF7D5A00), const Color(0xFFD4A017)],
        'wilting' => [const Color(0xFF7B241C), const Color(0xFFC0392B)],
        _         => [Colors.grey.shade800, Colors.grey.shade600],
      };

  String timeAgoWatered() {
    final diff = DateTime.now().difference(lastWateredAt);
    if (diff.inDays > 0) return '${diff.inDays} hari yang lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam yang lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit yang lalu';
    return 'Baru saja';
  }
}
