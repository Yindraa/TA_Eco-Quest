import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/reward_model.dart';
import '../../services/reward_service.dart';

class RewardScreen extends StatefulWidget {
  final int initialCoins;

  const RewardScreen({super.key, required this.initialCoins});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _coins;
  final _service = RewardService();

  late Future<List<RewardModel>> _rewardsFuture;
  late Future<List<RedemptionModel>> _redemptionsFuture;

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _rewardsFuture     = _service.getRewards();
    _redemptionsFuture = _service.getMyRedemptions();
  }

  Future<void> _redeem(RewardModel reward) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reward.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              reward.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2E2A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${reward.costCoins} Eco Coins',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sisa setelah tukar: ${_coins - reward.costCoins} coins',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            if (reward.isMerchandise) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Penukaran merchandise akan diproses oleh admin. '
                  'Pantau status di tab Riwayatku.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.orange[800],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text('Batal',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600])),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Tukar',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
    if (confirm != true || !mounted) return;

    final result = await _service.redeemReward(reward.rewardId);
    if (!mounted) return;

    if (result['success'] == true) {
      final remaining = (result['remaining_coins'] as num?)?.toInt() ?? _coins;
      setState(() {
        _coins = remaining;
        _loadData();
      });
      final (msg, color) = switch (reward.category) {
        'tree_boost'  => ('Nutrisi pohon berhasil ditambahkan! 🌱', AppColors.primary),
        'extra_quota' => ('Slot laporan ekstra aktif untuk hari ini! 📋', const Color(0xFF2471A3)),
        _             => ('Permintaan terkirim! Admin akan segera memproses 🎁', Colors.orange[700]!),
      };
      _showSnackBar(msg, color);
    } else {
      final msg = result['message'] as String? ?? '';
      _showSnackBar(
        switch (msg) {
          'insufficient_coins' => 'Eco Coins kamu tidak cukup.',
          'already_redeemed' => 'Kamu sudah memiliki gelar ini.',
          'out_of_stock' => 'Stok reward ini sudah habis.',
          _ => 'Gagal menukarkan reward. Coba lagi.',
        },
        Colors.red[400]!,
      );
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildKatalogTab(),
                _buildRiwayatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Tukar Reward',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    '$_coins',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Eco Coins',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  GoogleFonts.poppins(fontSize: 13),
              labelColor: Colors.white,
              unselectedLabelColor:
                  Colors.white.withValues(alpha: 0.6),
              tabs: const [
                Tab(text: 'Katalog'),
                Tab(text: 'Riwayatku'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Katalog Tab ────────────────────────────────────────────────────────────

  Widget _buildKatalogTab() {
    return FutureBuilder<List<RewardModel>>(
      future: _rewardsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        final rewards = snap.data ?? [];

        final boosts = rewards.where((r) => r.isTreeBoost).toList();
        final quotas = rewards.where((r) => r.isExtraQuota).toList();
        final merch  = rewards.where((r) => r.isMerchandise).toList();

        return RefreshIndicator(
          onRefresh: () async => setState(() => _loadData()),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (boosts.isNotEmpty) ...[
                  _sectionHeader('🌱', 'Boost Pohon',
                      'Nutrisi langsung ditambahkan ke pohon virtualmu'),
                  const SizedBox(height: 12),
                  ...boosts.map((r) => _RewardCard(
                        reward: r,
                        userCoins: _coins,
                        onRedeem: () => _redeem(r),
                      )),
                ],
                if (quotas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _sectionHeader('📋', 'Kuota Ekstra',
                      'Tambah slot laporan untuk hari ini'),
                  const SizedBox(height: 12),
                  ...quotas.map((r) => _RewardCard(
                        reward: r,
                        userCoins: _coins,
                        onRedeem: () => _redeem(r),
                      )),
                ],
                if (merch.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _sectionHeader('🎁', 'Merchandise DLH',
                      'Diproses admin · Notifikasi masuk saat siap diambil'),
                  const SizedBox(height: 12),
                  ...merch.map((r) => _RewardCard(
                        reward: r,
                        userCoins: _coins,
                        onRedeem: () => _redeem(r),
                      )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A2E2A))),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  // ── Riwayat Tab ───────────────────────────────────────────────────────────

  Widget _buildRiwayatTab() {
    return FutureBuilder<List<RedemptionModel>>(
      future: _redemptionsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎁', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Belum ada penukaran',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E2A))),
                const SizedBox(height: 4),
                Text('Tukarkan Eco Coins kamu di tab Katalog!',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _loadData()),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _buildRedemptionItem(list[i]),
          ),
        );
      },
    );
  }

  Widget _buildRedemptionItem(RedemptionModel item) {
    final (label, color) = switch (item.status) {
      'completed' => ('Aktif ✓', AppColors.primary),
      'pending' => ('Menunggu 🕐', Colors.orange[700]!),
      'rejected' => ('Ditolak ✗', Colors.red[400]!),
      _ => ('Unknown', Colors.grey),
    };

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = item.redeemedAt;
    final dateStr = '${d.day} ${months[d.month - 1]} ${d.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.isMerchandise ? '🎁' : item.rewardCategory == 'tree_boost' ? '🌱' : '📋',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.rewardName,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E2A))),
                Text(dateStr,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

// ── RewardCard ─────────────────────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final int userCoins;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.reward,
    required this.userCoins,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = userCoins >= reward.costCoins;
    final isOutOfStock = reward.isOutOfStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Emoji icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(reward.emoji,
                  style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reward.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A2E2A),
                        ),
                      ),
                    ),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: reward.isMerchandise
                            ? Colors.orange.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        reward.categoryLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: reward.isMerchandise
                              ? Colors.orange[700]
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  reward.description,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey[500], height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Cost chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙',
                              style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.costCoins}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: canAfford
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Stock indicator for merchandise
                    if (reward.isMerchandise && reward.stock != null)
                      Text(
                        'Stok: ${reward.stock}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: reward.isOutOfStock
                              ? Colors.red[400]
                              : Colors.grey[500],
                        ),
                      ),
                    const Spacer(),
                    // Action button
                    _buildButton(canAfford, isOutOfStock),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(bool canAfford, bool isOutOfStock) {
    if (isOutOfStock) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('Habis',
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red[400])),
      );
    }

    return ElevatedButton(
      onPressed: canAfford ? onRedeem : null,
      style: ElevatedButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        canAfford ? 'Tukar' : 'Kurang',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: canAfford ? Colors.white : Colors.grey[500],
        ),
      ),
    );
  }
}
