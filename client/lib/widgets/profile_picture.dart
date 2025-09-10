import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? userName;
  final double size;

  const ProfilePicture({
    Key? key,
    this.userName,
    this.size = 36,
  }) : super(key: key);

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
  }

  Color _getRandomColor(String? name) {
    if (name == null || name.isEmpty) return const Color(0xFF6B7280);
    
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    // Expanded color palette with more vibrant and diverse colors
    final colors = [
      // Reds
      const Color(0xFFEF4444), const Color(0xFFDC2626), const Color(0xFFB91C1C), const Color(0xFF991B1B),
      const Color(0xFFE11D48), const Color(0xBE185D), const Color(0xFF9F1239), const Color(0xFF881337),
      
      // Oranges
      const Color(0xFFF97316), const Color(0xFFEA580C), const Color(0xFFD97706), const Color(0xFFB45309),
      const Color(0xFFF59E0B), const Color(0xFFD97706), const Color(0xFFB45309), const Color(0xFF92400E),
      
      // Yellows
      const Color(0xFFEAB308), const Color(0xFFCA8A04), const Color(0xFFA16207), const Color(0xFF92400E),
      const Color(0xFFFBBF24), const Color(0xFFF59E0B), const Color(0xFFD97706), const Color(0xFFB45309),
      
      // Greens
      const Color(0xFF84CC16), const Color(0xFF65A30D), const Color(0xFF4D7C0F), const Color(0xFF365314),
      const Color(0xFF22C55E), const Color(0xFF16A34A), const Color(0xFF15803D), const Color(0xFF166534),
      const Color(0xFF10B981), const Color(0xFF059669), const Color(0xFF047857), const Color(0xFF065F46),
      
      // Teals
      const Color(0xFF14B8A6), const Color(0xFF0D9488), const Color(0xFF0F766E), const Color(0xFF115E59),
      const Color(0xFF06B6D4), const Color(0xFF0891B2), const Color(0xFF0E7490), const Color(0xFF155E75),
      
      // Blues
      const Color(0xFF0EA5E9), const Color(0xFF0284C7), const Color(0xFF0369A1), const Color(0xFF075985),
      const Color(0xFF3B82F6), const Color(0xFF2563EB), const Color(0xFF1D4ED8), const Color(0xFF1E40AF),
      const Color(0xFF6366F1), const Color(0xFF4F46E5), const Color(0xFF4338CA), const Color(0xFF3730A3),
      
      // Purples
      const Color(0xFF8B5CF6), const Color(0xFF7C3AED), const Color(0xFF6D28D9), const Color(0xFF5B21B6),
      const Color(0xFFA855F7), const Color(0xFF9333EA), const Color(0xFF7E22CE), const Color(0xFF6B21A8),
      const Color(0xFFD946EF), const Color(0xFFC026D3), const Color(0xFFA21CAF), const Color(0xFF86198F),
      
      // Pinks
      const Color(0xFFEC4899), const Color(0xFFDB2777), const Color(0xBE185D), const Color(0xFF9D174D),
      const Color(0xFFF43F5E), const Color(0xFFE11D48), const Color(0xBE123C), const Color(0xFF9F1239),
      
      // Additional vibrant colors
      const Color(0xFF06D6A0), const Color(0xFF118AB2), const Color(0xFF073B4C), const Color(0xFFFFD166),
      const Color(0xFFF72585), const Color(0xFF4CC9F0), const Color(0xFF7209B7), const Color(0xFF560BAD),
      const Color(0xFF480CA8), const Color(0xFF3A0CA3), const Color(0xFF3F37C9), const Color(0xFF4361EE),
      const Color(0xFF4895EF), const Color(0xFF4CC9F0), const Color(0xFF52B788), const Color(0xFF40916C),
      const Color(0xFF2D6A4F), const Color(0xFF1B4332), const Color(0xFF081C15), const Color(0xFFB7094C),
      const Color(0xFFA01A58), const Color(0xFF892B64), const Color(0xFF723C70), const Color(0xFF5B4D7C),
      
      // Neutral variations
      const Color(0xFF78716C), const Color(0xFF57534E), const Color(0xFF44403C), const Color(0xFF292524),
      const Color(0xFF6B7280), const Color(0xFF4B5563), const Color(0xFF374151), const Color(0xFF1F2937),
    ];
    
    return colors[hash.abs() % colors.length];
  }

  double _getFontSize() {
    if (size >= 100) return size * 0.4;
    if (size >= 60) return size * 0.35;
    return size * 0.45;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(userName);
    final baseColor = _getRandomColor(userName);
    final fontSize = _getFontSize();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            baseColor.withOpacity(0.8),
            baseColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}