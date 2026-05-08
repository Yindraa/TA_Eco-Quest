import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    if (isLoading) return _buildLoadingState();
    if (error != null) return _buildErrorState();
    if (position != null) return _buildMapState();
    return _buildEmptyState();
  }

  // ── Map preview (lokasi terdeteksi) ─────────────────────────────────────────

  Widget _buildMapState() {
    final latLng = LatLng(position!.latitude, position!.longitude);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Map
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 170,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: latLng,
                  zoom: 16.5,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('laporan'),
                    position: latLng,
                    infoWindow: const InfoWindow(title: 'Lokasi Laporan'),
                  ),
                },
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                liteModeEnabled: false,
              ),
            ),
          ),

          // Info row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: AppColors.fieldFill,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi terdeteksi ✓',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${position!.latitude.toStringAsFixed(5)}, '
                        '${position!.longitude.toStringAsFixed(5)}',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                _refreshButton('Perbarui', AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return _baseContainer(
      borderColor: Colors.grey.shade200,
      child: Row(
        children: [
          _iconCircle(Icons.location_on_rounded, Colors.grey.shade100,
              Colors.grey.shade400),
          const SizedBox(width: 12),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Text('Mendeteksi lokasi...',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return _baseContainer(
      borderColor: Colors.red.shade200,
      child: Row(
        children: [
          _iconCircle(
              Icons.location_off_rounded, Colors.red.shade50, Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(error!,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.red[600])),
                Text('Tap untuk coba lagi',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          _refreshButton('Coba Lagi', Colors.red.shade600),
        ],
      ),
    );
  }

  // ── Empty (belum ambil lokasi) ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    return _baseContainer(
      borderColor: Colors.grey.shade200,
      child: Row(
        children: [
          _iconCircle(Icons.location_on_rounded, Colors.grey.shade100,
              Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lokasi belum diambil',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey[600])),
                Text('Aktifkan GPS untuk menandai lokasi',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          _refreshButton('Ambil', AppColors.primary),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _baseContainer({required Color borderColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconCircle(IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _refreshButton(String label, Color color) {
    return TextButton(
      onPressed: onRefresh,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
