import 'dart:math';
import 'package:flutter/material.dart';

import '../models/station.dart';
import '../theme/availability_colors.dart';
import 'availability_badge.dart';
import 'glass_container.dart';

class CampusMapHeader extends StatefulWidget {
  final List<Station> stations;
  final String? selectedStationId;
  final ValueChanged<Station>? onStationSelected;

  const CampusMapHeader({
    super.key,
    required this.stations,
    this.selectedStationId,
    this.onStationSelected,
  });

  @override
  State<CampusMapHeader> createState() => _CampusMapHeaderState();
}

class _CampusMapHeaderState extends State<CampusMapHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openFullscreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullscreenCampusMapScreen(
          stations: widget.stations,
          initialStationId: widget.selectedStationId,
          onStationSelected: widget.onStationSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final availabilityColors =
        theme.extension<AvailabilityColors>() ?? AvailabilityColors.light;

    const mapHeight = 240.0;

    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      borderRadius: 24,
      blur: 18,
      opacity: isDark ? 0.75 : 0.85,
      tintColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
      borderColor: isDark
          ? Colors.tealAccent.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.85),
      borderWidth: 1.2,
      child: SizedBox(
        height: mapHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // 1. Realistic Vector Campus Graphics
            Positioned.fill(
              child: CustomPaint(
                painter: RealisticCampusMapPainter(
                  isDark: isDark,
                  primaryColor: colorScheme.primary,
                  accentColor: colorScheme.secondary,
                ),
              ),
            ),

            // 2. Station Marker Pins (Centered & Safe-Inset Anchor Positioning)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double marginX = 36.0;
                  const double marginY = 38.0;
                  final usableWidth =
                      max(50.0, constraints.maxWidth - (marginX * 2));
                  final usableHeight =
                      max(50.0, constraints.maxHeight - (marginY * 2));

                  return Stack(
                    clipBehavior: Clip.none,
                    children: widget.stations.map((station) {
                      final isSelected =
                          station.id == widget.selectedStationId;
                      final posX = marginX + (station.mapX * usableWidth);
                      final posY = marginY + (station.mapY * usableHeight);

                      Color pinColor;
                      switch (station.availabilityLevel) {
                        case AvailabilityLevel.plenty:
                          pinColor = availabilityColors.plenty;
                          break;
                        case AvailabilityLevel.low:
                          pinColor = availabilityColors.low;
                          break;
                        case AvailabilityLevel.empty:
                          pinColor = availabilityColors.empty;
                          break;
                      }

                      return Positioned(
                        left: posX,
                        top: posY,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -0.85),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              widget.onStationSelected?.call(station);
                            },
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 250),
                              scale: isSelected ? 1.15 : 1.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulsing selection radar ring
                                  if (isSelected)
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        final progress =
                                            _pulseController.value;
                                        return Container(
                                          width: 44 + (progress * 26),
                                          height: 44 + (progress * 26),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: pinColor.withValues(
                                                alpha: 1.0 - progress,
                                              ),
                                              width: 2.5,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                  // Pin Pill and Pointer
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF0F172A)
                                                  .withValues(alpha: 0.92)
                                              : Colors.white.withValues(
                                                  alpha: 0.95,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : pinColor.withValues(
                                                    alpha: 0.8,
                                                  ),
                                            width: isSelected ? 2.0 : 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: pinColor.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                            const BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: pinColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: pinColor.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 4.5),
                                            Text(
                                              '${station.availableBikes}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -3),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          size: 22,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : pinColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // 3. Glassmorphic Top Overlay Bar (Live telemetry tag + Fullscreen Action)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassContainer(
                    borderRadius: 16,
                    blur: 14,
                    opacity: isDark ? 0.7 : 0.85,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    borderWidth: 1.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10B981),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(
                                  alpha: 0.6,
                                ),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Live Campus Hub Map',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fullscreen Button with Tooltip and Text Tag
                  GlassContainer(
                    borderRadius: 14,
                    blur: 14,
                    opacity: isDark ? 0.75 : 0.9,
                    borderWidth: 1.0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _openFullscreenMap(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen,
                              size: 18,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Full Screen',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Subtle Orientation / Tap-to-expand Indicator (Bottom)
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.navigation,
                          size: 10,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'CAMPUS GRID • REALISTIC',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _openFullscreenMap(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pinch_outlined,
                            size: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pinch to Zoom & Pan',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fullscreen Interactive Campus Map with Pinch-to-Zoom, Pan, and Floating Station Card
class FullscreenCampusMapScreen extends StatefulWidget {
  final List<Station> stations;
  final String? initialStationId;
  final ValueChanged<Station>? onStationSelected;

  const FullscreenCampusMapScreen({
    super.key,
    required this.stations,
    this.initialStationId,
    this.onStationSelected,
  });

  @override
  State<FullscreenCampusMapScreen> createState() =>
      _FullscreenCampusMapScreenState();
}

class _FullscreenCampusMapScreenState extends State<FullscreenCampusMapScreen>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformController;
  late AnimationController _pulseController;
  Station? _selectedStation;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    if (widget.initialStationId != null) {
      _selectedStation = widget.stations.firstWhere(
        (s) => s.id == widget.initialStationId,
        orElse: () => widget.stations.first,
      );
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final matrix = _transformController.value.clone();
    matrix.scaleByDouble(1.3, 1.3, 1.0, 1.0);
    _transformController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    matrix.scaleByDouble(0.77, 0.77, 1.0, 1.0);
    _transformController.value = matrix;
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final availabilityColors =
        theme.extension<AvailabilityColors>() ?? AvailabilityColors.light;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFE2E8F0),
      body: Stack(
        children: [
          // 1. Full Screen Interactive Map Canvas
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.7,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(300),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Map Vector Canvas
                        Positioned.fill(
                          child: CustomPaint(
                            painter: RealisticCampusMapPainter(
                              isDark: isDark,
                              primaryColor: colorScheme.primary,
                              accentColor: colorScheme.secondary,
                              showLabels: true,
                            ),
                          ),
                        ),

                        // Station Pins with Centered Positioning
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const double marginX = 40.0;
                              const double marginY = 40.0;
                              final usableWidth = max(
                                50.0,
                                constraints.maxWidth - (marginX * 2),
                              );
                              final usableHeight = max(
                                50.0,
                                constraints.maxHeight - (marginY * 2),
                              );

                              return Stack(
                                clipBehavior: Clip.none,
                                children: widget.stations.map((station) {
                                  final isSelected =
                                      station.id == _selectedStation?.id;
                                  final posX =
                                      marginX + (station.mapX * usableWidth);
                                  final posY =
                                      marginY + (station.mapY * usableHeight);

                                  Color pinColor;
                                  switch (station.availabilityLevel) {
                                    case AvailabilityLevel.plenty:
                                      pinColor = availabilityColors.plenty;
                                      break;
                                    case AvailabilityLevel.low:
                                      pinColor = availabilityColors.low;
                                      break;
                                    case AvailabilityLevel.empty:
                                      pinColor = availabilityColors.empty;
                                      break;
                                  }

                                  return Positioned(
                                    left: posX,
                                    top: posY,
                                    child: FractionalTranslation(
                                      translation: const Offset(-0.5, -0.85),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _selectedStation = station;
                                          });
                                          widget.onStationSelected?.call(station);
                                        },
                                        child: AnimatedScale(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          scale: isSelected ? 1.25 : 1.0,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              if (isSelected)
                                                AnimatedBuilder(
                                                  animation: _pulseController,
                                                  builder: (context, child) {
                                                    final progress =
                                                        _pulseController.value;
                                                    return Container(
                                                      width: 50 + (progress * 30),
                                                      height:
                                                          50 + (progress * 30),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              pinColor.withValues(
                                                            alpha:
                                                                1.0 - progress,
                                                          ),
                                                          width: 3.0,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),

                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF0F172A,
                                                            ).withValues(
                                                              alpha: 0.95,
                                                            )
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        16,
                                                      ),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? colorScheme
                                                                .primary
                                                            : pinColor,
                                                        width: isSelected
                                                            ? 2.2
                                                            : 1.4,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: pinColor
                                                              .withValues(
                                                            alpha: 0.35,
                                                          ),
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                            0,
                                                            3,
                                                          ),
                                                        ),
                                                        const BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 6,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: pinColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          '${station.availableBikes}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: isDark
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF0F172A,
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Transform.translate(
                                                    offset: const Offset(0, -3),
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 24,
                                                      color: isSelected
                                                          ? colorScheme.primary
                                                          : pinColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Floating Top Header Bar (Close + Campus Hub Title + Live Indicator)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassContainer(
                  borderRadius: 16,
                  blur: 16,
                  opacity: isDark ? 0.75 : 0.9,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Exit Fullscreen',
                  ),
                ),
                GlassContainer(
                  borderRadius: 16,
                  blur: 16,
                  opacity: isDark ? 0.75 : 0.9,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(
                                alpha: 0.7,
                              ),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Interactive Campus GPS Map',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                GlassContainer(
                  borderRadius: 16,
                  blur: 16,
                  opacity: isDark ? 0.75 : 0.9,
                  child: IconButton(
                    icon: const Icon(Icons.center_focus_strong),
                    onPressed: _resetZoom,
                    tooltip: 'Reset Map View',
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Zoom Controls (+ / -)
          Positioned(
            right: 16,
            bottom: _selectedStation != null ? 180 : 30,
            child: Column(
              children: [
                GlassContainer(
                  borderRadius: 14,
                  blur: 14,
                  opacity: isDark ? 0.8 : 0.9,
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _zoomIn,
                    tooltip: 'Zoom In',
                  ),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 14,
                  blur: 14,
                  opacity: isDark ? 0.8 : 0.9,
                  child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _zoomOut,
                    tooltip: 'Zoom Out',
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Station Bottom Preview Sheet (when a station is selected)
          if (_selectedStation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: GlassContainer(
                borderRadius: 24,
                blur: 20,
                opacity: isDark ? 0.85 : 0.95,
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _selectedStation!.icon,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedStation!.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedStation!.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AvailabilityBadge(
                          level: _selectedStation!.availabilityLevel,
                          count: _selectedStation!.availableBikes,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedStation!.distanceFormatted,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_selectedStation!.availableBikes} bikes / ${_selectedStation!.totalDocks} docks',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: _selectedStation!.availableBikes <= 0
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              widget.onStationSelected?.call(_selectedStation!);
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _selectedStation!.availableBikes <= 0
                            ? 'No Bikes Available'
                            : 'Select & Reserve Bike',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Realistic Campus Map Painter featuring textured grounds, shaded buildings,
/// detailed roads with lane markings, sports arena, and realistic lake.
class RealisticCampusMapPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final Color accentColor;
  final bool showLabels;

  RealisticCampusMapPainter({
    required this.isDark,
    required this.primaryColor,
    required this.accentColor,
    this.showLabels = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Campus Ground / Topography Base
    final groundPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    canvas.drawRect(Offset.zero & size, groundPaint);

    // Subtle CAD topographic grid
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.035)
          : Colors.black.withValues(alpha: 0.035)
      ..strokeWidth = 1.0;

    const double gridSpacing = 28.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Lush Landscaped Quads, Parks & Greenery
    final lawnFill = Paint()
      ..color = isDark
          ? const Color(0xFF064E3B).withValues(alpha: 0.45)
          : const Color(0xFFDCFCE7)
      ..style = PaintingStyle.fill;

    final lawnBorder = Paint()
      ..color = isDark
          ? const Color(0xFF059669).withValues(alpha: 0.3)
          : const Color(0xFF86EFAC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Academic Central Quad
    final quadRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.16,
        size.width * 0.38,
        size.height * 0.38,
      ),
      const Radius.circular(22),
    );
    canvas.drawRRect(quadRect, lawnFill);
    canvas.drawRRect(quadRect, lawnBorder);

    // North-West Gate Botanical Lawn
    final nwLawn = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.06,
        size.height * 0.08,
        size.width * 0.22,
        size.height * 0.34,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(nwLawn, lawnFill);
    canvas.drawRRect(nwLawn, lawnBorder);

    // South-West Innovation Park
    final swLawn = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.64,
        size.width * 0.30,
        size.height * 0.30,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(swLawn, lawnFill);
    canvas.drawRRect(swLawn, lawnBorder);

    // 3. Athletics Zone: Realistic Red Tartan Running Track & Football Pitch
    final trackFill = Paint()
      ..color = isDark
          ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
          : const Color(0xFFFFE4E6)
      ..style = PaintingStyle.fill;

    final trackBorder = Paint()
      ..color = isDark
          ? const Color(0xFFE11D48).withValues(alpha: 0.5)
          : const Color(0xFFFDA4AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final trackRect = Rect.fromCenter(
      center: Offset(size.width * 0.82, size.height * 0.72),
      width: size.width * 0.28,
      height: size.height * 0.28,
    );
    canvas.drawOval(trackRect, trackFill);
    canvas.drawOval(trackRect, trackBorder);

    // Track running lanes (white inner lane divider rings)
    final trackLanePaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFFE11D48))
          .withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82, size.height * 0.72),
        width: size.width * 0.23,
        height: size.height * 0.23,
      ),
      trackLanePaint,
    );

    // Center Green Soccer Field
    final pitchRect = Rect.fromCenter(
      center: Offset(size.width * 0.82, size.height * 0.72),
      width: size.width * 0.16,
      height: size.height * 0.15,
    );
    canvas.drawOval(pitchRect, lawnFill);

    // 4. Realistic Serpentine Lake with Depth Gradient & Shore Beach
    final lakeShorePaint = Paint()
      ..color = isDark
          ? const Color(0xFF0C4A6E).withValues(alpha: 0.3)
          : const Color(0xFFE0F2FE)
      ..style = PaintingStyle.fill;

    final lakeWaterPaint = Paint()
      ..color = isDark
          ? const Color(0xFF0284C7).withValues(alpha: 0.45)
          : const Color(0xFF38BDF8).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final waterBorder = Paint()
      ..color = isDark
          ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
          : const Color(0xFF0284C7).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final waterPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.58)
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.52,
        size.width * 0.62,
        size.height * 0.54,
        size.width * 0.68,
        size.height * 0.64,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.72,
        size.width * 0.62,
        size.height * 0.84,
        size.width * 0.48,
        size.height * 0.80,
      )
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.76,
        size.width * 0.36,
        size.height * 0.64,
        size.width * 0.42,
        size.height * 0.58,
      )
      ..close();

    // Draw lake shore then lake water
    canvas.drawPath(waterPath, lakeShorePaint);
    canvas.drawPath(waterPath, lakeWaterPaint);
    canvas.drawPath(waterPath, waterBorder);

    // 5. Interconnected Paved Roads & Dedicated Cycle Superhighways
    final roadBase = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final roadAsphalt = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Glowing cycle lane
    final cycleLane = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.85 : 0.7)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final northRoute = Path()
      ..moveTo(size.width * 0.08, size.height * 0.22)
      ..lineTo(size.width * 0.48, size.height * 0.22)
      ..lineTo(size.width * 0.90, size.height * 0.24);

    final westRoute = Path()
      ..moveTo(size.width * 0.18, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.52,
        size.width * 0.22,
        size.height * 0.84,
      );

    final centralSpine = Path()
      ..moveTo(size.width * 0.48, size.height * 0.22)
      ..lineTo(size.width * 0.50, size.height * 0.40)
      ..lineTo(size.width * 0.58, size.height * 0.54)
      ..lineTo(size.width * 0.52, size.height * 0.88);

    final southRoute = Path()
      ..moveTo(size.width * 0.22, size.height * 0.84)
      ..lineTo(size.width * 0.52, size.height * 0.88)
      ..lineTo(size.width * 0.85, size.height * 0.80);

    final eastRoute = Path()
      ..moveTo(size.width * 0.78, size.height * 0.24)
      ..lineTo(size.width * 0.76, size.height * 0.52)
      ..lineTo(size.width * 0.82, size.height * 0.78);

    final crossWalkway = Path()
      ..moveTo(size.width * 0.35, size.height * 0.60)
      ..lineTo(size.width * 0.58, size.height * 0.54);

    final allRoutes = [
      northRoute,
      westRoute,
      centralSpine,
      southRoute,
      eastRoute,
      crossWalkway,
    ];

    for (final path in allRoutes) {
      canvas.drawPath(path, roadBase);
      canvas.drawPath(path, roadAsphalt);
      canvas.drawPath(path, cycleLane);
    }

    // 6. Lake Bridge Overpass
    final bridgePaint = Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.62),
      Offset(size.width * 0.56, size.height * 0.72),
      bridgePaint,
    );

    // 7. 3D Beveled Realistic Architectural Campus Buildings
    final buildingShadow = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.4 : 0.1)
      ..style = PaintingStyle.fill;

    final buildingFill = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : Colors.white
      ..style = PaintingStyle.fill;

    final buildingRoof = Paint()
      ..color = isDark
          ? const Color(0xFF334155)
          : const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final buildingBorder = Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final buildingData = [
      {'name': 'Main Gate', 'rect': Rect.fromLTWH(size.width * 0.08, size.height * 0.12, size.width * 0.09, size.height * 0.08)},
      {'name': 'Library', 'rect': Rect.fromLTWH(size.width * 0.42, size.height * 0.12, size.width * 0.14, size.height * 0.08)},
      {'name': 'Hostels', 'rect': Rect.fromLTWH(size.width * 0.74, size.height * 0.12, size.width * 0.15, size.height * 0.09)},
      {'name': 'Admin', 'rect': Rect.fromLTWH(size.width * 0.28, size.height * 0.52, size.width * 0.11, size.height * 0.09)},
      {'name': 'Food Court', 'rect': Rect.fromLTWH(size.width * 0.63, size.height * 0.44, size.width * 0.11, size.height * 0.09)},
      {'name': 'Tech Park', 'rect': Rect.fromLTWH(size.width * 0.14, size.height * 0.74, size.width * 0.12, size.height * 0.09)},
      {'name': 'Innovation', 'rect': Rect.fromLTWH(size.width * 0.44, size.height * 0.78, size.width * 0.14, size.height * 0.08)},
    ];

    for (final data in buildingData) {
      final rect = data['rect'] as Rect;
      // 3D Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.shift(const Offset(0, 4)),
          const Radius.circular(7),
        ),
        buildingShadow,
      );
      // Wall
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        buildingFill,
      );
      // Roof inset
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(2),
          const Radius.circular(5),
        ),
        buildingRoof,
      );
      // Border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        buildingBorder,
      );

      // Label on building if in fullscreen
      if (showLabels) {
        final textSpan = TextSpan(
          text: data['name'] as String,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            rect.center.dx - (tp.width / 2),
            rect.center.dy - (tp.height / 2),
          ),
        );
      }
    }

    // 8. Canopy Trees with Shadows
    final treeShadow = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.3 : 0.08)
      ..style = PaintingStyle.fill;

    final treeCanopy = Paint()
      ..color = isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.6)
          : const Color(0xFF34D399).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final treePositions = [
      Offset(size.width * 0.12, size.height * 0.18),
      Offset(size.width * 0.15, size.height * 0.26),
      Offset(size.width * 0.38, size.height * 0.28),
      Offset(size.width * 0.64, size.height * 0.26),
      Offset(size.width * 0.38, size.height * 0.44),
      Offset(size.width * 0.14, size.height * 0.68),
      Offset(size.width * 0.24, size.height * 0.72),
      Offset(size.width * 0.68, size.height * 0.78),
    ];

    for (final pos in treePositions) {
      canvas.drawCircle(pos.translate(0, 1.5), 4.5, treeShadow);
      canvas.drawCircle(pos, 4.5, treeCanopy);
    }
  }

  @override
  bool shouldRepaint(covariant RealisticCampusMapPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.showLabels != showLabels;
  }
}
