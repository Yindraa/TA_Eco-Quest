import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/tree_model.dart';
import '../../models/user_model.dart';
import '../../services/profile_service.dart';
import '../../services/tree_service.dart';
import 'widgets/pohon_header.dart';
import 'widgets/pohon_how_to_nutri.dart';
import 'widgets/pohon_level_journey.dart';
import 'widgets/pohon_nutrition_card.dart';
import 'widgets/pohon_stats_row.dart';
import 'widgets/pohon_tips_card.dart';
import 'widgets/pohon_tree_hero.dart';
import 'widgets/pohon_water_button.dart';

class PohonScreen extends StatefulWidget {
  const PohonScreen({super.key});

  @override
  State<PohonScreen> createState() => _PohonScreenState();
}

class _PohonScreenState extends State<PohonScreen> {
  TreeModel? _tree;
  int _currentExp = 0;
  int _currentStreak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      // Terapkan decay dulu sebelum fetch tree
      await TreeService().applyDecay();

      final results = await Future.wait([
        TreeService().getMyTree(),
        ProfileService().getCurrentProfile(),
      ]);
      if (!mounted) return;
      final profile = results[1] as UserModel;
      setState(() {
        _tree = results[0] as TreeModel;
        _currentExp = profile.totalPoints;
        _currentStreak = profile.currentStreak;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pertama kali loading
    if (_loading && _tree == null) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_tree == null) return _buildError();

    final tree = _tree!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: PohonHeader(tree: tree)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    PohonTreeHero(tree: tree),
                    const SizedBox(height: 16),
                    PohonWaterButton(
                      tree: tree,
                      currentExp: _currentExp,
                      currentStreak: _currentStreak,
                      onWatered: _loadData,
                    ),
                    const SizedBox(height: 16),
                    PohonNutritionCard(tree: tree),
                    const SizedBox(height: 16),
                    PohonLevelJourney(tree: tree),
                    const SizedBox(height: 16),
                    PohonStatsRow(tree: tree),
                    const SizedBox(height: 16),
                    PohonHowToNutri(tree: tree),
                    const SizedBox(height: 16),
                    PohonTipsCard(tree: tree),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Gagal memuat data pohon'),
            TextButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
