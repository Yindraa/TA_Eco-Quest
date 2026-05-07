import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/tree_model.dart';

class PohonTreeHero extends StatelessWidget {
  final TreeModel tree;
  const PohonTreeHero({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tree.healthGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: tree.healthColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Ground overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
            ),
          ),

          // Sparkles — healthy only
          if (tree.healthStatus == 'healthy') ...[
            Positioned(
              top: 18,
              left: 28,
              child: const Text('✨', style: TextStyle(fontSize: 18))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 1200.ms),
            ),
            Positioned(
              top: 32,
              right: 30,
              child: const Text('🌟', style: TextStyle(fontSize: 14))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 1600.ms, delay: 400.ms),
            ),
            Positioned(
              top: 12,
              right: 70,
              child: const Text('✨', style: TextStyle(fontSize: 12))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 1000.ms, delay: 700.ms),
            ),
          ],

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Level ${tree.treeLevel}  ·  ${tree.levelName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    _buildAnimatedTree(),
                    const SizedBox(height: 4),
                    Container(
                      width: 72,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tree.healthDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildAnimatedTree() {
    final treeWidget = Text(tree.emoji, style: const TextStyle(fontSize: 96));
    return switch (tree.healthStatus) {
      'healthy' => treeWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.08, 1.08),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .moveY(begin: 0, end: -6, duration: 2000.ms, curve: Curves.easeInOut),
      'wilting' => treeWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .rotate(begin: -0.04, end: 0.04, duration: 3000.ms,
              curve: Curves.easeInOut)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(0.9, 0.9)),
      _ => treeWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -3, duration: 3000.ms, curve: Curves.easeInOut),
    };
  }
}
