import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/user_model.dart';
import 'exp_history_sheet.dart';

class ProfilLevelCard extends StatelessWidget {
  final UserModel profile;

  const ProfilLevelCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.military_tech_rounded,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Perkembangan Level',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E2A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.levelName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: profile.levelProgress,
                minHeight: 10,
                backgroundColor: AppColors.fieldFill,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${profile.totalPoints} EXP',
                  style:
                      GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                ),
                if (profile.isMaxLevel)
                  Text(
                    'Level Maksimum 🎉',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Text(
                    '${profile.pointsToNextLevel} EXP lagi ke level berikutnya',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey[100], height: 1),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showExpHistorySheet(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Lihat riwayat perolehan EXP',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 13, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
