// lib/features/health_monitoring/providers/health_monitoring_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/smartwatch_device.dart';
import '../models/health_data.dart';
import '../models/safety_assessment.dart';
import '../services/bluetooth_service.dart';
import '../services/health_monitoring_service.dart';
import '../models/enums.dart';
import '../models/alert_config.dart';
// ========================================
// BLUETOOTH PROVIDERS
// ========================================

// Bluetooth Service Provider

final bluetoothServiceProvider = Provider<DeviceBluetoothService>((ref) {
  return DeviceBluetoothService();
});

// Available Devices Stream
final availableDevicesProvider = StreamProvider<List<SmartwatchDevice>>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.devicesStream;
});

// Connection Status Stream
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.connectionStream;
});

// Connected Device Provider
final connectedDeviceProvider = Provider<SmartwatchDevice?>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.connectedDevice;
});

// Bluetooth Data Stream
final bluetoothDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.dataStream;
});

// ========================================
// HEALTH MONITORING PROVIDERS
// ========================================

// Health Monitoring Service Provider
final healthMonitoringServiceProvider = Provider<HealthMonitoringService>((ref) {
  return HealthMonitoringService();
});

// Health Data Stream
final healthDataStreamProvider = StreamProvider<HealthData>((ref) {
  final service = ref.watch(healthMonitoringServiceProvider);
  return service.healthDataStream;
});

// Latest Health Data
final latestHealthDataProvider = Provider<HealthData?>((ref) {
  final service = ref.watch(healthMonitoringServiceProvider);
  return service.latestHealthData;
});

// Safety Assessment Stream
final safetyAssessmentStreamProvider = StreamProvider<SafetyAssessment>((ref) {
  final service = ref.watch(healthMonitoringServiceProvider);
  return service.safetyAssessmentStream;
});

// Latest Safety Assessment
final latestSafetyAssessmentProvider = Provider<SafetyAssessment?>((ref) {
  final service = ref.watch(healthMonitoringServiceProvider);
  return service.latestAssessment;
});

// Emergency Alert Stream
final emergencyAlertStreamProvider = StreamProvider<EmergencyAlert>((ref) {
  final service = ref.watch(healthMonitoringServiceProvider);
  return service.alertStream;
});

// Health History Provider (last hour)
final healthHistoryProvider = Provider<List<HealthData>>((ref) {
  final service = ref.watch(healthMonitoringServiceProvider);
  return service.getHealthHistory(duration: const Duration(hours: 1));
});

// ========================================
// STATE NOTIFIER PROVIDERS (FOR ACTIONS)
// ========================================

// Smartwatch Controller
final smartwatchControllerProvider =
StateNotifierProvider<SmartwatchController, SmartwatchState>((ref) {
  return SmartwatchController(ref);
});

class SmartwatchController extends StateNotifier<SmartwatchState> {
  final Ref ref;

  SmartwatchController(this.ref) : super(SmartwatchState.initial());

  // Start scanning for devices
  Future<void> startScanning() async {
    state = state.copyWith(isScanning: true, error: null);

    try {
      final service = ref.read(bluetoothServiceProvider);
      await service.startScanning();
      state = state.copyWith(isScanning: false);
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: e.toString(),
      );
    }
  }

  // Stop scanning
  Future<void> stopScanning() async {
    final service = ref.read(bluetoothServiceProvider);
    await service.stopScanning();
    state = state.copyWith(isScanning: false);
  }

  // Connect to device
  Future<void> connectToDevice(SmartwatchDevice device) async {
    state = state.copyWith(isConnecting: true, error: null);

    try {
      final service = ref.read(bluetoothServiceProvider);
      await service.connectToDevice(device);

      state = state.copyWith(
        isConnecting: false,
        connectedDevice: device,
      );

      // Start health monitoring after successful connection
      await startHealthMonitoring();

    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: 'Connection failed: ${e.toString()}',
      );
    }
  }

  // Disconnect device
  Future<void> disconnectDevice() async {
    try {
      final service = ref.read(bluetoothServiceProvider);
      await service.disconnectDevice();

      // Stop health monitoring
      await stopHealthMonitoring();

      state = state.copyWith(connectedDevice: null);
    } catch (e) {
      state = state.copyWith(error: 'Disconnect failed: ${e.toString()}');
    }
  }

  // Start health monitoring
  Future<void> startHealthMonitoring() async {
    try {
      final service = ref.read(healthMonitoringServiceProvider);
      await service.startMonitoring();
      state = state.copyWith(isMonitoring: true);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to start monitoring: ${e.toString()}',
      );
    }
  }

  // Stop health monitoring
  Future<void> stopHealthMonitoring() async {
    final service = ref.read(healthMonitoringServiceProvider);
    service.stopMonitoring();
    state = state.copyWith(isMonitoring: false);
  }

  // Update alert configuration
  void updateAlertConfig(AlertConfig config) {
    final service = ref.read(healthMonitoringServiceProvider);
    service.updateAlertConfig(config);
    state = state.copyWith(alertConfig: config);
  }
}

// Smartwatch State
class SmartwatchState {
  final bool isScanning;
  final bool isConnecting;
  final bool isMonitoring;
  final SmartwatchDevice? connectedDevice;
  final AlertConfig alertConfig;
  final String? error;

  SmartwatchState({
    required this.isScanning,
    required this.isConnecting,
    required this.isMonitoring,
    this.connectedDevice,
    required this.alertConfig,
    this.error,
  });

  factory SmartwatchState.initial() {
    return SmartwatchState(
      isScanning: false,
      isConnecting: false,
      isMonitoring: false,
      alertConfig: AlertConfig(),
    );
  }

  SmartwatchState copyWith({
    bool? isScanning,
    bool? isConnecting,
    bool? isMonitoring,
    SmartwatchDevice? connectedDevice,
    AlertConfig? alertConfig,
    String? error,
  }) {
    return SmartwatchState(
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      alertConfig: alertConfig ?? this.alertConfig,
      error: error,
    );
  }
}

// ========================================
// COMPUTED PROVIDERS (DERIVED STATE)
// ========================================

// Is device connected
final isDeviceConnectedProvider = Provider<bool>((ref) {
  final device = ref.watch(connectedDeviceProvider);
  return device?.status == ConnectionStatus.connected;
});

// Current heart rate
final currentHeartRateProvider = Provider<int?>((ref) {
  final healthData = ref.watch(latestHealthDataProvider);
  return healthData?.heartRate;
});

// Current safety level
final currentSafetyLevelProvider = Provider<SafetyLevel?>((ref) {
  final assessment = ref.watch(latestSafetyAssessmentProvider);
  return assessment?.overallSafety;
});

// Has active alerts
final hasActiveAlertsProvider = Provider<bool>((ref) {
  final assessment = ref.watch(latestSafetyAssessmentProvider);
  return assessment?.requiresAlert ?? false;
});

// Battery level
final batteryLevelProvider = Provider<int?>((ref) {
  final device = ref.watch(connectedDeviceProvider);
  return device?.batteryLevel;
});

// Connection quality
final connectionQualityProvider = Provider<ConnectionQuality?>((ref) {
  final device = ref.watch(connectedDeviceProvider);
  return device?.connectionQuality;
});