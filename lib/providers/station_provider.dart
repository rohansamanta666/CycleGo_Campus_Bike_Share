import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/station.dart';
import '../models/active_ride.dart';
import '../models/ride_record.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';

enum StationSortOption { nearest, mostBikes, name }

class StationProvider extends ChangeNotifier {
  final StorageService? storageService;
  final FirestoreService? firestoreService;

  List<Station> _stations = [];
  ActiveRide? _activeRide;
  StationSortOption _sortOption = StationSortOption.nearest;
  bool _filterAvailableOnly = false;
  String _searchQuery = '';
  bool _isSimulationActive = false;
  Timer? _simulationTimer;
  StreamSubscription<List<Station>>? _firestoreSubscription;

  StationProvider({this.storageService, this.firestoreService}) {
    _initializeStations();
    _connectFirestore();
  }

  // Initial realistic campus docking stations
  static List<Station> get initialStations => const [
    Station(
      id: 'st-01',
      name: 'Main Campus Gate',
      subtitle: 'North Entry & Security Post',
      distanceMeters: 120,
      totalDocks: 15,
      availableBikes: 8,
      icon: Icons.meeting_room,
      mapX: 0.18,
      mapY: 0.22,
    ),
    Station(
      id: 'st-02',
      name: 'Central Library',
      subtitle: 'Main Reading & Study Plaza',
      distanceMeters: 280,
      totalDocks: 12,
      availableBikes: 5,
      icon: Icons.local_library,
      mapX: 0.48,
      mapY: 0.35,
    ),
    Station(
      id: 'st-03',
      name: 'Hostel Block A & B',
      subtitle: 'Student Residence Quadrangle',
      distanceMeters: 450,
      totalDocks: 20,
      availableBikes: 2, // Low availability state
      icon: Icons.apartment,
      mapX: 0.78,
      mapY: 0.25,
    ),
    Station(
      id: 'st-04',
      name: 'Admin & Dean Block',
      subtitle: 'Academic Affairs & Senate',
      distanceMeters: 320,
      totalDocks: 10,
      availableBikes: 0, // Zero-bike unavailable station state
      icon: Icons.account_balance,
      mapX: 0.35,
      mapY: 0.60,
    ),
    Station(
      id: 'st-05',
      name: 'Sports Complex & Arena',
      subtitle: 'Gym, Track & Indoor Courts',
      distanceMeters: 620,
      totalDocks: 16,
      availableBikes: 9,
      icon: Icons.sports_tennis,
      mapX: 0.82,
      mapY: 0.75,
    ),
    Station(
      id: 'st-06',
      name: 'Food Court & Cafeteria',
      subtitle: 'Student Center & Dine In',
      distanceMeters: 210,
      totalDocks: 14,
      availableBikes: 3, // Low availability state
      icon: Icons.restaurant,
      mapX: 0.58,
      mapY: 0.52,
    ),
    Station(
      id: 'st-07',
      name: 'Tech Park & AI Labs',
      subtitle: 'CSE Dept & Research Cluster',
      distanceMeters: 380,
      totalDocks: 18,
      availableBikes: 11,
      icon: Icons.computer,
      mapX: 0.22,
      mapY: 0.82,
    ),
    Station(
      id: 'st-08',
      name: 'Innovation & Incubation Hub',
      subtitle: 'Startups & Makerspace',
      distanceMeters: 510,
      totalDocks: 10,
      availableBikes: 6,
      icon: Icons.lightbulb,
      mapX: 0.52,
      mapY: 0.88,
    ),
  ];

  void _initializeStations() {
    final cached = storageService?.loadStations();
    if (cached != null && cached.isNotEmpty) {
      _stations = cached;
    } else {
      _stations = List<Station>.from(initialStations);
    }
    _activeRide = storageService?.loadActiveRide();
  }

