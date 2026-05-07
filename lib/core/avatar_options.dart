import 'package:flutter/material.dart';

const List<({Color color, String emoji})> kAvatarOptions = [
  (color: Color(0xFF1A5C38), emoji: '🌱'),
  (color: Color(0xFF2ECC71), emoji: '🌿'),
  (color: Color(0xFF2471A3), emoji: '💧'),
  (color: Color(0xFFF39C12), emoji: '☀️'),
  (color: Color(0xFF8E44AD), emoji: '🦋'),
  (color: Color(0xFFE74C3C), emoji: '🌸'),
  (color: Color(0xFF16A085), emoji: '🐢'),
  (color: Color(0xFF27AE60), emoji: '🐸'),
  (color: Color(0xFF2C3E50), emoji: '🦅'),
  (color: Color(0xFFD35400), emoji: '🦁'),
  (color: Color(0xFF7F8C8D), emoji: '🐺'),
  (color: Color(0xFF1ABC9C), emoji: '🌴'),
];

Widget buildAvatarWidget({
  required int avatarId,
  required double radius,
  Color? borderColor,
  double borderWidth = 0,
}) {
  final idx = avatarId.clamp(0, kAvatarOptions.length - 1);
  final opt = kAvatarOptions[idx];

  Widget circle = CircleAvatar(
    radius: radius,
    backgroundColor: opt.color,
    child: Text(
      opt.emoji,
      style: TextStyle(fontSize: radius * 0.75),
    ),
  );

  if (borderColor != null && borderWidth > 0) {
    circle = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: circle,
    );
  }

  return circle;
}
