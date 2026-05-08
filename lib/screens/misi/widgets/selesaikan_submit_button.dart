import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class SelesaikanSubmitButton extends StatelessWidget {
  final bool canSubmit;
  final bool gpsBlocked;
  final VoidCallback? onTap;

  const SelesaikanSubmitButton({
    super.key,
    required this.canSubmit,
    required this.gpsBlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = canSubmit && !gpsBlocked;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: enabled
              ? AppColors.buttonGradient
              : const LinearGradient(
                  colors: [Color(0xFFB0BEC5), Color(0xFFCFD8DC)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Kirim Bukti Penyelesaian',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
