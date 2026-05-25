import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/lapor/lapor_screen.dart';
import '../../screens/leaderboard/leaderboard_screen.dart';
import '../../screens/peta/peta_screen.dart';
import '../../screens/profil/profil_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
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
