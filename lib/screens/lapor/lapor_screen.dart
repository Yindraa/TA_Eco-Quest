import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../services/report_service.dart';
import '../../widgets/lapor/camera_preview_widget.dart';
import '../../widgets/lapor/location_display_widget.dart';
import '../../widgets/lapor/waste_size_selector.dart';

class LaporScreen extends StatefulWidget {
  const LaporScreen({super.key});

  @override
  State<LaporScreen> createState() => _LaporScreenState();
}

class _LaporScreenState extends State<LaporScreen> {
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final _reportService = ReportService();

  Uint8List? _imageBytes;
  Position? _position;
  String? _selectedSize;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Foto (Kamera saja) ───────────────────────────────────────────────────

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
      setState(() => _imageBytes = bytes);
    } catch (e) {
      _showSnackBar('Gagal membuka kamera: ${e.toString()}');
    }
  }

  // ── Lokasi ───────────────────────────────────────────────────────────────

  Future<void> _getLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Layanan GPS tidak aktif. Aktifkan GPS terlebih dahulu.';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Izin lokasi ditolak.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Buka Pengaturan untuk mengaktifkan izin lokasi.';
          _isLoadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = pos;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Gagal mendapatkan lokasi.';
        _isLoadingLocation = false;
      });
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_imageBytes == null) {
      _showSnackBar('Mohon ambil foto sampah terlebih dahulu');
      return;
    }
    if (_position == null) {
      _showSnackBar('Mohon aktifkan lokasi GPS terlebih dahulu');
      return;
    }
    if (_selectedSize == null) {
      _showSnackBar('Mohon pilih ukuran sampah');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final imageUrl = await _reportService.uploadImage(_imageBytes!);
      await _reportService.createReport(
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        wasteSize: _selectedSize!,
        imageUrl: imageUrl,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      if (mounted) _showSuccessSheet();
    } on StorageException catch (e) {
      if (mounted) {
        _showSnackBar(
          e.message.contains('Bucket not found')
              ? 'Storage belum dikonfigurasi. Buat bucket "report-images" di Supabase.'
              : 'Gagal upload foto: ${e.message}',
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal mengirim laporan: ${e.toString()}');
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
                Icons.check_circle_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Laporan Berhasil Dikirim! 🎉',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Laporan kamu sedang menunggu verifikasi operator.\n'
              'EXP akan ditambahkan setelah laporan tervalidasi.',
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
                  Navigator.pop(context); // kembali ke HomeScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Kembali ke Beranda',
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

  bool get _canSubmit =>
      _imageBytes != null && _position != null && _selectedSize != null;

  // ── Build ────────────────────────────────────────────────────────────────

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
                      _sectionLabel('Foto Sampah', required: true),
                      const SizedBox(height: 10),
                      CameraPreviewWidget(
                        imageBytes: _imageBytes,
                        onTap: _takePhoto,
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 24),

                      _sectionLabel('Lokasi', required: true),
                      const SizedBox(height: 10),
                      LocationDisplayWidget(
                        position: _position,
                        isLoading: _isLoadingLocation,
                        error: _locationError,
                        onRefresh: _getLocation,
                      ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                      const SizedBox(height: 24),

                      _sectionLabel('Ukuran Sampah', required: true),
                      const SizedBox(height: 10),
                      WasteSizeSelector(
                        selectedSize: _selectedSize,
                        onChanged: (v) => setState(() => _selectedSize = v),
                      ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                      const SizedBox(height: 24),

                      _sectionLabel('Deskripsi', required: false),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText:
                                'Tambahkan keterangan tentang kondisi sampah (opsional)...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                      const SizedBox(height: 32),

                      _buildSubmitButton()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 250.ms),
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
                      'Mengirim laporan...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Mohon tunggu sebentar',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
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
              Text(
                'Lapor Sampah',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, {required bool required}) {
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
            )
          else
            TextSpan(
              text: '  (opsional)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _canSubmit ? _submit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _canSubmit
              ? AppColors.buttonGradient
              : const LinearGradient(
                  colors: [Color(0xFFB0BEC5), Color(0xFFCFD8DC)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _canSubmit
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
              const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Kirim Laporan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
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
