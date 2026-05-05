import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/shared/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Mohon lengkapi semua field');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Password tidak cocok!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      if (mounted) {
        _showSnackBar('Registrasi Berhasil! Silakan masuk.');
        Navigator.pop(context);
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
    if (m.contains('rate limit') ||
        m.contains('429') ||
        m.contains('too many')) {
      return 'Terlalu banyak percobaan. Tunggu beberapa saat lalu coba lagi.';
    }
    if (m.contains('already registered') || m.contains('user already exists')) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }
    if (m.contains('password') && m.contains('weak')) {
      return 'Password terlalu lemah. Gunakan minimal 8 karakter.';
    }
    if (m.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    return 'Gagal mendaftar: $message';
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                children: [
                  _buildField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    icon: Icons.person_outline_rounded,
                    index: 0,
                  ),
                  const SizedBox(height: 18),
                  _buildField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'contoh@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    index: 1,
                  ),
                  const SizedBox(height: 18),
                  _buildField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Min. 8 karakter',
                    icon: Icons.lock_outline_rounded,
                    isPassword: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    index: 2,
                  ),
                  const SizedBox(height: 18),
                  _buildField(
                    controller: _confirmPasswordController,
                    label: 'Konfirmasi Password',
                    hint: 'Ulangi password',
                    icon: Icons.lock_clock_outlined,
                    isPassword: _obscureConfirmPassword,
                    onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    index: 3,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Daftar Sekarang',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  ).animate().fadeIn(duration: 350.ms, delay: 420.ms),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Sudah punya akun? ',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Masuk Sekarang',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 480.ms),
                  const SizedBox(height: 16),
                ],
              ),
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat Akun Baru',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Bergabung dan mulai misi lingkunganmu',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
    required int index,
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
              keyboardType: keyboardType,
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(
          duration: 350.ms,
          delay: Duration(milliseconds: 80 + index * 80),
        )
        .slideX(begin: 0.08);
  }
}
