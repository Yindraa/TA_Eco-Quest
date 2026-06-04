import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/lapor/lapor_screen.dart';
import '../../screens/leaderboard/leaderboard_screen.dart';
import '../../screens/peta/peta_screen.dart';
import '../../screens/profil/profil_screen.dart';
import '../../services/notification_service.dart';
import '../../services/tree_service.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Setiap kali user kembali ke tab Beranda, nilai ini naik →
  // HomeScreen mendeteksinya via didUpdateWidget dan refresh datanya.
  int _homeRefreshKey = 0;

  RealtimeChannel? _reportChannel;

  @override
  void initState() {
    super.initState();
    _subscribeToReportChanges();
    _checkStreakReminder();
  }

  Future<void> _checkStreakReminder() async {
    final enabled = await NotificationService.isStreakReminderEnabled();
    if (!enabled) return;

    final alreadyWatered = await TreeService().hasWateredToday();
    if (alreadyWatered || !mounted) return;

    // Tunda sedikit agar UI selesai render sebelum banner muncul
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🌳', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Jangan lupa siram pohonmu hari ini!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE67E22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ke Beranda',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = 0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reportChannel?.unsubscribe();
    super.dispose();
  }

  void _showStatusSnackBar(String newStatus) {
    if (!mounted) return;
    final (msg, color) = switch (newStatus) {
      'claimed'  => ('Ada yang mengambil laporan sampahmu! 🙌', const Color(0xFF2471A3)),
      'resolved' => ('Laporan sampahmu ditindaklanjuti! 📸 Menunggu validasi.', Colors.orange[700]!),
      'valid'    => ('Laporan tervalidasi! ✅ EXP telah ditambahkan.', const Color(0xFF1A5C38)),
      'rejected' => ('Laporan sampahmu ditolak oleh Operator.', Colors.red[600]!),
      _          => (null, Colors.grey),
    };
    if (msg == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _subscribeToReportChanges() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _reportChannel = Supabase.instance.client
        .channel('report_status_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'reports',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final oldStatus = payload.oldRecord['status'] as String?;
            final newStatus = payload.newRecord['status'] as String?;
            if (oldStatus == null || newStatus == null) return;
            if (oldStatus == newStatus) return;

            // Tampilkan in-app SnackBar
            _showStatusSnackBar(newStatus);

            // Refresh beranda agar status laporan terupdate
            homeRefreshNotifier.value++;
          },
        )
        .subscribe();
  }

  List<Widget> get _screens => [
        HomeScreen(refreshKey: _homeRefreshKey),
        const PetaScreen(),
        const LeaderboardScreen(),
        const ProfilScreen(),
      ];

  void _openLapor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LaporScreen()),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) _homeRefreshKey++;
    });
  }

  Future<bool> _onExitConfirm() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F9F6),
                shape: BoxShape.circle,
              ),
              child: const Text('👋', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 16),
            Text(
              'Keluar dari Eco-Quest?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2E2A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Sampai jumpa lagi! Jangan lupa\nkembali untuk misi berikutnya 🌿',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF1A5C38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _onExitConfirm();
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openLapor,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_a_photo_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6,
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
              _navItem(1, Icons.map_rounded, Icons.map_outlined, 'Peta Misi'),
              const SizedBox(width: 56),
              _navItem(
                2,
                Icons.emoji_events_rounded,
                Icons.emoji_events_outlined,
                'Leaderboard',
              ),
              _navItem(
                3,
                Icons.person_rounded,
                Icons.person_outline_rounded,
                'Profil',
              ),
            ],
          ),
        ),
      ),
    ),  // closes Scaffold
    );  // closes PopScope
  }

  Widget _navItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.primary : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: isActive ? AppColors.primary : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
