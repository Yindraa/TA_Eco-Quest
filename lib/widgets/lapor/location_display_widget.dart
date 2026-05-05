import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class LocationDisplayWidget extends StatelessWidget {
  final Position? position;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const LocationDisplayWidget({
    super.key,
    required this.position,
    required this.isLoading,
    required this.onRefresh,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: position != null
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: position != null ? AppColors.fieldFill : Colors.grey[100]!,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: position != null ? AppColors.primary : Colors.grey[400],
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Mendeteksi lokasi...',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      );
    }

    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error!,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.red[600]),
          ),
          Text(
            'Tap untuk coba lagi',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      );
    }

    if (position != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lokasi terdeteksi ✓',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            '${position!.latitude.toStringAsFixed(6)}, '
            '${position!.longitude.toStringAsFixed(6)}',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi belum diambil',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        ),
        Text(
          'Aktifkan GPS untuk menandai lokasi',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildAction() {
    if (isLoading) return const SizedBox.shrink();
    return TextButton(
      onPressed: onRefresh,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        position != null ? 'Perbarui' : 'Ambil',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
