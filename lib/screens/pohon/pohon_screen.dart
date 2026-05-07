import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/tree_model.dart';
import '../../services/tree_service.dart';
import 'widgets/pohon_header.dart';
import 'widgets/pohon_how_to_nutri.dart';
import 'widgets/pohon_level_journey.dart';
import 'widgets/pohon_nutrition_card.dart';
import 'widgets/pohon_stats_row.dart';
import 'widgets/pohon_tips_card.dart';
import 'widgets/pohon_tree_hero.dart';

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

  Future<void> _refresh() async =>
      setState(() => _treeFuture = TreeService().getMyTree());

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
          if (snap.hasError || snap.data == null) return _buildError();
          final tree = snap.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
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
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Gagal memuat data pohon'),
          TextButton(
            onPressed: _refresh,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
