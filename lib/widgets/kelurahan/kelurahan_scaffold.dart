import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../screens/kelurahan/kelurahan_profil_screen.dart';
import '../../screens/verifikasi/verifikasi_screen.dart';

class KelurahanScaffold extends StatefulWidget {
  const KelurahanScaffold({super.key});

  @override
  State<KelurahanScaffold> createState() => _KelurahanScaffoldState();
}

class _KelurahanScaffoldState extends State<KelurahanScaffold> {
  int _currentIndex = 0;
  RealtimeChannel? _newReportsChannel;

  final List<Widget> _screens = const [
    VerifikasiScreen(),
    KelurahanProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToNewReports();
  }

  @override
  void dispose() {
    _newReportsChannel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToNewReports() {
    _newReportsChannel = Supabase.instance.client
        .channel('kelurahan_new_reports')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'reports',
          callback: (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '📋 Laporan baru masuk! Segera verifikasi.',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                backgroundColor: const Color(0xFF2471A3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Lihat',
                  textColor: Colors.white,
                  onPressed: () => setState(() => _currentIndex = 0),
                ),
              ),
            );
            homeRefreshNotifier.value++;
          },
        )
        .subscribe();
  }

  Future<bool> _onExitConfirm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar dari Eco-Quest?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Keluar',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
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
        if (await _onExitConfirm() && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
          backgroundColor: Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_outlined),
              activeIcon: Icon(Icons.verified_rounded),
              label: 'Verifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
