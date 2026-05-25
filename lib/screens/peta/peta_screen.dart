import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../services/report_service.dart';
import '../misi/selesaikan_misi_screen.dart';
import 'widgets/peta_claim_success_sheet.dart';
import 'widgets/peta_map_header.dart';
import 'widgets/peta_map_legend.dart';
import 'widgets/peta_report_detail_sheet.dart';

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

  static const _manado = CameraPosition(
    target: LatLng(1.4748, 124.8421),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _reportService.getMissionReports();
      final markers = _buildMarkers(reports);
      if (mounted) {
        setState(() {
          _markers = markers;
          _pendingCount =
              reports.where((r) => r['status'] == 'pending').length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Markers ───────────────────────────────────────────────────────────────────

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
          snippet:
              status == 'claimed' ? 'Sudah diklaim' : 'Tap untuk lihat detail',
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
      'Kecil' =>
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      'Sedang' =>
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      'Besar' =>
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      _ => BitmapDescriptor.defaultMarker,
    };
  }

  // ── Location ──────────────────────────────────────────────────────────────────

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

  // ── Bottom Sheets ─────────────────────────────────────────────────────────────

  void _showReportDetail(Map<String, dynamic> report) {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';
    final reportId = report['report_id'] as String;
    final imageUrl = report['image_url'] as String? ?? '';
    final wasteSize = report['waste_size'] as String? ?? '-';
    final lat = (report['latitude'] as num?)?.toDouble();
    final lng = (report['longitude'] as num?)?.toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => PetaReportDetailSheet(
        report: report,
        currentUserId: currentUserId,
        onSelesaikan: () {
          Navigator.pop(ctx);
          _navigateToSelesaikan(reportId, imageUrl, wasteSize, lat, lng);
        },
        onClaimConfirmed: () =>
            _processClaim(ctx, reportId, imageUrl, wasteSize, lat, lng),
      ),
    );
  }

  void _showClaimSuccessSheet({
    required String reportId,
    required String imageUrl,
    required String wasteSize,
    double? lat,
    double? lng,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PetaClaimSuccessSheet(
        onSelesaikanSekarang: () {
          Navigator.pop(context);
          _navigateToSelesaikan(reportId, imageUrl, wasteSize, lat, lng);
        },
        onSelesaikanNanti: () => Navigator.pop(context),
      ),
    );
  }

  // ── Mission actions ────────────────────────────────────────────────────────────

  Future<void> _processClaim(
    BuildContext sheetCtx,
    String reportId,
    String imageUrl,
    String wasteSize,
    double? lat,
    double? lng,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _reportService.claimMission(reportId);
      if (!mounted) return;
      if (sheetCtx.mounted) Navigator.pop(sheetCtx);

      setState(() {
        _markers =
            _markers.where((m) => m.markerId.value != reportId).toSet();
      });
      homeRefreshNotifier.value++;
      _loadReports();

      _showClaimSuccessSheet(
        reportId: reportId,
        imageUrl: imageUrl,
        wasteSize: wasteSize,
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  Future<void> _navigateToSelesaikan(
    String reportId,
    String imageUrl,
    String wasteSize,
    double? lat,
    double? lng,
  ) async {
    final resolved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SelesaikanMisiScreen(
          reportId: reportId,
          originalImageUrl: imageUrl,
          wasteSize: wasteSize,
          originalLat: lat,
          originalLng: lng,
        ),
      ),
    );
    if (resolved == true) {
      setState(() {
        _markers =
            _markers.where((m) => m.markerId.value != reportId).toSet();
      });
      homeRefreshNotifier.value++;
      _loadReports();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _manado,
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          PetaMapHeader(
            isLoading: _isLoading,
            pendingCount: _pendingCount,
            onRefresh: _loadReports,
          ),

          // Empty state saat tidak ada misi tersedia
          if (!_isLoading && _markers.isEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.fieldFill,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.map_outlined,
                          size: 36, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak Ada Misi Tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A2E2A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada laporan sampah yang\nmenunggu untuk dibersihkan.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

          const PetaMapLegend(),

          // FAB lokasiku (kanan bawah)
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.my_location_rounded,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
