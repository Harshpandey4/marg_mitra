import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../providers/weather_provider.dart';
import '../../services/sos_service.dart';
import '../../widgets/sos_button.dart';
import '../common/profile_screen.dart';
import '../provider/navigation_screen.dart';
import 'user_service_provider_communication_screen.dart';
import 'sos_request_screen.dart';

import '../../features/health_monitoring/widgets/smartwatch_connection_widget.dart';
import '../../features/health_monitoring/widgets/health_metrics_dashboard.dart';
import '../../features/health_monitoring/providers/health_monitoring_providers.dart';
import '../../features/health_monitoring/services/health_monitoring_service.dart';
class UserDashboardScreen extends ConsumerStatefulWidget {
  const UserDashboardScreen({super.key});
  @override
  ConsumerState<UserDashboardScreen> createState() => _UserDashboardScreenState();
}
class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  int _selectedNavIndex = 0;
  bool _isSOSActive = false;
  bool hasNewNotifications = true;
  String _userName = "Harsh";
  String _currentLocation = "Prayagraj, India";
  int _loyaltyPoints = 1250;
  // Medical Profile
  Map<String, dynamic> medicalProfile = {
    'bloodType': 'B+',
    'allergies': ['Penicillin'],
    'conditions': ['None'],
    'medications': ['None'],
    'emergencyContacts': [
      {'name': 'Father', 'phone': '+91 9876543210', 'relation': 'Parent'},
      {'name': 'Mother', 'phone': '+91 9876543211', 'relation': 'Parent'},
    ],
  };
  // Route Safety Data
  Map<String, dynamic>? plannedRoute;
  bool hasPlannedRoute = false;

  // Insurance Data
  Map<String, dynamic> insuranceInfo = {
    'provider': 'HDFC ERGO',
    'policyNumber': 'POL123456789',
    'validUntil': 'Dec 2025',
    'coverage': 'Comprehensive',
    'claimStatus': 'No active claims',
  };

  // Service Provider Verification
  Map<String, dynamic> verificationStats = {
    'verifiedProviders': 1450,
    'totalProviders': 1500,
    'averageResponseTime': '8 min',
    'successRate': '98.5%',
  };
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // REMOVED: _startHealthMonitoring(); - Now handled by new system

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(weatherNotifierProvider.notifier).getCurrentLocationWeather();

        // ============ NEW: Setup health monitoring alerts ============
        _setupHealthMonitoring();
      } catch (e) {
        print('Weather initialization failed: $e');
      }
    });
  }
  @override
  void dispose() {
    _pulseController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  // ============ NEW SMARTWATCH & HEALTH METHODS ============

  Widget _buildSmartWatchSection() {
    return const SmartwatchConnectionWidget();
  }

  Widget _buildHealthMonitoringDashboard() {
    return const HealthMetricsDashboard();
  }

  void _setupHealthMonitoring() {
    // Listen to emergency alerts
    ref.listen(emergencyAlertStreamProvider, (previous, next) {
      next.whenData((alert) {
        if (alert.requiresResponse) {
          _showEmergencyAlertDialog(alert);
        } else {
          _showHealthWarningSnackbar(alert);
        }
      });
    });
  }

  void _showEmergencyAlertDialog(alert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'HEALTH EMERGENCY',
                style: TextStyle(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            if (alert.healthData != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Vitals:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('❤️ Heart Rate: ${alert.healthData!.heartRate} BPM'),
                    if (alert.healthData!.oxygenSaturation != null)
                      Text('🫁 SpO2: ${alert.healthData!.oxygenSaturation}%'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('I\'m OK'),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _activateEmergencySOS();
            },
            icon: Icon(Icons.emergency),
            label: Text('CALL EMERGENCY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showHealthWarningSnackbar(alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Health Alert',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(alert.message, style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Open health dashboard
          },
        ),
      ),
    );
  }

// ============ END OF NEW METHODS ============
  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(weatherState),
              SizedBox(height: 16),
              _buildSmartWatchSection(),
              SizedBox(height: 16),
              _buildHealthMonitoringDashboard(),
              SizedBox(height: 16),
              _buildMedicalProfileCard(),
              SizedBox(height: 16),
              _buildWeatherCard(weatherState),
              SizedBox(height: 16),
              _buildRouteSafetyCard(weatherState),
              SizedBox(height: 16),
              _buildQuickActionsGrid(weatherState),
              SizedBox(height: 16),
              _buildEnhancedSOSCard(weatherState),
              SizedBox(height: 16),
              _buildVerificationStatsCard(),
              SizedBox(height: 16),
              _buildInsuranceCard(),
              SizedBox(height: 16),
              _buildEmergencyContactsCard(),
              SizedBox(height: 16),
              _buildUserStatsCard(),
              SizedBox(height: 16),
              _buildLoyaltyCard(),
              SizedBox(height: 16),
              _buildQuickServicesSection(),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSupportFAB(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MARG MITRA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.yellow[300],
              letterSpacing: 1.2,
            ),
          ),
          Text(
            '"Your journey is our responsibility"',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[200],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        // ============ NEW: SMART WATCH STATUS FROM PROVIDER ============
        Consumer(
          builder: (context, ref, _) {
            final isConnected = ref.watch(isDeviceConnectedProvider);
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isConnected ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.watch,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isConnected ? 'Connected' : 'Tap to Connect',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: Colors.yellow[300], size: 24),
              if (hasNewNotifications)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showNotificationsBottomSheet(),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeCard(WeatherState weatherState) {
    final weather = weatherState.currentWeather;
    final weatherDisplay = weather != null ? '${weather.temperature.round()}°C' : 'Loading...';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $_userName!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      _currentLocation,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.wb_cloudy, color: Colors.blue, size: 28),
                SizedBox(height: 4),
                Text(
                  weatherDisplay,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String title, String value, IconData icon, Color color, String status) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalProfileCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.medical_information, color: Colors.red, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Emergency medical information',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editMedicalProfile(),
                icon: Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
              ),
            ],
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMedicalInfo('Blood Type', medicalProfile['bloodType'], Icons.bloodtype, Colors.red),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildMedicalInfo(
                  'Allergies',
                  (medicalProfile['allergies'] as List).isEmpty ? 'None' : (medicalProfile['allergies'] as List).length.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shared with first responders in emergencies',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(WeatherState weatherState) {
    final weather = weatherState.currentWeather;
    final safetyLevel = weatherState.getRoadSafety();

    if (weather == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            if (weatherState.isLoading)
              CircularProgressIndicator(strokeWidth: 2)
            else
              Icon(Icons.error_outline, color: Colors.orange),
            SizedBox(width: 16),
            Text('Loading weather data...'),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: _getGradientForSafety(safetyLevel),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getSafetyColor(safetyLevel).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_cloudy, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Weather & Road Safety',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${weather.temperature.round()}°C - ${weather.description}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _getSafetyIndicator(safetyLevel),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail('Wind', '${weather.windSpeed.round()} m/s', Icons.air),
              _buildWeatherDetail('Humidity', '${weather.humidity}%', Icons.water_drop),
              _buildWeatherDetail('Visibility', '${(weather.visibility / 1000).toStringAsFixed(1)}km', Icons.visibility),
            ],
          ),
          if (safetyLevel != RoadSafetyLevel.safe) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSafetyMessage(safetyLevel),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _getSafetyIndicator(RoadSafetyLevel level) {
    IconData icon;
    Color color;

    switch (level) {
      case RoadSafetyLevel.dangerous:
        icon = Icons.dangerous;
        color = Colors.red[300]!;
        break;
      case RoadSafetyLevel.moderate:
        icon = Icons.warning;
        color = Colors.orange[300]!;
        break;
      default:
        icon = Icons.check_circle;
        color = Colors.green[300]!;
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 4),
        Text(
          _getSafetyLevelText(level),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteSafetyCard(WeatherState weatherState) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.route, color: Colors.blue, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Route Planning',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'AI-powered safety assessment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          if (!hasPlannedRoute) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.map_outlined, color: Colors.grey[400], size: 40),
                  SizedBox(height: 8),
                  Text(
                    'No active route',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Plan your journey with real-time safety analysis',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _planRoute(),
              icon: Icon(Icons.add_road, size: 18),
              label: Text('Plan Route with Safety Check'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Route Planned',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('From: Prayagraj • To: Delhi'),
                  Text('Distance: 634 km • Est. Time: 10h 30m'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(WeatherState weatherState) {
    final safetyLevel = weatherState.getRoadSafety();

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (safetyLevel != RoadSafetyLevel.safe) ...[
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: safetyLevel == RoadSafetyLevel.dangerous
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: safetyLevel == RoadSafetyLevel.dangerous
                          ? Colors.red.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 14,
                        color: safetyLevel == RoadSafetyLevel.dangerous ? Colors.red : Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Alert',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: safetyLevel == RoadSafetyLevel.dangerous ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Emergency\nSOS',
                  Icons.emergency,
                  Colors.red,
                      () => _activateEmergencySOS(),
                  isHighlighted: safetyLevel != RoadSafetyLevel.safe,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Find\nProvider',
                  Icons.search,
                  Colors.blue,
                      () => _findNearbyProviders(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Medical\nInfo',
                  Icons.medical_information,
                  Colors.green,
                      () => _editMedicalProfile(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap, {bool isHighlighted = false}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(isHighlighted ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(isHighlighted ? 0.5 : 0.3),
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(icon, color: color, size: 28),
                if (isHighlighted)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSOSCard(WeatherState weatherState) {
    final safetyLevel = weatherState.getRoadSafety();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSOSActive ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _getSOSGradient(safetyLevel),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: _isSOSActive ? 25 : 15,
                  spreadRadius: _isSOSActive ? 8 : 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency, size: 36, color: Colors.white),
                      if (safetyLevel != RoadSafetyLevel.safe) ...[
                        SizedBox(width: 8),
                        Icon(Icons.warning, size: 24, color: Colors.white),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Multi-Agency Response System',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'CONNECTED EMERGENCY SERVICES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAgencyIndicator(Icons.local_hospital, 'Hospital'),
                            _buildAgencyIndicator(Icons.local_police, 'Police'),
                            _buildAgencyIndicator(Icons.local_shipping, 'Ambulance'),
                            _buildAgencyIndicator(Icons.contacts, 'Family'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (safetyLevel == RoadSafetyLevel.dangerous) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRIORITY MODE: Weather Emergency Response',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SosButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgencyIndicator(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStatsCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.verified_user, color: Colors.green, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified Provider Network',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Multi-layer credential verification',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildVerificationStat(
                  'Verified',
                  '${verificationStats['verifiedProviders']}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildVerificationStat(
                  'Response',
                  verificationStats['averageResponseTime'],
                  Icons.timer,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Success Rate: ${verificationStats['successRate']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Transparent service records & verified billing',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[700]!, Colors.indigo[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insurance Integration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      insuranceInfo['provider'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildInsuranceRow('Policy No:', insuranceInfo['policyNumber']),
                SizedBox(height: 8),
                _buildInsuranceRow('Valid Until:', insuranceInfo['validUntil']),
                SizedBox(height: 8),
                _buildInsuranceRow('Coverage:', insuranceInfo['coverage']),
              ],
            ),
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewInsuranceDetails(),
                  icon: Icon(Icons.description, size: 16),
                  label: Text('View Details', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo[700],
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _fileClaim(),
                  icon: Icon(Icons.add_circle, size: 16),
                  label: Text('File Claim', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactsCard() {
    final contacts = medicalProfile['emergencyContacts'] as List;

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.contacts, color: Colors.orange, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Auto-notified in emergencies',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _manageEmergencyContacts(),
                icon: Icon(Icons.add, color: AppTheme.primaryColor),
              ),
            ],
          ),
          SizedBox(height: 16),

          ...contacts.map((contact) => _buildContactItem(contact)).toList(),

          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Contacts receive real-time location & status updates',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(Map<String, dynamic> contact) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.orange, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${contact['relation']} • ${contact['phone']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildUserStatsCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Services', '47', Icons.build, Colors.blue),
              ),
              Expanded(
                child: _buildStatItem('Rating', '4.6/5', Icons.star, Colors.amber),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Savings', '₹2,350', Icons.savings, Colors.green),
              ),
              Expanded(
                child: _buildStatItem('Points', '$_loyaltyPoints', Icons.stars, Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Loyalty Points',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '$_loyaltyPoints Points',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Redeem for discounts & rewards',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.rewards),
                  child: Text('Redeem Points'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// QUICK SERVICES SECTION
  Widget _buildQuickServicesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    final services = [
      {
        'title': 'Towing',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
        'price': '₹###..',
        'eta': '15-20 min',
        'description': 'Vehicle breakdown assistance',
        'rating': 4.8,
        'available': true,
        'popular': true,
      },
      {
        'title': 'Battery',
        'icon': Icons.battery_charging_full,
        'color': Colors.green,
        'price': '₹###..',
        'eta': '10-15 min',
        'description': 'Jump start & replacement',
        'rating': 4.9,
        'available': true,
        'popular': true,
      },
      {
        'title': 'Flat Tire',
        'icon': Icons.tire_repair,
        'color': Colors.orange,
        'price': '₹###..',
        'eta': '12-18 min',
        'description': 'Tire change & repair',
        'rating': 4.7,
        'available': true,
        'popular': false,
      },
      {
        'title': 'Fuel',
        'icon': Icons.local_gas_station,
        'color': Colors.red,
        'price': '₹###..',
        'eta': '8-12 min',
        'description': 'Emergency fuel delivery',
        'rating': 4.6,
        'available': true,
        'popular': true,
      },
      {
        'title': 'Lockout',
        'icon': Icons.key,
        'color': Colors.purple,
        'price': '₹###..',
        'eta': '15-25 min',
        'description': 'Key & lock assistance',
        'rating': 4.5,
        'available': true,
        'popular': false,
      },
      {
        'title': 'Mechanic',
        'icon': Icons.build,
        'color': Colors.teal,
        'price': '₹###..',
        'eta': '20-30 min',
        'description': 'On-spot repair service',
        'rating': 4.8,
        'available': true,
        'popular': false,
      },
      {
        'title': 'Unidentified',
        'icon': Icons.help_outline,
        'color': Colors.orangeAccent,
        'price': '₹###..',
        'eta': '45-60 min',
        'description': 'Support when unsure',
        'rating': 4.6,
        'available': true,
        'popular': false,
      }
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, Colors.blue[700]!],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.room_service,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 24,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Quick Services',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : (isMediumScreen ? 18 : 22),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fast & Reliable Assistance',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[100]!, Colors.orange[50]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange[300]!, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.whatshot,
                      color: Colors.orange[700],
                      size: isSmallScreen ? 12 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Popular',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true, Icons.grid_view, isSmallScreen),
                SizedBox(width: 6),
                _buildFilterChip('Popular', false, Icons.local_fire_department, isSmallScreen),
                SizedBox(width: 6),
                _buildFilterChip('Emergency', false, Icons.emergency, isSmallScreen),
                SizedBox(width: 6),
                _buildFilterChip('Maintenance', false, Icons.build_circle, isSmallScreen),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Services Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: isSmallScreen ? 0.58 : (isMediumScreen ? 0.65 : 0.72),
              crossAxisSpacing: isSmallScreen ? 8 : 12,
              mainAxisSpacing: isSmallScreen ? 8 : 12,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildEnhancedServiceCard(service, isSmallScreen, isMediumScreen);
            },
          ),

          SizedBox(height: 12),

          // View All Button
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.allServices),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Colors.blue[700]!],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'View All Services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 13 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: isSmallScreen ? 14 : 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, IconData icon, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 14,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [AppTheme.primaryColor, Colors.blue[700]!],
        )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 12 : 16,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedServiceCard(Map<String, dynamic> service, bool isSmallScreen, bool isMediumScreen) {
    final bool isAvailable = service['available'];
    final bool isPopular = service['popular'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: isAvailable
              ? () {
            HapticFeedback.mediumImpact();
            _showServiceDetails(service);
          }
              : () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${service['title']} is currently unavailable.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              border: Border.all(
                color: isAvailable
                    ? (service['color'] as Color).withOpacity(0.3)
                    : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isAvailable
                      ? (service['color'] as Color).withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main Content
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : (isMediumScreen ? 8 : 12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Container
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 6 : (isMediumScreen ? 8 : 10)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isAvailable
                                ? [
                              (service['color'] as Color).withOpacity(0.2),
                              (service['color'] as Color).withOpacity(0.1),
                            ]
                                : [Colors.grey[200]!, Colors.grey[100]!],
                          ),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : (isMediumScreen ? 10 : 12)),
                        ),
                        child: Icon(
                          service['icon'],
                          size: isSmallScreen ? 18 : (isMediumScreen ? 22 : 28),
                          color: isAvailable ? service['color'] : Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : (isMediumScreen ? 6 : 8)),

                      // Service Title
                      Text(
                        service['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 11 : (isMediumScreen ? 13 : 15),
                          color: isAvailable ? Colors.grey[800] : Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),

                      // Description
                      Text(
                        service['description'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 8 : (isMediumScreen ? 9 : 10),
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),

                      // Rating & ETA
                      Padding(
                        padding: EdgeInsets.only(bottom: isSmallScreen ? 3 : 5),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: isSmallScreen ? 10 : (isMediumScreen ? 11 : 13)),
                            SizedBox(width: 2),
                            Text(
                              '${service['rating']}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : (isMediumScreen ? 10 : 11),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.access_time, color: Colors.grey[500], size: isSmallScreen ? 9 : (isMediumScreen ? 10 : 12)),
                            SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                service['eta'],
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 8 : (isMediumScreen ? 9 : 10),
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price & Book Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 7 : (isMediumScreen ? 8 : 9),
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Text(
                                  service['price'],
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : (isMediumScreen ? 13 : 16),
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable
                                        ? service['color']
                                        : Colors.grey[500],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 6 : (isMediumScreen ? 8 : 10),
                              vertical: isSmallScreen ? 4 : (isMediumScreen ? 5 : 6),
                            ),
                            decoration: BoxDecoration(
                              gradient: isAvailable
                                  ? LinearGradient(
                                colors: [
                                  service['color'] as Color,
                                  (service['color'] as Color).withOpacity(0.7),
                                ],
                              )
                                  : null,
                              color: isAvailable ? null : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isAvailable ? 'Book' : 'N/A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 9 : (isMediumScreen ? 10 : 11),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isSmallScreen) ...[
                                  SizedBox(width: 3),
                                  Icon(
                                    isAvailable ? Icons.arrow_forward : Icons.block,
                                    color: Colors.white,
                                    size: isMediumScreen ? 10 : 12,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Popular Badge
                if (isPopular && isAvailable)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 4 : (isMediumScreen ? 5 : 6),
                        vertical: isSmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.deepOrange[400]!],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: isSmallScreen ? 8 : (isMediumScreen ? 9 : 10),
                          ),
                          if (!isSmallScreen) ...[
                            SizedBox(width: 2),
                            Text(
                              'Hot',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMediumScreen ? 7 : 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

// Service Details Bottom Sheet
  void _showServiceDetails(Map<String, dynamic> service) {
    print('Opening service details for: ${service['title']}'); // Debug

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (service['color'] as Color).withOpacity(0.2),
                                (service['color'] as Color).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            service['icon'],
                            size: 40,
                            color: service['color'],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['title'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    '${service['rating']} (2.5k reviews)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Description
                    Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      service['description'] +
                          '. Our certified professionals will reach your location and provide ' +
                          'quick and reliable service. All work is guaranteed with 100% satisfaction.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Service Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.access_time,
                            'ETA',
                            service['eta'],
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.verified_user,
                            'Verified',
                            'Professionals',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.support_agent,
                            '24/7',
                            'Support',
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.workspace_premium,
                            'Quality',
                            'Guaranteed',
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // What's Included
                    Text(
                      'What\'s Included',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildIncludedItem('Professional service by certified technicians'),
                    _buildIncludedItem('Free diagnosis and assessment'),
                    _buildIncludedItem('Quality parts and materials'),
                    _buildIncludedItem('30-day service warranty'),
                    _buildIncludedItem('Real-time tracking and updates'),
                    SizedBox(height: 24),

                    // Book Now Button - THIS IS THE KEY PART
                    ElevatedButton(
                      onPressed: () {
                        print('Book button pressed for: ${service['title']}'); // Debug
                        Navigator.pop(context); // Close the bottom sheet

                        // Navigate to SOS Request Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SOSRequestScreen(
                              preselectedService: service['title'],
                              isFromQuickService: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: service['color'],
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: (service['color'] as Color).withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Book ${service['title']} Service',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIncludedItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 14),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.blue[50]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -8),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedNavIndex,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: (index) {
            setState(() => _selectedNavIndex = index);
            HapticFeedback.lightImpact();

            switch (index) {
              case 0: break;
              case 1: Navigator.pushNamed(context, AppRoutes.tracking); break;
              case 2: Navigator.pushNamed(context, AppRoutes.payment); break;
              case 3: Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); break;
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Navigation'),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportFAB() {
    return FloatingActionButton(
      onPressed: _showSupportOptions,
      backgroundColor: Colors.green,
      child: Icon(Icons.support_agent, color: Colors.white, size: 28),
    );
  }

  LinearGradient _getGradientForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return LinearGradient(colors: [Colors.red[700]!, Colors.red[500]!]);
      case RoadSafetyLevel.moderate:
        return LinearGradient(colors: [Colors.orange[700]!, Colors.orange[500]!]);
      default:
        return LinearGradient(colors: [Colors.blue[700]!, Colors.blue[500]!]);
    }
  }

  LinearGradient _getSOSGradient(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return LinearGradient(colors: [Colors.red[800]!, Colors.red[600]!]);
      case RoadSafetyLevel.moderate:
        return LinearGradient(colors: [Colors.orange[700]!, Colors.red[600]!]);
      default:
        return LinearGradient(colors: [Colors.red[600]!, Colors.red[400]!]);
    }
  }

  Color _getSafetyColor(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return Colors.red;
      case RoadSafetyLevel.moderate: return Colors.orange;
      default: return Colors.green;
    }
  }

  String _getSafetyLevelText(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return 'DANGER';
      case RoadSafetyLevel.moderate: return 'CAUTION';
      default: return 'SAFE';
    }
  }

  String _getSafetyMessage(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return 'DANGEROUS road conditions. Avoid travel if possible.';
      case RoadSafetyLevel.moderate:
        return 'Moderate weather risks. Drive carefully.';
      default:
        return 'Good conditions for travel.';
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  void _activateEmergencySOS() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SOSRequestScreen(
          isFromQuickService: true,
        ),
      ),
    );
  }

  void _findNearbyProviders() {
    Navigator.pushNamed(context, AppRoutes.findGarage);
  }

  void _requestService(String serviceType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SOSRequestScreen(
          preselectedService: serviceType,
          isFromQuickService: true,
        ),
      ),
    );
  }

  void _editMedicalProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.medical_information, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Medical Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  children: [
                    ListTile(
                      leading: Icon(Icons.bloodtype, color: Colors.red),
                      title: Text('Blood Type'),
                      subtitle: Text(medicalProfile['bloodType']),
                      trailing: Icon(Icons.edit, size: 18),
                    ),
                    ListTile(
                      leading: Icon(Icons.warning, color: Colors.orange),
                      title: Text('Allergies'),
                      subtitle: Text((medicalProfile['allergies'] as List).join(', ')),
                      trailing: Icon(Icons.edit, size: 18),
                    ),
                    ListTile(
                      leading: Icon(Icons.local_hospital, color: Colors.blue),
                      title: Text('Medical Conditions'),
                      subtitle: Text((medicalProfile['conditions'] as List).join(', ')),
                      trailing: Icon(Icons.edit, size: 18),
                    ),
                    ListTile(
                      leading: Icon(Icons.medication, color: Colors.green),
                      title: Text('Current Medications'),
                      subtitle: Text((medicalProfile['medications'] as List).join(', ')),
                      trailing: Icon(Icons.edit, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _planRoute() {
    setState(() {
      hasPlannedRoute = true;
      plannedRoute = {
        'from': 'Prayagraj',
        'to': 'Delhi',
        'distance': '634 km',
        'time': '10h 30m',
        'safetyScore': 'Good',
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Route planned with safety assessment'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _manageEmergencyContacts() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.contacts, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Opening emergency contacts management...'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _viewInsuranceDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.shield, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Opening insurance details...'),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _fileClaim() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Opening claim filing form...'),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSupportOptions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.support_agent, color: Colors.green, size: 48),
              SizedBox(height: 16),
              Text(
                'Need Help?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.call, color: Colors.blue),
                title: Text('Call Support'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.green),
                title: Text('Live Chat'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.mail, color: Colors.orange),
                title: Text('Email Us'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Opening notifications...'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();

    try {
      await ref.read(weatherNotifierProvider.notifier).getCurrentLocationWeather();

      setState(() {
        //_heartRate = 70 + (DateTime.now().second % 10);
       // _lastHealthUpdate = DateTime.now();
        _loyaltyPoints += 10;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Dashboard refreshed successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Refresh failed. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }
}