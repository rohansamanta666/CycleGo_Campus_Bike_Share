import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import '../models/active_ride.dart';
import '../models/ride_record.dart';
import '../models/station.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? _firestore;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  FirebaseFirestore get db {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  /// Initialize Firebase & Firestore
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firestore = FirebaseFirestore.instance;
      _initialized = true;
      debugPrint('[FirestoreService] Firebase Firestore initialized successfully.');
    } catch (e) {
      debugPrint('[FirestoreService] Firebase init error: $e');
    }
  }

  // ==========================================
  // STATIONS SYNC & REALTIME STREAM
  // ==========================================

  CollectionReference<Map<String, dynamic>> get _stationsCollection =>
      db.collection('stations');

  /// Listen to real-time updates for all campus stations
  Stream<List<Station>> streamStations() {
    if (!_initialized) {
      return const Stream.empty();
    }
    return _stationsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Station.fromJson(data);
      }).toList();
    });
  }

  /// Seed initial station data into Firestore if collection is empty
  Future<void> seedInitialStationsIfEmpty(List<Station> defaultStations) async {
    if (!_initialized) return;
    try {
      final snapshot = await _stationsCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('[FirestoreService] Seeding initial stations into Firestore...');
        final batch = db.batch();
        for (final station in defaultStations) {
          final docRef = _stationsCollection.doc(station.id);
          batch.set(docRef, station.toJson());
        }
        await batch.commit();
        debugPrint('[FirestoreService] Stations seeded successfully.');
      }
    } catch (e) {
      debugPrint('[FirestoreService] Seed stations error: $e');
    }
  }

  /// Update station bike availability count in Firestore
  Future<void> updateStationAvailability(String stationId, int availableBikes) async {
    if (!_initialized) return;
    try {
      await _stationsCollection.doc(stationId).update({
        'availableBikes': availableBikes,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FirestoreService] updateStationAvailability error: $e');
    }
  }

  // ==========================================
  // RIDES & HISTORY SYNC
  // ==========================================

  CollectionReference<Map<String, dynamic>> get _ridesCollection =>
      db.collection('rides');

  /// Save completed ride to Firestore
  Future<void> saveRideRecord(RideRecord ride) async {
    if (!_initialized) return;
    try {
      await _ridesCollection.doc(ride.id).set({
        ...ride.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FirestoreService] saveRideRecord error: $e');
    }
  }

  /// Stream ride history from Firestore (sorted by newest first)
  Stream<List<RideRecord>> streamRideHistory() {
    if (!_initialized) return const Stream.empty();
    return _ridesCollection
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RideRecord.fromJson(doc.data());
      }).toList();
    });
  }

  // ==========================================
  // ACTIVE RIDE SYNC
  // ==========================================

  CollectionReference<Map<String, dynamic>> get _activeRidesCollection =>
      db.collection('active_rides');

  /// Sync active ride to Firestore
  Future<void> syncActiveRide(ActiveRide? activeRide, {String deviceId = 'primary_user'}) async {
    if (!_initialized) return;
    try {
      final docRef = _activeRidesCollection.doc(deviceId);
      if (activeRide == null) {
        await docRef.delete();
      } else {
        await docRef.set({
          ...activeRide.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('[FirestoreService] syncActiveRide error: $e');
    }
  }

  // ==========================================
  // APP METADATA & FLEET METRICS
  // ==========================================

  CollectionReference<Map<String, dynamic>> get _metadataCollection =>
      db.collection('metadata');

  /// Publish or update general app & fleet metadata
  Future<void> updateAppMetadata({
    required int totalBikes,
    required int totalDocks,
    required int activeStationsCount,
  }) async {
    if (!_initialized) return;
    try {
      await _metadataCollection.doc('fleet_info').set({
        'appName': 'CycleGO',
        'version': '1.0.0+1',
        'totalCampusBikes': totalBikes,
        'totalCampusDocks': totalDocks,
        'activeStationsCount': activeStationsCount,
        'lastSync': FieldValue.serverTimestamp(),
        'systemStatus': 'Operational',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirestoreService] updateAppMetadata error: $e');
    }
  }
}
