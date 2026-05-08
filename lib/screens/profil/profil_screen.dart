import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../../services/profile_service.dart';
import '../../services/report_service.dart';
import 'settings_screen.dart';
import 'widgets/avatar_picker_sheet.dart';
import 'widgets/profil_header.dart';
import 'widgets/profil_level_card.dart';
import 'widgets/profil_report_history.dart';
import 'widgets/profil_stats_row.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  UserModel? _profile;
  int _reportsCount = 0;
  bool _loading = true;

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

  void _onExternalRefresh() {
    if (mounted) _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final profile = await ProfileService().getCurrentProfile();
      final count = await ReportService().getMyReportsCount();
      if (mounted) {
        setState(() {
          _profile = profile;
          _reportsCount = count;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSettings() async {
    if (_profile == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(currentName: _profile!.fullName),
      ),
    );
    _loadData();
  }

  Future<void> _openAvatarPicker() async {
    if (_profile == null) return;
    final changed = await showAvatarPickerSheet(
      context,
      currentAvatarId: _profile!.avatarId,
    );
    if (changed) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ProfilHeader(
              profile: _profile,
              onSettingsTap: _openSettings,
              onAvatarTap: _openAvatarPicker,
            ).animate().fadeIn(duration: 400.ms),
          ),
          if (_loading && _profile == null)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_profile != null)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ProfilStatsRow(
                    profile: _profile!,
                    reportsCount: _reportsCount,
                  ).animate().fadeIn(duration: 400.ms, delay: 80.ms),
                  const SizedBox(height: 16),
                  ProfilLevelCard(profile: _profile!)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 160.ms),
                  const SizedBox(height: 24),
                  const ProfilReportHistory()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 240.ms),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
