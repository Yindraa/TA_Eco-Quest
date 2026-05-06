import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../misi/selesaikan_misi_screen.dart';

class ActiveMisiSection extends StatelessWidget {
  /// Future yang berisi daftar misi aktif (status: claimed, solver = user ini).
  final Future<List<Map<String, dynamic>>> misionFuture;

  /// Dipanggil setelah selesaikan misi berhasil agar HomeScreen refresh data.
  final VoidCallback onRefresh;

  const ActiveMisiSection({
    super.key,
    required this.misionFuture,
    required this.onRefresh,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: misionFuture,
      builder: (context, snap) {
        final missions = snap.data ?? [];
        if (missions.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Misi Aktifku 🤝',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A2E2A),
                    ),
                  ),
                  Text(
                    '${missions.length} misi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF2471A3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...missions.map((m) => _buildMisiCard(context, m)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMisiCard(BuildContext context, Map<String, dynamic> mission) {
    final reportId = mission['report_id'] as String;
    final wasteSize = mission['waste_size'] as String? ?? '-';
    final imageUrl = mission['image_url'] as String? ?? '';
    final createdAt =
        DateTime.tryParse(mission['created_at'] as String? ?? '') ??
        DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2471A3).withValues(alpha: 0.3),
        ),
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
                  'Diklaim ${_formatDate(createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final resolved = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => SelesaikanMisiScreen(
                    reportId: reportId,
                    originalImageUrl: imageUrl,
                    wasteSize: wasteSize,
                  ),
                ),
              );
              if (resolved == true) onRefresh();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF2471A3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Selesaikan',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
}
