import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/station.dart';
import '../models/ride_record.dart';
import '../providers/station_provider.dart';
import '../providers/ride_history_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/progress_stepper.dart';

class ActiveRideScreen extends StatefulWidget {
  final bool isNestedView;
  final ValueChanged<int>? onNavigateToTab;

  const ActiveRideScreen({
    super.key,
    this.isNestedView = false,
    this.onNavigateToTab,
  });

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  Timer? _tickerTimer;
  String? _selectedReturnStationId;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final activeRide = context.read<StationProvider>().activeRide;
      if (activeRide != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    final hrs = totalSecs ~/ 3600;
    if (hrs > 0) {
      final h = hrs.toString().padLeft(2, '0');
      return '$h:$mins:$secs';
    }
    return '$mins:$secs';
  }

  void _handleReturn() async {
    final stationProvider = context.read<StationProvider>();
    final historyProvider = context.read<RideHistoryProvider>();

    if (!stationProvider.hasActiveRide) return;

    final stations = stationProvider.allStations;
    final returnTargetId =
        _selectedReturnStationId ??
        stations.firstWhere((s) => !s.isFull, orElse: () => stations.first).id;

    final chosenStation = await showModalBottomSheet<Station>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ReturnStationPickerSheet(
          stations: stations,
          initialStationId: returnTargetId,
        );
      },
    );

    if (chosenStation == null || !mounted) return;

    try {
      final rideRecord = stationProvider.returnBike(chosenStation.id);
      await historyProvider.addRide(rideRecord);

      if (!mounted) return;
      _showRideSummaryModal(context, rideRecord);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Return error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showRideSummaryModal(BuildContext context, RideRecord ride) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return GlassContainer(
          borderRadius: 28,
          blur: 24,
          opacity: isDark ? 0.9 : 0.95,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_score_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ride Completed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Bike successfully docked at ${ride.returnStationName}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Summary Stats Card
              GlassContainer(
                borderRadius: 18,
                blur: 12,
                opacity: isDark ? 0.5 : 0.7,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryMetric(
                      'Duration',
                      ride.formattedDuration,
                      Icons.timer,
                      colorScheme.primary,
                    ),
                    _buildSummaryMetric(
                      'Distance',
                      ride.formattedDistance,
                      Icons.straighten,
                      colorScheme.secondary,
                    ),
                    _buildSummaryMetric(
                      'Burned',
                      '${ride.caloriesBurned.toStringAsFixed(0)} kcal',
                      Icons.local_fire_department,
                      Colors.deepOrange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(modalContext).pop();
                        if (widget.isNestedView) {
                          Navigator.of(context).pop();
                        } else {
                          widget.onNavigateToTab?.call(0);
                        }
                      },
                      child: const Text('Back to Stations'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(modalContext).pop();
                        if (widget.isNestedView) {
                          Navigator.of(context).pop();
                        }
                        widget.onNavigateToTab?.call(2); // History Tab
                      },
                      child: const Text('View History'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stationProvider = context.watch<StationProvider>();
    final activeRide = stationProvider.activeRide;

    return AmbientBackgroundMesh(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Active Ride'),
          leading: widget.isNestedView
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
        body: activeRide == null
            ? _buildNoActiveRideState(context)
            : _buildActiveRideContent(context, activeRide),
      ),
    );
  }

  Widget _buildNoActiveRideState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GlassContainer(
          borderRadius: 24,
          blur: 18,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.25),
                      colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_bike_outlined,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Active Ride in Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a docking station from the campus map to reserve a cycle.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  if (widget.isNestedView) {
                    Navigator.of(context).pop();
                  } else {
                    widget.onNavigateToTab?.call(0);
                  }
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Explore Campus Stations'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRideContent(
    BuildContext context,
    dynamic activeRide,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final totalSecs = activeRide.elapsedSeconds as int;
    final estimatedDistMeters = (totalSecs * 3.5).toInt();
    final estimatedCalories = (totalSecs * 0.12).toStringAsFixed(1);
    final co2Grams = (estimatedDistMeters * 0.16).toStringAsFixed(0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Stepper (Step 3: Ride / Return)
          const ProgressStepper(currentStep: 3),
          const SizedBox(height: 16),

          // Live Timer Glass Hero Card
          GlassContainer(
            borderRadius: 24,
            blur: 20,
            opacity: isDark ? 0.75 : 0.85,
            tintColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFE6FFFA),
            borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.5 : 0.7),
            borderWidth: 1.5,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RIDE IN PROGRESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatTimer(totalSecs),
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isDark ? Colors.white : colorScheme.onSurface,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Bike: ${activeRide.bikeId}   •   PIN: ${activeRide.unlockCode}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pickup Station & Route Details Glass Card
          GlassContainer(
            borderRadius: 20,
            blur: 16,
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trip_origin,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup Station',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            activeRide.pickupStationName as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Live Metrics: Distance, Calories, CO2 in Glass Containers
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'Est. Distance',
                  value: estimatedDistMeters < 1000
                      ? '$estimatedDistMeters m'
                      : '${(estimatedDistMeters / 1000).toStringAsFixed(2)} km',
                  icon: Icons.straighten,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'Calories',
                  value: '$estimatedCalories kcal',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'CO2 Saved',
                  value: '$co2Grams g',
                  icon: Icons.eco,
                  iconColor: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Return Bike Button (Step 4)
          FilledButton.icon(
            onPressed: () => _handleReturn(),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: colorScheme.primary.withValues(alpha: 0.4),
            ),
            icon: const Icon(Icons.where_to_vote),
            label: const Text(
              'Select Station & Return Bike',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),

          const SizedBox(height: 12),

          // Cancel Reservation Option
          Center(
            child: TextButton.icon(
              onPressed: () {
                _showCancelConfirmationDialog(context);
              },
              icon: const Icon(
                Icons.cancel_outlined,
                size: 16,
                color: Colors.red,
              ),
              label: const Text(
                'Cancel Ride / Unlock Failed',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          title: const Text('Cancel Reservation?'),
          content: const Text(
            'This will return the bike to its original pickup dock without creating a history record.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlgContext).pop(),
              child: const Text('Keep Riding'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dlgContext).pop();
                context.read<StationProvider>().cancelReservation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reservation cancelled.')),
                );
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassContainer(
      borderRadius: 18,
      blur: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor ?? colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnStationPickerSheet extends StatefulWidget {
  final List<Station> stations;
  final String initialStationId;

  const _ReturnStationPickerSheet({
    required this.stations,
    required this.initialStationId,
  });

  @override
  State<_ReturnStationPickerSheet> createState() =>
      _ReturnStationPickerSheetState();
}

class _ReturnStationPickerSheetState extends State<_ReturnStationPickerSheet> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialStationId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GlassContainer(
      borderRadius: 28,
      blur: 24,
      opacity: isDark ? 0.9 : 0.95,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.70,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Drop-off Docking Station',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You can return the bike to any campus station with open docks.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.stations.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
                itemBuilder: (context, index) {
                  final station = widget.stations[index];
                  final isSelected = station.id == _selectedId;
                  final isFull = station.isFull;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        station.icon,
                        color: isSelected ? colorScheme.primary : Colors.grey,
                      ),
                    ),
                    title: Text(
                      station.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      isFull
                          ? '🚫 Station Full (0 docks free)'
                          : '${station.availableDocks} free docks (${station.availableBikes}/${station.totalDocks} bikes)',
                      style: TextStyle(
                        color: isFull ? Colors.red : colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isFull
                        ? const Chip(
                            label: Text(
                              'FULL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.zero,
                          )
                        : isSelected
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: isFull
                        ? null
                        : () {
                            setState(() {
                              _selectedId = station.id;
                            });
                          },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final chosen = widget.stations.firstWhere(
                  (s) => s.id == _selectedId,
                );
                Navigator.of(context).pop(chosen);
              },
              child: const Text('Confirm Return Station'),
            ),
          ],
        ),
      ),
    );
  }
}
