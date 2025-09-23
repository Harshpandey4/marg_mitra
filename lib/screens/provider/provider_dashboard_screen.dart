import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import 'earnings_screen.dart';
import 'service_history_screen.dart';
import 'service_management_screen.dart';
import 'job_management_screen.dart';
import 'navigation_screen.dart';
import 'provider_profile_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  @override
  _ProviderDashboardScreenState createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen>
    with TickerProviderStateMixin {
  bool isOnline = false;
  bool hasNewNotifications = true;
  bool inService = false;
  int _currentIndex = 0;
  bool _isRefreshing = false;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _statusColorAnimation;

  // Provider stats
  Map<String, dynamic> todayStats = {
    'responseTime': '3.2',
    'successRate': '95',
    'rating': '4.8',
    'completedJobs': 12,
    'totalEarnings': 2850.0,
    'onlineHours': 6.5,
  };

  // Active job data
  Map<String, dynamic>? activeJob;

  // Recent notifications
  List<Map<String, dynamic>> recentNotifications = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _statusColorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.green,
    ).animate(_animationController);

    _initializeData();
  }

  void _initializeData() {
    // Initialize sample active job when in service
    activeJob = {
      'id': 'JOB_${DateTime.now().millisecondsSinceEpoch}',
      'customerName': 'Rahul Sharma',
      'customerAddress': 'Prayagraj Highway, Near Morbi Road',
      'customerPhone': '+91 9876543210',
      'serviceType': 'Vehicle Repair',
      'issueDescription': 'Engine overheating problem',
      'estimatedTime': '45 min',
      'distance': '2.3 km',
      'status': 'assigned',
    };

    // Initialize notifications
    _generateSampleNotifications();
  }

  void _generateSampleNotifications() {
    final now = DateTime.now();
    recentNotifications = [
      {
        'id': '1',
        'title': 'New Job Request',
        'subtitle': 'Vehicle repair needed at Prayagraj Highway',
        'icon': Icons.build,
        'color': Colors.blue,
        'timestamp': now.subtract(Duration(minutes: 2)),
        'isRead': false,
        'type': 'job_request',
      },
      {
        'id': '2',
        'title': 'Payment Received',
        'subtitle': '₹850 credited to your account',
        'icon': Icons.payment,
        'color': Colors.green,
        'timestamp': now.subtract(Duration(minutes: 15)),
        'isRead': false,
        'type': 'payment',
      },
      {
        'id': '3',
        'title': 'Service Completed',
        'subtitle': 'Fuel delivery completed successfully',
        'icon': Icons.check_circle,
        'color': Colors.orange,
        'timestamp': now.subtract(Duration(hours: 1)),
        'isRead': true,
        'type': 'completion',
      },
      {
        'id': '4',
        'title': 'Customer Rating',
        'subtitle': 'You received 5 stars from Amit Kumar',
        'icon': Icons.star,
        'color': Colors.amber,
        'timestamp': now.subtract(Duration(hours: 2)),
        'isRead': true,
        'type': 'rating',
      },
      {
        'id': '5',
        'title': 'Profile Update',
        'subtitle': 'Your service area has been updated',
        'icon': Icons.location_on,
        'color': Colors.purple,
        'timestamp': now.subtract(Duration(hours: 4)),
        'isRead': true,
        'type': 'update',
      },
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleOnlineStatus() {
    setState(() {
      isOnline = !isOnline;
      if (isOnline) {
        inService = true;
        _animationController.forward();
      } else {
        inService = false;
        _animationController.reverse();
      }
    });

    HapticFeedback.mediumImpact();

    // Show status change feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOnline ? Icons.check_circle : Icons.offline_bolt,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              isOnline
                  ? 'You are now online and ready to accept jobs'
                  : 'You are now offline',
            ),
          ],
        ),
        backgroundColor: isOnline ? Colors.green : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
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

      // Update badge
      hasNewNotifications = recentNotifications.any((n) => !n['isRead']);
    });
  }

  void _simulateJobCompletion() {
    setState(() {
      inService = false;
      activeJob = null;
      todayStats['completedJobs'] += 1;
      todayStats['totalEarnings'] += 450.0;
    });

    // Add completion notification
    final now = DateTime.now();
    setState(() {
      recentNotifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'Job Completed',
        'subtitle': 'Payment of ₹450 received successfully',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'timestamp': now,
        'isRead': false,
        'type': 'completion',
      });
      hasNewNotifications = true;
    });

    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Job completed successfully! ₹450 earned'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _buildOnlineStatusCard(),
              SizedBox(height: 16),
              if (inService && activeJob != null) ...[
                _buildActiveJobCard(),
                SizedBox(height: 16),
              ],
              _buildQuickActionsGrid(),
              SizedBox(height: 16),
              _buildPerformanceMetrics(),
              SizedBox(height: 16),
              _buildEarningsOverview(),
              SizedBox(height: 16),
              _buildRecentNotifications(),
              SizedBox(height: 80), // Extra padding for bottom navigation
            ],
          ),
        ),
      ),
      floatingActionButton: _buildEmergencyFAB(),
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
            'Service Provider Dashboard',
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
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
          ),
          onPressed: () => _navigateToProfile(),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOnlineStatusCard() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [Colors.green, Colors.green.shade700]
              : [Colors.grey, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? Colors.green : Colors.grey).withOpacity(0.4),
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
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isOnline ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: isOnline ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ] : null,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 12),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Switch.adaptive(
                value: isOnline,
                onChanged: (value) => _toggleOnlineStatus(),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.3),
                inactiveThumbColor: Colors.white.withOpacity(0.8),
                inactiveTrackColor: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          if (isOnline) ...[
            SizedBox(height: 16),
            Row(
              children: [
                _buildStatusInfo('Service Radius', '15 km', Icons.radar),
                SizedBox(width: 20),
                _buildStatusInfo('Online Time', '${todayStats['onlineHours']}h', Icons.access_time),
              ],
            ),
            SizedBox(height: 8),
            Text(
              inService
                  ? 'Currently serving a customer'
                  : 'Ready to accept new requests',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            SizedBox(height: 12),
            Text(
              'Go online to start receiving job requests',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveJobCard() {
    if (activeJob == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
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
              Icon(Icons.work, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Active Job',
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
            '${activeJob!['serviceType']} - ${activeJob!['issueDescription']}',
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
                  activeJob!['customerName'],
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
                  activeJob!['customerAddress'],
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
                'Est. ${activeJob!['estimatedTime']} • ${activeJob!['distance']} away',
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
                  onPressed: () => _navigateToNavigationFromActiveJob(),
                  icon: Icon(Icons.navigation, size: 18),
                  label: Text('Navigate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
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
                  onPressed: () => _simulateJobCompletion(),
                  icon: Icon(Icons.check, size: 18),
                  label: Text('Complete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildQuickActionCard(
                'Job\nManagement',
                Icons.work_outline,
                Colors.blue,
                    () => _navigateToJobManagement(),
              ),
              _buildQuickActionCard(
                'Service\nHistory',
                Icons.history,
                Colors.purple,
                    () => _navigateToServiceHistory(),
              ),
              _buildQuickActionCard(
                'Earnings',
                Icons.account_balance_wallet,
                Colors.green,
                    () => _navigateToEarnings(),
              ),
              _buildQuickActionCard(
                'Settings',
                Icons.settings,
                Colors.orange,
                    () => _navigateToServiceManagement(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
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
            'Today\'s Performance',
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
                child: _buildMetricItem(
                  'Response Time',
                  '${todayStats['responseTime']} min',
                  Icons.timer,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Success Rate',
                  '${todayStats['successRate']}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Rating',
                  '${todayStats['rating']}/5',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Jobs Done',
                  '${todayStats['completedJobs']}',
                  Icons.task_alt,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsOverview() {
    return Container(
      padding: EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Today\'s Earnings',
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
            '₹${todayStats['totalEarnings'].toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'From ${todayStats['completedJobs']} completed jobs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToEarnings(),
            child: Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
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
    );
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
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

  Widget _buildEmergencyFAB() {
    return FloatingActionButton(
      onPressed: _showEmergencyOptions,
      backgroundColor: Colors.red,
      child: Icon(Icons.emergency, color: Colors.white, size: 28),
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
          currentIndex: _currentIndex,
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
              _currentIndex = index;
            });

            HapticFeedback.lightImpact();

            switch (index) {
              case 0:
              // Already on dashboard
                break;
              case 1:
                _navigateToNavigationScreen();
                break;
              case 2:
                _navigateToProfile();
                break;
            }
          },
          items: [
            _buildBottomNavItem(
              icon: Icons.home_rounded,
              activeIcon: Icons.dashboard,
              label: 'Home',
              index: 0,
            ),
            _buildBottomNavItem(
              icon: Icons.navigation_rounded,
              activeIcon: Icons.navigation,
              label: 'Navigation',
              index: 1,
            ),
            _buildBottomNavItem(
              icon: Icons.account_circle_outlined,
              activeIcon: Icons.account_circle,
              label: 'Profile',
              index: 2,
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
    final isSelected = _currentIndex == index;

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

  // Navigation Methods
  void _navigateToServiceManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServiceManagementScreen()),
    );
  }

  void _navigateToJobManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobManagementScreen()),
    );
  }

  void _navigateToNavigationFromActiveJob() {
    if (activeJob != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(
            customerName: activeJob!['customerName'],
            customerAddress: activeJob!['customerAddress'],
            customerPhone: activeJob!['customerPhone'],
            serviceType: activeJob!['serviceType'],
          ),
        ),
      );
    }
  }

  void _navigateToEarnings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EarningsScreen()),
    );
  }

  void _navigateToServiceHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServiceHistoryScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProviderProfileScreen()),
    );
  }

  void _navigateToNavigationScreen() {
    if (inService && activeJob != null) {
      // Navigate with active job data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(
            customerName: activeJob!['customerName'],
            customerAddress: activeJob!['customerAddress'],
            customerPhone: activeJob!['customerPhone'],
            serviceType: activeJob!['serviceType'],
          ),
        ),
      );
    } else if (isOnline) {
      _showNavigationOptions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Please go online to use navigation'),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showNavigationOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
            // Drag handle
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
                    Icons.navigation,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Navigation Options',
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
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNavigationOption(
                    icon: Icons.work,
                    iconColor: Colors.blue,
                    title: 'Recent Job Location',
                    subtitle: 'Navigate to last job location',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRecentJobLocation();
                    },
                  ),
                  _buildNavigationOption(
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    title: 'Custom Destination',
                    subtitle: 'Enter address to navigate',
                    onTap: () {
                      Navigator.pop(context);
                      _showCustomDestinationDialog();
                    },
                  ),
                  _buildNavigationOption(
                    icon: Icons.home,
                    iconColor: Colors.orange,
                    title: 'Navigate Home',
                    subtitle: 'Return to base location',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToHome();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _navigateToRecentJobLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          customerName: 'Previous Customer',
          customerAddress: 'Last Service Location',
          customerPhone: '+91 9876543210',
          serviceType: 'Previous Service',
        ),
      ),
    );
  }

  void _showCustomDestinationDialog() {
    TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Destination'),
        content: TextField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: 'Enter address or location',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (addressController.text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationScreen(
                      customerName: 'Custom Destination',
                      customerAddress: addressController.text,
                      customerPhone: '',
                      serviceType: 'Navigation',
                    ),
                  ),
                );
              }
            },
            child: Text('Navigate'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          customerName: 'Home Base',
          customerAddress: 'Service Center Location',
          customerPhone: '',
          serviceType: 'Return Home',
        ),
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
              // Drag handle
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

  void _markAllNotificationsRead() {
    setState(() {
      for (var notification in recentNotifications) {
        notification['isRead'] = true;
      }
      hasNewNotifications = false;
    });
  }

  void _showEmergencyOptions() {
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
                Colors.red.shade50,
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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.emergency,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Emergency Assistance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Get immediate help when you need it',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              _buildEmergencyOption(
                icon: Icons.local_police,
                iconColor: Colors.blue,
                title: 'Police',
                subtitle: 'Call 100',
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.heavyImpact();
                  // TODO: Implement actual emergency call
                },
              ),
              SizedBox(height: 12),
              _buildEmergencyOption(
                icon: Icons.local_hospital,
                iconColor: Colors.red,
                title: 'Ambulance',
                subtitle: 'Call 108',
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.heavyImpact();
                  // TODO: Implement actual emergency call
                },
              ),
              SizedBox(height: 12),
              _buildEmergencyOption(
                icon: Icons.support_agent,
                iconColor: Colors.green,
                title: 'Support',
                subtitle: 'Contact Marg Mitra',
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to support screen
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

  Widget _buildEmergencyOption({
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

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(Duration(seconds: 2));

      // Simulate data refresh
      setState(() {
        todayStats['responseTime'] = (2.8 + (0.8 * (DateTime.now().millisecond % 1000) / 1000)).toStringAsFixed(1);
        todayStats['successRate'] = '${94 + (DateTime.now().millisecond % 6)}';
        // Add a new notification
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
}