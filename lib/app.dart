import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/station_provider.dart';
import 'providers/ride_history_provider.dart';
import 'providers/theme_provider.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/station_list_screen.dart';
import 'screens/active_ride_screen.dart';
import 'screens/ride_history_screen.dart';
import 'widgets/glass_container.dart';

class CycleGoApp extends StatelessWidget {
  final StorageService storageService;
  final FirestoreService? firestoreService;

  const CycleGoApp({
    super.key,
    required this.storageService,
    this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StationProvider>(
          create: (_) => StationProvider(
            storageService: storageService,
            firestoreService: firestoreService,
          ),
        ),
        ChangeNotifierProvider<RideHistoryProvider>(
          create: (_) => RideHistoryProvider(
            storageService: storageService,
            firestoreService: firestoreService,
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(storageService: storageService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'CycleGo - Campus Bike Rental',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationShell(),
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final stationProvider = context.watch<StationProvider>();
    final historyProvider = context.watch<RideHistoryProvider>();
    final hasActiveRide = stationProvider.hasActiveRide;
    final rideCount = historyProvider.totalRides;

    final screens = [
      StationListScreen(onNavigateToTab: _onTabSelected),
      ActiveRideScreen(onNavigateToTab: _onTabSelected),
      RideHistoryScreen(onNavigateToTab: _onTabSelected),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Row(
              children: [
                GlassContainer(
                  borderRadius: 0,
                  blur: 20,
                  opacity: isDark ? 0.75 : 0.85,
                  child: NavigationRail(
                    backgroundColor: Colors.transparent,
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onTabSelected,
                    labelType: NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
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
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pedal_bike,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    destinations: [
                      const NavigationRailDestination(
                        icon: Icon(Icons.location_on_outlined),
                        selectedIcon: Icon(Icons.location_on),
                        label: Text('Stations'),
                      ),
                      NavigationRailDestination(
                        icon: Badge(
                          isLabelVisible: hasActiveRide,
                          backgroundColor: Colors.amber.shade800,
                          smallSize: 8,
                          child: const Icon(Icons.directions_bike_outlined),
                        ),
                        selectedIcon: Badge(
                          isLabelVisible: hasActiveRide,
                          backgroundColor: Colors.amber.shade800,
                          smallSize: 8,
                          child: const Icon(Icons.directions_bike),
                        ),
                        label: const Text('Active Ride'),
                      ),
                      NavigationRailDestination(
                        icon: Badge(
                          isLabelVisible: rideCount > 0,
                          label: Text('$rideCount'),
                          child: const Icon(Icons.history_outlined),
                        ),
                        selectedIcon: Badge(
                          isLabelVisible: rideCount > 0,
                          label: Text('$rideCount'),
                          child: const Icon(Icons.history),
                        ),
                        label: const Text('History'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: GlassContainer(
            borderRadius: 0,
            blur: 20,
            opacity: isDark ? 0.75 : 0.85,
            borderColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.7),
            borderWidth: 1.0,
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on),
                  label: 'Stations',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: hasActiveRide,
                    backgroundColor: Colors.amber.shade800,
                    smallSize: 8,
                    child: const Icon(Icons.directions_bike_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: hasActiveRide,
                    backgroundColor: Colors.amber.shade800,
                    smallSize: 8,
                    child: const Icon(Icons.directions_bike),
                  ),
                  label: 'Active Ride',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: rideCount > 0,
                    label: Text('$rideCount'),
                    child: const Icon(Icons.history_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: rideCount > 0,
                    label: Text('$rideCount'),
                    child: const Icon(Icons.history),
                  ),
                  label: 'History',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
