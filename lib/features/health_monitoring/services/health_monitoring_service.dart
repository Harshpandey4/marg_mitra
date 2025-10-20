// lib/features/health_monitoring/services/health_monitoring_service.dart

import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/health_data.dart';
import '../models/safety_assessment.dart';
import '../models/safety_factor.dart';
import '../models/alert_config.dart';
import '../models/enums.dart';
class HealthMonitoringService {
  static final HealthMonitoringService _instance = HealthMonitoringService._internal();
  factory HealthMonitoringService() => _instance;
  HealthMonitoringService._internal();

  // Stream controllers
  final _healthDataController = StreamController<HealthData>.broadcast();
  final _safetyAssessmentController = StreamController<SafetyAssessment>.broadcast();
  final _alertController = StreamController<EmergencyAlert>.broadcast();

  // Streams
  Stream<HealthData> get healthDataStream => _healthDataController.stream;
  Stream<SafetyAssessment> get safetyAssessmentStream => _safetyAssessmentController.stream;
  Stream<EmergencyAlert> get alertStream => _alertController.stream;

  // Data storage
  final List<HealthData> _healthHistory = [];
  final List<AccelerometerData> _accelerometerBuffer = [];

  // Current state
  HealthData? _lastHealthData;
  SafetyAssessment? _lastAssessment;
  AlertConfig _alertConfig = AlertConfig();

  // Monitoring flags
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  Timer? _analysisTimer;

  // Sensor subscriptions
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Baseline values for anomaly detection
  double _baselineHeartRate = 75.0;
  double _heartRateVariance = 15.0;

  // Start comprehensive monitoring
  Future<void> startMonitoring({AlertConfig? config}) async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    if (config != null) _alertConfig = config;

    // Start sensor monitoring
    await _startSensorMonitoring();

