import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class WasteSizeSelector extends StatelessWidget {
  final String? selectedSize;
  final ValueChanged<String> onChanged;

  const WasteSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onChanged,
  });

  static const _sizes = [
    (
      value: 'Kecil',
      emoji: '🟢',
      desc: 'Sampah berserakan kecil',
      points: '+10 EXP',
    ),
    (
      value: 'Sedang',
      emoji: '🟡',
      desc: 'Tumpukan sampah sedang',
      points: '+25 EXP',
    ),
    (
      value: 'Besar',
      emoji: '🔴',
      desc: 'Tumpukan sampah besar',
      points: '+50 EXP',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _sizes.map((s) {
        final isSelected = selectedSize == s.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: s.value != 'Besar' ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(s.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    s.value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF1A2E2A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.desc,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey[100]!,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.points,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
