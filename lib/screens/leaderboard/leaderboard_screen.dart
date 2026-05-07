import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/avatar_options.dart';
import '../../core/theme.dart';
import 'widgets/leaderboard_podium.dart';
import 'widgets/leaderboard_rank_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;
  late Future<Map<String, dynamic>?> _myRankFuture;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    _leaderboardFuture = _fetchLeaderboard();
    _myRankFuture = _fetchMyRank();
  }

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final rows = await Supabase.instance.client
        .from('leaderboard')
        .select()
        .limit(20);

    if (rows.isEmpty) return rows;

    // Fetch avatar_id in one batch — independent of view definition
    final ids = rows.map((r) => r['id'] as String).toList();
    final profiles = await Supabase.instance.client
        .from('profiles')
        .select('id, avatar_id')
        .inFilter('id', ids);

    final avatarMap = <String, int>{
      for (final p in profiles)
        p['id'] as String: (p['avatar_id'] as num?)?.toInt() ?? 0,
    };

    return rows
        .map((r) => {...r, 'avatar_id': avatarMap[r['id'] as String] ?? 0})
        .toList();
  }

  Future<Map<String, dynamic>?> _fetchMyRank() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final rankData = await Supabase.instance.client
        .from('leaderboard')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (rankData == null) return null;

    // Fetch avatar_id directly from profiles for accuracy
    final profileData = await Supabase.instance.client
        .from('profiles')
        .select('avatar_id')
        .eq('id', userId)
        .maybeSingle();

    return {
      ...rankData,
      'avatar_id': (profileData?['avatar_id'] as num?)?.toInt() ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _leaderboardFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final data = snap.data ?? [];
                if (data.isEmpty) return _buildEmpty();
                return _buildContent(data);
              },
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Colors.amber, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Leaderboard',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Top EXP',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Kompetisi mingguan para Eco-Warrior Manado',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> data) {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';
    final topThree = data.take(3).toList();
    final rest = data.skip(3).toList();

    return RefreshIndicator(
      onRefresh: () async => setState(_loadAll),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Podium
          SliverToBoxAdapter(
            child: LeaderboardPodium(
              topThree: topThree,
              currentUserId: currentUserId,
            ),
          ),

          // "Posisimu" banner
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _myRankFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                return _buildMyRankBanner(snap.data, data, currentUserId);
              },
            ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
          ),

          // Rank list 4–20
          if (rest.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'Peringkat Lainnya',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A2E2A),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = rest[i];
                    final rank =
                        (item['rank'] as num?)?.toInt() ?? (i + 4);
                    final name =
                        item['full_name'] as String? ?? 'Pengguna';
                    final points =
                        (item['total_points'] as num?)?.toInt() ?? 0;
                    final levelName =
                        item['level_name'] as String? ?? '';
                    final streak =
                        (item['current_streak'] as num?)?.toInt() ?? 0;
                    final isMe = item['id'] == currentUserId;
                    final avatarId =
                        (item['avatar_id'] as num?)?.toInt() ?? 0;

                    return LeaderboardRankCard(
                      rank: rank,
                      name: name,
                      points: points,
                      levelName: levelName,
                      streak: streak,
                      isMe: isMe,
                      avatarId: avatarId,
                    )
                        .animate(delay: (i * 40).ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.2, end: 0);
                  },
                  childCount: rest.length,
                ),
              ),
            ),
          ] else
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildMyRankBanner(
    Map<String, dynamic>? myData,
    List<Map<String, dynamic>> top20,
    String currentUserId,
  ) {
    // Check if user is in top 3 (already on podium)
    final isInTopThree =
        top20.take(3).any((e) => e['id'] == currentUserId);
    if (isInTopThree) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'Selamat! Kamu ada di Top 3!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (myData == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              const Icon(Icons.info_outline_rounded,
                  color: Colors.grey, size: 18),
              const SizedBox(width: 10),
              Text(
                'Kumpulkan EXP untuk masuk leaderboard!',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    final rank = (myData['rank'] as num?)?.toInt() ?? 0;
    final name = myData['full_name'] as String? ?? 'Pengguna';
    final points = (myData['total_points'] as num?)?.toInt() ?? 0;
    final levelName = myData['level_name'] as String? ?? '';
    final streak = (myData['current_streak'] as num?)?.toInt() ?? 0;
    final myAvatarId = (myData['avatar_id'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.fieldFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$rank',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2E2A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Kamu',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$levelName  ·  🔥 $streak hari  ·  $points EXP',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            buildAvatarWidget(avatarId: myAvatarId, radius: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined,
              size: 60, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Leaderboard Kosong',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadilah yang pertama di puncak!\nMulai laporkan sampah sekarang.',
            textAlign: TextAlign.center,
            style:
                GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
