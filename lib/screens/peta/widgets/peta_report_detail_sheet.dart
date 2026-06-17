import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

/// Bottom-sheet konten detail laporan di Peta Misi.
///
/// [onSelesaikan] — dipanggil ketika user tap "Selesaikan Misi!" (isMyMission).
/// [onClaimConfirmed] — dipanggil setelah dialog konfirmasi "Ya, Ambil!" disetujui.
class PetaReportDetailSheet extends StatelessWidget {
  final Map<String, dynamic> report;
  final String currentUserId;
  final VoidCallback onSelesaikan;
  final VoidCallback onClaimConfirmed;

  const PetaReportDetailSheet({
    super.key,
    required this.report,
    required this.currentUserId,
    required this.onSelesaikan,
    required this.onClaimConfirmed,
  });

  // ── Computed fields ─────────────────────────────────────────────────────────

  String get _userId => report['user_id'] as String? ?? '';
  String get _wasteSize => report['waste_size'] as String? ?? '-';
  String get _status => report['status'] as String? ?? 'pending';
  String? get _imageUrl => report['image_url'] as String?;
  String? get _description => report['description'] as String?;
  String? get _solverId => report['solver_id'] as String?;
  DateTime? get _createdAt =>
      DateTime.tryParse(report['created_at'] as String? ?? '');

  bool get _isMyReport => _userId == currentUserId;
  bool get _isMyMission => _solverId == currentUserId && _status == 'claimed';
  bool get _isPending => _status == 'pending';
  bool get _canBeClaimed => _wasteSize == 'Kecil'; // sesuai proposal

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                _statusBadge(_status),
              ],
            ),
            const SizedBox(height: 16),

            // Foto
            if (_imageUrl != null && _imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  _imageUrl!,
                  height: 180,
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

            // Info rows
            _infoRow(Icons.delete_outline_rounded, 'Ukuran Sampah',
                'Sampah $_wasteSize'),
            const SizedBox(height: 8),
            if (_description != null && _description!.isNotEmpty) ...[
              _infoRow(Icons.notes_rounded, 'Keterangan', _description!),
              const SizedBox(height: 8),
            ],
            if (_createdAt != null)
              _infoRow(Icons.schedule_rounded, 'Dilaporkan',
                  _formatDate(_createdAt!)),
            const SizedBox(height: 20),

            // Action
            _buildAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    if (_isMyMission) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white),
          label: Text(
            'Selesaikan Misi!',
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2471A3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onSelesaikan,
        ),
      );
    }

    if (_isMyReport) {
      return _chip(Icons.person_rounded, 'Ini laporan milikmu', AppColors.primary);
    }

    if (!_isPending) {
      return _chip(Icons.check_circle_outline_rounded,
          'Misi sudah diklaim oleh pengguna lain', const Color(0xFF2471A3));
    }

    if (!_canBeClaimed) {
      return _chip(Icons.info_outline_rounded,
          'Sampah $_wasteSize hanya bisa ditangani operator', Colors.orange);
    }

    // Pending + Kecil + bukan milikku
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.handshake_outlined, color: Colors.white),
        label: Text(
          'Ambil Misi Ini!',
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _confirmClaim(context),
      ),
    );
  }

  Future<void> _confirmClaim(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ambil Misi?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Kamu akan bertanggung jawab membersihkan lokasi ini. Lanjutkan?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
    if (confirm == true) onClaimConfirmed();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
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
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
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
                    color: const Color(0xFF1A2E2A)),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
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
                  color: color),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