    // Periodic health data processing (every 5 seconds)
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _processHealthData(),
    );

    // Periodic safety analysis (every 10 seconds)
    _analysisTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _performSafetyAnalysis(),
    );

    print('Health monitoring started');
  }

  // Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _analysisTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    print('Health monitoring stopped');
  }

  // Start sensor monitoring
  Future<void> _startSensorMonitoring() async {
    // Accelerometer for impact detection
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final data = AccelerometerData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: DateTime.now(),
      );

      _accelerometerBuffer.add(data);

      // Keep only last 100 readings (5 seconds at 20Hz)
      if (_accelerometerBuffer.length > 100) {
        _accelerometerBuffer.removeAt(0);
      }

      // Check for sudden impact
      if (_alertConfig.enableImpactDetection && data.isPotentialImpact) {
        _handleImpactDetection(data);
      }
    });

    // Gyroscope for movement patterns
    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      // Process gyroscope data for drowsiness detection
      if (_alertConfig.enableDrowsinessAlerts) {
        _checkDrowsinessPattern(event);
      }
    });
  }

  // Process incoming health data
  void _processHealthData() {
    if (!_isMonitoring) return;

    // Simulate or get real data from Bluetooth
    final healthData = _generateOrFetchHealthData();

    _lastHealthData = healthData;
    _healthHistory.add(healthData);

    // Keep only last 1 hour of data
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    _healthHistory.removeWhere((data) => data.timestamp.isBefore(oneHourAgo));

    // Emit health data
    _healthDataController.add(healthData);

    // Check for immediate alerts
    _checkHealthAlerts(healthData);
  }

  // Generate or fetch real health data
  HealthData _generateOrFetchHealthData() {
    // This would come from Bluetooth in production
    // For now, simulating realistic data

    final random = Random();
    final timestamp = DateTime.now();

    // Simulate heart rate with some variation
    final heartRate = (_baselineHeartRate +
        (random.nextDouble() * _heartRateVariance - _heartRateVariance / 2))
        .round();

    // Get latest accelerometer data
    final accelerometer = _accelerometerBuffer.isNotEmpty
        ? _accelerometerBuffer.last
        : null;

    return HealthData(
      timestamp: timestamp,
      heartRate: heartRate,
      oxygenSaturation: 95 + random.nextInt(5), // 95-99%
      temperature: 36.5 + random.nextDouble() * 0.5, // 36.5-37.0°C
      steps: random.nextInt(100),
      calories: random.nextDouble() * 10,
      accelerometer: accelerometer,
      stressLevel: 20 + random.nextInt(40), // 20-60
      hrvScore: 40 + random.nextInt(40), // 40-80
      currentActivity: _detectCurrentActivity(),
    );
  }

  // Detect current activity from motion data
  ActivityType _detectCurrentActivity() {
    if (_accelerometerBuffer.length < 10) return ActivityType.unknown;

    final recentData = _accelerometerBuffer.sublist(
      _accelerometerBuffer.length - 10,
    );

    // Calculate average magnitude
    final avgMagnitude = recentData
        .map((d) => d.magnitude)
        .reduce((a, b) => a + b) / recentData.length;

    // Simple activity classification
    if (avgMagnitude < 1.1) return ActivityType.stationary;
    if (avgMagnitude < 1.5) return ActivityType.walking;
    if (avgMagnitude < 2.0) return ActivityType.driving;
    if (avgMagnitude < 3.0) return ActivityType.running;
    return ActivityType.unknown;
  }

  // Check for health alerts
  void _checkHealthAlerts(HealthData data) {
    final alerts = <String>[];

    // Heart rate alerts
    if (_alertConfig.enableHeartRateAlerts) {
      if (data.heartRate < _alertConfig.heartRateThresholdLow) {
        alerts.add('Low heart rate detected: ${data.heartRate} BPM');
        _triggerAlert(
          type: AlertType.abnormalHeartRate,
          severity: AlertSeverity.warning,
          message: 'Heart rate below normal range',
          data: data,
        );
      } else if (data.heartRate > _alertConfig.heartRateThresholdHigh) {
        alerts.add('High heart rate detected: ${data.heartRate} BPM');
        _triggerAlert(
          type: AlertType.abnormalHeartRate,
          severity: AlertSeverity.warning,
          message: 'Heart rate above normal range',
          data: data,
        );
      }
    }

    // Oxygen saturation alerts
    if (data.oxygenSaturation != null &&
        data.oxygenSaturation! < _alertConfig.oxygenThreshold) {
      alerts.add('Low oxygen saturation: ${data.oxygenSaturation}%');
      _triggerAlert(
        type: AlertType.lowOxygen,
        severity: AlertSeverity.critical,
        message: 'Oxygen saturation critically low',
        data: data,
      );
    }

    // Stress alerts
    if (_alertConfig.enableStressAlerts &&
        data.stressLevel != null &&
        data.stressLevel! > _alertConfig.stressThreshold) {
      alerts.add('High stress detected: ${data.stressLevel}/100');
      _triggerAlert(
        type: AlertType.highStress,
        severity: AlertSeverity.info,
        message: 'Consider taking a break',
        data: data,
      );
    }
  }

  // Handle impact detection
  void _handleImpactDetection(AccelerometerData data) {
    print('⚠️ IMPACT DETECTED: ${data.magnitude.toStringAsFixed(2)}g');

    // Check if this is a sustained impact (potential accident)
    final recentImpacts = _accelerometerBuffer
        .where((d) => d.timestamp.isAfter(
        DateTime.now().subtract(const Duration(seconds: 2))))
        .where((d) => d.isPotentialImpact)
        .length;

    if (recentImpacts >= 3) {
      // Multiple impacts in short time = likely accident
      _triggerAlert(
        type: AlertType.accidentDetected,
        severity: AlertSeverity.critical,
        message: 'Severe impact detected - potential accident',
        data: _lastHealthData,
      );
    } else {
      // Single impact - monitor closely
      _triggerAlert(
        type: AlertType.impactDetected,
        severity: AlertSeverity.warning,
        message: 'Impact detected - are you OK?',
        data: _lastHealthData,
      );
    }
  }

  // Check for drowsiness patterns
  void _checkDrowsinessPattern(GyroscopeEvent event) {
    // TODO: Implement ML-based drowsiness detection
    // This would analyze head movement patterns
    // For now, placeholder logic
  }

  // Perform comprehensive safety analysis
  Future<void> _performSafetyAnalysis() async {
    if (_healthHistory.length < 5) return;

    final recentData = _healthHistory.sublist(
      max(0, _healthHistory.length - 12), // Last minute
    );

    // Calculate trends
    final heartRateTrend = _calculateTrend(
      recentData.map((d) => d.heartRate.toDouble()).toList(),
    );

    // Analyze patterns
    final factors = <SafetyFactor>[];
    final warnings = <String>[];
    final recommendations = <String>[];

    // Heart rate analysis
    final avgHeartRate = recentData
        .map((d) => d.heartRate)
        .reduce((a, b) => a + b) / recentData.length;

    if (avgHeartRate < 50 || avgHeartRate > 120) {
      factors.add(SafetyFactor(
        name: 'Heart Rate',
        type: FactorType.health,
        severity: 0.7,
        description: 'Abnormal average heart rate: ${avgHeartRate.toStringAsFixed(1)} BPM',
        actionRequired: 'Consider stopping and resting',
      ));
      warnings.add('Heart rate outside normal range');
    }

    // Rapid heart rate changes
    if (heartRateTrend.abs() > 2.0) {
      factors.add(SafetyFactor(
        name: 'Heart Rate Variability',
        type: FactorType.health,
        severity: 0.5,
        description: 'Rapid heart rate changes detected',
        actionRequired: 'Monitor your condition',
      ));
    }

    // Motion analysis
    if (_accelerometerBuffer.length > 50) {
      final recentMotion = _accelerometerBuffer.sublist(
        _accelerometerBuffer.length - 50,
      );

      final avgMagnitude = recentMotion
          .map((d) => d.magnitude)
          .reduce((a, b) => a + b) / recentMotion.length;

      if (avgMagnitude > 2.5) {
        factors.add(SafetyFactor(
          name: 'Excessive Movement',
          type: FactorType.motion,
          severity: 0.6,
          description: 'Unusual movement patterns detected',
          actionRequired: 'Ensure you are driving safely',
        ));
        warnings.add('Erratic movement detected');
      }
    }

    // Determine overall safety level
    final maxSeverity = factors.isEmpty
        ? 0.0
        : factors.map((f) => f.severity).reduce(max);

    SafetyLevel overallSafety;
    if (maxSeverity >= 0.8) {
      overallSafety = SafetyLevel.critical;
    } else if (maxSeverity >= 0.6) {
      overallSafety = SafetyLevel.warning;
    } else if (maxSeverity >= 0.4) {
      overallSafety = SafetyLevel.caution;
    } else {
      overallSafety = SafetyLevel.safe;
    }

    // Generate recommendations
    if (overallSafety != SafetyLevel.safe) {
      recommendations.add('Consider pulling over safely');
      recommendations.add('Take deep breaths and relax');
      recommendations.add('Call emergency if condition worsens');
    }

    final assessment = SafetyAssessment(
      timestamp: DateTime.now(),
      overallSafety: overallSafety,
      factors: factors,
      warnings: warnings,
      recommendations: recommendations,
      confidenceScore: _calculateConfidence(recentData.length),
      impactDetected: factors.any((f) => f.name.contains('Impact')),
      suddenMovement: factors.any((f) => f.name.contains('Movement')),  // ADD THIS
      abnormalHeartRate: factors.any((f) => f.name.contains('Heart')),
      lowOxygen: recentData.any((d) =>  // ADD THIS
      d.oxygenSaturation != null &&
          d.oxygenSaturation! < _alertConfig.oxygenThreshold),
      highStress: recentData.last.stressLevel != null &&
          recentData.last.stressLevel! > 70,
    );

    _lastAssessment = assessment;
    _safetyAssessmentController.add(assessment);

    // Trigger emergency response if critical
    if (assessment.requiresEmergencyResponse) {
      _triggerEmergencyResponse(assessment);
    }
  }

  // Calculate trend (positive = increasing, negative = decreasing)
  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    // Simple linear regression slope
    final n = values.length;
    final xMean = (n - 1) / 2;
    final yMean = values.reduce((a, b) => a + b) / n;

    double numerator = 0.0;
    double denominator = 0.0;

    for (int i = 0; i < n; i++) {
      numerator += (i - xMean) * (values[i] - yMean);
      denominator += pow(i - xMean, 2);
    }

    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  // Calculate confidence based on data availability
  double _calculateConfidence(int dataPoints) {
    if (dataPoints < 5) return 0.3;
    if (dataPoints < 10) return 0.6;
    if (dataPoints < 20) return 0.8;
    return 0.95;
  }

  // Trigger alert
  void _triggerAlert({
    required AlertType type,
    required AlertSeverity severity,
    required String message,
    HealthData? data,
  }) {
    final alert = EmergencyAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      severity: severity,
      message: message,
      timestamp: DateTime.now(),
      healthData: data,
      requiresResponse: severity == AlertSeverity.critical,
    );

    _alertController.add(alert);
  }

  // Trigger emergency response
  void _triggerEmergencyResponse(SafetyAssessment assessment) {
    if (!_alertConfig.autoCallEmergency) return;

    print('🚨 EMERGENCY RESPONSE TRIGGERED');
    print('Reason: ${assessment.primaryWarning}');

    // This would integrate with emergency services
    // For now, just logging
  }

  // Update alert configuration
  void updateAlertConfig(AlertConfig config) {
    _alertConfig = config;
  }

  // Get health history
  List<HealthData> getHealthHistory({Duration? duration}) {
    if (duration == null) return List.from(_healthHistory);

    final cutoff = DateTime.now().subtract(duration);
    return _healthHistory
        .where((data) => data.timestamp.isAfter(cutoff))
        .toList();
  }

  // Get latest health data
  HealthData? get latestHealthData => _lastHealthData;

  // Get latest safety assessment
  SafetyAssessment? get latestAssessment => _lastAssessment;

  // Dispose
  void dispose() {
    stopMonitoring();
    _healthDataController.close();
    _safetyAssessmentController.close();
    _alertController.close();
  }
}

// Emergency Alert Model
class EmergencyAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final HealthData? healthData;
  final bool requiresResponse;
  bool acknowledged;

  EmergencyAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.healthData,
    this.requiresResponse = false,
    this.acknowledged = false,
  });
}

enum AlertType {
  abnormalHeartRate,
  lowOxygen,
  highStress,
  impactDetected,
  accidentDetected,
  drowsinessDetected,
}

enum AlertSeverity {
  info,
  warning,
  critical,
}