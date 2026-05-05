import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/tree_model.dart';
import '../../services/tree_service.dart';

class PohonScreen extends StatefulWidget {
  const PohonScreen({super.key});

  @override
  State<PohonScreen> createState() => _PohonScreenState();
}

class _PohonScreenState extends State<PohonScreen> {
  late Future<TreeModel> _treeFuture;

  @override
  void initState() {
    super.initState();
    _treeFuture = TreeService().getMyTree();
  }

  Future<void> _refresh() async {
    setState(() => _treeFuture = TreeService().getMyTree());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<TreeModel>(
        future: _treeFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snap.hasError || snap.data == null) {
            return _buildError();
          }
          final tree = snap.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(tree)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        _buildTreeHero(tree),
                        const SizedBox(height: 16),
                        _buildNutritionCard(tree),
                        const SizedBox(height: 16),
                        _buildStatsRow(tree),
                        const SizedBox(height: 16),
                        _buildTipsCard(tree),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(TreeModel tree) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tree.healthGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              const Icon(Icons.eco_rounded, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pohon Virtualku',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tree.healthColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tree.healthLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Tree Hero Visual ─────────────────────────────────────────────────────

  Widget _buildTreeHero(TreeModel tree) {
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
          // Dekorasi lingkaran latar
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

          // Konten utama
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
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
                const SizedBox(height: 28),

                // Pohon animatif
                _buildAnimatedTree(tree),

                const SizedBox(height: 20),

                // Status deskripsi
                Text(
                  tree.healthDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildAnimatedTree(TreeModel tree) {
    final treeWidget = Text(
      tree.emoji,
      style: const TextStyle(fontSize: 96),
    );

    return switch (tree.healthStatus) {
      'healthy' => treeWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.08, 1.08),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .moveY(
            begin: 0,
            end: -6,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
      'wilting' => treeWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .rotate(
            begin: -0.04,
            end: 0.04,
            duration: 3000.ms,
            curve: Curves.easeInOut,
          )
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(0.9, 0.9),
          ),
      _ => treeWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -3,
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ),
    };
  }

  // ── Nutrition Progress ───────────────────────────────────────────────────

  Widget _buildNutritionCard(TreeModel tree) {
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
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Nutrisi Pohon',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2E2A),
                ),
              ),
              const Spacer(),
              Text(
                '${tree.nutritionPoints} poin',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: tree.nutritionProgress,
              minHeight: 10,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(tree.healthColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tree.isMaxLevel
                    ? '🎉 Level Tertinggi!'
                    : '${(tree.nutritionProgress * 100).toStringAsFixed(0)}% menuju ${tree.levelName == "Pohon Dewasa" ? "level max" : "level selanjutnya"}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              if (!tree.isMaxLevel)
                Text(
                  '+${tree.pointsToNextLevel} lagi',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tree.healthColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1);
  }

  // ── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(TreeModel tree) {
    return Row(
      children: [
        _statCard(
          icon: Icons.eco_rounded,
          iconBg: AppColors.fieldFill,
          iconColor: AppColors.primary,
          label: 'Level Pohon',
          value: 'Level ${tree.treeLevel}',
          sub: tree.levelName,
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.water_rounded,
          iconBg: const Color(0xFFEBF5FB),
          iconColor: const Color(0xFF2471A3),
          label: 'Terakhir Disiram',
          value: tree.timeAgoWatered(),
          sub: 'via laporan valid',
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2E2A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              sub,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tips Card ────────────────────────────────────────────────────────────

  Widget _buildTipsCard(TreeModel tree) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tree.healthColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tree.healthColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tree.healthColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              switch (tree.healthStatus) {
                'healthy' => Icons.tips_and_updates_rounded,
                'wilting' => Icons.warning_rounded,
                _         => Icons.info_outline_rounded,
              },
              color: tree.healthColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (tree.healthStatus) {
                    'healthy' => 'Tips untuk Pohonmu',
                    'wilting' => '⚠️ Pohonmu Butuh Bantuan!',
                    _         => 'Perhatian',
                  },
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: tree.healthColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tree.healthTip,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1);
  }

  // ── Error State ──────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data pohon',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          TextButton(
            onPressed: _refresh,
            child: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
