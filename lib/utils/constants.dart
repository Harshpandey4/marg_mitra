import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Marg Mitra';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.margmitra.com';
  static const int connectionTimeout = 30; // seconds

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);

  // Service Types
  static const List<Map<String, dynamic>> serviceTypes = [
    {
      'id': 'flat_tire',
      'name': 'Flat Tire',
      'icon': Icons.tire_repair,
      'estimatedTime': '30-45 min',
      'basePrice': 500,
    },
    {
      'id': 'battery_jumpstart',
      'name': 'Battery Jump Start',
      'icon': Icons.battery_charging_full,
      'estimatedTime': '15-20 min',
      'basePrice': 300,
    },
    {
      'id': 'fuel_delivery',
      'name': 'Fuel Delivery',
      'icon': Icons.local_gas_station,
      'estimatedTime': '20-30 min',
      'basePrice': 200,
    },
    {
      'id': 'towing',
      'name': 'Towing Service',
      'icon': Icons.local_shipping,
      'estimatedTime': '45-60 min',
      'basePrice': 1000,
    },
    {
      'id': 'lockout',
      'name': 'Car Lockout',
      'icon': Icons.lock_open,
      'estimatedTime': '20-30 min',
      'basePrice': 400,
    },
    {
      'id': 'emergency',
      'name': 'Emergency SOS',
      'icon': Icons.emergency,
      'estimatedTime': '10-15 min',
      'basePrice': 0,
    },
  ];

  // Emergency Contacts
  static const String policeNumber = '100';
  static const String ambulanceNumber = '108';
  static const String fireServiceNumber = '101';

  // Map
  static const double defaultZoom = 15.0;
  static const double maxSearchRadius = 50.0; // km
}