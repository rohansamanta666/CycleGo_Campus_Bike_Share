import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/station.dart';
import '../models/active_ride.dart';
import '../providers/station_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/progress_stepper.dart';
import '../widgets/availability_badge.dart';

class ReservationScreen extends StatefulWidget {
  final String stationId;

  const ReservationScreen({super.key, required this.stationId});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  bool _isProcessing = false;

  void _handleReserve(BuildContext context, Station station) async {
    final stationProvider = context.read<StationProvider>();

    if (stationProvider.hasActiveRide) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Active ride already exists (${stationProvider.activeRide!.bikeId}). Please complete it first.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (station.availableBikes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No bikes currently available at ${station.name}.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final activeRide = stationProvider.reserveBike(station.id);
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;
      _showReservationSuccessDialog(context, activeRide);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reserving bike: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showReservationSuccessDialog(
    BuildContext context,
    ActiveRide activeRide,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassContainer(
            borderRadius: 26,
            blur: 24,
            opacity: isDark ? 0.9 : 0.95,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Bike Reserved!',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Your bike is unlocked and ready for pickup at ${activeRide.pickupStationName}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  borderRadius: 16,
                  blur: 10,
                  opacity: isDark ? 0.5 : 0.7,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Assigned Bike:',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            activeRide.bikeId,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Unlock PIN:',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              activeRide.unlockCode,
                              style: const TextStyle(
                                color: Colors.white,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'You can return this cycle to ANY station when done.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Stations'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pop(true);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Riding Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stationProvider = context.watch<StationProvider>();
    final station = stationProvider.getStationById(widget.stationId);

    if (station == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Station Details')),
        body: const Center(child: Text('Station not found')),
      );
    }

    final hasActiveRide = stationProvider.hasActiveRide;
    final isZeroBike = station.availableBikes <= 0;

    return AmbientBackgroundMesh(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Reserve Bike')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Stepper (Step 2: Reserve)
              const ProgressStepper(currentStep: 2),
              const SizedBox(height: 16),

              // Active Ride Warning if already holding one
              if (hasActiveRide)
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  borderRadius: 18,
                  tintColor: Colors.amber.shade100,
                  borderColor: Colors.amber.shade700,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade900,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You already have an active ride (${stationProvider.activeRide!.bikeId}). Please return it before booking another.',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Station Hero Glass Card
              GlassContainer(
                borderRadius: 22,
                blur: 18,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isZeroBike
                                  ? [
                                      colorScheme.error.withValues(alpha: 0.3),
                                      colorScheme.error.withValues(alpha: 0.1),
                                    ]
                                  : [
                                      colorScheme.primary.withValues(alpha: 0.3),
                                      colorScheme.secondary.withValues(alpha: 0.15),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            station.icon,
                            size: 32,
                            color: isZeroBike
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                station.subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Key Stats Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox(
                          context,
                          title: 'Distance',
                          value: station.distanceFormatted,
                          icon: Icons.directions_walk,
                        ),
                        _buildStatBox(
                          context,
                          title: 'Available',
                          value: '${station.availableBikes} bikes',
                          icon: Icons.pedal_bike,
                          valueColor: isZeroBike ? Colors.red : null,
                        ),
                        _buildStatBox(
                          context,
                          title: 'Total Docks',
                          value: '${station.totalDocks}',
                          icon: Icons.local_parking,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Availability Badge
                    Center(
                      child: AvailabilityBadge(
                        level: station.availabilityLevel,
                        count: station.availableBikes,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rental Info & Campus Guidelines Glass Card
              GlassContainer(
                borderRadius: 20,
                blur: 16,
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rental Terms & Guidelines',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildGuidelineRow(
                      context,
                      icon: Icons.check_circle_outline,
                      title: 'Free Campus Transit',
                      subtitle:
                          'Zero rental fee for all verified students & staff',
                    ),
                    const SizedBox(height: 10),
                    _buildGuidelineRow(
                      context,
                      icon: Icons.swap_horiz,
                      title: 'Flexible Any-Dock Return',
                      subtitle: 'Drop off at any station across campus',
                    ),
                    const SizedBox(height: 10),
                    _buildGuidelineRow(
                      context,
                      icon: Icons.eco_outlined,
                      title: 'Zero Emission Commute',
                      subtitle: 'Save CO2 footprint while staying fit',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Button
              FilledButton(
                onPressed: (_isProcessing || isZeroBike || hasActiveRide)
                    ? null
                    : () => _handleReserve(context, station),
                style: FilledButton.styleFrom(
                  elevation: 4,
                  shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isZeroBike
                            ? 'No Bikes Available'
                            : hasActiveRide
                            ? 'Active Ride in Progress'
                            : 'Confirm & Reserve Bike',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
              const SizedBox(height: 12),

              if (isZeroBike)
                Center(
                  child: Text(
                    'Please check another station on campus map for bikes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGuidelineRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
