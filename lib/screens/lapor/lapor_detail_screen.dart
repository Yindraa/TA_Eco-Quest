import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class LaporDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const LaporDetailScreen({super.key, required this.report});

  // ── Computed fields ─────────────────────────────────────────────────────────

  String get _wasteSize => report['waste_size'] as String? ?? '-';
  String get _status => report['status'] as String? ?? 'pending';
  String? get _imageUrl => report['image_url'] as String?;
  String? get _resolvedImageUrl => report['resolved_image_url'] as String?;
  String? get _description => report['description'] as String?;
  String? get _rejectionReason => report['rejection_reason'] as String?;
  DateTime get _createdAt =>
      DateTime.tryParse(report['created_at'] as String? ?? '') ??
      DateTime.now();

  bool get _isClaimed =>
      _status == 'claimed' || _status == 'resolved' || _status == 'valid';
  bool get _hasProof =>
      (_status == 'resolved' || _status == 'valid') &&
      (_resolvedImageUrl?.isNotEmpty ?? false);

  (String, Color) get _statusInfo => switch (_status) {
        'pending' => ('Menunggu Diambil', Colors.grey),
        'claimed' => ('Sedang Dikerjakan', const Color(0xFF2471A3)),
        'resolved' => ('Menunggu Validasi', Colors.orange),
        'valid' => ('Tervalidasi ✓', AppColors.primary),
        'rejected' => ('Ditolak', Colors.red),
        _ => ('Tidak Diketahui', Colors.grey),
      };

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status timeline
                  _buildTimeline()
                      .animate()
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 12),

                  // Banner alasan penolakan (dari Operator via web dashboard)
                  if (_status == 'rejected' &&
                      _rejectionReason != null &&
                      _rejectionReason!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.red[300]!.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.cancel_outlined,
                              color: Colors.red[600], size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alasan Penolakan',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700]),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _rejectionReason!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red[800],
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 60.ms),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),

                  // Foto laporan asli
                  if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                    _label('Foto Laporan'),
                    const SizedBox(height: 10),
                    _networkPhoto(_imageUrl!, height: 200)
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 80.ms),
                    const SizedBox(height: 20),
                  ],

                  // Info card
                  _buildInfoCard()
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 120.ms),

                  // Bukti pembersihan
                  if (_hasProof) ...[
                    const SizedBox(height: 24),
                    _buildProofSection()
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 160.ms),
                  ] else if (_isClaimed && !_hasProof) ...[
                    const SizedBox(height: 20),
                    _buildClaimedInfo()
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 160.ms),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final (statusLabel, _) = _statusInfo;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
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
                    Text(
                      'Detail Laporan',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      'Sampah $_wasteSize · ${_formatDate(_createdAt)}',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status Timeline ──────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    final isRejected = _status == 'rejected';
    final steps = [
      ('Dilaporkan', true, null),
      ('Diambil', _isClaimed || isRejected, null),
      ('Bukti\nDikirim', _status == 'resolved' || _status == 'valid', null),
      (isRejected ? 'Ditolak' : 'Divalidasi', _status == 'valid' || isRejected,
          isRejected ? Colors.red[600]! : null),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _stepDot(steps[i].$1, steps[i].$2, colorOverride: steps[i].$3),
            if (i < steps.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    height: 2,
                    color: steps[i].$2 && steps[i + 1].$2
                        ? (steps[i + 1].$3 ?? AppColors.primary)
                        : Colors.grey[200],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _stepDot(String label, bool done, {Color? colorOverride}) {
    final activeColor = colorOverride ?? AppColors.primary;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done ? activeColor : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.circle_outlined,
            color: done ? Colors.white : Colors.grey[400],
            size: 13,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 52,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              color: done ? activeColor : Colors.grey[400],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
              Icons.delete_outline_rounded, 'Ukuran Sampah', 'Sampah $_wasteSize'),
          const Divider(height: 20),
          _infoRow(Icons.schedule_rounded, 'Tanggal Laporan',
              _formatDate(_createdAt)),
          if (_description != null && _description!.isNotEmpty) ...[
            const Divider(height: 20),
            _infoRow(Icons.notes_rounded, 'Keterangan', _description!),
          ],
        ],
      ),
    );
  }

  // ── Claimed Info (belum ada bukti) ────────────────────────────────────────────

  Widget _buildClaimedInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FB),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF2471A3).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.handshake_outlined,
              color: Color(0xFF2471A3), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Laporan ini sedang dikerjakan oleh seorang pengguna. '
              'Bukti pembersihan akan muncul di sini setelah dikirim.',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF1A5276),
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Proof Section ─────────────────────────────────────────────────────────────

  Widget _buildProofSection() {
    final isValid = _status == 'valid';
    final color = isValid ? AppColors.primary : Colors.orange[700]!;
    final icon = isValid
        ? Icons.verified_rounded
        : Icons.pending_actions_rounded;
    final message = isValid
        ? 'Laporan ini telah divalidasi oleh Operator ✓'
        : 'Bukti pembersihan telah dikirim, menunggu validasi Operator';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Bukti Pembersihan'),
        const SizedBox(height: 10),

        // Status chip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Proof photo
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _networkPhoto(_resolvedImageUrl!, height: 220),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Sesudah',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Widget _networkPhoto(String url, {double height = 200}) {
    return Image.network(
      url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: double.infinity,
        height: height,
        color: Colors.grey[100],
        child: const Center(
          child:
              Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A2E2A)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: Colors.grey[500])),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A2E2A))),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
