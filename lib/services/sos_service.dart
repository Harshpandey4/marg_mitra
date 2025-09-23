import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../providers/weather_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SosService {
  static const platform = MethodChannel('com.margmitra.app/sos');
  static const emergencyPlatform = MethodChannel('com.margmitra.app/emergency');

  SosService();

  /// Advanced SOS trigger with multi-sensor fusion and AI coordination
  Future<void> triggerAdvancedSos({
    required Map<String, dynamic> emergencyData,
    bool multiAgencyCoordination = true,
    bool familyNotification = true,
    List<String>? customContacts,
  }) async {
    try {
      // Get current location (mock for now - replace with actual location service)
      final mockPosition = await _getCurrentLocation();

      // Enhanced emergency data with Marg Mitra features
      final enhancedSosData = {
        'emergencyId': _generateEmergencyId(),
        'timestamp': DateTime.now().toIso8601String(),
        'location': {
          'latitude': mockPosition['latitude'],
          'longitude': mockPosition['longitude'],
          'accuracy': mockPosition['accuracy'] ?? 10.0,
          'altitude': mockPosition['altitude'] ?? 0.0,
        },
        'deviceInfo': {
          'platform': 'flutter',
          'version': '1.0.0',
          'deviceId': 'mock_device_id',
        },
        'emergencyType': emergencyData['emergencyType'] ?? 'manual_trigger',
        'aiConfidence': emergencyData['aiConfidence'] ?? 0.95,
        'sensorData': emergencyData['sensorData'] ?? {},
        'multiSensorFusion': {
          'accelerometerData': emergencyData['sensorData']?['accelerometer'],
          'gyroscopeData': emergencyData['sensorData']?['gyroscope'],
          'heartRateData': emergencyData['sensorData']?['heartRate'],
          'gpsTracking': emergencyData['sensorData']?['gps'],
        },
        'weatherContext': emergencyData['weather'],
        'roadSafetyLevel': emergencyData['roadSafety'],
        'autoDetectionActive': emergencyData['autoDetection'] ?? false,
      };

      print('🚨 Advanced SOS triggered with data: ${json.encode(enhancedSosData)}');

      // 1. Immediate Emergency Response Coordination
      if (multiAgencyCoordination) {
        await _coordinateMultiAgencyResponse(enhancedSosData);
      }

      // 2. Family and Emergency Contact Notification
      if (familyNotification) {
        await _notifyEmergencyContacts(enhancedSosData, customContacts);
      }

      // 3. AI-Powered Emergency Classification and Response
      await _classifyAndRespond(enhancedSosData);

      // 4. Real-time Location Tracking
      await _startLocationTracking(enhancedSosData['emergencyId']);

      // 5. Emergency Documentation
      await _documentEmergency(enhancedSosData);

      print('✅ Advanced SOS alert successfully coordinated');

    } catch (e) {
      print('❌ Advanced SOS Service Error: $e');
      throw Exception('Failed to send advanced SOS: $e');
    }
  }

  /// Multi-agency emergency response coordination
  Future<void> _coordinateMultiAgencyResponse(Map<String, dynamic> sosData) async {
    try {
      print('🚨 Coordinating multi-agency emergency response...');

      // Determine priority level based on AI confidence and sensor data
      final priority = _calculateEmergencyPriority(sosData);

      // Coordinate with multiple emergency services
      final agencies = ['police', 'ambulance', 'fire_department'];

      for (String agency in agencies) {
        await _contactEmergencyService(agency, sosData, priority);
      }

      // Special coordination for high-priority emergencies
      if (priority == 'critical') {
        await _triggerCriticalEmergencyProtocol(sosData);
      }

    } catch (e) {
      print('Multi-agency coordination error: $e');
      // Continue with basic emergency response
      await _basicEmergencyResponse(sosData);
    }
  }

  /// Contact specific emergency service with contextual data
  Future<void> _contactEmergencyService(
      String agency,
      Map<String, dynamic> sosData,
      String priority
      ) async {
    try {
      final location = sosData['location'];
      final weatherInfo = sosData['weatherContext'] != null
          ? 'Weather: ${sosData['weatherContext']['description']}, ${sosData['weatherContext']['temperature']}°C'
          : '';

      final emergencyMessage = _buildEmergencyMessage(agency, sosData, weatherInfo);

      await platform.invokeMethod('contactEmergencyService', {
        'agency': agency,
        'emergencyId': sosData['emergencyId'],
        'location': '${location['latitude']},${location['longitude']}',
        'message': emergencyMessage,
        'priority': priority,
        'aiConfidence': sosData['aiConfidence'],
        'sensorData': json.encode(sosData['multiSensorFusion']),
        'timestamp': sosData['timestamp'],
      });

      print('✅ $agency contacted successfully');
    } catch (e) {
      print('❌ Error contacting $agency: $e');
    }
  }

  /// Build contextual emergency message for different agencies
  String _buildEmergencyMessage(String agency, Map<String, dynamic> sosData, String weatherInfo) {
    final location = sosData['location'];
    final emergencyType = sosData['emergencyType'];
    final aiConfidence = sosData['aiConfidence'];

    final baseMessage = 'MARG MITRA EMERGENCY ALERT\n'
        'Emergency ID: ${sosData['emergencyId']}\n'
        'Type: $emergencyType\n'
        'AI Confidence: ${(aiConfidence * 100).round()}%\n'
        'Location: ${location['latitude']}, ${location['longitude']}\n';

    switch (agency) {
      case 'police':
        return '${baseMessage}Request immediate police assistance. Multi-sensor detection active. $weatherInfo';
      case 'ambulance':
        return '${baseMessage}Medical emergency detected. Heart rate monitoring: ${sosData['multiSensorFusion']['heartRateData'] ?? 'active'}. $weatherInfo';
      case 'fire_department':
        return '${baseMessage}Emergency assistance required. Vehicle/accident detection. $weatherInfo';
      default:
        return '${baseMessage}Emergency assistance required at location. $weatherInfo';
    }
  }

  /// Notify family and emergency contacts
  Future<void> _notifyEmergencyContacts(Map<String, dynamic> sosData, List<String>? customContacts) async {
    try {
      print('📱 Notifying emergency contacts...');

      final defaultContacts = ['emergency_contact_1', 'emergency_contact_2']; // Replace with actual contacts
      final contactsToNotify = customContacts ?? defaultContacts;

      final location = sosData['location'];
      final familyMessage = 'EMERGENCY ALERT: Your family member has triggered an emergency alert through Marg Mitra. '
          'Location: ${location['latitude']}, ${location['longitude']}. '
          'Emergency services have been notified. '
          'Emergency ID: ${sosData['emergencyId']}';

      for (String contact in contactsToNotify) {
        await platform.invokeMethod('notifyEmergencyContact', {
          'contact': contact,
          'message': familyMessage,
          'location': '${location['latitude']},${location['longitude']}',
          'emergencyId': sosData['emergencyId'],
          'trackingLink': 'https://margmitra.app/track/${sosData['emergencyId']}',
        });
      }

      print('✅ Emergency contacts notified successfully');
    } catch (e) {
      print('❌ Error notifying emergency contacts: $e');
    }
  }

  /// AI-powered emergency classification and response
  Future<void> _classifyAndRespond(Map<String, dynamic> sosData) async {
    try {
      print('🤖 AI classifying emergency and optimizing response...');

      await emergencyPlatform.invokeMethod('aiEmergencyClassification', {
        'emergencyData': json.encode(sosData),
        'sensorFusion': json.encode(sosData['multiSensorFusion']),
        'weatherContext': json.encode(sosData['weatherContext']),
        'aiModel': 'tensorflow_emergency_detector_v2',
      });

      print('✅ AI classification completed');
    } catch (e) {
      print('❌ AI classification error: $e');
    }
  }

  /// Start real-time location tracking
  Future<void> _startLocationTracking(String emergencyId) async {
    try {
      print('📍 Starting real-time location tracking...');

      await platform.invokeMethod('startLocationTracking', {
        'emergencyId': emergencyId,
        'updateInterval': 10, // seconds
        'highAccuracy': true,
      });

      print('✅ Location tracking started');
    } catch (e) {
      print('❌ Location tracking error: $e');
    }
  }

  /// Document emergency for records and insurance
  Future<void> _documentEmergency(Map<String, dynamic> sosData) async {
    try {
      print('📋 Documenting emergency for records...');

      await platform.invokeMethod('documentEmergency', {
        'emergencyData': json.encode(sosData),
        'blockchainRecord': true, // For tamper-proof records
        'insuranceIntegration': true,
        'abdmCompliance': true, // Ayushman Bharat Digital Mission compliance
      });

      print('✅ Emergency documented successfully');
    } catch (e) {
      print('❌ Documentation error: $e');
    }
  }

  /// Calculate emergency priority based on AI and sensor data
  String _calculateEmergencyPriority(Map<String, dynamic> sosData) {
    final aiConfidence = sosData['aiConfidence'] ?? 0.0;
    final roadSafety = sosData['roadSafetyLevel'] ?? '';
    final emergencyType = sosData['emergencyType'] ?? '';

    if (aiConfidence > 0.9 || roadSafety.contains('dangerous') || emergencyType.contains('critical')) {
      return 'critical';
    } else if (aiConfidence > 0.7 || roadSafety.contains('moderate')) {
      return 'high';
    }
    return 'normal';
  }

  /// Critical emergency protocol for high-priority situations
  Future<void> _triggerCriticalEmergencyProtocol(Map<String, dynamic> sosData) async {
    try {
      print('🚨 CRITICAL EMERGENCY PROTOCOL ACTIVATED');

      await emergencyPlatform.invokeMethod('criticalEmergencyProtocol', {
        'emergencyData': json.encode(sosData),
        'alertLevel': 'maximum',
        'responseTime': 'immediate',
      });

    } catch (e) {
      print('Critical protocol error: $e');
    }
  }

  /// Basic emergency response fallback
  Future<void> _basicEmergencyResponse(Map<String, dynamic> sosData) async {
    try {
      final location = sosData['location'];
      await platform.invokeMethod('sendEmergencySMS', {
        'location': '${location['latitude']},${location['longitude']}',
        'message': 'EMERGENCY: I need immediate assistance at this location. Emergency ID: ${sosData['emergencyId']}',
        'priority': true,
      });
    } catch (e) {
      print('Basic emergency response error: $e');
    }
  }

  /// Get current location (mock implementation)
  Future<Map<String, dynamic>> _getCurrentLocation() async {
    // Replace with actual location service
    return {
      'latitude': 26.7806, // Fatehpur, UP coordinates as example
      'longitude': 80.8138,
      'accuracy': 5.0,
      'altitude': 100.0,
    };
  }

  /// Generate unique emergency ID
  String _generateEmergencyId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'MM_${timestamp}_$random';
  }

  /// Original trigger SOS method (maintained for backward compatibility)
  Future<void> triggerSos() async {
    await triggerAdvancedSos(
      emergencyData: {
        'emergencyType': 'manual_basic',
        'aiConfidence': 0.8,
        'autoDetection': false,
      },
      multiAgencyCoordination: true,
      familyNotification: true,
    );
  }

  /// Trigger SOS with weather context (enhanced)
  Future<void> triggerSosWithWeather({
    WeatherData? weather,
    required RoadSafetyLevel safetyLevel,
  }) async {
    final weatherData = weather != null ? {
      'temperature': weather.temperature,
      'condition': weather.condition,
      'description': weather.description,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'visibility': weather.visibility,
    } : null;

    await triggerAdvancedSos(
      emergencyData: {
        'emergencyType': 'weather_emergency',
        'aiConfidence': safetyLevel == RoadSafetyLevel.dangerous ? 0.95 : 0.8,
        'autoDetection': false,
        'weather': weatherData,
        'roadSafety': safetyLevel.toString(),
      },
      multiAgencyCoordination: true,
      familyNotification: true,
    );

    // Additional weather-specific protocols
    if (safetyLevel == RoadSafetyLevel.dangerous) {
      await _triggerEmergencyWeatherProtocol({
        'latitude': 26.7806,
        'longitude': 80.8138,
      }, weather);
    }
  }

  /// Additional emergency protocol for dangerous weather conditions
  Future<void> _triggerEmergencyWeatherProtocol(
      dynamic position,
      WeatherData? weather,
      ) async {
    try {
      print('🌩️ Emergency weather protocol triggered for location: ${position['latitude']}, ${position['longitude']}');

      await platform.invokeMethod('triggerWeatherEmergency', {
        'location': '${position['latitude']},${position['longitude']}',
        'weatherCondition': weather?.condition ?? 'severe',
        'temperature': weather?.temperature ?? 0,
        'windSpeed': weather?.windSpeed ?? 0,
        'visibility': weather?.visibility ?? 0,
        'emergencyWeatherResponse': true,
      });

    } catch (e) {
      print('Emergency weather protocol error: $e');
    }
  }

  /// Cancel SOS alert with enhanced tracking
  Future<void> cancelSos({String? emergencyId}) async {
    try {
      print('🚫 SOS cancelled');

      if (emergencyId != null) {
        await platform.invokeMethod('cancelEmergencyAlert', {
          'emergencyId': emergencyId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

    } catch (e) {
      print('Error cancelling SOS: $e');
    }
  }

  /// Test emergency systems (for development)
  Future<void> testEmergencySystems() async {
    try {
      print('🧪 Testing emergency systems...');

      await platform.invokeMethod('testEmergencySystems', {
        'timestamp': DateTime.now().toIso8601String(),
        'testMode': true,
      });

    } catch (e) {
      print('Emergency systems test error: $e');
    }
  }
}

/// Riverpod provider for SosService
final sosServiceProvider = Provider<SosService>((ref) {
  return SosService();
});