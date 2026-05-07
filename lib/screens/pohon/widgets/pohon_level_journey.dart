import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/tree_model.dart';

class PohonLevelJourney extends StatelessWidget {
  final TreeModel tree;
  const PohonLevelJourney({super.key, required this.tree});

  static const _stages = [
    (level: 1, emoji: '🌱', name: 'Bibit', range: '0–100'),
    (level: 2, emoji: '🪴', name: 'Bibit\nMuda', range: '100–300'),
    (level: 3, emoji: '🌿', name: 'Pohon\nMuda', range: '300–600'),
    (level: 4, emoji: '🌳', name: 'Pohon\nDewasa', range: '600+'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.route_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Perjalanan Pohon',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2E2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _stages.asMap().entries.map((e) {
              final i = e.key;
              final stage = e.value;
              final isPast = tree.treeLevel > stage.level;
              final isCurrent = tree.treeLevel == stage.level;
              final isFirst = i == 0;
              final isLast = i == _stages.length - 1;

              final nodeColor =
                  isPast || isCurrent ? AppColors.primary : Colors.white;
              final borderColor = isPast || isCurrent
                  ? AppColors.primary
                  : Colors.grey[300]!;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (!isFirst)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isPast
                                  ? AppColors.primary
                                  : Colors.grey[200],
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: isCurrent ? 30 : 22,
                          height: isCurrent ? 30 : 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: nodeColor,
                            border: Border.all(
                                color: borderColor, width: 2),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isPast
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 13)
                                : isCurrent
                                    ? const Icon(Icons.eco_rounded,
                                        color: Colors.white, size: 13)
                                    : null,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isPast
                                  ? AppColors.primary
                                  : Colors.grey[200],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(stage.emoji,
                        style:
                            TextStyle(fontSize: isCurrent ? 26 : 18)),
                    const SizedBox(height: 4),
                    Text(
                      stage.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrent
                            ? AppColors.primary
                            : Colors.grey[500],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stage.range,
                      style: GoogleFonts.poppins(
                          fontSize: 9, color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.1);
  }
}
