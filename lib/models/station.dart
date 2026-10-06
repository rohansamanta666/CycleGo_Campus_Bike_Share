import 'package:flutter/material.dart';

enum AvailabilityLevel {
  plenty, // >= 5 bikes
  low, // 1 - 4 bikes
  empty, // 0 bikes
}

class Station {
  final String id;
  final String name;
  final int distanceMeters;
  final int totalDocks;
  final int availableBikes;
  final String subtitle;
  final IconData icon;

  /// Campus map coordinates normalized between 0.0 and 1.0
  final double mapX;
  final double mapY;

  const Station({
    required this.id,
    required this.name,
    required this.distanceMeters,
    required this.totalDocks,
    required this.availableBikes,
    this.subtitle = 'Campus Docking Station',
    this.icon = Icons.directions_bike,
    this.mapX = 0.5,
    this.mapY = 0.5,
  });

  int get availableDocks => totalDocks - availableBikes;
  bool get hasBikes => availableBikes > 0;
  bool get isFull => availableBikes >= totalDocks;

  AvailabilityLevel get availabilityLevel {
    if (availableBikes <= 0) return AvailabilityLevel.empty;
    if (availableBikes < 5) return AvailabilityLevel.low;
    return AvailabilityLevel.plenty;
  }

  String get availabilityText {
    switch (availabilityLevel) {
      case AvailabilityLevel.plenty:
        return 'Plenty ($availableBikes available)';
      case AvailabilityLevel.low:
        return 'Low Stock ($availableBikes left)';
      case AvailabilityLevel.empty:
        return 'Unavailable (0 bikes)';
    }
  }

  String get distanceFormatted {
    if (distanceMeters < 1000) {
      return '$distanceMeters m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  Station copyWith({
    String? id,
    String? name,
    int? distanceMeters,
    int? totalDocks,
    int? availableBikes,
    String? subtitle,
    IconData? icon,
    double? mapX,
    double? mapY,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      totalDocks: totalDocks ?? this.totalDocks,
      availableBikes: availableBikes ?? this.availableBikes,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distanceMeters': distanceMeters,
      'totalDocks': totalDocks,
      'availableBikes': availableBikes,
      'subtitle': subtitle,
      'iconCodePoint': icon.codePoint,
      'mapX': mapX,
      'mapY': mapY,
    };
  }

  static IconData getIconForId(String id) {
    switch (id) {
      case 'st-01':
        return Icons.meeting_room;
      case 'st-02':
        return Icons.local_library;
      case 'st-03':
        return Icons.apartment;
      case 'st-04':
        return Icons.account_balance;
      case 'st-05':
        return Icons.sports_tennis;
      case 'st-06':
        return Icons.restaurant;
      case 'st-07':
        return Icons.computer;
      case 'st-08':
        return Icons.lightbulb;
      default:
        return Icons.directions_bike;
    }
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return Station(
      id: id,
      name: json['name'] as String,
      distanceMeters: json['distanceMeters'] as int,
      totalDocks: json['totalDocks'] as int,
      availableBikes: json['availableBikes'] as int,
      subtitle: (json['subtitle'] as String?) ?? 'Campus Docking Station',
      icon: getIconForId(id),
      mapX: (json['mapX'] as num?)?.toDouble() ?? 0.5,
      mapY: (json['mapY'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
