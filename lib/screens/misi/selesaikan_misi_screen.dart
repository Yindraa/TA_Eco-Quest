import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../services/report_service.dart';
import '../../widgets/lapor/camera_preview_widget.dart';

class SelesaikanMisiScreen extends StatefulWidget {
  final String reportId;
  final String originalImageUrl;
  final String wasteSize;

  const SelesaikanMisiScreen({
    super.key,
    required this.reportId,
    required this.originalImageUrl,
    required this.wasteSize,
  });

  @override
  State<SelesaikanMisiScreen> createState() => _SelesaikanMisiScreenState();
}

class _SelesaikanMisiScreenState extends State<SelesaikanMisiScreen> {
  final _picker = ImagePicker();
  final _reportService = ReportService();

  Uint8List? _resolvedImageBytes;
  bool _isSubmitting = false;

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

    setState(() => _isSubmitting = true);
    try {
      final resolvedUrl = await _reportService.uploadResolvedImage(
        _resolvedImageBytes!,
      );
      await _reportService.resolveReport(
        reportId: widget.reportId,
        resolvedImageUrl: resolvedUrl,
      );
      if (mounted) _showSuccessSheet();
    } on StorageException catch (e) {
      if (mounted) _showSnackBar('Gagal upload foto: ${e.message}');
    } catch (e) {
      if (mounted) _showSnackBar('Gagal mengirim: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessSheet() {
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
                color: AppColors.fieldFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handshake_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Misi Berhasil Diselesaikan! 🎉',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Laporan kamu sedang menunggu validasi operator.\n'
              'EXP akan ditambahkan setelah divalidasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // tutup sheet
                  Navigator.pop(
                    context,
                    true,
                  ); // kembali ke peta, beri signal refresh
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Kembali ke Peta',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            color: const Color(
                              0xFF2471A3,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF2471A3),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ambil foto dari sudut yang sama dengan '
                                '"Foto Sebelum" sebagai bukti pembersihan.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF1A5276),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Foto Sebelum (original)
                      _sectionLabel('Foto Sebelum'),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.originalImageUrl.isNotEmpty
                            ? Image.network(
                                widget.originalImageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 20),

                      // Foto Sesudah (kamera)
                      _sectionLabel('Foto Sesudah', required: true),
                      const SizedBox(height: 10),
                      CameraPreviewWidget(
                        imageBytes: _resolvedImageBytes,
                        onTap: _takePhoto,
                      ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                      const SizedBox(height: 32),

                      // Submit button
                      _buildSubmitButton().animate().fadeIn(
                        duration: 300.ms,
                        delay: 200.ms,
                      ),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Mengirim bukti penyelesaian...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selesaikan Misi',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Sampah ${widget.wasteSize} · Kirim foto sesudah',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
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

  Widget _sectionLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2E2A),
            ),
          ),
          if (required)
            TextSpan(
              text: ' *',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _resolvedImageBytes != null;
    return GestureDetector(
      onTap: canSubmit ? _submit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: canSubmit
              ? AppColors.buttonGradient
              : const LinearGradient(
                  colors: [Color(0xFFB0BEC5), Color(0xFFCFD8DC)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: canSubmit
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
