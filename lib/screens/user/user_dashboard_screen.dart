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
import 'package:flutter_contacts/flutter_contacts.dart';
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
  late Animation<Color?> _statusColorAnimation;

  int _selectedNavIndex = 0;
  bool _isSOSActive = false;
  bool _isRefreshing = false;
  bool hasNewNotifications = true;
  String _userName = "Harsh";
  String _currentLocation = "Prayagraj, India";
  int _loyaltyPoints = 1250;
  bool _isDarkMode = false;

  Map<String, dynamic>? activeService;
  bool hasActiveService = false;

  // User stats
  Map<String, dynamic> userStats = {
    'totalServices': 47,
    'averageRating': 4.6,
    'totalSavings': 2350.0,
    'memberSince': 'Jan 2023',
  };

  final List<Map<String, dynamic>> _quickServices = [
    {'title': 'Towing', 'icon': Icons.local_shipping, 'color': Colors.blue, 'price': '₹299'},
    {'title': 'Battery', 'icon': Icons.battery_charging_full, 'color': Colors.green, 'price': '₹199'},
    {'title': 'Flat Tire', 'icon': Icons.tire_repair, 'color': Colors.orange, 'price': '₹149'},
    {'title': 'Fuel', 'icon': Icons.local_gas_station, 'color': Colors.red, 'price': '₹50'},
    {'title': 'Lockout', 'icon': Icons.key, 'color': Colors.purple, 'price': '₹99'},
    {'title': 'Mechanic', 'icon': Icons.build, 'color': Colors.teal, 'price': '₹199'},
  ];

  final List<Map<String, dynamic>> _recentServices = [
    {
      'id': 'SRV_001',
      'title': 'Battery Jump Start',
      'subtitle': 'Completed • 2 days ago',
      'price': '₹299',
      'status': 'completed',
      'rating': 4.8,
      'icon': Icons.battery_charging_full,
      'color': Colors.green,
      'location': 'Connaught Place',
      'providerName': 'Rajesh Kumar',
      'providerPhone': '+91 9876543210',
      'estimatedTime': '15 min',
      'timestamp': DateTime.now().subtract(Duration(days: 2)),
    },
    {
      'id': 'SRV_002',
      'title': 'Fuel Delivery',
      'subtitle': 'In Progress • Now',
      'price': '₹200',
      'status': 'ongoing',
      'rating': 0.0,
      'icon': Icons.local_gas_station,
      'color': Colors.blue,
      'location': 'India Gate',
      'providerName': 'Suresh Gupta',
      'providerPhone': '+91 9876543212',
      'estimatedTime': '25 min',
      'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
    },
    {
      'id': 'SRV_003',
      'title': 'Tire Replacement',
      'subtitle': 'Completed • 1 week ago',
      'price': '₹850',
      'status': 'completed',
      'rating': 5.0,
      'icon': Icons.tire_repair,
      'color': Colors.orange,
      'location': 'Central Delhi',
      'providerName': 'Amit Singh',
      'providerPhone': '+91 9876543213',
      'estimatedTime': '30 min',
      'timestamp': DateTime.now().subtract(Duration(days: 7)),
    },
  ];

  List<Map<String, dynamic>> recentNotifications = [];

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

    _statusColorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.green,
    ).animate(_animationController);

    _initializeActiveService();
    _generateSampleNotifications();

    // Initialize weather data with error handling
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        print('Initializing weather data...');
        await ref.read(weatherNotifierProvider.notifier).getCurrentLocationWeather();
        print('Weather initialization completed');
      } catch (e) {
        print('Weather initialization failed: $e');
      }
    });
  }

  void _generateSampleNotifications() {
    final now = DateTime.now();
    recentNotifications = [
      {
        'id': '1',
        'title': 'Service Completed',
        'subtitle': 'Battery jump start completed successfully',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'timestamp': now.subtract(Duration(hours: 2)),
        'isRead': false,
        'type': 'completion',
      },
      {
        'id': '2',
        'title': 'Provider En Route',
        'subtitle': 'Suresh is on the way to your location',
        'icon': Icons.directions_car,
        'color': Colors.blue,
        'timestamp': now.subtract(Duration(minutes: 15)),
        'isRead': false,
        'type': 'update',
      },
      {
        'id': '3',
        'title': 'Weather Alert',
        'subtitle': 'Heavy rain expected - drive carefully',
        'icon': Icons.cloud,
        'color': Colors.orange,
        'timestamp': now.subtract(Duration(minutes: 30)),
        'isRead': false,
        'type': 'weather',
      },
      {
        'id': '4',
        'title': 'Loyalty Points Earned',
        'subtitle': 'You earned 50 points from your last service',
        'icon': Icons.stars,
        'color': Colors.amber,
        'timestamp': now.subtract(Duration(hours: 5)),
        'isRead': true,
        'type': 'reward',
      },
      {
        'id': '5',
        'title': 'Special Offer',
        'subtitle': '20% off on your next fuel delivery service',
        'icon': Icons.local_offer,
        'color': Colors.orange,
        'timestamp': now.subtract(Duration(days: 1)),
        'isRead': true,
        'type': 'promotion',
      },
    ];
  }

  void _initializeActiveService() {
    final ongoingService = _recentServices.firstWhere(
          (service) => service['status'] == 'ongoing',
      orElse: () => {},
    );

    if (ongoingService.isNotEmpty) {
      setState(() {
        hasActiveService = true;
        activeService = ongoingService;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  void _markNotificationAsRead(String notificationId) {
    setState(() {
      final index = recentNotifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        recentNotifications[index]['isRead'] = true;
      }
      hasNewNotifications = recentNotifications.any((n) => !n['isRead']);
    });
  }

  void _markAllNotificationsRead() {
    setState(() {
      for (var notification in recentNotifications) {
        notification['isRead'] = true;
      }
      hasNewNotifications = false;
    });
  }

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

              // Weather Card - New Feature
              _buildWeatherCard(weatherState),
              SizedBox(height: 16),

              if (hasActiveService) ...[
                _buildActiveServiceCard(),
                SizedBox(height: 16),
              ],
              _buildQuickActionsGrid(),
              SizedBox(height: 16),

              // Enhanced SOS Card with Weather Integration
              _buildEnhancedSOSCard(weatherState),
              SizedBox(height: 16),

              _buildUserStatsCard(),
              SizedBox(height: 16),
              _buildLoyaltyCard(),
              SizedBox(height: 16),
              _buildQuickServicesSection(),
              SizedBox(height: 16),
              _buildRecentNotifications(),
              SizedBox(height: 16),
              _buildRecentServicesSection(),
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
            AppConstants.tagline,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[200],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined,
                  color: Colors.yellow[300],
                  size: 24
              ),
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
                    child: Center(
                      child: Text(
                        '${recentNotifications.where((n) => !n['isRead']).length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showNotificationsBottomSheet(),
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.yellow[300]),
          onPressed: () async {
            print('Manual weather refresh triggered');
            await ref.read(weatherNotifierProvider.notifier).getCurrentLocationWeather();
          },
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
          ),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeCard(WeatherState weatherState) {
    final weather = weatherState.currentWeather;
    final weatherDisplay = weather != null
        ? '${weather.temperature.round()}°C'
        : weatherState.isLoading ? 'Loading...' : 'No data';

    // Add debug information
    print('Weather Debug - isLoading: ${weatherState.isLoading}, weather: ${weather?.temperature}, location: ${weather?.location}');

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
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()}, $_userName!',
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
                        Expanded(
                          child: Text(
                            _currentLocation,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Member since ${userStats['memberSince']}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showWeatherDetails(),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getWeatherColor(weather).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(_getWeatherIcon(weather), color: _getWeatherColor(weather), size: 28),
                      SizedBox(height: 4),
                      Text(
                        weatherDisplay,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (weather != null)
                        Text(
                          weather.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (weatherState.error != null)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Weather Error: ${weatherState.error}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
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
            if (weatherState.isLoading) ...[
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(width: 16),
              Text('Loading weather data...'),
            ] else ...[
              Icon(Icons.error_outline, color: Colors.orange),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weather data unavailable'),
                    if (weatherState.error != null)
                      Text(
                        weatherState.error!,
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ],
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
            color: _getWeatherColor(weather).withOpacity(0.3),
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
                        'Weather & Road Conditions',
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
                    '${weather.temperature.round()}°C • ${weather.description}',
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
          if (weatherState.currentWeather?.alerts.isNotEmpty == true) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Weather Alert: ${weatherState.currentWeather!.alerts.first}',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildActiveServiceCard() {
    if (!hasActiveService || activeService == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Active Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'In Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            activeService!['title'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Provider: ${activeService!['providerName']}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  activeService!['location'],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Text(
                'Est. ${activeService!['estimatedTime']} • ${_formatTime(activeService!['timestamp'])}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openProviderChat(activeService!),
                  icon: Icon(Icons.chat, size: 18),
                  label: Text('Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToServiceTracking,
                  icon: Icon(Icons.track_changes, size: 18),
                  label: Text('Track', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final weatherState = ref.watch(weatherNotifierProvider);
    final safetyLevel = weatherState.getRoadSafety();

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 40),
            spreadRadius: 1,
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
                        safetyLevel == RoadSafetyLevel.dangerous ? 'Weather Alert' : 'Drive Safe',
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
                  safetyLevel == RoadSafetyLevel.dangerous ? Colors.red[800]! : Colors.red,
                      () => _activateEmergencySOS(),
                  isHighlighted: safetyLevel != RoadSafetyLevel.safe,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Weather\nInfo',
                  Icons.wb_cloudy,
                  _getWeatherColor(weatherState.currentWeather),
                      () => _showWeatherDetails(),
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
        padding: EdgeInsets.all(5),
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
                fontSize: 14,
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
              gradient: _getSOSGradientForSafety(safetyLevel),
              boxShadow: [
                BoxShadow(
                  color: _getSOSColorForSafety(safetyLevel).withOpacity(0.4),
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
                      Icon(_getSOSIconForSafety(safetyLevel), size: 36, color: Colors.white),
                      if (safetyLevel != RoadSafetyLevel.safe) ...[
                        SizedBox(width: 8),
                        Icon(Icons.warning, size: 24, color: Colors.white),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getSOSTitleForSafety(safetyLevel),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSOSDescriptionForSafety(safetyLevel),
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (safetyLevel == RoadSafetyLevel.dangerous) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'WEATHER PRIORITY MODE: Faster emergency response',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Use the enhanced SOS button widget
                  SosButton(),
                ],
              ),
            ),
          ),
        );
      },
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
            spreadRadius: 1,
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
                child: _buildStatItem(
                  'Services Used',
                  '${userStats['totalServices']}',
                  Icons.build,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Average Rating',
                  '${userStats['averageRating']}/5',
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Savings',
                  '₹${userStats['totalSavings'].toStringAsFixed(0)}',
                  Icons.savings,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Loyalty Points',
                  '$_loyaltyPoints',
                  Icons.stars,
                  Colors.purple,
                ),
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
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            spreadRadius: 1,
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
                  child: Text('Redeem Points', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildQuickServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.allServices),
              icon: Icon(Icons.grid_view, size: 16),
              label: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 5),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _quickServices.length,
          itemBuilder: (context, index) {
            final service = _quickServices[index];
            return _buildServiceCard(
              service['title'],
              service['icon'],
              service['color'],
              service['price'],
                  () => _requestService(service['title']),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, String price, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 54, color: color),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotifications() {
    final recentThree = recentNotifications.take(3).toList();

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
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () => _showNotificationsBottomSheet(),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...recentThree.map((notification) => _buildNotificationItem(notification)).toList(),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.grey[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead'] ? Colors.grey[200]! : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (notification['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              notification['icon'] as IconData,
              color: notification['color'] as Color,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  notification['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _formatTime(notification['timestamp'] as DateTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!notification['isRead'])
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: notification['color'] as Color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.tracking),
              icon: Icon(Icons.history, size: 16),
              label: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        ..._recentServices.take(3).map((service) => _buildRecentServiceCard(service)).toList(),
      ],
    );
  }

  Widget _buildRecentServiceCard(Map<String, dynamic> service) {
    final isOngoing = service['status'] == 'ongoing';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: isOngoing ? Border.all(color: Colors.blue.withOpacity(0.3), width: 2) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (service['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      service['subtitle'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          service['location'] as String,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service['price'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (service['status'] == 'completed')
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 2),
                        Text(
                          '${service['rating']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          if (isOngoing) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openProviderChat(service),
                    icon: Icon(Icons.chat, size: 18),
                    label: Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToServiceTracking(),
                    icon: Icon(Icons.track_changes, size: 18),
                    label: Text('Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupportFAB() {
    return FloatingActionButton(
      onPressed: _showSupportOptions,
      backgroundColor: Colors.green,
      child: Icon(Icons.support_agent, color: Colors.white, size: 28),
      elevation: 8,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.blue[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -8),
            spreadRadius: 2,
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
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          onTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });

            HapticFeedback.lightImpact();

            switch (index) {
              case 0:
              // Already on home
                break;
              case 1:
                Navigator.pushNamed(context, AppRoutes.tracking);
                break;
              case 2:
                Navigator.pushNamed(context, AppRoutes.payment);
                break;
              case 3:
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                break;
            }
          },
          items: [
            _buildBottomNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
            ),
            _buildBottomNavItem(
              icon: Icons.map_outlined,
              activeIcon: Icons.navigation,
              label: 'Navigation',
              index: 1,
            ),
            _buildBottomNavItem(
              icon: Icons.payment_outlined,
              activeIcon: Icons.payment,
              label: 'Payments',
              index: 2,
            ),
            _buildBottomNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedNavIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.15),
              AppTheme.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1.5,
          )
              : null,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Icon(
            isSelected ? activeIcon : icon,
            key: ValueKey('$icon-$isSelected'),
            size: isSelected ? 28 : 24,
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.shade400,
          ),
        ),
      ),
      label: label,
    );
  }

  // Helper methods for weather integration
  Color _getWeatherColor(WeatherData? weather) {
    if (weather == null) return Colors.grey;

    if (weather.mainCondition.toLowerCase().contains('clear')) return Colors.orange;
    if (weather.mainCondition.toLowerCase().contains('cloud')) return Colors.grey;
    if (weather.mainCondition.toLowerCase().contains('rain')) return Colors.blue;
    if (weather.mainCondition.toLowerCase().contains('snow')) return Colors.lightBlue;
    if (weather.mainCondition.toLowerCase().contains('thunderstorm')) return Colors.purple;
    return Colors.grey;
  }

  IconData _getWeatherIcon(WeatherData? weather) {
    if (weather == null) return Icons.wb_cloudy;

    switch (weather.mainCondition.toLowerCase()) {
      case 'clear': return Icons.wb_sunny;
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.grain;
      case 'drizzle': return Icons.grain;
      case 'thunderstorm': return Icons.flash_on;
      case 'snow': return Icons.ac_unit;
      case 'mist':
      case 'fog': return Icons.cloud;
      default: return Icons.wb_cloudy;
    }
  }

  LinearGradient _getGradientForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return LinearGradient(
          colors: [Colors.red[700]!, Colors.red[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RoadSafetyLevel.moderate:
        return LinearGradient(
          colors: [Colors.orange[700]!, Colors.orange[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
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

  String _getSafetyMessage(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return 'DANGEROUS road conditions detected. Avoid travel if possible.';
      case RoadSafetyLevel.moderate:
        return 'Moderate weather risks. Drive carefully and reduce speed.';
      default:
        return 'Good weather conditions for travel.';
    }
  }

  String _getSafetyLevelText(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return 'DANGER';
      case RoadSafetyLevel.moderate: return 'CAUTION';
      default: return 'SAFE';
    }
  }

  LinearGradient _getSOSGradientForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return LinearGradient(colors: [Colors.red[800]!, Colors.red[600]!]);
      case RoadSafetyLevel.moderate:
        return LinearGradient(colors: [Colors.orange[700]!, Colors.red[600]!]);
      default:
        return LinearGradient(colors: [AppTheme.emergencyColor, AppTheme.emergencyColor.withOpacity(0.8)]);
    }
  }

  Color _getSOSColorForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return Colors.red[800]!;
      case RoadSafetyLevel.moderate: return Colors.orange[700]!;
      default: return AppTheme.emergencyColor;
    }
  }

  IconData _getSOSIconForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return Icons.crisis_alert;
      case RoadSafetyLevel.moderate: return Icons.warning;
      default: return Icons.emergency;
    }
  }

  String _getSOSTitleForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return 'CRITICAL EMERGENCY SOS';
      case RoadSafetyLevel.moderate: return 'Weather Alert SOS';
      default: return 'Emergency SOS';
    }
  }

  String _getSOSDescriptionForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return 'Dangerous weather detected!\nPriority emergency response activated';
      case RoadSafetyLevel.moderate:
        return 'Weather conditions require caution\nEnhanced emergency monitoring';
      default:
        return 'Get immediate roadside assistance\nwith one tap';
    }
  }

  // Navigation and Action Methods
  void _activateEmergencySOS() {
    Navigator.pushNamed(context, AppRoutes.sosRequest);
  }

  void _findNearbyProviders() {
    Navigator.pushNamed(context, AppRoutes.findGarage);
  }

  void _viewBookings() {
    Navigator.pushNamed(context, AppRoutes.tracking);
  }

  void _requestService(String serviceType) {
    Navigator.pushNamed(
      context,
      AppRoutes.sosRequest,
      arguments: {'preselectedService': serviceType},
    );
  }

  void _openProviderChat(Map<String, dynamic> service) {
    Navigator.pushNamed(
      context,
      AppRoutes.userServiceProviderCommunication,
      arguments: {
        'providerId': 'provider_${service['providerName'].toString().replaceAll(' ', '_')}',
        'providerName': service['providerName'],
        'providerPhone': service['providerPhone'],
        'providerVehicle': 'Vehicle Info',
        'serviceType': service['title'],
        'requestId': service['id'],
        'providerRating': 4.8,
      },
    );
  }

  void _navigateToServiceTracking() {
    if (activeService != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(
            customerName: _userName,
            customerAddress: _currentLocation,
            customerPhone: '+91 9876543210',
            serviceType: activeService!['title'],
            isUserView: true,
          ),
        ),
      );
    }
  }

  void _showWeatherDetails() {
    // Navigate to dedicated weather screen or show detailed weather info
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWeatherDetailsSheet(),
    );
  }

  Widget _buildWeatherDetailsSheet() {
    final weatherState = ref.watch(weatherNotifierProvider);
    final weather = weatherState.currentWeather;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
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
                  Icon(Icons.wb_cloudy, color: AppTheme.primaryColor, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Weather Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (weather != null)
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailedWeatherInfo(weather, weatherState.getRoadSafety()),
                      SizedBox(height: 20),
                      _buildWeatherRecommendations(weatherState.getRoadSafety()),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text('Weather data not available'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedWeatherInfo(WeatherData weather, RoadSafetyLevel safetyLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _getGradientForSafety(safetyLevel),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°C',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weather.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Feels like ${weather.feelsLike.round()}°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getWeatherIcon(weather),
                size: 64,
                color: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildWeatherMetric('Wind Speed', '${weather.windSpeed.round()} m/s', Icons.air),
            _buildWeatherMetric('Humidity', '${weather.humidity}%', Icons.water_drop),
            _buildWeatherMetric('Visibility', '${(weather.visibility / 1000).toStringAsFixed(1)} km', Icons.visibility),
            _buildWeatherMetric('Cloudiness', '${weather.cloudiness}%', Icons.cloud),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherMetric(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherRecommendations(RoadSafetyLevel safetyLevel) {
    final recommendations = _getWeatherRecommendations(safetyLevel);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSafetyColor(safetyLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getSafetyColor(safetyLevel).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getSafetyIcon(safetyLevel), color: _getSafetyColor(safetyLevel)),
              SizedBox(width: 8),
              Text(
                'Safety Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(child: Text(rec, style: TextStyle(fontSize: 14))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Color _getSafetyColor(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return Colors.red;
      case RoadSafetyLevel.moderate: return Colors.orange;
      default: return Colors.green;
    }
  }

  IconData _getSafetyIcon(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous: return Icons.dangerous;
      case RoadSafetyLevel.moderate: return Icons.warning;
      default: return Icons.check_circle;
    }
  }

  List<String> _getWeatherRecommendations(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return [
          'Avoid non-essential travel if possible',
          'Reduce speed significantly and increase following distance',
          'Use headlights and hazard lights when necessary',
          'Keep emergency kit in vehicle',
          'Inform someone about your travel plans',
        ];
      case RoadSafetyLevel.moderate:
        return [
          'Reduce speed and drive cautiously',
          'Increase following distance',
          'Use headlights during low visibility',
          'Avoid sudden maneuvers',
          'Stay alert for changing conditions',
        ];
      default:
        return [
          'Maintain safe following distance',
          'Check weather updates during long trips',
          'Ensure vehicle is in good condition',
          'Keep emergency contact numbers handy',
          'Drive defensively and stay alert',
        ];
    }
  }

  void _showSupportOptions() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.support_agent,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We\'re here to assist you 24/7',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              _buildSupportOption(
                icon: Icons.call,
                iconColor: Colors.blue,
                title: 'Call Support',
                subtitle: 'Speak with our team',
                onTap: () {
                  Navigator.pop(context);
                  _callSupport();
                },
              ),
              SizedBox(height: 12),
              _buildSupportOption(
                icon: Icons.chat,
                iconColor: Colors.green,
                title: 'Live Chat',
                subtitle: 'Get instant help',
                onTap: () {
                  Navigator.pop(context);
                  _openLiveChat();
                },
              ),
              SizedBox(height: 12),
              _buildSupportOption(
                icon: Icons.mail,
                iconColor: Colors.orange,
                title: 'Email Us',
                subtitle: 'Send us a message',
                onTap: () {
                  Navigator.pop(context);
                  _sendEmail();
                },
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _callSupport() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.call, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Calling support: +91-1800-123-4567'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _openLiveChat() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.chat, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Opening live chat...'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _sendEmail() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.mail, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Opening email client...'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showNotificationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
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
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'All Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Spacer(),
                    if (hasNewNotifications)
                      TextButton(
                        onPressed: _markAllNotificationsRead,
                        child: Text('Mark all read'),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recentNotifications.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => _markNotificationAsRead(recentNotifications[index]['id']),
                    child: _buildEnhancedNotificationItem(recentNotifications[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.grey.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead'] ? Colors.grey.shade200 : Colors.blue.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (notification['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            notification['icon'] as IconData,
            color: notification['color'] as Color,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'] as String,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              notification['subtitle'] as String,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(notification['timestamp'] as DateTime),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: !notification['isRead']
            ? Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: notification['color'] as Color,
            borderRadius: BorderRadius.circular(4),
          ),
        )
            : null,
      ),
    );
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(Duration(seconds: 2));

      // Refresh weather data
      await ref.read(weatherNotifierProvider.notifier).getCurrentLocationWeather();

      setState(() {
        _loyaltyPoints += 50;
        userStats['totalServices'] = (userStats['totalServices'] as int) + 1;
        _generateSampleNotifications();
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
              Text('Failed to refresh. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
