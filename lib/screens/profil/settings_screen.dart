import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/profile_service.dart';

class SettingsScreen extends StatefulWidget {
  final String currentName;

  const SettingsScreen({super.key, required this.currentName});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _streakReminder = false;
  late String _currentName;

  @override
  void initState() {
    super.initState();
    _currentName = widget.currentName;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final enabled = await NotificationService.isStreakReminderEnabled();
    if (mounted) setState(() => _streakReminder = enabled);
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Keluar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Keluar',
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AuthService().signOut();
      if (mounted) context.go('/login');
    }
  }

  void _showEditNamaSheet() {
    final controller =
        TextEditingController(text: _currentName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title: 'Edit Nama',
        subtitle: 'Nama akan terlihat di profil dan leaderboard',
        children: [
          _inputField(
            controller: controller,
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            icon: Icons.person_outline_rounded,
          ),
        ],
        onSave: () async {
          final name = controller.text.trim();
          if (name.isEmpty) return;
          await ProfileService().updateFullName(name);
        },
        onSuccess: () {
          final newName = controller.text.trim();
          setState(() => _currentName = newName);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            _successSnackBar('Nama berhasil diperbarui'),
          );
        },
      ),
    );
  }

  void _showGantiPasswordSheet() {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title: 'Ganti Password',
        subtitle: 'Gunakan minimal 8 karakter',
        children: [
          _inputField(
            controller: newPassCtrl,
            label: 'Password Baru',
            hint: 'Minimal 8 karakter',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: confirmCtrl,
            label: 'Konfirmasi Password',
            hint: 'Ulangi password baru',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
        ],
        validate: () {
          if (newPassCtrl.text.length < 8) {
            return 'Password minimal 8 karakter';
          }
          if (newPassCtrl.text != confirmCtrl.text) {
            return 'Password tidak cocok';
          }
          return null;
        },
        onSave: () async {
          await ProfileService().updatePassword(newPassCtrl.text);
        },
        onSuccess: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            _successSnackBar('Password berhasil diperbarui'),
          );
        },
      ),
    );
  }

  void _showTentangSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Eco-Quest',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Versi 1.0.0',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _tentangRow('Dikembangkan oleh', 'Made Narayindra'),
            _tentangRow('NIM', '220211060016'),
            _tentangRow('Tahun', '2025 / 2026'),
            _tentangRow(
              'Deskripsi',
              'Platform pelaporan sampah berbasis gamifikasi untuk mendorong partisipasi masyarakat muda Manado.',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _tentangRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2E2A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _sectionLabel('Akun'),
                _tile(
                  icon: Icons.edit_rounded,
                  iconColor: AppColors.primary,
                  title: 'Edit Nama',
                  subtitle: _currentName,
                  onTap: _showEditNamaSheet,
                ),
                _tile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF2471A3),
                  title: 'Ganti Password',
                  subtitle: '••••••••',
                  onTap: _showGantiPasswordSheet,
                ),
                const SizedBox(height: 20),
                _sectionLabel('Preferensi'),
                _switchTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange,
                  title: 'Notifikasi Pengingat Streak',
                  subtitle: 'Ingatkan agar streak harian tidak putus',
                  value: _streakReminder,
                  onChanged: (val) async {
                    setState(() => _streakReminder = val);
                    await NotificationService.setStreakReminderEnabled(val);
                  },
                ),
                const SizedBox(height: 20),
                _sectionLabel('Informasi'),
                _tile(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.blueGrey,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Eco-Quest v1.0.0',
                  onTap: _showTentangSheet,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _handleSignOut,
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: Text(
                      'Keluar dari Akun',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              Text(
                'Pengaturan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E2A)),
        ),
        subtitle: Text(
          subtitle,
          style:
              GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E2A)),
        ),
        subtitle: Text(
          subtitle,
          style:
              GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ),
    );
  }

  SnackBar _successSnackBar(String message) {
    return SnackBar(
      content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ── Reusable bottom sheet form ──────────────────────────────────────────────

class _FormSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String? Function()? validate;
  final Future<void> Function() onSave;
  final VoidCallback onSuccess;

  const _FormSheet({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onSave,
    required this.onSuccess,
    this.validate,
  });

  @override
  State<_FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<_FormSheet> {
  bool _saving = false;
  String? _error;

  Future<void> _submit() async {
    final err = widget.validate?.call();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave();
      if (mounted) widget.onSuccess();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Terjadi kesalahan. Coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
              widget.title,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            ...widget.children,
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.red[400]),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared input field builder ───────────────────────────────────────────────

Widget _inputField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  bool obscure = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF4F9F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
