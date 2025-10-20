// lib/features/health_monitoring/models/smartwatch_device.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum DeviceType {
  appleWatch,
  galaxyWatch,
  fitbit,
  miWatch,
  other,
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class SmartwatchDevice {
  final String id;
  final String name;
  final DeviceType type;
  final ConnectionStatus status;
  final int batteryLevel;
  final DateTime? lastSyncTime;
  final BluetoothDevice? bluetoothDevice;
  final List<String> supportedFeatures;

  final int signalStrength;

  final String? firmwareVersion;
  final String? hardwareVersion;

  SmartwatchDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.batteryLevel = 100,
    this.lastSyncTime,
    this.bluetoothDevice,
    this.supportedFeatures = const [],
    this.signalStrength = 0,
    this.firmwareVersion,
    this.hardwareVersion,
  });

  bool get supportsHeartRate => supportedFeatures.contains('heart_rate');
  bool get supportsAccelerometer => supportedFeatures.contains('accelerometer');
  bool get supportsFallDetection => supportedFeatures.contains('fall_detection');
  bool get supportsGPS => supportedFeatures.contains('gps');

  ConnectionQuality get connectionQuality {
    if (signalStrength >= -50) return ConnectionQuality.excellent;
    if (signalStrength >= -70) return ConnectionQuality.good;
    if (signalStrength >= -85) return ConnectionQuality.fair;
    return ConnectionQuality.poor;
  }

  SmartwatchDevice copyWith({
    String? id,
    String? name,
    DeviceType? type,
    ConnectionStatus? status,
    int? batteryLevel,
    DateTime? lastSyncTime,
    BluetoothDevice? bluetoothDevice,
    List<String>? supportedFeatures,
    int? signalStrength,
    String? firmwareVersion,
    String? hardwareVersion,
  }) {
    return SmartwatchDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      supportedFeatures: supportedFeatures ?? this.supportedFeatures,
      signalStrength: signalStrength ?? this.signalStrength,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      hardwareVersion: hardwareVersion ?? this.hardwareVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'status': status.toString(),
      'batteryLevel': batteryLevel,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'supportedFeatures': supportedFeatures,
      'signalStrength': signalStrength,
      'firmwareVersion': firmwareVersion,
      'hardwareVersion': hardwareVersion,
    };
  }

  factory SmartwatchDevice.fromJson(Map<String, dynamic> json) {
    return SmartwatchDevice(
      id: json['id'],
      name: json['name'],
      type: DeviceType.values.firstWhere(
            (e) => e.toString() == json['type'],
        orElse: () => DeviceType.other,
      ),
      status: ConnectionStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => ConnectionStatus.disconnected,
      ),
      batteryLevel: json['batteryLevel'] ?? 100,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'])
          : null,
      supportedFeatures: List<String>.from(json['supportedFeatures'] ?? []),
      signalStrength: json['signalStrength'] ?? 0,
      firmwareVersion: json['firmwareVersion'],
      hardwareVersion: json['hardwareVersion'],
    );
  }
}

enum ConnectionQuality {
  excellent,
  good,
  fair,
  poor,
}