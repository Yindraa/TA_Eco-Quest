import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    context.go(isLoggedIn ? '/' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Lingkaran dekoratif
            Positioned(
              top: -40,
              right: -40,
              child: _circle(130, 0.10),
            ),
            Positioned(
              top: 90,
              left: -55,
              child: _circle(170, 0.06),
            ),
            Positioned(
              bottom: 80,
              right: -30,
              child: _circle(120, 0.07),
            ),

            // Konten tengah
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.65, 0.65),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 24),

                    Text(
                      'Eco-Quest',
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ).animate(delay: 350.ms).fadeIn(duration: 500.ms).slideY(
                          begin: 0.25,
                          end: 0,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 8),

                    Text(
                      'Partisipasi Remaja untuk Manado Bersih',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      textAlign: TextAlign.center,
                    ).animate(delay: 550.ms).fadeIn(duration: 500.ms),

                    const SizedBox(height: 72),

                    // Loading indicator
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white.withValues(alpha: 0.65),
                        strokeWidth: 2.5,
                      ),
                    ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}
