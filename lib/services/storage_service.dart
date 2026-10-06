import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ride_record.dart';
import '../models/active_ride.dart';
import '../models/station.dart';

class StorageService {
  static const String _keyRideHistory = 'cyclego_ride_history';
  static const String _keyActiveRide = 'cyclego_active_ride';
  static const String _keyStations = 'cyclego_stations';
  static const String _keyThemeMode = 'cyclego_theme_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Ride History ---
  Future<bool> saveRideHistory(List<RideRecord> history) async {
    final jsonList = history.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    return await _prefs.setString(_keyRideHistory, jsonString);
  }

  List<RideRecord> loadRideHistory() {
    final jsonString = _prefs.getString(_keyRideHistory);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => RideRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> clearRideHistory() async {
    return await _prefs.remove(_keyRideHistory);
  }

  // --- Active Ride Persistence ---
  Future<bool> saveActiveRide(ActiveRide? activeRide) async {
    if (activeRide == null) {
      return await _prefs.remove(_keyActiveRide);
    }
    final jsonString = jsonEncode(activeRide.toJson());
    return await _prefs.setString(_keyActiveRide, jsonString);
  }

  ActiveRide? loadActiveRide() {
    final jsonString = _prefs.getString(_keyActiveRide);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return ActiveRide.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }

  // --- Stations Cache ---
  Future<bool> saveStations(List<Station> stations) async {
    final jsonList = stations.map((s) => s.toJson()).toList();
    return await _prefs.setString(_keyStations, jsonEncode(jsonList));
  }

  List<Station>? loadStations() {
    final jsonString = _prefs.getString(_keyStations);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => Station.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // --- Theme Mode ---
  Future<bool> saveThemeMode(String mode) async {
    return await _prefs.setString(_keyThemeMode, mode);
  }

  String? loadThemeMode() {
    return _prefs.getString(_keyThemeMode);
  }
}
