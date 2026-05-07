import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../services/report_service.dart';

class ProfilReportHistory extends StatefulWidget {
  const ProfilReportHistory({super.key});

  @override
  State<ProfilReportHistory> createState() => _ProfilReportHistoryState();
}

class _ProfilReportHistoryState extends State<ProfilReportHistory> {
  String? _selectedFilter;
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  static const _filters = <(String, String?)>[
    ('Semua', null),
    ('Menunggu', 'pending'),
    ('Dikerjakan', 'claimed'),
    ('Validasi', 'resolved'),
    ('Tervalidasi', 'valid'),
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = ReportService().getMyReports(status: _selectedFilter);
  }

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
          Text(
            'Riwayat Laporan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2E2A),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f.$2;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedFilter = f.$2;
                      _loadReports();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        f.$1,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _reportsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                );
              }
              final reports = snap.data ?? [];
              if (reports.isEmpty) return _buildEmpty();
              return Column(
                children: reports.map(_buildReportItem).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final status = report['status'] as String? ?? 'pending';
    final wasteSize = report['waste_size'] as String? ?? '-';
    final createdAt =
        DateTime.tryParse(report['created_at'] as String? ?? '') ??
            DateTime.now();
    final imageUrl = report['image_url'] as String? ?? '';

    final (label, color) = switch (status) {
      'pending' => ('Menunggu', Colors.grey),
      'claimed' => ('Dikerjakan', const Color(0xFF2471A3)),
      'resolved' => ('Menunggu Validasi', Colors.orange),
      'valid' => ('Tervalidasi ✓', AppColors.primary),
      'rejected' => ('Ditolak', Colors.red),
      _ => ('Unknown', Colors.grey),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imageFallback(),
                  )
                : _imageFallback(),
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
                      fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 52,
      height: 52,
      color: AppColors.fieldFill,
      child: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.primary,
        size: 24,
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
          const Icon(Icons.inbox_outlined, size: 34, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Tidak ada laporan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E2A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedFilter == null
                ? 'Kamu belum membuat laporan.'
                : 'Tidak ada laporan dengan status ini.',
            style:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
