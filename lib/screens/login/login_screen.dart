import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/shared/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService        = AuthService();

  bool _isLoading         = false;
  bool _obscurePassword   = true;
  bool _isResettingEmail  = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Mohon isi email dan password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        final msg = e is AuthException
            ? _mapAuthError(e.message)
            : 'Terjadi kesalahan. Coba lagi.';
        _showSnackBar(msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('not confirmed') || m.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox emailmu.';
    }
    if (m.contains('invalid login credentials') || m.contains('invalid email or password')) {
      return 'Email atau password salah.';
    }
    if (m.contains('user not found') || m.contains('no user found')) {
      return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
    }
    if (m.contains('too many requests') || m.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu beberapa saat.';
    }
    return 'Gagal masuk: $message';
  }

  void _showForgotPasswordSheet() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Lupa Password?',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Masukkan email akunmu. Kami akan mengirimkan\nlink untuk mereset password.',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[500], height: 1.5),
                ),
                const SizedBox(height: 20),
                _buildField(
                  controller: emailCtrl,
                  label: 'Email',
                  hint: 'contoh@email.com',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isResettingEmail
                        ? null
                        : () async {
                            final email = emailCtrl.text.trim();
                            if (email.isEmpty) return;
                            setSheet(() => _isResettingEmail = true);
                            try {
                              await Supabase.instance.client.auth
                                  .resetPasswordForEmail(email);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              _showSnackBar(
                                  'Link reset password dikirim ke $email. Cek inboxmu!');
                            } catch (_) {
                              if (ctx.mounted) {
                                _showSnackBar(
                                    'Gagal mengirim email. Pastikan email sudah terdaftar.');
                              }
                            } finally {
                              if (ctx.mounted) {
                                setSheet(() => _isResettingEmail = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isResettingEmail
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Kirim Link Reset',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full gradient background
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          ),

          // White area at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.63,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: _circle(130, 0.12),
          ),
          Positioned(
            top: 90,
            left: -55,
            child: _circle(170, 0.07),
          ),
          Positioned(
            top: 20,
            right: 100,
            child: _circle(50, 0.10),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(flex: 37, child: _buildLogoSection()),
                  Expanded(flex: 63, child: _buildFormSection()),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildLogoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 90,
          height: 90,
        ),
        const SizedBox(height: 14),
        Text(
          'Eco-Quest',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Partisipasi Remaja untuk Manado Bersih',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15);
  }

  Widget _buildFormSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang 👋',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            'Masuk untuk lanjutkan misi lingkunganmu',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 28),

          _buildField(
            controller: _emailController,
            label: 'Email',
            hint: 'contoh@email.com',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 18),
          _buildField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Masukkan password',
            icon: Icons.lock_outline_rounded,
            isPassword: _obscurePassword,
            onToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordSheet,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lupa Password?',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          CustomButton(
            text: 'Masuk',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 20),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: RichText(
                text: TextSpan(
                  text: 'Belum punya akun? ',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Daftar Sekarang',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, delay: 200.ms);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: onToggle != null
                ? IconButton(
                    icon: Icon(
                      isPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            filled: true,
            fillColor: AppColors.fieldFill,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
