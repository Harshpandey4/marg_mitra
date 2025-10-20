import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../providers/weather_provider.dart';

// SOS Service for both authenticated and anonymous users
class EnhancedSosService {
  static const platform = MethodChannel('com.margmitra.app/sos');
  static const emergencyPlatform = MethodChannel('com.margmitra.app/emergency');
  static const videoPlatform = MethodChannel('com.margmitra.app/video');

  // anonymous emergency session
  String _generateAnonymousSession() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 100000).toString().padLeft(5, '0');
    return 'ANON_${timestamp}_$random';
  }

  // anonymous SOS (no login required)
  Future<Map<String, dynamic>> triggerAnonymousSos({
    String? phoneNumber,
    String? name,
    required bool requestVideoCall,
    WeatherData? weather,
  }) async {
    try {
      final sessionId = _generateAnonymousSession();
      final location = await _getCurrentLocation();

      //  anonymous emergency profile
      final anonymousProfile = {
        'sessionId': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'emergencyType': 'anonymous_sos',
        'isAnonymous': true,
        'contactInfo': {
          'phone': phoneNumber,
          'name': name ?? 'Anonymous User',
          'providedVoluntarily': phoneNumber != null,
        },
        'location': {
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          'accuracy': location['accuracy'] ?? 10.0,
          'altitude': location['altitude'] ?? 0.0,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'requestVideoCall': requestVideoCall,
        'weatherContext': weather != null ? {
          'temperature': weather.temperature,
          'condition': weather.condition,
          'description': weather.description,
          'visibility': weather.visibility,
          'windSpeed': weather.windSpeed,
        } : null,
        'deviceInfo': {
          'platform': 'flutter',
          'appVersion': '1.0.0',
        },
      };

      print('🚨 Anonymous SOS triggered: Session ID: $sessionId');

      // 1. Immediate emergency alert to service providers
      await _dispatchToNearbyProviders(anonymousProfile);

      // 2. Setup video call channel if requested
      String? videoCallToken;
      if (requestVideoCall) {
        videoCallToken = await _initializeVideoCall(sessionId, anonymousProfile);
      }

      // 3. Start real-time location tracking
      await _startAnonymousLocationTracking(sessionId);

      // 4. Alert emergency services (112)
      await _alertEmergencyServices(anonymousProfile);

      // 5. Send SMS with tracking link (if phone provided)
      if (phoneNumber != null) {
        await _sendTrackingLink(phoneNumber, sessionId);
      }

      return {
        'success': true,
        'sessionId': sessionId,
        'videoCallToken': videoCallToken,
        'trackingUrl': 'https://margmitra.app/track/$sessionId',
        'estimatedResponseTime': '5-10 minutes',
        'nearbyProvidersAlerted': true,
      };

    } catch (e) {
      print('❌ Anonymous SOS Error: $e');
      // Fallback to basic emergency protocol
      await _basicEmergencyFallback();
      rethrow;
    }
  }

  // Dispatch emergency to nearby service providers
  Future<void> _dispatchToNearbyProviders(Map<String, dynamic> profile) async {
    try {
      print('📡 Dispatching to nearby service providers...');

      final location = profile['location'];

      await platform.invokeMethod('dispatchEmergencyToProviders', {
        'sessionId': profile['sessionId'],
        'location': {
          'lat': location['latitude'],
          'lng': location['longitude'],
        },
        'emergencyType': 'roadside_assistance',
        'isAnonymous': true,
        'urgencyLevel': 'high',
        'requestVideoCall': profile['requestVideoCall'],
        'weatherCondition': profile['weatherContext']?['condition'] ?? 'unknown',
        'timestamp': profile['timestamp'],
        'radiusKm': 10, // Search within 10km radius
      });

      print('✅ Dispatched to providers within 10km radius');
    } catch (e) {
      print('Provider dispatch error: $e');
    }
  }

  //Initialize video call session
  Future<String?> _initializeVideoCall(
      String sessionId,
      Map<String, dynamic> profile
      ) async {
    try {
      print('📹 Initializing video call for session: $sessionId');

      final result = await videoPlatform.invokeMethod('initializeVideoCall', {
        'sessionId': sessionId,
        'isAnonymous': true,
        'location': profile['location'],
        'emergencyType': 'sos',
      });

      final videoCallToken = result['token'] as String?;

      if (videoCallToken != null) {
        print('✅ Video call initialized. Token: ${videoCallToken.substring(0, 10)}...');

        // Store video call session
        await platform.invokeMethod('storeVideoSession', {
          'sessionId': sessionId,
          'token': videoCallToken,
          'expiresAt': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
        });
      }

      return videoCallToken;
    } catch (e) {
      print('❌ Video call initialization error: $e');
      return null;
    }
  }

  /// Start anonymous location tracking
  Future<void> _startAnonymousLocationTracking(String sessionId) async {
    try {
      print('📍 Starting anonymous location tracking...');

      await platform.invokeMethod('startAnonymousTracking', {
        'sessionId': sessionId,
        'updateInterval': 5, // Update every 5 seconds
        'highAccuracy': true,
        'backgroundTracking': true,
        'shareWithProviders': true,
      });

      print('✅ Location tracking started for session: $sessionId');
    } catch (e) {
      print('Location tracking error: $e');
    }
  }

  /// Alert emergency services (112)
  Future<void> _alertEmergencyServices(Map<String, dynamic> profile) async {
    try {
      final location = profile['location'];
      final contactInfo = profile['contactInfo'];

      final emergencyMessage = '''
MARG MITRA EMERGENCY ALERT
Session: ${profile['sessionId']}
User: ${contactInfo['name']}
Phone: ${contactInfo['phone'] ?? 'Not provided'}
Location: ${location['latitude']}, ${location['longitude']}
Time: ${DateTime.now().toLocal()}
Type: Roadside Emergency
Weather: ${profile['weatherContext']?['description'] ?? 'Unknown'}
''';

      await emergencyPlatform.invokeMethod('alert112', {
        'message': emergencyMessage,
        'location': '${location['latitude']},${location['longitude']}',
        'priority': 'high',
        'sessionId': profile['sessionId'],
      });

      print('✅ Emergency services (112) alerted');
    } catch (e) {
      print('Emergency services alert error: $e');
    }
  }

  /// Send tracking link via SMS
  Future<void> _sendTrackingLink(String phoneNumber, String sessionId) async {
    try {
      final trackingUrl = 'https://margmitra.app/track/$sessionId';

      await platform.invokeMethod('sendSMS', {
        'phone': phoneNumber,
        'message': 'Your emergency alert is active. Track your help request: $trackingUrl\n\nHelp is on the way. Stay safe.',
      });

      print('✅ Tracking link sent to: $phoneNumber');
    } catch (e) {
      print('SMS sending error: $e');
    }
  }

  /// Get provider video call status
  Future<Map<String, dynamic>> getProviderVideoCallStatus(String sessionId) async {
    try {
      final result = await videoPlatform.invokeMethod('getProviderStatus', {
        'sessionId': sessionId,
      });

      return {
        'providerConnected': result['connected'] ?? false,
        'providerName': result['providerName'],
        'providerPhone': result['providerPhone'],
        'estimatedArrival': result['eta'],
        'currentLocation': result['location'],
      };
    } catch (e) {
      print('Provider status error: $e');
      return {'providerConnected': false};
    }
  }

  // Join video call (for user)
  Future<void> joinVideoCall(String sessionId, String token) async {
    try {
      await videoPlatform.invokeMethod('joinVideoCall', {
        'sessionId': sessionId,
        'token': token,
        'role': 'user',
      });
    } catch (e) {
      print('Join video call error: $e');
      rethrow;
    }
  }

  // End video call
  Future<void> endVideoCall(String sessionId) async {
    try {
      await videoPlatform.invokeMethod('endVideoCall', {
        'sessionId': sessionId,
      });
    } catch (e) {
      print('End video call error: $e');
    }
  }

  //Cancel anonymous SOS
  Future<void> cancelAnonymousSos(String sessionId) async {
    try {
      print('🚫 Cancelling anonymous SOS: $sessionId');

      await platform.invokeMethod('cancelAnonymousEmergency', {
        'sessionId': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'reason': 'user_cancelled',
      });

      // Stop location tracking
      await platform.invokeMethod('stopAnonymousTracking', {
        'sessionId': sessionId,
      });

      // End video call if active
      await endVideoCall(sessionId);

      print('✅ Anonymous SOS cancelled');
    } catch (e) {
      print('Cancel SOS error: $e');
    }
  }

  //  Basic emergency fallback
  Future<void> _basicEmergencyFallback() async {
    try {
      final location = await _getCurrentLocation();

      await platform.invokeMethod('dialEmergency', {
        'number': '112',
        'location': '${location['latitude']},${location['longitude']}',
      });
    } catch (e) {
      print('Fallback error: $e');
    }
  }

  //  Get current location
  Future<Map<String, dynamic>> _getCurrentLocation() async {
    try {
      final result = await platform.invokeMethod('getCurrentLocation');
      return {
        'latitude': result['latitude'] ?? 26.7806,
        'longitude': result['longitude'] ?? 80.8138,
        'accuracy': result['accuracy'] ?? 5.0,
        'altitude': result['altitude'] ?? 100.0,
      };
    } catch (e) {
      // Fallback location
      return {
        'latitude': 26.7806,
        'longitude': 80.8138,
        'accuracy': 10.0,
        'altitude': 100.0,
      };
    }
  }

  // Trigger authenticated SOS (for logged-in users)
  Future<void> triggerAuthenticatedSos({
    required String userId,
    required Map<String, dynamic> emergencyData,
    bool requestVideoCall = true,
  }) async {
    try {
      final sessionId = 'AUTH_${DateTime.now().millisecondsSinceEpoch}';
      final location = await _getCurrentLocation();

      final authenticatedProfile = {
        'sessionId': sessionId,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'emergencyType': 'authenticated_sos',
        'isAnonymous': false,
        'location': location,
        'requestVideoCall': requestVideoCall,
        ...emergencyData,
      };

      //dispatch with user profile
      await _dispatchToNearbyProviders(authenticatedProfile);

      if (requestVideoCall) {
        await _initializeVideoCall(sessionId, authenticatedProfile);
      }

      await _startAnonymousLocationTracking(sessionId);
      await _alertEmergencyServices(authenticatedProfile);

      print('✅ Authenticated SOS triggered: $sessionId');
    } catch (e) {
      print('❌ Authenticated SOS error: $e');
      rethrow;
    }
  }
}

/// Riverpod statM..
final enhancedSosServiceProvider = Provider<EnhancedSosService>((ref) {
  return EnhancedSosService();
});