import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../models/tree_model.dart';
import '../../models/user_model.dart';
import '../../services/profile_service.dart';
import '../../services/report_service.dart';
import '../../services/quiz_service.dart';
import '../../services/tree_service.dart';
import 'widgets/active_misi_section.dart';
import 'widgets/gamification_card.dart';
import 'widgets/home_header.dart';
import 'widgets/lapor_cta_button.dart';
import 'widgets/misi_tersedia_card.dart';
import 'widgets/recent_reports_section.dart';
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
  }

  Future<UserModel> _fetchProfile() async {
    final service = ProfileService();
    await service.recordDailyActivity();
    return service.getCurrentProfile();
  }

  Future<List<Map<String, dynamic>>> _fetchRecentReports() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return await Supabase.instance.client
        .from('reports')
        .select('report_id, status, waste_size, created_at')
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
                        GamificationCard(profile: profile)
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
                      TantanganHarianCard(
                        todayAttemptFuture: _quizAttemptFuture,
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
