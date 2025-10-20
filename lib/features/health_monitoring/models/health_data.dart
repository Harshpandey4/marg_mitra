import 'dart:math';
import 'enums.dart';

class HealthData {
  final DateTime timestamp;
  final int heartRate;
  final int? oxygenSaturation;
  final double? temperature;
  final int? steps;
  final double? calories;

  final AccelerometerData? accelerometer;
  final GyroscopeData? gyroscope;

  final double? latitude;
  final double? longitude;

  final int? stressLevel;
  final int? hrvScore;

  final SleepQuality? sleepQuality;

  final ActivityType currentActivity;

  HealthData({
    required this.timestamp,
    required this.heartRate,
    this.oxygenSaturation,
    this.temperature,
    this.steps,
    this.calories,
    this.accelerometer,
    this.gyroscope,
    this.latitude,
    this.longitude,
    this.stressLevel,
    this.hrvScore,
    this.sleepQuality,
    this.currentActivity = ActivityType.stationary,
  });

  bool get isHeartRateAbnormal => heartRate < 40 || heartRate > 140;
  bool get isOxygenLow => (oxygenSaturation ?? 100) < 90;
  bool get isStressHigh => (stressLevel ?? 0) > 70;

  HealthRiskLevel get riskLevel {
    if (isHeartRateAbnormal || isOxygenLow) return HealthRiskLevel.critical;
    if (isStressHigh) return HealthRiskLevel.warning;
    return HealthRiskLevel.normal;
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'oxygenSaturation': oxygenSaturation,
      'temperature': temperature,
      'steps': steps,
      'calories': calories,
      'accelerometer': accelerometer?.toJson(),
      'gyroscope': gyroscope?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'stressLevel': stressLevel,
      'hrvScore': hrvScore,
      'sleepQuality': sleepQuality?.toString(),
      'currentActivity': currentActivity.toString(),
    };
  }
}

class AccelerometerData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  double get magnitude => sqrt(x * x + y * y + z * z);

  bool get isPotentialImpact => magnitude > 3.0;

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'timestamp': timestamp.toIso8601String(),
  };
}

class GyroscopeData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  GyroscopeData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'timestamp': timestamp.toIso8601String(),
  };
}

enum ActivityType {
  stationary,
  walking,
  running,
  driving,
  cycling,
  unknown,
}

enum SleepQuality {
  excellent,
  good,
  fair,
  poor,
}

enum HealthRiskLevel {
  normal,
  warning,
  critical,
}

class HealthDataHistory {
  final List<HealthData> dataPoints;
  final DateTime startTime;
  final DateTime endTime;

  HealthDataHistory({
    required this.dataPoints,
    required this.startTime,
    required this.endTime,
  });

  double get averageHeartRate {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((e) => e.heartRate).reduce((a, b) => a + b) /
        dataPoints.length;
  }

  double? get averageSpO2 {
    final validPoints = dataPoints
        .where((e) => e.oxygenSaturation != null)
        .toList();
    if (validPoints.isEmpty) return null;

    return validPoints
        .map((e) => e.oxygenSaturation!)
        .reduce((a, b) => a + b) /
        validPoints.length;
  }

  List<HealthData> get anomalies {
    return dataPoints.where((data) =>
    data.riskLevel == HealthRiskLevel.critical ||
        data.riskLevel == HealthRiskLevel.warning
    ).toList();
  }
}