import 'package:flutter/material.dart';

import '../models/station.dart';
import '../theme/availability_colors.dart';
import 'availability_badge.dart';
import 'glass_container.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final bool isSelected;
  final bool hasActiveRide;
  final VoidCallback onTap;
  final VoidCallback onReserveTap;

  const StationCard({
    super.key,
    required this.station,
    this.isSelected = false,
    this.hasActiveRide = false,
    required this.onTap,
    required this.onReserveTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final availabilityColors =
        theme.extension<AvailabilityColors>() ?? AvailabilityColors.light;

    final isZeroBike = station.availableBikes == 0;

    Color cardTint;
    Color borderColor;
    double borderWidth;

    if (isZeroBike) {
      cardTint = isDark ? const Color(0xFF2A1215) : const Color(0xFFFFF1F2);
      borderColor = availabilityColors.empty.withValues(alpha: 0.5);
      borderWidth = 1.3;
    } else if (isSelected) {
      cardTint = isDark ? const Color(0xFF13332D) : const Color(0xFFE6F4EA);
      borderColor = colorScheme.primary;
      borderWidth = 2.0;
    } else {
      cardTint = isDark ? const Color(0xFF0F172A) : Colors.white;
      borderColor = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.85);
      borderWidth = 1.2;
    }

    final dockRatio = station.totalDocks > 0
        ? (station.availableBikes / station.totalDocks)
        : 0.0;

    Color progressColor;
    switch (station.availabilityLevel) {
      case AvailabilityLevel.plenty:
        progressColor = availabilityColors.plenty;
        break;
      case AvailabilityLevel.low:
        progressColor = availabilityColors.low;
        break;
      case AvailabilityLevel.empty:
        progressColor = availabilityColors.empty;
        break;
    }

    return Semantics(
      label:
          '${station.name}, ${station.distanceFormatted} away, ${station.availabilityText}',
      button: true,
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        borderRadius: 22,
        blur: 16,
        opacity: isDark ? 0.65 : 0.82,
        tintColor: cardTint,
        borderColor: borderColor,
        borderWidth: borderWidth,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Station Icon with Gradient, Station Title & Subtitle, Distance Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isZeroBike
                            ? [
                                availabilityColors.empty.withValues(alpha: 0.3),
                                availabilityColors.empty.withValues(alpha: 0.1),
                              ]
                            : [
                                colorScheme.primary.withValues(alpha: 0.3),
                                colorScheme.secondary.withValues(alpha: 0.15),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isZeroBike
                            ? availabilityColors.empty.withValues(alpha: 0.4)
                            : colorScheme.primary.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      station.icon,
                      color: isZeroBike
                          ? availabilityColors.empty
                          : colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            fontSize: 16,
                            color: isZeroBike && !isDark
                                ? const Color(0xFF991B1B)
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          station.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Glass Distance Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          station.distanceFormatted,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Availability Badge & Docks Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AvailabilityBadge(
                    level: station.availabilityLevel,
                    count: station.availableBikes,
                  ),
                  Text(
                    '${station.availableBikes} / ${station.totalDocks} Docks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Capacity Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 7,
                  color: isDark
                      ? const Color(0xFF334155).withValues(alpha: 0.5)
                      : const Color(0xFFE2E8F0),
                  child: LinearProgressIndicator(
                    value: dockRatio.clamp(0.0, 1.0),
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Action Row with Comfortable Hitbox
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isZeroBike
                          ? '🚫 No bikes docked right now'
                          : hasActiveRide
                          ? '⚠️ Active ride in progress'
                          : '⚡ Tap to reserve bike',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isZeroBike
                            ? availabilityColors.empty
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: (isZeroBike || hasActiveRide)
                        ? null
                        : onReserveTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(104, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      backgroundColor: colorScheme.primary,
                      elevation: (isZeroBike || hasActiveRide) ? 0 : 3,
                      shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isZeroBike
                          ? 'Empty'
                          : hasActiveRide
                          ? 'Locked'
                          : 'Reserve',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
