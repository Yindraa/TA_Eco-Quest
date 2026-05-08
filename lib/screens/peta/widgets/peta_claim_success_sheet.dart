import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

/// Bottom-sheet konfirmasi keberhasilan klaim misi.
///
/// [onSelesaikanSekarang] — dipanggil ketika user tap "Selesaikan Sekarang".
/// [onSelesaikanNanti] — dipanggil ketika user tap "Selesaikan Nanti".
class PetaClaimSuccessSheet extends StatelessWidget {
  final VoidCallback onSelesaikanSekarang;
  final VoidCallback onSelesaikanNanti;

  const PetaClaimSuccessSheet({
    super.key,
    required this.onSelesaikanSekarang,
    required this.onSelesaikanNanti,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AppColors.fieldFill,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handshake_rounded,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Misi Berhasil Diambil! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pergi ke lokasi, bersihkan sampah,\n'
            'lalu kirim foto bukti penyelesaian.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 24),

          // Selesaikan Sekarang
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 18),
              label: Text(
                'Selesaikan Sekarang',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onSelesaikanSekarang,
            ),
          ),
          const SizedBox(height: 12),

          // Selesaikan Nanti
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onSelesaikanNanti,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Selesaikan Nanti (ada di Beranda)',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
