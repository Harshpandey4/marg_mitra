import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// Models
class WeatherData {
  final String location;
  final String description;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double visibility;
  final double pressure;
  final String condition; // clear, cloudy and many more ,,
  final DateTime timestamp;
  final double rainfall;
  final String mainCondition;
  final double feelsLike;
  final int cloudiness;
  final List<String> alerts;

  WeatherData({
    required this.location,
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.pressure,
    required this.condition,
    required this.timestamp,
    required this.mainCondition,
    required this.feelsLike,
    required this.cloudiness,
    this.rainfall = 0.0,
    this.alerts = const [],
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['name'] ?? 'Unknown Location',
      description: json['weather']?[0]?['description'] ?? 'Unknown',
      temperature: (json['main']?['temp'] ?? 20.0).toDouble(),
      humidity: (json['main']?['humidity'] ?? 50.0).toDouble(),
      windSpeed: (json['wind']?['speed'] ?? 0.0).toDouble(),
      windDirection: _getWindDirection(json['wind']?['deg'] ?? 0),
      visibility: (json['visibility'] ?? 10000.0).toDouble() / 1000, // Convert to km
      pressure: (json['main']?['pressure'] ?? 1013.0).toDouble(),
      condition: _mapWeatherCondition(json['weather']?[0]?['main'] ?? 'Clear'),
      mainCondition: json['weather']?[0]?['main'] ?? 'Clear',
      feelsLike: (json['main']?['feels_like'] ?? 20.0).toDouble(),
      cloudiness: (json['clouds']?['all'] ?? 0).toInt(),
      timestamp: DateTime.now(),
      rainfall: (json['rain']?['1h'] ?? 0.0).toDouble(),
      alerts: _extractAlerts(json),
    );
  }

  static String _getWindDirection(int degrees) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    int index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  static String _mapWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'clear';
      case 'clouds':
        return 'cloudy';
      case 'rain':
      case 'drizzle':
        return 'rainy';
      case 'thunderstorm':
        return 'stormy';
      case 'mist':
      case 'fog':
        return 'foggy';
      case 'snow':
        return 'snowy';
      default:
        return 'clear';
    }
  }

  static List<String> _extractAlerts(Map<String, dynamic> json) {
    List<String> alerts = [];

    // Check for weather alerts
    if (json['alerts'] != null) {
      for (var alert in json['alerts']) {
        alerts.add(alert['event'] ?? 'Weather Alert');
      }
    }

    return alerts;
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'description': description,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'visibility': visibility,
      'pressure': pressure,
      'condition': condition,
      'mainCondition': mainCondition,
      'feelsLike': feelsLike,
      'cloudiness': cloudiness,
      'timestamp': timestamp.toIso8601String(),
      'rainfall': rainfall,
      'alerts': alerts,
    };
  }
}

// Weather alert class
class WeatherAlert {
  final String event;
  final String description;
  final String severity;

  WeatherAlert({
    required this.event,
    required this.description,
    required this.severity,
  });
}

enum RoadSafetyLevel {
  safe,
  moderate,
  dangerous,
}

class WeatherState {
  final WeatherData? currentWeather;
  final bool isLoading;
  final String? error;
  final Position? currentPosition;
  final RoadSafetyLevel safetyLevel;
  final List<String> safetyRecommendations;
  final DateTime? lastUpdated;

  WeatherState({
    this.currentWeather,
    this.isLoading = false,
    this.error,
    this.currentPosition,
    this.safetyLevel = RoadSafetyLevel.safe,
    this.safetyRecommendations = const [],
    this.lastUpdated,
  });

  WeatherState copyWith({
    WeatherData? currentWeather,
    bool? isLoading,
    String? error,
    Position? currentPosition,
    RoadSafetyLevel? safetyLevel,
    List<String>? safetyRecommendations,
    DateTime? lastUpdated,
  }) {
    return WeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPosition: currentPosition ?? this.currentPosition,
      safetyLevel: safetyLevel ?? this.safetyLevel,
      safetyRecommendations: safetyRecommendations ?? this.safetyRecommendations,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Method to get road safety level
  RoadSafetyLevel getRoadSafety() {
    return safetyLevel;
  }

  // Method to get weather alerts -   to return List<WeatherAlert>
  List<WeatherAlert>? get alerts {
    if (currentWeather?.alerts.isEmpty != false) return null;

    return currentWeather!.alerts.map((alertText) => WeatherAlert(
      event: alertText,
      description: alertText,
      severity: 'moderate',
    )).toList();
  }
}

// Weather Notifier
class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier() : super(WeatherState());

