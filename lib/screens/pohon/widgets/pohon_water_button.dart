import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_notifier.dart';
import '../../../core/theme.dart';
import '../../../models/tree_model.dart';
import '../../../services/tree_service.dart';

class PohonWaterButton extends StatefulWidget {
  final TreeModel tree;
  final int currentExp; // tidak dipakai untuk deduction, hanya info
  final VoidCallback onWatered;

  const PohonWaterButton({
    super.key,
    required this.tree,
    required this.currentExp,
    required this.onWatered,
  });

  @override
  State<PohonWaterButton> createState() => _PohonWaterButtonState();
}

class _PohonWaterButtonState extends State<PohonWaterButton> {
  bool _watering = false;
  late int _localRemaining;

  @override
  void initState() {
    super.initState();
    _localRemaining = widget.tree.remainingWaterings;
  }

  @override
  void didUpdateWidget(PohonWaterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data DB menunjukkan lebih sedikit dari lokal, pakai DB
    // (mencegah reset ke nilai lebih besar setelah re-fetch)
    final dbRemaining = widget.tree.remainingWaterings;
    if (dbRemaining < _localRemaining) {
      setState(() => _localRemaining = dbRemaining);
    }
  }

  int get _remaining => _localRemaining;
  bool get _canWater => _remaining > 0;

  Future<void> _water() async {
    if (_watering || !_canWater) return;
    setState(() => _watering = true);

    final result = await TreeService().waterTree();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _watering = false;
        _localRemaining = (_localRemaining - 1).clamp(0, 2);
      });
      homeRefreshNotifier.value++;
      widget.onWatered();
      _snack('Pohon berhasil disiram! +20 poin nutrisi 💧',
          const Color(0xFF2471A3));
    } else {
      final msg = result['message'] as String? ?? '';
      if (msg == 'daily_limit_reached' || msg == 'already_watered_today') {
        // Server mengonfirmasi limit tercapai — paksa lokal ke 0
        setState(() {
          _watering = false;
          _localRemaining = 0;
        });
        _snack('Sudah menyiram 2× hari ini. Kembali besok!',
            Colors.orange[700]!);
      } else {
        setState(() => _watering = false);
        _snack('Gagal menyiram pohon. Coba lagi.', Colors.red[400]!);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop_rounded,
                    color: Color(0xFF2471A3), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Siram Pohon',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2E2A),
                ),
              ),
              const Spacer(),
              // Siraman counter badge
              _WaterCountBadge(remaining: _remaining),
            ],
          ),
          const SizedBox(height: 16),

          if (!_canWater)
            _buildDoneState()
          else
            _buildActiveState(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 120.ms).slideY(begin: 0.1);
  }

  Widget _buildDoneState() {
    return Row(
      children: [
        const Text('🌱', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pohon sudah disiram 2× hari ini!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Kembali besok untuk menyiram lagi 💧',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info
        Text(
          'Setiap siraman menambah +20 poin nutrisi pohon.',
          style:
              GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          'Menyiram tidak mengurangi total EXP kamu.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),

        // Water button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _canWater ? _water : null,
            icon: _watering
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('💧', style: TextStyle(fontSize: 18)),
            label: Text(
              _watering ? 'Menyiram...' : 'Siram Pohon (+20 nutrisi)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2471A3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Counter badge ─────────────────────────────────────────────────────────────

class _WaterCountBadge extends StatelessWidget {
  final int remaining;
  const _WaterCountBadge({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final done = remaining == 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (i) {
        final filled = i < (2 - remaining);
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? const Color(0xFF2471A3)
                  : const Color(0xFFEBF5FB),
              border: Border.all(
                color: done
                    ? AppColors.primary
                    : const Color(0xFF2471A3).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '💧',
                style: TextStyle(fontSize: filled ? 10 : 8),
              ),
            ),
          ),
        );
      }),
    );
  }
}
