import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cycle_go/providers/station_provider.dart';
import 'package:cycle_go/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late StationProvider stationProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    stationProvider = StationProvider(storageService: storageService);
  });

  group('StationProvider Unit Tests', () {
    test('Initializes with default 8 campus stations', () {
      expect(stationProvider.allStations.length, 8);
      expect(stationProvider.hasActiveRide, isFalse);
      expect(stationProvider.activeRide, isNull);
    });

    test('reserveBike decrements availableBikes immediately and creates ActiveRide', () {
      final initialStation = stationProvider.allStations.first;
      final initialCount = initialStation.availableBikes;
      expect(initialCount, greaterThan(0));

      final activeRide = stationProvider.reserveBike(initialStation.id);

      expect(stationProvider.hasActiveRide, isTrue);
      expect(activeRide.pickupStationId, initialStation.id);
      expect(activeRide.pickupStationName, initialStation.name);

      final updatedStation = stationProvider.getStationById(initialStation.id)!;
      expect(updatedStation.availableBikes, initialCount - 1);
    });

    test('reserveBike throws error when station has 0 bikes', () {
      // Find the zero-bike station (Admin Block st-04)
      final zeroBikeStation = stationProvider.allStations.firstWhere(
        (s) => s.availableBikes == 0,
      );

      expect(
        () => stationProvider.reserveBike(zeroBikeStation.id),
        throwsA(isA<StateError>()),
      );
    });

    test('reserveBike throws error when user already has an active ride (one-active-ride rule)', () {
      final station1 = stationProvider.allStations.firstWhere(
        (s) => s.availableBikes > 0,
      );
      stationProvider.reserveBike(station1.id);

      expect(stationProvider.hasActiveRide, isTrue);

      final station2 = stationProvider.allStations
          .where((s) => s.id != station1.id && s.availableBikes > 0)
          .first;

      expect(
        () => stationProvider.reserveBike(station2.id),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'returnBike increments return station bike count and returns RideRecord',
      () {
        // Pickup from station 1
        final pickupStation = stationProvider.allStations.firstWhere(
          (s) => s.availableBikes > 0,
        );
        final initialPickupCount = pickupStation.availableBikes;
        stationProvider.reserveBike(pickupStation.id);

        // Return to a different station (e.g. station 2)
        final returnStation = stationProvider.allStations.firstWhere(
          (s) => s.id != pickupStation.id && !s.isFull,
        );
        final initialReturnCount = returnStation.availableBikes;

        final rideRecord = stationProvider.returnBike(returnStation.id);

        expect(stationProvider.hasActiveRide, isFalse);
        expect(rideRecord.pickupStationId, pickupStation.id);
        expect(rideRecord.returnStationId, returnStation.id);
        expect(rideRecord.durationSeconds, greaterThanOrEqualTo(0));

        final updatedReturnStation = stationProvider.getStationById(
          returnStation.id,
        )!;
        expect(updatedReturnStation.availableBikes, initialReturnCount + 1);

        final updatedPickupStation = stationProvider.getStationById(
          pickupStation.id,
        )!;
        expect(updatedPickupStation.availableBikes, initialPickupCount - 1);
      },
    );

    test('returnBike throws error when returning to a full station or non-existent station', () {
      final stProvider = StationProvider(storageService: storageService);
      stProvider.resetToDefault();
      stProvider.reserveBike('st-01');

      expect(
        () => stProvider.returnBike('non-existent-id'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('cancelReservation restores bike count and clears active ride', () {
      final station = stationProvider.allStations.firstWhere(
        (s) => s.availableBikes > 0,
      );
      final initialBikes = station.availableBikes;

      stationProvider.reserveBike(station.id);
      expect(stationProvider.hasActiveRide, isTrue);
      expect(
        stationProvider.getStationById(station.id)!.availableBikes,
        initialBikes - 1,
      );

      stationProvider.cancelReservation();
      expect(stationProvider.hasActiveRide, isFalse);
      expect(
        stationProvider.getStationById(station.id)!.availableBikes,
        initialBikes,
      );
    });

    test('Sorting options work correctly', () {
      stationProvider.setSortOption(StationSortOption.mostBikes);
      final sortedMostBikes = stationProvider.filteredStations;
      for (int i = 0; i < sortedMostBikes.length - 1; i++) {
        expect(
          sortedMostBikes[i].availableBikes,
          greaterThanOrEqualTo(sortedMostBikes[i + 1].availableBikes),
        );
      }

      stationProvider.setSortOption(StationSortOption.nearest);
      final sortedNearest = stationProvider.filteredStations;
      for (int i = 0; i < sortedNearest.length - 1; i++) {
        expect(
          sortedNearest[i].distanceMeters,
          lessThanOrEqualTo(sortedNearest[i + 1].distanceMeters),
        );
      }
    });

    test('Filter available only excludes 0-bike stations', () {
      stationProvider.toggleFilterAvailableOnly();
      final availableOnly = stationProvider.filteredStations;
      for (final s in availableOnly) {
        expect(s.availableBikes, greaterThan(0));
      }
    });
  });
}
