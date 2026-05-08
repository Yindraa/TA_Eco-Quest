import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../services/report_service.dart';
import '../../widgets/lapor/camera_preview_widget.dart';
import 'widgets/selesaikan_gps_section.dart';
import 'widgets/selesaikan_submit_button.dart';

class SelesaikanMisiScreen extends StatefulWidget {
  final String reportId;
  final String originalImageUrl;
  final String wasteSize;
  final double? originalLat;
  final double? originalLng;

  const SelesaikanMisiScreen({
    super.key,
    required this.reportId,
    required this.originalImageUrl,
    required this.wasteSize,
    this.originalLat,
    this.originalLng,
  });

  @override
  State<SelesaikanMisiScreen> createState() => _SelesaikanMisiScreenState();
}

class _SelesaikanMisiScreenState extends State<SelesaikanMisiScreen> {
  final _picker = ImagePicker();
  final _reportService = ReportService();

  Uint8List? _resolvedImageBytes;
  bool _isSubmitting = false;

  bool _isCapturingGps = false;
  double? _distanceMeters;
  bool _gpsFailed = false;

  bool get _hasCoords =>
      widget.originalLat != null && widget.originalLng != null;

  @override
  void initState() {
    super.initState();
    if (_hasCoords) _captureGps();
  }

  Future<void> _captureGps() async {
    setState(() {
      _isCapturingGps = true;
      _gpsFailed = false;
      _distanceMeters = null;
    });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) setState(() { _isCapturingGps = false; _gpsFailed = true; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      final dist = Geolocator.distanceBetween(
        widget.originalLat!,
        widget.originalLng!,
        pos.latitude,
        pos.longitude,
      );
      setState(() {
        _distanceMeters = dist;
        _isCapturingGps = false;
      });
    } catch (_) {
      if (mounted) setState(() { _isCapturingGps = false; _gpsFailed = true; });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1280,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _resolvedImageBytes = bytes);
    } catch (e) {
      _showSnackBar('Gagal membuka kamera: ${e.toString()}');
    }
  }

  Future<void> _submit() async {
    if (_resolvedImageBytes == null) {
      _showSnackBar('Mohon ambil foto sesudah pembersihan terlebih dahulu');
      return;
    }

    // GPS validation
    if (_hasCoords && _distanceMeters != null) {
      if (_distanceMeters! > SelesaikanGpsSection.blockDist) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Lokasi Terlalu Jauh',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text(
              'Kamu berada ${_fmt(_distanceMeters!)} dari titik sampah. '
              'Kamu harus berada dalam ${_fmt(SelesaikanGpsSection.blockDist)} '
              'untuk dapat mengirim bukti penyelesaian.',
              style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Mengerti',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        );
        return;
      }

      if (_distanceMeters! > SelesaikanGpsSection.warnDist) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Konfirmasi Lokasi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text(
              'Kamu berada ${_fmt(_distanceMeters!)} dari titik sampah. '
              'Pastikan kamu sudah berada di lokasi yang tepat.',
              style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal',
                    style: GoogleFonts.poppins(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Lanjutkan',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final resolvedUrl =
          await _reportService.uploadResolvedImage(_resolvedImageBytes!);
      final expEarned = await _reportService.resolveReport(
        reportId: widget.reportId,
        resolvedImageUrl: resolvedUrl,
      );
      if (mounted) {
        homeRefreshNotifier.value++; // refresh profil + pohon
        _showSuccessSheet(expEarned);
      }
    } on StorageException catch (e) {
      if (mounted) _showSnackBar('Gagal upload foto: ${e.message}');
    } catch (e) {
      if (mounted) _showSnackBar('Gagal mengirim: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _fmt(double m) =>
      m < 1000 ? '${m.toStringAsFixed(0)} m' : '${(m / 1000).toStringAsFixed(1)} km';

  void _showSuccessSheet(int expEarned) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: AppColors.fieldFill, shape: BoxShape.circle),
              child: const Icon(Icons.handshake_rounded,
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Misi Berhasil Diselesaikan! 🎉',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // EXP badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC107)),
              ),
              child: Text(
                '+$expEarned EXP diperoleh! ✨',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF856404),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Foto bukti telah dikirim dan sedang menunggu\n'
              'validasi Operator.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Kembali ke Peta',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gpsBlocked = _hasCoords &&
        _distanceMeters != null &&
        _distanceMeters! > SelesaikanGpsSection.blockDist;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.surface,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF2471A3)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Color(0xFF2471A3), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ambil foto dari sudut yang sama dengan '
                                '"Foto Sebelum" sebagai bukti pembersihan.',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF1A5276),
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Foto Sebelum
                      _label('Foto Sebelum'),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.originalImageUrl.isNotEmpty
                            ? Image.network(
                                widget.originalImageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _imgPlaceholder(),
                              )
                            : _imgPlaceholder(),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 20),

                      // Foto Sesudah
                      _label('Foto Sesudah', required: true),
                      const SizedBox(height: 10),
                      CameraPreviewWidget(
                        imageBytes: _resolvedImageBytes,
                        onTap: _takePhoto,
                      ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                      // GPS Section
                      if (_hasCoords) ...[
                        const SizedBox(height: 20),
                        _label('Verifikasi Lokasi'),
                        const SizedBox(height: 10),
                        SelesaikanGpsSection(
                          isLoading: _isCapturingGps,
                          failed: _gpsFailed,
                          distanceMeters: _distanceMeters,
                          onRetry: _captureGps,
                        ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                      ],

                      const SizedBox(height: 32),
                      SelesaikanSubmitButton(
                        canSubmit: _resolvedImageBytes != null,
                        gpsBlocked: gpsBlocked,
                        onTap: _submit,
                      ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Loading overlay
        if (_isSubmitting)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text('Mengirim bukti penyelesaian...',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selesaikan Misi',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(
                      'Sampah ${widget.wasteSize} · Kirim foto sesudah',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2E2A)),
          ),
          if (required)
            TextSpan(
              text: ' *',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        height: 180,
        color: Colors.grey[100],
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
        ),
      );
}
