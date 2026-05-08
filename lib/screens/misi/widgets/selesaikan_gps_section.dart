import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class SelesaikanGpsSection extends StatelessWidget {
  final bool isLoading;
  final bool failed;
  final double? distanceMeters;
  final VoidCallback onRetry;

  static const double warnDist = 200.0;
  static const double blockDist = 500.0;

  const SelesaikanGpsSection({
    super.key,
    required this.isLoading,
    required this.failed,
    required this.distanceMeters,
    required this.onRetry,
  });

  String _fmt(double m) =>
      m < 1000 ? '${m.toStringAsFixed(0)} m' : '${(m / 1000).toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _tile(
        color: Colors.grey,
        icon: null,
        loading: true,
        title: 'Mendeteksi lokasi kamu...',
        sub: 'GPS sedang diaktifkan',
      );
    }

    if (failed || distanceMeters == null) {
      return _tile(
        color: Colors.orange,
        icon: Icons.location_off_rounded,
        loading: false,
        title: 'GPS tidak dapat dideteksi',
        sub: 'Validasi lokasi tidak tersedia',
        onRetry: onRetry,
      );
    }

    final d = distanceMeters!;

    if (d > blockDist) {
      return _tile(
        color: Colors.red[600]!,
        icon: Icons.wrong_location_rounded,
        loading: false,
        title: 'Terlalu jauh dari lokasi (${_fmt(d)})',
        sub: 'Kamu harus berada dalam ${_fmt(blockDist)} dari titik sampah',
      );
    }

    if (d > warnDist) {
      return _tile(
        color: Colors.orange[700]!,
        icon: Icons.location_searching_rounded,
        loading: false,
        title: 'Cukup dekat dengan lokasi (${_fmt(d)})',
        sub: 'Lebih baik jika berada tepat di titik sampah',
      );
    }

    return _tile(
      color: AppColors.primary,
      icon: Icons.location_on_rounded,
      loading: false,
      title: 'Lokasi terverifikasi ✓',
      sub: 'Kamu berada ${_fmt(d)} dari titik sampah',
    );
  }

  Widget _tile({
    required Color color,
    required IconData? icon,
    required bool loading,
    required String title,
    required String sub,
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: color,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
