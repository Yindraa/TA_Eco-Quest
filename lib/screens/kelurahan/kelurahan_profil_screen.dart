import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/avatar_options.dart';
import '../../core/theme.dart';

class KelurahanProfilScreen extends StatefulWidget {
  const KelurahanProfilScreen({super.key});

  @override
  State<KelurahanProfilScreen> createState() => _KelurahanProfilScreenState();
}

class _KelurahanProfilScreenState extends State<KelurahanProfilScreen> {
  String _fullName = '';
  int _avatarId   = 0;
  bool _loading   = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_id')
          .eq('id', userId)
          .single();
      if (mounted) {
        setState(() {
          _fullName = data['full_name'] as String? ?? 'Petugas';
          _avatarId = (data['avatar_id'] as num?)?.toInt() ?? 0;
          _loading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _memberSince() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final raw  = Supabase.instance.client.auth.currentUser?.createdAt;
    final date = raw != null ? DateTime.tryParse(raw) : null;
    if (date == null) return '-';
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Kamu akan keluar dari akun ini.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Keluar',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          if (_loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildActionCard(),
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              Text(
                'Profil',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              buildAvatarWidget(
                avatarId: _avatarId,
                radius: 40,
                borderColor: Colors.white.withValues(alpha: 0.5),
                borderWidth: 3,
              ),
              const SizedBox(height: 12),
              Text(
                _fullName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '🏛️ Petugas Kelurahan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '📅 Bergabung sejak ${_memberSince()}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Akun',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2E2A),
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.person_outline_rounded, 'Nama', _fullName),
          const Divider(height: 20),
          _infoRow(
            Icons.email_outlined,
            'Email',
            Supabase.instance.client.auth.currentUser?.email ?? '-',
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.verified_user_outlined,
            'Role',
            'Petugas Kelurahan',
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _actionTile(
            icon: Icons.lock_outline_rounded,
            label: 'Ubah Password',
            color: AppColors.primary,
            onTap: _showChangePasswordSheet,
          ),
          const Divider(height: 1, indent: 56),
          _actionTile(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            color: Colors.red[400]!,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: Colors.grey[500])),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2E2A))),
          ],
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E2A))),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.grey[300], size: 20),
    );
  }

  void _showChangePasswordSheet() {
    final pwCtrl      = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure1 = true, obscure2 = true;
    bool saving = false;

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
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
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
                Text('Ubah Password',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const SizedBox(height: 20),
                _pwField(ctx, pwCtrl, 'Password Baru', obscure1,
                    () => setSheet(() => obscure1 = !obscure1)),
                const SizedBox(height: 14),
                _pwField(ctx, confirmCtrl, 'Konfirmasi Password',
                    obscure2,
                    () => setSheet(() => obscure2 = !obscure2)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (pwCtrl.text != confirmCtrl.text) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Password tidak cocok',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13)),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            setSheet(() => saving = true);
                            try {
                              await Supabase.instance.client.auth
                                  .updateUser(UserAttributes(
                                      password: pwCtrl.text));
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Password berhasil diubah!',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13)),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            } catch (_) {
                              if (ctx.mounted) {
                                setSheet(() => saving = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Simpan',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pwField(BuildContext ctx, TextEditingController ctrl,
      String hint, bool obscure, VoidCallback onToggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppColors.primary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey[400],
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.fieldFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}
