import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _fetchLeaderboard();
  }

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    return await Supabase.instance.client
        .from('leaderboard')
        .select()
        .limit(20);
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
                return _buildList(data);
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
          child: Row(
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
              Text(
                'Top EXP',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> data) {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final item = data[i];
        final rank = (item['rank'] as num?)?.toInt() ?? (i + 1);
        final name = item['full_name'] as String? ?? 'Pengguna';
        final points = (item['total_points'] as num?)?.toInt() ?? 0;
        final levelName = item['level_name'] as String? ?? '';
        final streak = (item['current_streak'] as num?)?.toInt() ?? 0;
        final isMe = item['id'] == currentUserId;

        return _buildRankCard(
          rank: rank,
          name: name,
          points: points,
          levelName: levelName,
          streak: streak,
          isMe: isMe,
        );
      },
    );
  }

  Widget _buildRankCard({
    required int rank,
    required String name,
    required int points,
    required String levelName,
    required int streak,
    required bool isMe,
  }) {
    final (medalColor, medalIcon) = switch (rank) {
      1 => (Colors.amber, Icons.looks_one_rounded),
      2 => (Colors.blueGrey[300]!, Icons.looks_two_rounded),
      3 => (Colors.brown[300]!, Icons.looks_3_rounded),
      _ => (Colors.grey[400]!, Icons.tag_rounded),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.fieldFill
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)
            : null,
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
          // Rank
          SizedBox(
            width: 36,
            child: Icon(medalIcon, color: medalColor, size: 26),
          ),
          const SizedBox(width: 4),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              name[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
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
                    if (isMe) ...[
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
                  ],
                ),
                Text(
                  '$levelName  ·  🔥 $streak hari',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'EXP',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
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
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
