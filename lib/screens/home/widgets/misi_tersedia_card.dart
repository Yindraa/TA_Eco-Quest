import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../peta/peta_screen.dart';

class MisiTersediaCard extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> availableMissionsFuture;

  const MisiTersediaCard({super.key, required this.availableMissionsFuture});

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
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: availableMissionsFuture,
        builder: (context, snap) {
          final missions = snap.data ?? [];
          final isLoading =
              snap.connectionState == ConnectionState.waiting;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5FB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.map_rounded,
                            color: Color(0xFF2471A3), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Misi Tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A2E2A),
                        ),
                      ),
                      const Spacer(),
                      if (!isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: missions.isEmpty
                                ? Colors.grey[100]
                                : AppColors.fieldFill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${missions.length} misi',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: missions.isEmpty
                                  ? Colors.grey
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Content
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                else if (missions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.primary, size: 30),
                          const SizedBox(height: 6),
                          Text(
                            'Tidak ada misi tersedia saat ini',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...missions.map(_misiItem),

                const Divider(height: 1),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PetaScreen()),
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Semua di Peta Misi',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2471A3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFF2471A3), size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _misiItem(Map<String, dynamic> mission) {
    final createdAt = DateTime.tryParse(
          mission['created_at'] as String? ?? '',
        ) ??
        DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sampah Kecil · perlu dibersihkan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A2E2A),
              ),
            ),
          ),
          Text(
            _formatDate(createdAt),
            style: GoogleFonts.poppins(
                fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
