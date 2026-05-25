import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/avatar_options.dart';
import '../../../core/theme.dart';
import '../../../models/user_model.dart';

class ProfilHeader extends StatelessWidget {
  final UserModel? profile;
  final VoidCallback onSettingsTap;
  final VoidCallback onAvatarTap;

  const ProfilHeader({
    super.key,
    required this.profile,
    required this.onSettingsTap,
    required this.onAvatarTap,
  });

  String _memberSince() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final raw = Supabase.instance.client.auth.currentUser?.createdAt;
    final date = raw != null ? DateTime.tryParse(raw) : null;
    if (date == null) return '-';
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profil',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: onSettingsTap,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: 'Pengaturan',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onAvatarTap,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    buildAvatarWidget(
                      avatarId: profile?.avatarId ?? 0,
                      radius: 42,
                      borderColor: Colors.white.withValues(alpha: 0.5),
                      borderWidth: 3,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile?.fullName ?? '...',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile?.levelName ?? 'Eco Newbie',
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
}
