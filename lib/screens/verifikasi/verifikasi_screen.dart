import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/report_service.dart';
import 'widgets/verifikasi_detail_sheet.dart';

class VerifikasiScreen extends StatefulWidget {
  const VerifikasiScreen({super.key});

  @override
  State<VerifikasiScreen> createState() => _VerifikasiScreenState();
}

class _VerifikasiScreenState extends State<VerifikasiScreen> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _reportsFuture = ReportService().getUnverifiedReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _reportsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final reports = snap.data ?? [];
                if (reports.isEmpty) return _buildEmpty();
                return RefreshIndicator(
                  onRefresh: () async => setState(_load),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    itemCount: reports.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _VerifikasiCard(
                      report: reports[i],
                      onDone: () => setState(_load),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verifikasi Laporan',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Konfirmasi sebelum muncul di Peta Misi',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(_load),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Muat ulang',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✅', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Semua Laporan Sudah Diproses',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E2A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada laporan baru yang menunggu verifikasi',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ── Card per laporan ──────────────────────────────────────────────────────────

class _VerifikasiCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onDone;

  const _VerifikasiCard({required this.report, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final wasteSize = report['waste_size'] as String? ?? '-';
    final imageUrl  = report['image_url']  as String? ?? '';
    final createdAt = DateTime.tryParse(
          report['created_at'] as String? ?? '',
        ) ??
        DateTime.now();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final dateStr =
        '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';

    final sizeColor = switch (wasteSize) {
      'Kecil'  => Colors.green[700]!,
      'Sedang' => Colors.orange[700]!,
      'Besar'  => Colors.red[600]!,
      _        => Colors.grey,
    };

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => VerifikasiDetailSheet(
          report: report,
          onDone: () {
            Navigator.pop(context);
            onDone();
          },
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: sizeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sampah $wasteSize',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sizeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          'Tap untuk lihat detail',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Verifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 64,
        height: 64,
        color: AppColors.fieldFill,
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.primary, size: 28),
      );
}
