import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cycle_go/models/ride_record.dart';
import 'package:cycle_go/providers/ride_history_provider.dart';
import 'package:cycle_go/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late RideHistoryProvider historyProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    historyProvider = RideHistoryProvider(storageService: storageService);
  });

  group('RideHistoryProvider Unit Tests', () {
    test('Initializes with empty history', () {
      expect(historyProvider.history, isEmpty);
      expect(historyProvider.isEmpty, isTrue);
      expect(historyProvider.totalRides, 0);
      expect(historyProvider.totalDurationSeconds, 0);
    });

    test(
      'addRide adds ride record to list and calculates analytics correctly',
      () async {
        final now = DateTime.now();
        final ride1 = RideRecord(
          id: 'test-ride-1',
          pickupStationId: 'st-01',
          pickupStationName: 'Main Gate',
          returnStationId: 'st-02',
          returnStationName: 'Library',
          startTime: now.subtract(const Duration(minutes: 10)),
          endTime: now,
          durationSeconds: 600,
          distanceMeters: 1500,
          caloriesBurned: 72.0,
          bikeId: 'CG-505',
        );

        await historyProvider.addRide(ride1);

        expect(historyProvider.totalRides, 1);
        expect(historyProvider.history.first.id, 'test-ride-1');
        expect(historyProvider.totalDurationSeconds, 600);
        expect(historyProvider.totalDistanceMeters, 1500);
        expect(historyProvider.totalCaloriesBurned, 72.0);
        expect(historyProvider.co2SavedKg, closeTo(0.24, 0.01)); // 1.5km * 0.16
      },
    );

    test(
      'Persists history across provider recreation (simulating app restart)',
      () async {
        final now = DateTime.now();
        final ride = RideRecord(
          id: 'persisted-ride-1',
          pickupStationId: 'st-03',
          pickupStationName: 'Hostel Block',
          returnStationId: 'st-07',
          returnStationName: 'Tech Park',
          startTime: now.subtract(const Duration(minutes: 15)),
          endTime: now,
          durationSeconds: 900,
          distanceMeters: 2200,
          caloriesBurned: 108.0,
          bikeId: 'CG-777',
        );

        await historyProvider.addRide(ride);

        // Recreate history provider with same storage service
        final newHistoryProvider = RideHistoryProvider(
          storageService: storageService,
        );
        expect(newHistoryProvider.totalRides, 1);
        expect(newHistoryProvider.history.first.id, 'persisted-ride-1');
        expect(
          newHistoryProvider.history.first.pickupStationName,
          'Hostel Block',
        );
      },
    );

    test('clearHistory clears in-memory and persistent records', () async {
      final ride = RideRecord(
        id: 'clear-test',
        pickupStationId: 'st-01',
        pickupStationName: 'Main Gate',
        returnStationId: 'st-02',
        returnStationName: 'Library',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        durationSeconds: 300,
        distanceMeters: 800,
        caloriesBurned: 36.0,
        bikeId: 'CG-101',
      );

      await historyProvider.addRide(ride);
      expect(historyProvider.totalRides, 1);

      await historyProvider.clearHistory();
      expect(historyProvider.totalRides, 0);
      expect(historyProvider.isEmpty, isTrue);

      // Verify persistence was wiped
      final reloadedProvider = RideHistoryProvider(
        storageService: storageService,
      );
      expect(reloadedProvider.totalRides, 0);
    });
  });
}
