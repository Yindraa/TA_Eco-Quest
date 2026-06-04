import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../core/streak_utils.dart';
import '../../models/tree_model.dart';
import '../../models/user_model.dart';
import '../../services/profile_service.dart';
import '../../services/report_service.dart';
import '../../services/puzzle_service.dart';
import '../../services/quiz_service.dart';
import '../../services/tree_service.dart';
import 'widgets/active_misi_section.dart';
import 'widgets/gamification_card.dart';
import 'widgets/home_header.dart';
import 'widgets/lapor_cta_button.dart';
import 'widgets/misi_tersedia_card.dart';
import 'widgets/recent_reports_section.dart';
import 'widgets/puzzle_harian_card.dart';
import 'widgets/tantangan_harian_card.dart';
import 'widgets/tree_highlight_card.dart';

class HomeScreen extends StatefulWidget {
  final int refreshKey;

  const HomeScreen({super.key, this.refreshKey = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<UserModel> _profileFuture;
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  late Future<List<Map<String, dynamic>>> _misionFuture;
  late Future<List<Map<String, dynamic>>> _availableMissionsFuture;
  late Future<TreeModel> _treeFuture;
  late Future<Map<String, dynamic>?> _quizAttemptFuture;
  late Future<Map<String, dynamic>?> _puzzleAttemptFuture;

  int _lastKnownLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    homeRefreshNotifier.addListener(_onExternalRefresh);
  }

  @override
  void dispose() {
    homeRefreshNotifier.removeListener(_onExternalRefresh);
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshKey != oldWidget.refreshKey) {
      _loadData();
    }
  }

  void _onExternalRefresh() {
    if (mounted) setState(_loadData);
  }

  void _loadData() {
    _profileFuture           = _fetchProfile();
    _reportsFuture           = _fetchRecentReports();
    _misionFuture            = ReportService().getMyActiveMissions();
    _availableMissionsFuture = ReportService().getAvailableMissions();
    _treeFuture              = TreeService().getMyTree();
    _quizAttemptFuture       = QuizService().getTodayAttempt();
    _puzzleAttemptFuture     = PuzzleService().getTodayAttempt();
  }

  Future<UserModel> _fetchProfile() async {
    final service = ProfileService();
    await service.recordDailyActivity();
    final profile = await service.getCurrentProfile();

    // Level Up detection
    if (_lastKnownLevel > 0 && profile.levelId > _lastKnownLevel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showLevelUpDialog(profile.levelName);
      });
    }
    _lastKnownLevel = profile.levelId;

    // Streak milestone detection
    _checkStreakMilestone(profile.currentStreak);

    return profile;
  }

  Future<void> _checkStreakMilestone(int streak) async {
    final milestone = kStreakCelebrationDays.lastWhere(
      (d) => streak >= d,
      orElse: () => -1,
    );
    if (milestone == -1) return;

    final prefs = await SharedPreferences.getInstance();
    final lastCelebrated = prefs.getInt('last_celebrated_streak') ?? 0;
    if (milestone <= lastCelebrated) return;

    await prefs.setInt('last_celebrated_streak', milestone);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showStreakMilestoneDialog(milestone);
    });
  }

  void _showStreakMilestoneDialog(int milestone) {
    final info = getStreakInfo(milestone);
    final gradientColors = streakCelebrationGradient(milestone);
    final message = streakCelebrationMessage(milestone);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.emoji,
                  style: const TextStyle(fontSize: 56))
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 12),
              Text(
                'Streak ${info.label}!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$milestone Hari Berturut-turut 🔥',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: gradientColors.last,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Pertahankan! 💪',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLevelUpDialog(String levelName) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D4F2E), Color(0xFF1A8A50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⬆️', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Level Naik!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selamat! Kamu sekarang adalah',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                levelName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Terus aktif dan jaga lingkungan! 🌿',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: const Color(0xFF0D4F2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Luar Biasa! 🎉',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRecentReports() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return await Supabase.instance.client
        .from('reports')
        .select(
          'report_id, status, waste_size, created_at, '
          'image_url, resolved_image_url, description',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(5);
  }

  Future<void> _refresh() async => setState(_loadData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F6),
      body: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, profileSnap) {
          final profile = profileSnap.data;
          final isLoading =
              profileSnap.connectionState == ConnectionState.waiting;

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF1A5C38),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(profile: profile, isLoading: isLoading)
                      .animate()
                      .fadeIn(duration: 400.ms),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      if (isLoading)
                        _buildLoadingCard()
                      else if (profile != null)
                        GamificationCard(
                          profile: profile,
                          treeFuture: _treeFuture,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 100.ms)
                            .slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      TreeHighlightCard(treeFuture: _treeFuture)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 180.ms)
                          .slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      const LaporCtaButton()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 260.ms),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TantanganHarianCard(
                                todayAttemptFuture: _quizAttemptFuture,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PuzzleHarianCard(
                                todayAttemptFuture: _puzzleAttemptFuture,
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 280.ms),
                      const SizedBox(height: 16),
                      MisiTersediaCard(
                        availableMissionsFuture: _availableMissionsFuture,
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                      const SizedBox(height: 24),
                      ActiveMisiSection(
                        misionFuture: _misionFuture,
                        onRefresh: () => setState(_loadData),
                      ).animate().fadeIn(duration: 400.ms, delay: 320.ms),
                      RecentReportsSection(reportsFuture: _reportsFuture)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 350.ms),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
