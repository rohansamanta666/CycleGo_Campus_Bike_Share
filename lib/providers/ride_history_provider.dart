import 'dart:async';

import 'package:flutter/material.dart';

import '../models/ride_record.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';

class RideHistoryProvider extends ChangeNotifier {
  final StorageService? storageService;
  final FirestoreService? firestoreService;

  List<RideRecord> _history = [];
  bool _isLoading = true;
  StreamSubscription<List<RideRecord>>? _firestoreSubscription;

  RideHistoryProvider({this.storageService, this.firestoreService}) {
    _loadHistory();
    _connectFirestore();
  }

  List<RideRecord> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  bool get isEmpty => _history.isEmpty;
  int get totalRides => _history.length;

  int get totalDurationSeconds =>
      _history.fold(0, (sum, ride) => sum + ride.durationSeconds);

  int get totalDistanceMeters =>
      _history.fold(0, (sum, ride) => sum + ride.distanceMeters);

  double get totalCaloriesBurned =>
      _history.fold(0.0, (sum, ride) => sum + ride.caloriesBurned);

  /// Green campus impact: 0.16 kg CO2 saved per km vs motor vehicle
  double get co2SavedKg => (totalDistanceMeters / 1000.0) * 0.16;

  void _loadHistory() {
    if (storageService != null) {
      _history = storageService!.loadRideHistory();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _connectFirestore() {
    if (firestoreService == null) return;
    _firestoreSubscription = firestoreService!.streamRideHistory().listen((cloudRides) {
      if (cloudRides.isNotEmpty) {
        // Merge cloud rides with local list, avoiding duplicates by id
        final existingIds = _history.map((r) => r.id).toSet();
        final newRides = cloudRides.where((r) => !existingIds.contains(r.id)).toList();
        if (newRides.isNotEmpty) {
          _history.addAll(newRides);
          _history.sort((a, b) => b.startTime.compareTo(a.startTime));
          storageService?.saveRideHistory(_history);
          notifyListeners();
        }
      }
    });
  }

  /// Add a newly finished ride to the top of the history list and persist.
  Future<void> addRide(RideRecord ride) async {
    _history.insert(0, ride);
    if (storageService != null) {
      await storageService!.saveRideHistory(_history);
    }
    firestoreService?.saveRideRecord(ride);
    notifyListeners();
  }

  /// Clear all ride history and wipe storage.
  Future<void> clearHistory() async {
    _history.clear();
    if (storageService != null) {
      await storageService!.clearRideHistory();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
