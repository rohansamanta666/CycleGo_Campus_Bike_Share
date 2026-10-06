import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/station.dart';
import '../providers/station_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/station_card.dart';
import '../widgets/campus_map_header.dart';
import '../widgets/active_ride_banner.dart';
import '../widgets/availability_badge.dart';
import 'reservation_screen.dart';

class StationListScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const StationListScreen({super.key, this.onNavigateToTab});

  @override
  State<StationListScreen> createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStationId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openReservation(BuildContext context, Station station) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReservationScreen(stationId: station.id),
      ),
    );
    if (result == true) {
      widget.onNavigateToTab?.call(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final stationProvider = context.watch<StationProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final stations = stationProvider.filteredStations;
    final activeRide = stationProvider.activeRide;

    return AmbientBackgroundMesh(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 900;

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pedal_bike,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'CycleGo',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 21,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Campus Bike Share',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Live Campus Simulation Toggle Button in Glass Container
                GlassContainer(
                  borderRadius: 14,
                  blur: 12,
                  opacity: isDark ? 0.65 : 0.8,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  borderWidth: 1.0,
                  child: Tooltip(
                    message: stationProvider.isSimulationActive
                        ? 'Live Simulation Active (Click to Pause)'
                        : 'Enable Live Simulation (Simulates campus users)',
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      onPressed: () {
                        stationProvider.toggleSimulation();
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              stationProvider.isSimulationActive
                                  ? '⚡ Live campus bike updates enabled'
                                  : '⏸️ Live simulation paused',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        stationProvider.isSimulationActive
                            ? Icons.bolt
                            : Icons.bolt_outlined,
                        color: stationProvider.isSimulationActive
                            ? Colors.amber
                            : colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      label: Text(
                        stationProvider.isSimulationActive ? 'LIVE' : 'Simulate',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: stationProvider.isSimulationActive
                              ? (isDark
                                    ? Colors.amberAccent
                                    : Colors.amber.shade900)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Theme Toggle Glass Icon Button
                GlassContainer(
                  borderRadius: 14,
                  blur: 12,
                  opacity: isDark ? 0.65 : 0.8,
                  borderWidth: 1.0,
                  child: IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode_outlined,
                      color: isDark ? Colors.amber : colorScheme.onSurface,
                    ),
                    tooltip: 'Toggle Theme',
                    onPressed: () => themeProvider.toggleTheme(),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: isWideScreen
                ? _buildWideScreenLayout(
                    context,
                    stationProvider,
                    stations,
                    activeRide,
                  )
                : _buildMobileLayout(
                    context,
                    stationProvider,
                    stations,
                    activeRide,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    StationProvider provider,
    List<Station> stations,
    dynamic activeRide,
  ) {
    return CustomScrollView(
      slivers: [
        // Active ride banner if ride is in progress
        if (activeRide != null)
          SliverToBoxAdapter(
            child: ActiveRideBanner(
              activeRide: activeRide,
              onTap: () {
                widget.onNavigateToTab?.call(1);
              },
            ),
          ),

        // Realistic & Fullscreen-ready Campus Map Header
        SliverToBoxAdapter(
          child: CampusMapHeader(
            stations: provider.allStations,
            selectedStationId: _selectedStationId,
            onStationSelected: (station) {
              setState(() {
                _selectedStationId = station.id;
              });
              _openReservation(context, station);
            },
          ),
        ),

        // Search & Filter Header
        SliverToBoxAdapter(child: _buildSearchAndFilterControls(provider)),

        // Station Cards List
        if (stations.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyFilterState(provider),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final station = stations[index];
              return StationCard(
                station: station,
                isSelected: station.id == _selectedStationId,
                hasActiveRide: provider.hasActiveRide,
                onTap: () {
                  setState(() {
                    _selectedStationId = station.id;
                  });
                  _openReservation(context, station);
                },
                onReserveTap: () => _openReservation(context, station),
              );
            }, childCount: stations.length),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 36)),
      ],
    );
  }

  Widget _buildWideScreenLayout(
    BuildContext context,
    StationProvider provider,
    List<Station> stations,
    dynamic activeRide,
  ) {
    final selectedStation =
        provider.getStationById(_selectedStationId ?? '') ??
        (stations.isNotEmpty ? stations.first : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Station List & Filters
        Expanded(
          flex: 6,
          child: CustomScrollView(
            slivers: [
              if (activeRide != null)
                SliverToBoxAdapter(
                  child: ActiveRideBanner(
                    activeRide: activeRide,
                    onTap: () => widget.onNavigateToTab?.call(1),
                  ),
                ),
              SliverToBoxAdapter(
                child: _buildSearchAndFilterControls(provider),
              ),
              if (stations.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyFilterState(provider),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final station = stations[index];
                    return StationCard(
                      station: station,
                      isSelected: station.id == selectedStation?.id,
                      hasActiveRide: provider.hasActiveRide,
                      onTap: () {
                        setState(() {
                          _selectedStationId = station.id;
                        });
                      },
                      onReserveTap: () => _openReservation(context, station),
                    );
                  }, childCount: stations.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 36)),
            ],
          ),
        ),

        // Vertical divider
        const VerticalDivider(width: 1),

        // Right Column: Live Map & Selected Station Detail Pane
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CampusMapHeader(
                  stations: provider.allStations,
                  selectedStationId: selectedStation?.id,
                  onStationSelected: (st) {
                    setState(() {
                      _selectedStationId = st.id;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedStation != null)
                  _buildStationDetailCard(context, selectedStation, provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationDetailCard(
    BuildContext context,
    Station station,
    StationProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isZeroBike = station.availableBikes == 0;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: 24,
      blur: 18,
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(station.icon, color: colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      station.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AvailabilityBadge(
                level: station.availabilityLevel,
                count: station.availableBikes,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distance: ${station.distanceFormatted}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Total Capacity: ${station.totalDocks} docks',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: (isZeroBike || provider.hasActiveRide)
                ? null
                : () => _openReservation(context, station),
            child: Text(
              isZeroBike
                  ? 'No Bikes Available'
                  : provider.hasActiveRide
                  ? 'Active Ride in Progress'
                  : 'Proceed to Reserve Bike',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterControls(StationProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glass Search Input Field
          GlassContainer(
            borderRadius: 18,
            blur: 14,
            opacity: isDark ? 0.65 : 0.85,
            borderWidth: 1.2,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search campus stations, hubs, dorms...',
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 22,
                  color: colorScheme.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sort & Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Nearest',
                  selected: provider.sortOption == StationSortOption.nearest,
                  icon: Icons.near_me_outlined,
                  onSelected: () =>
                      provider.setSortOption(StationSortOption.nearest),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Most Bikes',
                  selected: provider.sortOption == StationSortOption.mostBikes,
                  icon: Icons.pedal_bike_outlined,
                  onSelected: () =>
                      provider.setSortOption(StationSortOption.mostBikes),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'A-Z',
                  selected: provider.sortOption == StationSortOption.name,
                  icon: Icons.sort_by_alpha_outlined,
                  onSelected: () =>
                      provider.setSortOption(StationSortOption.name),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Available Only',
                  selected: provider.filterAvailableOnly,
                  icon: Icons.check_circle_outline,
                  onSelected: () => provider.toggleFilterAvailableOnly(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Total counts summary bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.filteredStations.length} Campus Stations',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${provider.totalAvailableBikes} Bikes Ready for Rental',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required IconData icon,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GlassContainer(
      borderRadius: 14,
      blur: 10,
      opacity: selected ? (isDark ? 0.8 : 0.9) : (isDark ? 0.45 : 0.6),
      tintColor: selected
          ? colorScheme.primaryContainer
          : (isDark ? const Color(0xFF0F172A) : Colors.white),
      borderColor: selected
          ? colorScheme.primary
          : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
      borderWidth: selected ? 1.5 : 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      onTap: onSelected,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState(StationProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GlassContainer(
          borderRadius: 24,
          blur: 18,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Stations Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try changing your search query or reset your availability filters.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                  if (provider.filterAvailableOnly) {
                    provider.toggleFilterAvailableOnly();
                  }
                },
                child: const Text('Reset Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
