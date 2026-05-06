import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