  // OpenWeatherMap api key section
  static const String _apiKey = '5dd6187152e21d7e56ad742133659595';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<void> getCurrentLocationWeather() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current location
      Position position = await _getCurrentPosition();

      // Fetch weather data
      WeatherData weather = await _fetchWeatherData(
          position.latitude,
          position.longitude
      );

      // Calculate road safety level
      RoadSafetyLevel safety = _calculateRoadSafety(weather);
      List<String> recommendations = _getSafetyRecommendations(safety, weather);

      state = state.copyWith(
        currentWeather: weather,
        currentPosition: position,
        safetyLevel: safety,
        safetyRecommendations: recommendations,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshWeather() async {
    if (state.currentPosition != null) {
      await getCurrentLocationWeather();
    }
  }

  Future<WeatherData> getWeatherForLocation(double lat, double lon) async {
    return await _fetchWeatherData(lat, lon);
  }

  RoadSafetyLevel getRoadSafety() {
    return state.safetyLevel;
  }

  bool isWeatherDangerous() {
    return state.safetyLevel == RoadSafetyLevel.dangerous;
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<WeatherData> _fetchWeatherData(double lat, double lon) async {
    try {
      final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else if (response.statusCode == 401) {
        // API key issue - return mock data for development
        return _getMockWeatherData(lat, lon);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Weather API Error: $e');
        // Return mock data in debug mode
        return _getMockWeatherData(lat, lon);
      }
      throw Exception('Weather service unavailable: $e');
    }
  }

  WeatherData _getMockWeatherData(double lat, double lon) {
    final random = Random();
    final conditions = ['clear', 'cloudy', 'rainy', 'stormy', 'foggy'];
    final descriptions = {
      'clear': 'Clear sky',
      'cloudy': 'Partly cloudy',
      'rainy': 'Light rain',
      'stormy': 'Thunderstorm',
      'foggy': 'Foggy conditions',
    };

    final condition = conditions[random.nextInt(conditions.length)];
    final mainConditions = ['Clear', 'Clouds', 'Rain', 'Thunderstorm', 'Mist'];

    return WeatherData(
      location: 'Current Location',
      description: descriptions[condition]!,
      temperature: 15 + random.nextInt(25).toDouble(), // 15-40°C
      humidity: 30 + random.nextInt(50).toDouble(), // 30-80%
      windSpeed: random.nextInt(20).toDouble(), // 0-20 km/h
      windDirection: 'NE',
      visibility: 5 + random.nextInt(10).toDouble(), // 5-15 km
      pressure: 1000 + random.nextInt(50).toDouble(), // 1000-1050 hPa
      condition: condition,
      mainCondition: mainConditions[random.nextInt(mainConditions.length)],
      feelsLike: 15 + random.nextInt(25).toDouble(),
      cloudiness: random.nextInt(100), // 0-100%
      timestamp: DateTime.now(),
      rainfall: condition == 'rainy' || condition == 'stormy' ?
      random.nextInt(20).toDouble() : 0.0,
      alerts: condition == 'stormy' ? ['Thunderstorm Warning'] : [],
    );
  }

  RoadSafetyLevel _calculateRoadSafety(WeatherData weather) {
    int riskScore = 0;

    // Temperature risks
    if (weather.temperature < 0 || weather.temperature > 45) {
      riskScore += 3; // Extreme temperature
    } else if (weather.temperature < 5 || weather.temperature > 40) {
      riskScore += 2; // High temperature risk
    }

    // Visibility risks
    if (weather.visibility < 1) {
      riskScore += 4; // Very poor visibility
    } else if (weather.visibility < 3) {
      riskScore += 3; // Poor visibility
    } else if (weather.visibility < 5) {
      riskScore += 1; // Moderate visibility
    }

    // Wind risks
    if (weather.windSpeed > 60) {
      riskScore += 4; // Dangerous winds
    } else if (weather.windSpeed > 40) {
      riskScore += 3; // High winds
    } else if (weather.windSpeed > 25) {
      riskScore += 2; // Moderate winds
    }

    // Precipitation risks
    if (weather.rainfall > 15) {
      riskScore += 4; // Heavy rain
    } else if (weather.rainfall > 5) {
      riskScore += 2; // Moderate rain
    } else if (weather.rainfall > 0) {
      riskScore += 1; // Light rain
    }

    // Weather condition specific risks
    switch (weather.condition) {
      case 'stormy':
        riskScore += 4;
        break;
      case 'snowy':
        riskScore += 3;
        break;
      case 'foggy':
        riskScore += 3;
        break;
      case 'rainy':
        riskScore += 2;
        break;
      case 'cloudy':
        riskScore += 1;
        break;
    }

    // Humidity risks (extreme humidity can cause visibility issues)
    if (weather.humidity > 90) {
      riskScore += 2;
    } else if (weather.humidity > 80) {
      riskScore += 1;
    }

    // Weather alerts
    riskScore += weather.alerts.length * 2;

    // Determine safety level based on risk score
    if (riskScore >= 8) {
      return RoadSafetyLevel.dangerous;
    } else if (riskScore >= 4) {
      return RoadSafetyLevel.moderate;
    } else {
      return RoadSafetyLevel.safe;
    }
  }

  List<String> _getSafetyRecommendations(RoadSafetyLevel level, WeatherData weather) {
    List<String> recommendations = [];

    switch (level) {
      case RoadSafetyLevel.dangerous:
        recommendations.addAll([
          'AVOID TRAVEL if possible - Dangerous conditions detected',
          'If you must travel, reduce speed significantly',
          'Maintain extra distance from other vehicles',
          'Keep emergency supplies in your vehicle',
          'Inform someone of your travel route and expected arrival',
          'Consider delaying travel until conditions improve',
        ]);
        break;

      case RoadSafetyLevel.moderate:
        recommendations.addAll([
          'Drive with extra caution - Moderate risk conditions',
          'Reduce speed and increase following distance',
          'Use headlights even during daytime',
          'Avoid sudden movements and hard braking',
          'Stay alert and avoid distractions',
        ]);
        break;

      case RoadSafetyLevel.safe:
        recommendations.addAll([
          'Normal driving conditions - Stay alert',
          'Follow standard traffic rules',
          'Maintain vehicle regularly',
          'Keep emergency contacts handy',
        ]);
        break;
    }

    // Weather-specific recommendations
    switch (weather.condition) {
      case 'rainy':
        recommendations.add('Turn on wipers and use rain-appropriate tires');
        recommendations.add('Watch for water accumulation on roads');
        break;
      case 'foggy':
        recommendations.add('Use fog lights and drive slowly');
        recommendations.add('Use lane markings as guides');
        break;
      case 'stormy':
        recommendations.add('Avoid parking under trees');
        recommendations.add('Pull over safely if visibility becomes zero');
        break;
      case 'snowy':
        recommendations.add('Use tire chains if required');
        recommendations.add('Warm up your vehicle before driving');
        break;
    }

    // Wind-specific recommendations
    if (weather.windSpeed > 25) {
      recommendations.add('Be extra careful of crosswinds, especially on highways');
      recommendations.add('Grip steering wheel firmly with both hands');
    }

    return recommendations;
  }

  // Method to check if weather update is needed
  bool shouldUpdateWeather() {
    if (state.lastUpdated == null) return true;

    final difference = DateTime.now().difference(state.lastUpdated!);
    return difference.inMinutes > 30; // Update every 30 minutes
  }

  // Get weather color for UI
  String getWeatherColorCode() {
    switch (state.safetyLevel) {
      case RoadSafetyLevel.dangerous:
        return '#FF5252'; // Red
      case RoadSafetyLevel.moderate:
        return '#FF9800'; // Orange
      case RoadSafetyLevel.safe:
        return '#4CAF50'; // Green
    }
  }

  // Get weather icon name
  String getWeatherIcon() {
    if (state.currentWeather == null) return 'wb_sunny';

    switch (state.currentWeather!.condition) {
      case 'clear':
        return 'wb_sunny';
      case 'cloudy':
        return 'wb_cloudy';
      case 'rainy':
        return 'grain';
      case 'stormy':
        return 'flash_on';
      case 'foggy':
        return 'cloud';
      case 'snowy':
        return 'ac_unit';
      default:
        return 'wb_sunny';
    }
  }

  // Method to clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Method to reset state
  void reset() {
    state = WeatherState();
  }
}

// Provider
final weatherNotifierProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier();
});

// Helper providers for specific data
final currentWeatherProvider = Provider<WeatherData?>((ref) {
  return ref.watch(weatherNotifierProvider).currentWeather;
});

final roadSafetyProvider = Provider<RoadSafetyLevel>((ref) {
  return ref.watch(weatherNotifierProvider).safetyLevel;
});

final weatherLoadingProvider = Provider<bool>((ref) {
  return ref.watch(weatherNotifierProvider).isLoading;
});

final weatherErrorProvider = Provider<String?>((ref) {
  return ref.watch(weatherNotifierProvider).error;
});

final safetyRecommendationsProvider = Provider<List<String>>((ref) {
  return ref.watch(weatherNotifierProvider).safetyRecommendations;
});