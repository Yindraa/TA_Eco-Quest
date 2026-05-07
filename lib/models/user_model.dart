class UserModel {
  final String id;
  final String fullName;
  final String role;
  final int totalPoints;
  final int currentStreak;
  final int levelId;
  final String levelName;
  final int levelMinPoints;
  final int levelMaxPoints;
  final DateTime lastActivityAt;
  final int avatarId;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.totalPoints,
    required this.currentStreak,
    required this.levelId,
    required this.levelName,
    required this.levelMinPoints,
    required this.levelMaxPoints,
    required this.lastActivityAt,
    this.avatarId = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final levels = map['levels'] as Map<String, dynamic>?;
    return UserModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? 'Pengguna',
      role: map['role'] as String? ?? 'user',
      totalPoints: map['total_points'] as int? ?? 0,
      currentStreak: map['current_streak'] as int? ?? 0,
      levelId: map['level_id'] as int? ?? 1,
      levelName: levels?['level_name'] as String? ?? 'Eco Newbie',
      levelMinPoints: levels?['min_points'] as int? ?? 0,
      levelMaxPoints: levels?['max_points'] as int? ?? 99,
      lastActivityAt: DateTime.tryParse(
            map['last_activity_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      avatarId: (map['avatar_id'] as num?)?.toInt() ?? 0,
    );
  }

  String get firstName => fullName.split(' ').first;

  bool get isMaxLevel => levelMaxPoints >= 999999;

  double get levelProgress {
    if (isMaxLevel) return 1.0;
    final range = levelMaxPoints - levelMinPoints;
    if (range <= 0) return 1.0;
    return ((totalPoints - levelMinPoints) / range).clamp(0.0, 1.0);
  }

  int get pointsToNextLevel {
    if (isMaxLevel) return 0;
    return (levelMaxPoints + 1) - totalPoints;
  }
}