  void _connectFirestore() {
    if (firestoreService == null) return;
    
    // Seed initial stations if needed
    firestoreService!.seedInitialStationsIfEmpty(initialStations);

    // Stream real-time updates from Firestore
    _firestoreSubscription = firestoreService!.streamStations().listen((cloudStations) {
      if (cloudStations.isNotEmpty) {
        _stations = cloudStations;
        storageService?.saveStations(_stations);
        notifyListeners();
      }
    });
  }

  // Getters
  List<Station> get allStations => List.unmodifiable(_stations);

  List<Station> get filteredStations {
    var list = _stations.where((station) {
      if (_filterAvailableOnly && station.availableBikes <= 0) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = station.name.toLowerCase().contains(query);
        final matchSub = station.subtitle.toLowerCase().contains(query);
        if (!matchName && !matchSub) return false;
      }
      return true;
    }).toList();

    switch (_sortOption) {
      case StationSortOption.nearest:
        list.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        break;
      case StationSortOption.mostBikes:
        list.sort((a, b) => b.availableBikes.compareTo(a.availableBikes));
        break;
      case StationSortOption.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return list;
  }

  ActiveRide? get activeRide => _activeRide;
  bool get hasActiveRide => _activeRide != null;
  StationSortOption get sortOption => _sortOption;
  bool get filterAvailableOnly => _filterAvailableOnly;
  String get searchQuery => _searchQuery;
  bool get isSimulationActive => _isSimulationActive;

  int get totalAvailableBikes =>
      _stations.fold(0, (sum, s) => sum + s.availableBikes);
  int get totalCampusDocks => _stations.fold(0, (sum, s) => sum + s.totalDocks);

