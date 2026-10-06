import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ride_history_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/ride_card.dart';

class RideHistoryScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const RideHistoryScreen({super.key, this.onNavigateToTab});

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Ride History?'),
          content: const Text(
            'Are you sure you want to delete all saved ride logs? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context.read<RideHistoryProvider>().clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ride history cleared successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final historyProvider = context.watch<RideHistoryProvider>();

    final history = historyProvider.history;
    final hasHistory = history.isNotEmpty;

    return AmbientBackgroundMesh(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Ride History'),
          actions: [
            if (hasHistory)
              GlassContainer(
                borderRadius: 14,
                blur: 12,
                opacity: isDark ? 0.6 : 0.7,
                margin: const EdgeInsets.only(right: 12),
                borderWidth: 1.0,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear History',
                  onPressed: () => _showClearConfirmation(context),
                ),
              ),
          ],
        ),
        body: historyProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : !hasHistory
            ? _buildEmptyState(context, colorScheme)
            : CustomScrollView(
                slivers: [
                  // Statistics Summary Card Header
                  SliverToBoxAdapter(
                    child: _buildSummaryAnalyticsCard(context, historyProvider),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RECENT CAMPUS TRIPS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: colorScheme.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${history.length} rides recorded',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List of Ride Cards
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final ride = history[index];
                      return RideCard(ride: ride);
                    }, childCount: history.length),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryAnalyticsCard(
    BuildContext context,
    RideHistoryProvider provider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final totalMinutes = provider.totalDurationSeconds ~/ 60;
    final totalKm = (provider.totalDistanceMeters / 1000.0).toStringAsFixed(1);
    final co2Kg = provider.co2SavedKg.toStringAsFixed(2);
    final calories = provider.totalCaloriesBurned.toStringAsFixed(0);

    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      borderRadius: 22,
      blur: 18,
      opacity: isDark ? 0.75 : 0.85,
      tintColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.5),
      borderWidth: 1.3,
      padding: const EdgeInsets.all(18),
      child: Column(
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Campus Eco Impact Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Rides',
                '${provider.totalRides}',
                Icons.pedal_bike,
                colorScheme.primary,
              ),
              _buildStatItem(
                'Time',
                '${totalMinutes}m',
                Icons.schedule,
                colorScheme.secondary,
              ),
              _buildStatItem(
                'Distance',
                '$totalKm km',
                Icons.alt_route,
                const Color(0xFF0284C7),
              ),
              _buildStatItem(
                'CO2 Saved',
                '$co2Kg kg',
                Icons.forest,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.deepOrange.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                '🔥 Total Energy Burned: $calories kcal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

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
                      colorScheme.primary.withValues(alpha: 0.2),
                      colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_toggle_off_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Ride History Yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your completed campus bicycle trips and eco impact stats will appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  onNavigateToTab?.call(0);
                },
                icon: const Icon(Icons.pedal_bike),
                label: const Text('Start Your First Ride'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
