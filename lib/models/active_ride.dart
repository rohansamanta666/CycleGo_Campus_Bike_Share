class ActiveRide {
  final String id;
  final String pickupStationId;
  final String pickupStationName;
  final DateTime startTime;
  final String bikeId;
  final String unlockCode;

  const ActiveRide({
    required this.id,
    required this.pickupStationId,
    required this.pickupStationName,
    required this.startTime,
    required this.bikeId,
    required this.unlockCode,
  });

  int get elapsedSeconds => DateTime.now().difference(startTime).inSeconds;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupStationId': pickupStationId,
      'pickupStationName': pickupStationName,
      'startTime': startTime.toIso8601String(),
      'bikeId': bikeId,
      'unlockCode': unlockCode,
    };
  }

  factory ActiveRide.fromJson(Map<String, dynamic> json) {
    return ActiveRide(
      id: json['id'] as String,
      pickupStationId: json['pickupStationId'] as String,
      pickupStationName: json['pickupStationName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      bikeId: json['bikeId'] as String,
      unlockCode: json['unlockCode'] as String,
    );
  }
}
