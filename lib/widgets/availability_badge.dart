import 'package:flutter/material.dart';

import '../models/station.dart';
import '../theme/availability_colors.dart';
import 'glass_container.dart';

class AvailabilityBadge extends StatelessWidget {
  final AvailabilityLevel level;
  final int count;
  final bool compact;

  const AvailabilityBadge({
    super.key,
    required this.level,
    required this.count,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors =
        theme.extension<AvailabilityColors>() ??
        AvailabilityColors.light;

    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (level) {
      case AvailabilityLevel.plenty:
        bg = colors.plentyContainer.withValues(alpha: isDark ? 0.4 : 0.65);
        fg = isDark ? const Color(0xFF6EE7B7) : colors.onPlentyContainer;
        icon = Icons.check_circle_rounded;
        label = compact ? '$count bikes' : '$count Available';
        break;
      case AvailabilityLevel.low:
        bg = colors.lowContainer.withValues(alpha: isDark ? 0.4 : 0.65);
        fg = isDark ? const Color(0xFFFCD34D) : colors.onLowContainer;
        icon = Icons.warning_amber_rounded;
        label = compact ? '$count left' : 'Low Stock ($count)';
        break;
      case AvailabilityLevel.empty:
        bg = colors.emptyContainer.withValues(alpha: isDark ? 0.4 : 0.65);
        fg = isDark ? const Color(0xFFFCA5A5) : colors.onEmptyContainer;
        icon = Icons.block_rounded;
        label = compact ? '0 bikes' : 'Unavailable';
        break;
    }

    return Semantics(
      label: 'Station status: $label',
      child: GlassContainer(
        borderRadius: 20,
        blur: 10,
        opacity: isDark ? 0.6 : 0.8,
        tintColor: bg,
        borderColor: fg.withValues(alpha: 0.35),
        borderWidth: 1.0,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        customShadows: [
          BoxShadow(
            color: fg.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 13 : 15, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 11 : 12.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