  Station? getStationById(String id) {
    try {
      return _stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Sorting and Filtering
  void setSortOption(StationSortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  void toggleFilterAvailableOnly() {
    _filterAvailableOnly = !_filterAvailableOnly;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  /// Reserve a bike from the specified station.
  /// Enforces:
  /// 1. Only ONE active reservation/ride allowed at a time.
  /// 2. Station must have at least 1 bike available.
  /// Decrements station bike count instantly and triggers reactive updates.
  ActiveRide reserveBike(String stationId) {
    if (hasActiveRide) {
      throw StateError(
        'You already have an active ride (${_activeRide!.bikeId}). Return your current bike before reserving another.',
      );
    }

    final index = _stations.indexWhere((s) => s.id == stationId);
    if (index == -1) {
      throw ArgumentError('Station not found: $stationId');
    }

    final station = _stations[index];
    if (station.availableBikes <= 0) {
      throw StateError(
        'No bikes currently available at ${station.name}. Please select another station.',
      );
    }

    // Decrement bike count immediately
    _stations[index] = station.copyWith(
      availableBikes: station.availableBikes - 1,
    );

    final randomId = Random().nextInt(900) + 100;
    final bikeCode = 'CG-$randomId';
    final unlockPin = '${Random().nextInt(9000) + 1000}';

    _activeRide = ActiveRide(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      pickupStationId: station.id,
      pickupStationName: station.name,
      startTime: DateTime.now(),
      bikeId: bikeCode,
      unlockCode: unlockPin,
    );

    _persistState();
    _syncFirestoreStation(station.id, _stations[index].availableBikes);
    firestoreService?.syncActiveRide(_activeRide);
    _syncFleetMetadata();
    notifyListeners();
    return _activeRide!;
  }

  /// Return a bike at ANY station (including different from pickup).
  /// Enforces:
  /// 1. Must have an active ride.
  /// 2. Return station must not exceed dock capacity.
  /// Increments return station bike count instantly and returns a completed RideRecord.
  RideRecord returnBike(String returnStationId) {
    if (!hasActiveRide) {
      throw StateError('No active ride to return.');
    }

    final index = _stations.indexWhere((s) => s.id == returnStationId);
    if (index == -1) {
      throw ArgumentError('Return station not found: $returnStationId');
    }

    final station = _stations[index];
    if (station.isFull) {
      throw StateError(
        '${station.name} is currently full (${station.totalDocks}/${station.totalDocks} docks occupied). Please choose another docking station.',
      );
    }

    // Increment bike count at return station
    _stations[index] = station.copyWith(
      availableBikes: station.availableBikes + 1,
    );

    final active = _activeRide!;
    final endTime = DateTime.now();
    final durationSeconds = max(
      5,
      endTime.difference(active.startTime).inSeconds,
    );

    // Calculate approximate metrics for student display
    final distanceMeters = max(200, (durationSeconds * 3.5).toInt());
    final caloriesBurned = double.parse(
      (durationSeconds * 0.12).toStringAsFixed(1),
    );

    final rideRecord = RideRecord(
      id: active.id,
      pickupStationId: active.pickupStationId,
      pickupStationName: active.pickupStationName,
      returnStationId: station.id,
      returnStationName: station.name,
      startTime: active.startTime,
      endTime: endTime,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      caloriesBurned: caloriesBurned,
      bikeId: active.bikeId,
    );

    _activeRide = null;
    _persistState();
    _syncFirestoreStation(station.id, _stations[index].availableBikes);
    firestoreService?.syncActiveRide(null);
    _syncFleetMetadata();
    notifyListeners();
    return rideRecord;
  }

  /// Cancel an active reservation immediately, restoring bike count.
  void cancelReservation() {
    if (!hasActiveRide) return;
    final pickupId = _activeRide!.pickupStationId;
    final index = _stations.indexWhere((s) => s.id == pickupId);
    if (index != -1) {
      final station = _stations[index];
      if (station.availableBikes < station.totalDocks) {
        _stations[index] = station.copyWith(
          availableBikes: station.availableBikes + 1,
        );
        _syncFirestoreStation(pickupId, _stations[index].availableBikes);
      }
    }
    _activeRide = null;
    _persistState();
    firestoreService?.syncActiveRide(null);
    _syncFleetMetadata();
    notifyListeners();
  }

  /// Reset all stations to default testing state.
  void resetToDefault() {
    _stations = List<Station>.from(initialStations);
    _activeRide = null;
    _persistState();
    for (final s in _stations) {
      _syncFirestoreStation(s.id, s.availableBikes);
    }
    firestoreService?.syncActiveRide(null);
    _syncFleetMetadata();
    notifyListeners();
  }

  // --- Live Campus Simulation ---
  /// Toggle live simulation of background campus bike checkouts/returns.
  void toggleSimulation([bool? enable]) {
    final nextState = enable ?? !_isSimulationActive;
    if (_isSimulationActive == nextState) return;

    _isSimulationActive = nextState;
    if (_isSimulationActive) {
      _startSimulation();
    } else {
      _simulationTimer?.cancel();
      _simulationTimer = null;
    }
    notifyListeners();
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _simulateRandomCampusActivity();
    });
  }

  void _simulateRandomCampusActivity() {
    if (_stations.isEmpty) return;
    final random = Random();
    final stationIndex = random.nextInt(_stations.length);
    final station = _stations[stationIndex];

    final isReturn = random.nextBool();
    if (isReturn && station.availableBikes < station.totalDocks) {
      _stations[stationIndex] = station.copyWith(
        availableBikes: station.availableBikes + 1,
      );
      _persistState();
      _syncFirestoreStation(station.id, _stations[stationIndex].availableBikes);
      _syncFleetMetadata();
      notifyListeners();
    } else if (!isReturn && station.availableBikes > 0) {
      _stations[stationIndex] = station.copyWith(
        availableBikes: station.availableBikes - 1,
      );
      _persistState();
      _syncFirestoreStation(station.id, _stations[stationIndex].availableBikes);
      _syncFleetMetadata();
      notifyListeners();
    }
  }

  void _syncFirestoreStation(String stationId, int bikes) {
    firestoreService?.updateStationAvailability(stationId, bikes);
  }

  void _syncFleetMetadata() {
    firestoreService?.updateAppMetadata(
      totalBikes: totalAvailableBikes,
      totalDocks: totalCampusDocks,
      activeStationsCount: _stations.length,
    );
  }

  void _persistState() {
    storageService?.saveStations(_stations);
    storageService?.saveActiveRide(_activeRide);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
