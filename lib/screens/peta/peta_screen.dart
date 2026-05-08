import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../services/report_service.dart';
import '../misi/selesaikan_misi_screen.dart';

class PetaScreen extends StatefulWidget {
  const PetaScreen({super.key});

  @override
  State<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> {
  GoogleMapController? _mapController;
  final _reportService = ReportService();

  Set<Marker> _markers = {};
  bool _isLoading = true;
  int _pendingCount = 0;

  // Pusat peta: Kota Manado, Sulawesi Utara
  static const _manado = CameraPosition(
    target: LatLng(1.4748, 124.8421),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _reportService.getMissionReports();
      final markers = _buildMarkers(reports);
      if (mounted) {
        setState(() {
          _markers = markers;
          _pendingCount = reports.where((r) => r['status'] == 'pending').length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Markers ──────────────────────────────────────────────────────────────

  Set<Marker> _buildMarkers(List<Map<String, dynamic>> reports) {
    return reports.map((report) {
      final lat = (report['latitude'] as num).toDouble();
      final lng = (report['longitude'] as num).toDouble();
      final wasteSize = report['waste_size'] as String? ?? 'Kecil';
      final status = report['status'] as String? ?? 'pending';

      return Marker(
        markerId: MarkerId(report['report_id'] as String),
        position: LatLng(lat, lng),
        icon: _markerIcon(wasteSize, status),
        infoWindow: InfoWindow(
          title: 'Sampah $wasteSize',
          snippet: status == 'claimed'
              ? 'Sudah diklaim'
              : 'Tap untuk lihat detail',
        ),
        onTap: () => _showReportDetail(report),
      );
    }).toSet();
  }

  BitmapDescriptor _markerIcon(String wasteSize, String status) {
    if (status == 'claimed') {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
    return switch (wasteSize) {
      'Kecil' => BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      'Sedang' => BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueOrange,
      ),
      'Besar' => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      _ => BitmapDescriptor.defaultMarker,
    };
  }

  // ── Go to current location ───────────────────────────────────────────────

  Future<void> _goToMyLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15),
      );
    } catch (_) {}
  }

  // ── Report Detail Bottom Sheet ───────────────────────────────────────────

  void _showReportDetail(Map<String, dynamic> report) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final reportId = report['report_id'] as String;
    final userId = report['user_id'] as String;
    final wasteSize = report['waste_size'] as String? ?? '-';
    final status = report['status'] as String? ?? 'pending';
    final imageUrl = report['image_url'] as String?;
    final description = report['description'] as String?;
    final createdAt = DateTime.tryParse(report['created_at'] as String? ?? '');

    final solverId = report['solver_id'] as String?;
    final isMyReport = userId == currentUserId;
    final isMyMission = solverId == currentUserId && status == 'claimed';
    final isPending = status == 'pending';
    // Sesuai proposal: hanya sampah Kecil yang bisa diklaim oleh sesama user
    final canBeClaimed = wasteSize == 'Kecil';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
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
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Laporan',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A2E2A),
                        ),
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 16),

                // Foto
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 100,
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),

                // Info grid
                _infoRow(
                  Icons.delete_outline_rounded,
                  'Ukuran Sampah',
                  'Sampah $wasteSize',
                ),
                const SizedBox(height: 8),
                if (description != null && description.isNotEmpty)
                  _infoRow(Icons.notes_rounded, 'Keterangan', description),
                if (description != null && description.isNotEmpty)
                  const SizedBox(height: 8),
                if (createdAt != null)
                  _infoRow(
                    Icons.schedule_rounded,
                    'Dilaporkan',
                    _formatDate(createdAt),
                  ),
                const SizedBox(height: 20),

                // Action button
                if (isMyMission)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Selesaikan Misi!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2471A3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final resolved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelesaikanMisiScreen(
                              reportId: reportId,
                              originalImageUrl: imageUrl ?? '',
                              wasteSize: wasteSize,
                            ),
                          ),
                        );
                        if (resolved == true) {
                          setState(() {
                            _markers = _markers
                                .where((m) => m.markerId.value != reportId)
                                .toSet();
                          });
                          homeRefreshNotifier.value++;
                          _loadReports();
                        }
                      },
                    ),
                  )
                else if (isMyReport)
                  _infoChip(
                    icon: Icons.person_rounded,
                    label: 'Ini laporan milikmu',
                    color: AppColors.primary,
                  )
                else if (!isPending)
                  _infoChip(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Misi sudah diklaim oleh pengguna lain',
                    color: const Color(0xFF2471A3),
                  )
                else if (!canBeClaimed)
                  _infoChip(
                    icon: Icons.info_outline_rounded,
                    label: 'Sampah $wasteSize hanya bisa ditangani operator',
                    color: Colors.orange,
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.handshake_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Ambil Misi Ini!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _claimMission(
                        ctx,
                        reportId,
                        setSheetState,
                        imageUrl ?? '',
                        wasteSize,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _claimMission(
    BuildContext sheetCtx,
    String reportId,
    StateSetter setSheetState,
    String imageUrl,
    String wasteSize,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: sheetCtx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ambil Misi?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Kamu akan bertanggung jawab membersihkan lokasi ini. Lanjutkan?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(sheetCtx, false),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(sheetCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Ya, Ambil!',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _reportService.claimMission(reportId);
      if (mounted) {
        Navigator.pop(sheetCtx);

        // Optimistic: hapus marker lama seketika agar tidak bisa diklaim lagi
        setState(() {
          _markers = _markers
              .where((m) => m.markerId.value != reportId)
              .toSet();
        });

        // Beri tahu HomeScreen untuk refresh misi aktif
        homeRefreshNotifier.value++;

        // Refresh penuh marker di background (akan tambah kembali marker biru)
        _loadReports();

        _showClaimSuccessSheet(
          reportId: reportId,
          imageUrl: imageUrl,
          wasteSize: wasteSize,
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil misi: ${e.toString()}',
                style: GoogleFonts.poppins(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showClaimSuccessSheet({
    required String reportId,
    required String imageUrl,
    required String wasteSize,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
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
                onPressed: () async {
                  Navigator.pop(context); // tutup sheet ini
                  final resolved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelesaikanMisiScreen(
                        reportId: reportId,
                        originalImageUrl: imageUrl,
                        wasteSize: wasteSize,
                      ),
                    ),
                  );
                  if (resolved == true) {
                    setState(() {
                      _markers = _markers
                          .where((m) => m.markerId.value != reportId)
                          .toSet();
                    });
                    homeRefreshNotifier.value++;
                    _loadReports();
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Selesaikan Nanti
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
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
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _statusBadge(String status) {
    final (label, color) = switch (status) {
      'pending' => ('Menunggu', Colors.orange),
      'claimed' => ('Diklaim', const Color(0xFF2471A3)),
      _ => ('Unknown', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A2E2A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: _manado,
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Header card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peta Misi',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _isLoading
                                  ? 'Memuat laporan...'
                                  : '$_pendingCount misi tersedia',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Refresh
                      IconButton(
                        onPressed: _loadReports,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Legend card (kiri bawah)
          Positioned(
            bottom: 100,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keterangan',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _legendItem('🟢', 'Kecil'),
                  _legendItem('🟡', 'Sedang'),
                  _legendItem('🔴', 'Besar'),
                  _legendItem('🔵', 'Diklaim'),
                ],
              ),
            ),
          ),

          // FAB lokasiku (kanan bawah)
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              elevation: 4,
              mini: false,
              child: const Icon(
                Icons.my_location_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
