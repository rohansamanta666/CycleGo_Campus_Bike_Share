import 'package:intl/intl.dart';

class RideRecord {
  final String id;
  final String pickupStationId;
  final String pickupStationName;
  final String returnStationId;
  final String returnStationName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int distanceMeters;
  final double caloriesBurned;
  final String bikeId;

  const RideRecord({
    required this.id,
    required this.pickupStationId,
    required this.pickupStationName,
    required this.returnStationId,
    required this.returnStationName,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.caloriesBurned,
    required this.bikeId,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) {
      return '$seconds sec';
    } else if (minutes < 60) {
      return '$minutes min $seconds sec';
    } else {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      return '${hours}h ${remainingMins}m';
    }
  }

  String get formattedDate {
    return DateFormat('MMM d, yyyy • h:mm a').format(startTime);
  }

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '$distanceMeters m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupStationId': pickupStationId,
      'pickupStationName': pickupStationName,
      'returnStationId': returnStationId,
      'returnStationName': returnStationName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'distanceMeters': distanceMeters,
      'caloriesBurned': caloriesBurned,
      'bikeId': bikeId,
    };
  }

  factory RideRecord.fromJson(Map<String, dynamic> json) {
    return RideRecord(
      id: json['id'] as String,
      pickupStationId: json['pickupStationId'] as String,
      pickupStationName: json['pickupStationName'] as String,
      returnStationId: json['returnStationId'] as String,
      returnStationName: json['returnStationName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationSeconds: json['durationSeconds'] as int,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 500,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 25.0,
      bikeId: (json['bikeId'] as String?) ?? 'CG-101',
    );
  }
}
