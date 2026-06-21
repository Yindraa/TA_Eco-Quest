import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../services/report_service.dart';

class VerifikasiDetailSheet extends StatefulWidget {
  final Map<String, dynamic> report;
  final VoidCallback onDone;

  const VerifikasiDetailSheet({
    super.key,
    required this.report,
    required this.onDone,
  });

  @override
  State<VerifikasiDetailSheet> createState() => _VerifikasiDetailSheetState();
}

class _VerifikasiDetailSheetState extends State<VerifikasiDetailSheet> {
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool verified) async {
    setState(() => _isLoading = true);
    try {
      final result = await ReportService().verifyReport(
        reportId: widget.report['report_id'] as String,
        verified: verified,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      if (result['success'] == true) {
        widget.onDone();
        _snack(
          verified
              ? 'Laporan diverifikasi! Kini muncul di Peta Misi ✅'
              : 'Laporan ditolak dan tidak akan ditampilkan ❌',
          verified ? AppColors.primary : Colors.red[600]!,
        );
      } else {
        setState(() => _isLoading = false);
        _snack('Gagal memproses. Coba lagi.', Colors.red[400]!);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _snack('Terjadi kesalahan. Coba lagi.', Colors.red[400]!);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final wasteSize   = widget.report['waste_size']   as String? ?? '-';
    final imageUrl    = widget.report['image_url']    as String? ?? '';
    final description = widget.report['description']  as String?;
    final lat = (widget.report['latitude']  as num?)?.toDouble();
    final lng = (widget.report['longitude'] as num?)?.toDouble();
    final createdAt = DateTime.tryParse(
          widget.report['created_at'] as String? ?? '',
        ) ??
        DateTime.now();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final dateStr =
        '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}'
        ', ${createdAt.hour.toString().padLeft(2, '0')}'
        ':${createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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

            Text(
              'Detail Laporan',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2E2A),
              ),
            ),
            const SizedBox(height: 14),

            // Foto
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 100,
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image_outlined,
                        color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 14),

            _infoRow(Icons.delete_outline_rounded, 'Ukuran', 'Sampah $wasteSize'),
            const SizedBox(height: 8),
            _infoRow(Icons.schedule_rounded, 'Dilaporkan', dateStr),
            if (lat != null && lng != null) ...[
              const SizedBox(height: 8),
              _infoRow(
                Icons.location_on_rounded,
                'Koordinat',
                '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
              ),
            ],
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.notes_rounded, 'Keterangan', description),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            Text(
              'Catatan Verifikasi (opsional)',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2E2A),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan jika diperlukan...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[400]),
                filled: true,
                fillColor: AppColors.fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _submit(false),
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.red, size: 18),
                      label: Text(
                        'Tolak',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: Colors.red.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _submit(true),
                      icon: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18),
                      label: Text(
                        'Verifikasi',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: Colors.grey[500])),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E2A),
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
