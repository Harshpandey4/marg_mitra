import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// API Service class - handles all API requests
class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});


  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Auth endpoints
  Future<Map<String, dynamic>> login(String phone, String otp) async {
    return await post('/auth/login', {'phone': phone, 'otp': otp});
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post('/auth/register', userData);
  }

  /// Service request endpoints
  Future<Map<String, dynamic>> createServiceRequest(Map<String, dynamic> requestData) async {
    return await post('/service-requests', requestData);
  }

  Future<List<dynamic>> getNearbyProviders(double lat, double lng) async {
    final response = await get('/providers/nearby?lat=$lat&lng=$lng');
    return response['data'] as List<dynamic>;
  }
}

/// Riverpoprovider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: 'https://api.margmitra.com'); // Your API base URL
});
