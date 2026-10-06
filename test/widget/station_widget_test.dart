import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cycle_go/app.dart';
import 'package:cycle_go/models/station.dart';
import 'package:cycle_go/services/storage_service.dart';
import 'package:cycle_go/widgets/station_card.dart';
import 'package:cycle_go/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Widget Tests', () {
    testWidgets(
      'StationCard renders station details and plenty availability badge',
      (WidgetTester tester) async {
        const station = Station(
          id: 'st-01',
          name: 'Main Campus Gate',
          distanceMeters: 250,
          totalDocks: 15,
          availableBikes: 8,
          subtitle: 'North Entry & Security Post',
        );

        bool tapped = false;
        bool reserved = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: StationCard(
                station: station,
                onTap: () => tapped = true,
                onReserveTap: () => reserved = true,
              ),
            ),
          ),
        );

        expect(find.text('Main Campus Gate'), findsOneWidget);
        expect(find.text('250 m'), findsOneWidget);
        expect(find.text('8 Available'), findsOneWidget);
        expect(find.text('8 / 15 Docks'), findsOneWidget);
        expect(find.text('Reserve'), findsOneWidget);

        await tester.tap(find.text('Reserve'));
        expect(reserved, isTrue);

        await tester.tap(find.text('Main Campus Gate'));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'StationCard renders zero-bike station with Unavailable badge and disabled Reserve',
      (WidgetTester tester) async {
        const station = Station(
          id: 'st-04',
          name: 'Admin & Dean Block',
          distanceMeters: 320,
          totalDocks: 10,
          availableBikes: 0,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: StationCard(
                station: station,
                onTap: () {},
                onReserveTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Admin & Dean Block'), findsOneWidget);
        expect(find.text('Unavailable'), findsOneWidget);
        expect(find.text('Empty'), findsOneWidget);
      },
    );

    testWidgets(
      'Full cycle journey: Reserve bike updates station count live and navigates',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final storageService = await StorageService.init();

        await tester.pumpWidget(CycleGoApp(storageService: storageService));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify app title
        expect(find.text('CycleGo'), findsOneWidget);

        // Verify Main Campus Gate has 8 Available bikes initially
        expect(find.text('Main Campus Gate'), findsOneWidget);
        expect(find.text('8 Available'), findsOneWidget);

        // Tap on Main Campus Gate to open reservation screen
        await tester.tap(find.text('Main Campus Gate').first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // We should be on the Reserve Bike screen (Step 2)
        expect(find.text('Reserve Bike'), findsWidgets);
        expect(find.text('Step 2 of 4'), findsOneWidget);
        expect(find.text('Confirm & Reserve Bike'), findsOneWidget);

        // Tap Confirm & Reserve Bike
        await tester.ensureVisible(find.text('Confirm & Reserve Bike'));
        await tester.tap(find.text('Confirm & Reserve Bike'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Reservation Success dialog appears
        expect(find.text('Bike Reserved!'), findsOneWidget);
        expect(find.text('Start Riding Now'), findsOneWidget);

        // Tap Start Riding Now
        await tester.tap(find.text('Start Riding Now'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // We should now be on the Active Ride Screen
        expect(find.text('RIDE IN PROGRESS'), findsOneWidget);
        expect(find.text('Step 3 of 4'), findsOneWidget);
        expect(find.text('Select Station & Return Bike'), findsOneWidget);

        // Return the bike
        await tester.ensureVisible(find.text('Select Station & Return Bike'));
        await tester.tap(find.text('Select Station & Return Bike'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Return station picker modal appears
        expect(find.text('Select Drop-off Docking Station'), findsOneWidget);

        // Confirm return
        await tester.tap(find.text('Confirm Return Station'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Ride completed dialog
        expect(find.text('Ride Completed!'), findsOneWidget);
        expect(find.text('View History'), findsOneWidget);

        // Tap View History
        await tester.tap(find.text('View History'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should be on History tab with 1 ride recorded
        expect(find.text('Ride History'), findsWidgets);
        expect(find.text('Campus Eco Impact Summary'), findsOneWidget);
        expect(find.text('1 rides recorded'), findsOneWidget);
      },
    );
  });
}
