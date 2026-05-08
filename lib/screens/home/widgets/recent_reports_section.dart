import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../lapor/lapor_detail_screen.dart';

class RecentReportsSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> reportsFuture;

  const RecentReportsSection({super.key, required this.reportsFuture});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Laporan Terbaru',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2E2A),
                ),
              ),
              Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: reportsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _buildLoading();
              }
              final reports = snap.data ?? [];
              if (reports.isEmpty) return _buildEmpty();
              return Column(
                children: reports
                    .map((r) => _buildReportItem(context, r))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, Map<String, dynamic> report) {
    final status = report['status'] as String? ?? 'pending';
    final wasteSize = report['waste_size'] as String? ?? '-';
    final createdAt = DateTime.tryParse(
          report['created_at'] as String? ?? '',
        ) ??
        DateTime.now();

    final (label, color, icon) = switch (status) {
      'pending'  => ('Menunggu Diambil', Colors.grey,
          Icons.hourglass_empty_rounded),
      'claimed'  => ('Sedang Dikerjakan', const Color(0xFF2471A3),
          Icons.handshake_outlined),
      'resolved' => ('Menunggu Validasi', Colors.orange,
          Icons.pending_actions_rounded),
      'valid'    => ('Tervalidasi ✓', AppColors.primary,
          Icons.verified_rounded),
      'rejected' => ('Ditolak', Colors.red, Icons.cancel_outlined),
      _          => ('Tidak Diketahui', Colors.grey,
          Icons.help_outline_rounded),
    };

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LaporDetailScreen(report: report),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sampah $wasteSize',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E2A),
                    ),
                  ),
                  Text(
                    _formatDate(createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.fieldFill,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined,
                size: 34, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada laporan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E2A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jadilah yang pertama melaporkan\nsampah di sekitarmu!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
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
}
