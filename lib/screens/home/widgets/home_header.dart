import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/avatar_options.dart';
import '../../../core/theme.dart';
import '../../../models/user_model.dart';

class HomeHeader extends StatelessWidget {
  final UserModel? profile;
  final bool isLoading;

  const HomeHeader({super.key, this.profile, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              buildAvatarWidget(
                avatarId: profile?.avatarId ?? 0,
                radius: 24,
                borderColor: Colors.white.withValues(alpha: 0.4),
                borderWidth: 2,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading
                          ? 'Memuat...'
                          : 'Halo, ${profile?.firstName ?? ''} 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Apa yang bisa kamu lakukan hari ini?',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
