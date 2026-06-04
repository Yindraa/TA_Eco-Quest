import 'package:flutter/material.dart';

class StreakInfo {
  final String label;
  final String emoji;
  final Color color;
  final int currentMilestoneMin;
  final int? nextMilestoneDays;
  final int animLevel; // 0=none 1=slow pulse 2=medium 3=intense

  const StreakInfo({
    required this.label,
    required this.emoji,
    required this.color,
    required this.currentMilestoneMin,
    this.nextMilestoneDays,
    required this.animLevel,
  });

  String get nextMilestoneLabel {
    if (nextMilestoneDays == null) return 'Legenda';
    return getStreakInfo(nextMilestoneDays!).label;
  }
}

StreakInfo getStreakInfo(int streak) {
  if (streak >= 30) {
    return const StreakInfo(
      label: 'Legenda',
      emoji: '💥',
      color: Color(0xFFB71C1C),
      currentMilestoneMin: 30,
      nextMilestoneDays: null,
      animLevel: 3,
    );
  }
  if (streak >= 14) {
    return const StreakInfo(
      label: 'Pejuang',
      emoji: '🔥',
      color: Color(0xFFFF5722),
      currentMilestoneMin: 14,
      nextMilestoneDays: 30,
      animLevel: 2,
    );
  }
  if (streak >= 7) {
    return const StreakInfo(
      label: 'Berdedikasi',
      emoji: '🔥',
      color: Color(0xFFFF9800),
      currentMilestoneMin: 7,
      nextMilestoneDays: 14,
      animLevel: 2,
    );
  }
  if (streak >= 3) {
    return const StreakInfo(
      label: 'Konsisten',
      emoji: '🔥',
      color: Color(0xFFFFC107),
      currentMilestoneMin: 3,
      nextMilestoneDays: 7,
      animLevel: 1,
    );
  }
  return const StreakInfo(
    label: 'Baru Mulai',
    emoji: '🌱',
    color: Color(0xFF78909C),
    currentMilestoneMin: 0,
    nextMilestoneDays: 3,
    animLevel: 0,
  );
}

/// Progress (0.0–1.0) dari milestone saat ini ke berikutnya.
double getStreakProgress(int streak) {
  final info = getStreakInfo(streak);
  if (info.nextMilestoneDays == null) return 1.0;
  final range = info.nextMilestoneDays! - info.currentMilestoneMin;
  if (range <= 0) return 1.0;
  return ((streak - info.currentMilestoneMin) / range).clamp(0.0, 1.0);
}

/// Milestone-milestone yang memunculkan dialog perayaan.
const List<int> kStreakCelebrationDays = [3, 7, 14, 30];

/// Pesan perayaan per milestone.
String streakCelebrationMessage(int milestone) => switch (milestone) {
      3  => 'Awal yang luar biasa!\nKamu sudah aktif 3 hari berturut-turut.',
      7  => 'Satu minggu penuh!\nKonsistensimu benar-benar menginspirasi.',
      14 => 'Dua minggu tanpa henti!\nKamu sudah menjadi Pejuang sejati.',
      _  => 'Satu bulan penuh aktif!\nKamu telah mencapai status Legenda!',
    };

/// Gradient latar dialog perayaan per milestone.
List<Color> streakCelebrationGradient(int milestone) => switch (milestone) {
      3  => [const Color(0xFFE65100), const Color(0xFFFFA000)],
      7  => [const Color(0xFFBF360C), const Color(0xFFFF7043)],
      14 => [const Color(0xFF880E4F), const Color(0xFFE91E63)],
      _  => [const Color(0xFF4A148C), const Color(0xFF9C27B0)],
    };
