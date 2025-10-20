import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({Key? key}) : super(key: key);

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // Loading states
  bool _isLoading = false;

  // Form controllers for settings
  final _workingHoursController = TextEditingController();
  final _serviceRadiusController = TextEditingController();
  final _baseRateController = TextEditingController();

  // Service status with proper initialization
  final Map<String, bool> _serviceStatus = {
    'vehicle_repair': true,
    'e_charging_service': true,
    'medical_emergency': true,
    'auto_parts': false,
    'accident_support': true,
    'fuel_delivery': true,
    'towing_service': true,
    'roadside_assistance': true,
    'emergency_locksmith': false,
  };

  final Map<String, int> _servicePriority = {
    'vehicle_repair': 1,
    'e_charging_service': 2,
    'medical_emergency': 5,
    'auto_parts': 2,
    'accident_support': 5,
    'fuel_delivery': 3,
    'towing_service': 4,
    'roadside_assistance': 3,
    'emergency_locksmith': 2,
  };

  // Service configuration data
  final Map<String, Map<String, dynamic>> _serviceConfig = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _initializeServiceConfig();
    _workingHoursController.text = '6:00 AM - 10:00 PM';
    _serviceRadiusController.text = '15';
    _baseRateController.text = '500';
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
  }

  void _initializeServiceConfig() {
    for (String serviceKey in _serviceStatus.keys) {
      _serviceConfig[serviceKey] = {
        'baseRate': 500.0,
        'emergencyRate': 750.0,
        'responseTime': '15-30 minutes',
        'serviceRadius': 15.0,
        'workingHours': '8:00 AM - 8:00 PM',
        'isEmergencyAvailable': true,
      };
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController?.dispose();
    _workingHoursController.dispose();
    _serviceRadiusController.dispose();
    _baseRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: _buildResponsiveAppBar(context),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _fadeAnimation != null
            ? FadeTransition(
          opacity: _fadeAnimation!,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMyServicesTab(isTablet),
              _buildSpecializationsTab(isTablet),
              _buildServiceSettingsTab(isTablet),
            ],
          ),
        )
            : TabBarView(
          controller: _tabController,
          children: [
            _buildMyServicesTab(isTablet),
            _buildSpecializationsTab(isTablet),
            _buildServiceSettingsTab(isTablet),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(BuildContext context) {
    return AppBar(
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Service Management Settings',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.yellow[300],
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.yellow[700],
        indicatorWeight: 5,
        labelColor: Colors.yellow[300],
        unselectedLabelColor: Colors.blue[100],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(icon: Icon(Icons.build_circle, size: 25), text: 'Services'),
          Tab(icon: Icon(Icons.stars, size: 25), text: 'Skills'),
          Tab(icon: Icon(Icons.settings, size: 25), text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMyServicesTab(bool isTablet) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() => _isLoading = false);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceStatusCard(isTablet),
            const SizedBox(height: 20),
            _buildActiveServicesSection(isTablet),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusCard(bool isTablet) {
    final activeServices = _serviceStatus.values.where((status) => status).length;
    final totalServices = _serviceStatus.length;
    final progress = activeServices / totalServices;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isTablet ? 200 : 160),
      child: Card(
        elevation: 8,
        shadowColor: AppTheme.primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.5),
                Colors.yellow[300]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          child: Text(
                            '$activeServices/$totalServices',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 42 : 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${(progress * 100).toInt()}% Services Active',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.build_circle,
                        color: Colors.yellow[500],
                        size: isTablet ? 36 : 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withOpacity(0.3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.yellow.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.red[300], size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tap on services below to enable/disable',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 14 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveServicesSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Services',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your service offerings and availability',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        const SizedBox(height: 16),
        ..._serviceStatus.keys.map((serviceKey) {
          return _buildServiceCard(
            _getServiceTitle(serviceKey),
            _getServiceDescription(serviceKey),
            _getServiceIcon(serviceKey),
            _getServiceColor(serviceKey),
            serviceKey,
            emergencyLevel: _servicePriority[serviceKey] ?? 1,
            isTablet: isTablet,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildServiceCard(
      String title,
      String description,
      IconData icon,
      Color color,
      String serviceKey, {
        required int emergencyLevel,
        required bool isTablet,
      }) {
    final isActive = _serviceStatus[serviceKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isActive ? 8 : 3,
        shadowColor: isActive ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(color: color.withOpacity(0.4), width: 2)
                : Border.all(color: Colors.grey.withOpacity(0.1)),
            gradient: isActive
                ? LinearGradient(
              colors: [Colors.yellow[100]!, color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Icon(icon, color: color, size: isTablet ? 28 : 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? color : Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPriorityBadge(emergencyLevel, isTablet),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: isTablet ? 15 : 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Transform.scale(
                      scale: isTablet ? 1.2 : 1.0,
                      child: Switch.adaptive(
                        value: isActive,
                        activeColor: color,
                        activeTrackColor: color.withOpacity(0.3),
                        inactiveThumbColor: Colors.red[300],
                        inactiveTrackColor: Colors.white,
                        onChanged: (value) => _toggleService(serviceKey, value),
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Service is active and visible to customers',
                            style: TextStyle(
                              color: color,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showServiceDetails(title, serviceKey),
                          icon: const Icon(Icons.settings, size: 16),
                          label: Text(
                            'Configure',
                            style: TextStyle(fontSize: isTablet ? 14 : 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: color,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(int level, bool isTablet) {
    final badgeData = _getPriorityBadgeData(level);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: badgeData['color'].withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeData['color'].withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeData['icon'], color: badgeData['color'], size: isTablet ? 12 : 10),
          const SizedBox(width: 4),
          Text(
            badgeData['text'],
            style: TextStyle(
              color: badgeData['color'],
              fontSize: isTablet ? 11 : 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPriorityBadgeData(int level) {
    switch (level) {
      case 5:
        return {'text': 'CRITICAL', 'color': Colors.red, 'icon': Icons.priority_high};
      case 4:
        return {'text': 'HIGH', 'color': Colors.orange, 'icon': Icons.trending_up};
      case 3:
        return {'text': 'MEDIUM', 'color': AppTheme.warningColor, 'icon': Icons.remove};
      case 2:
        return {'text': 'LOW', 'color': Colors.blue, 'icon': Icons.trending_down};
      default:
        return {'text': 'BASIC', 'color': Colors.grey, 'icon': Icons.circle};
    }
  }

  Widget _buildSpecializationsTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Specializations',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your expertise and certifications to attract more customers',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          const SizedBox(height: 20),
          _buildSpecializationSection(
            'Vehicle Expertise',
            [
              'Engine Diagnostics',
              'Brake Systems',
              'Electrical Systems',
              'AC/Cooling',
              'Transmission',
              'Suspension',
            ],
            Icons.build,
            AppTheme.primaryColor,
            isTablet,
          ),
          _buildSpecializationSection(
            'E-Charging Services',
            [
              'Fast Charging Stations',
              'Level 2 AC Charging',
              'DC Fast Charging',
              'Mobile Charging Units',
              'Battery Health Check',
              'Charging Port Repair',
              'Smart Charging Solutions',
            ],
            Icons.electric_bolt,
            Colors.green,
            isTablet,
          ),
          _buildSpecializationSection(
            'Medical Certifications',
            [
              'First Aid Certified',
              'CPR Trained',
              'Emergency Response',
              'Trauma Care',
            ],
            Icons.medical_services,
            Colors.red,
            isTablet,
          ),
          _buildSpecializationSection(
            'Equipment & Tools',
            [
              'Professional Tool Kit',
              'Diagnostic Scanner',
              'Jump Starter',
              'Air Compressor',
              'Welding Equipment',
              'Medical Kit',
            ],
            Icons.inventory,
            Colors.orange,
            isTablet,
          ),
          _buildSpecializationSection(
            'Vehicle Types',
            [
              'Cars',
              'Motorcycles',
              'Trucks',
              'Commercial Vehicles',
              'Electric Vehicles',
            ],
            Icons.directions_car,
            Colors.blue,
            isTablet,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSpecializationSection(
      String title,
      List<String> items,
      IconData icon,
      Color color,
      bool isTablet,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: isTablet ? 24 : 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items.map((item) => _buildSkillChip(item, color, isTablet)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill, Color color, bool isTablet) {
    return FilterChip(
      label: Text(
        skill,
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: true,
      onSelected: (bool selected) {
        HapticFeedback.lightImpact();
        // Add functionality to toggle skill selection
      },
      selectedColor: color.withOpacity(0.15),
      backgroundColor: Colors.grey[100],
      checkmarkColor: color,
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 8 : 4,
      ),
    );
  }

  Widget _buildServiceSettingsTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection(
            'Service Availability',
            Icons.schedule,
            AppTheme.primaryColor,
            [
              _buildSettingItem(
                'Working Hours',
                _workingHoursController.text,
                Icons.access_time,
                    () => _showWorkingHoursDialog(),
                isTablet,
              ),
              _buildSettingItem(
                'Service Radius',
                '${_serviceRadiusController.text} km',
                Icons.location_on,
                    () => _showServiceRadiusDialog(),
                isTablet,
              ),
              _buildSettingItem(
                'Emergency Services',
                '24/7 Available',
                Icons.emergency,
                    () => _showEmergencySettingsDialog(),
                isTablet,
              ),
            ],
            isTablet,
          ),
          _buildSettingsSection(
            'Pricing & Rates',
            Icons.attach_money,
            Colors.green,
            [
              _buildSettingItem(
                'Base Service Rate',
                '₹${_baseRateController.text}/hour',
                Icons.currency_rupee,
                    () => _showPricingDialog(),
                isTablet,
              ),
              _buildSettingItem(
                'Emergency Charges',
                'After hours pricing',
                Icons.schedule,
                    () => _showEmergencyPricingDialog(),
                isTablet,
              ),
            ],
            isTablet,
          ),
          _buildSettingsSection(
            'Communication',
            Icons.chat,
            Colors.orange,
            [
              _buildSettingItem(
                'Auto-Accept Requests',
                'Disabled',
                Icons.auto_awesome,
                    () => _showAutoAcceptDialog(),
                isTablet,
              ),
              _buildSettingItem(
                'Response Time',
                '5 minutes',
                Icons.timer,
                    () => _showResponseTimeDialog(),
                isTablet,
              ),
              _buildSettingItem(
                'Customer Notifications',
                'Enabled',
                Icons.notifications,
                    () => _showNotificationSettings(),
                isTablet,
              ),
            ],
            isTablet,
          ),
          _buildSettingsSection(
            'Safety & Security',
            Icons.security,
            Colors.red,
            [
              _buildSettingItem(
                'Emergency Contacts',
                '3 contacts added',
                Icons.contact_emergency,
                    () => _showEmergencyContactsDialog(),
                isTablet,
              ),
              _buildSettingItem(
                'Live Location Sharing',
                'Enabled during service',
                Icons.share_location,
                    () => _showLocationSharingDialog(),
                isTablet,
              ),
            ],
            isTablet,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
      String title,
      IconData sectionIcon,
      Color sectionColor,
      List<Widget> items,
      bool isTablet,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: sectionColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  sectionIcon,
                  color: sectionColor,
                  size: isTablet ? 20 : 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 4,
          shadowColor: sectionColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, sectionColor.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: items),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingItem(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      bool isTablet,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(isTablet ? 10 : 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: isTablet ? 22 : 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: isTablet ? 14 : 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isTablet ? 18 : 16,
        color: Colors.grey[400],
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  // Helper methods for service data
  String _getServiceTitle(String serviceKey) {
    const titles = {
      'vehicle_repair': 'Vehicle Repair',
      'e_charging_service': 'E-Charging Service',
      'medical_emergency': 'Medical Emergency',
      'auto_parts': 'Auto Parts Delivery',
      'accident_support': 'Accident Support',
      'fuel_delivery': 'Fuel Delivery',
      'towing_service': 'Towing Service',
      'roadside_assistance': 'Roadside Assistance',
      'emergency_locksmith': 'Emergency Locksmith',
    };
    return titles[serviceKey] ?? serviceKey.replaceAll('_', ' ').toUpperCase();
  }

  String _getServiceDescription(String serviceKey) {
    const descriptions = {
      'vehicle_repair': 'Engine problems, brake issues, electrical faults',
      'e_charging_service': 'Fast charging, battery diagnostics, charging port maintenance',
      'medical_emergency': 'First aid, medical assistance, ambulance support',
      'auto_parts': 'Spare parts, batteries, oils, filters supply',
      'accident_support': 'Accident assistance, police liaison, documentation',
      'fuel_delivery': 'Petrol, diesel, emergency fuel supply',
      'towing_service': 'Vehicle towing, breakdown recovery',
      'roadside_assistance': 'Flat tire, jump start, lockout service',
      'emergency_locksmith': 'Car lockout, key replacement, lock repair',
    };
    return descriptions[serviceKey] ?? 'Professional service with certified technicians';
  }

  IconData _getServiceIcon(String serviceKey) {
    const icons = {
      'vehicle_repair': Icons.build,
      'e_charging_service': Icons.ev_station,
      'medical_emergency': Icons.medical_services,
      'auto_parts': Icons.inventory,
      'accident_support': Icons.warning,
      'fuel_delivery': Icons.local_gas_station,
      'towing_service': Icons.local_shipping,
      'roadside_assistance': Icons.support_agent,
      'emergency_locksmith': Icons.lock,
    };
    return icons[serviceKey] ?? Icons.build;
  }

  Color _getServiceColor(String serviceKey) {
    const colors = {
      'vehicle_repair': AppTheme.primaryColor,
      'e_charging_service': Colors.green,
      'medical_emergency': Colors.red,
      'auto_parts': Colors.orange,
      'accident_support': Colors.redAccent,
      'fuel_delivery': Colors.green,
      'towing_service': Colors.blue,
      'roadside_assistance': AppTheme.warningColor,
      'emergency_locksmith': Colors.purple,
    };
    return colors[serviceKey] ?? AppTheme.primaryColor;
  }

  // Action methods
  void _toggleService(String serviceKey, bool value) {
    HapticFeedback.lightImpact();
    setState(() {
      _serviceStatus[serviceKey] = value;
    });

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ? 'Service activated successfully' : 'Service deactivated',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: value ? AppTheme.successColor : Colors.orange[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      action: value
          ? null
          : SnackBarAction(
        label: 'Undo',
        textColor: Colors.white,
        onPressed: () => _toggleService(serviceKey, true),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showServiceDetails(String title, String serviceKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getServiceColor(serviceKey).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getServiceIcon(serviceKey),
                              color: _getServiceColor(serviceKey),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$title Configuration',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  'Customize your service settings',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildConfigurationSection('Service Details', [
                        _buildConfigItem('Base Rate', '₹${_serviceConfig[serviceKey]?['baseRate']?.toInt() ?? 500}/hour', Icons.currency_rupee),
                        _buildConfigItem('Emergency Rate', '₹${_serviceConfig[serviceKey]?['emergencyRate']?.toInt() ?? 750}/hour', Icons.emergency),
                        _buildConfigItem('Response Time', _serviceConfig[serviceKey]?['responseTime'] ?? '15-30 minutes', Icons.timer),
                        _buildConfigItem('Service Area', '${_serviceConfig[serviceKey]?['serviceRadius']?.toInt() ?? 15} km radius', Icons.location_on),
                      ]),
                      const SizedBox(height: 24),
                      _buildConfigurationSection('Availability', [
                        _buildConfigItem('Working Hours', _serviceConfig[serviceKey]?['workingHours'] ?? '8:00 AM - 8:00 PM', Icons.schedule),
                        _buildConfigItem('Weekend Hours', 'Sat-Sun: 9AM-6PM', Icons.weekend),
                        _buildConfigItem('Emergency Hours', _serviceConfig[serviceKey]?['isEmergencyAvailable'] == true ? '24/7 Available' : 'Not Available', Icons.access_time),
                      ]),
                      const SizedBox(height: 24),
                      _buildConfigurationSection('Requirements', [
                        _buildConfigItem('Equipment', 'Professional tools required', Icons.build_circle),
                        _buildConfigItem('Experience', 'Minimum 2 years', Icons.star),
                        _buildConfigItem('Certification', 'Valid license needed', Icons.verified),
                      ]),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showServiceConfigDialog(title, serviceKey);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Settings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getServiceColor(serviceKey),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildConfigItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods with   functionality
  void _showServiceConfigDialog(String title, String serviceKey) {
    final baseRateController = TextEditingController(
        text: _serviceConfig[serviceKey]?['baseRate']?.toString() ?? '500'
    );
    final emergencyRateController = TextEditingController(
        text: _serviceConfig[serviceKey]?['emergencyRate']?.toString() ?? '750'
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_getServiceIcon(serviceKey), color: _getServiceColor(serviceKey)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Configure $title',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: baseRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base Rate (₹/hour)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emergencyRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Emergency Rate (₹/hour)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              baseRateController.dispose();
              emergencyRateController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _serviceConfig[serviceKey]?['baseRate'] = double.tryParse(baseRateController.text) ?? 500.0;
                _serviceConfig[serviceKey]?['emergencyRate'] = double.tryParse(emergencyRateController.text) ?? 750.0;
              });

              baseRateController.dispose();
              emergencyRateController.dispose();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Service configuration updated successfully'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getServiceColor(serviceKey),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWorkingHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Working Hours'),
        content: TextField(
          controller: _workingHoursController,
          decoration: const InputDecoration(
            labelText: 'Working Hours',
            hintText: 'e.g., 6:00 AM - 10:00 PM',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
              _showSuccessSnackBar('Working hours updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showServiceRadiusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Service Radius'),
        content: TextField(
          controller: _serviceRadiusController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Service Radius (km)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
              _showSuccessSnackBar('Service radius updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPricingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Base Rate'),
        content: TextField(
          controller: _baseRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Base Rate (₹/hour)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
              _showSuccessSnackBar('Base rate updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEmergencySettingsDialog() {
    _showGenericDialog('Emergency Services', 'Configure emergency service settings', Icons.emergency, Colors.red);
  }

  void _showEmergencyPricingDialog() {
    _showGenericDialog('Emergency Pricing', 'Configure after-hours pricing', Icons.schedule, Colors.orange);
  }

  void _showAutoAcceptDialog() {
    _showGenericDialog('Auto-Accept', 'Configure automatic request acceptance', Icons.auto_awesome, Colors.blue);
  }

  void _showResponseTimeDialog() {
    _showGenericDialog('Response Time', 'Set your expected response time', Icons.timer, Colors.green);
  }

  void _showNotificationSettings() {
    _showGenericDialog('Notifications', 'Manage notification preferences', Icons.notifications, Colors.purple);
  }

  void _showEmergencyContactsDialog() {
    _showGenericDialog('Emergency Contacts', 'Manage emergency contact list', Icons.contact_emergency, Colors.red);
  }

  void _showLocationSharingDialog() {
    _showGenericDialog('Location Sharing', 'Configure location sharing settings', Icons.share_location, Colors.blue);
  }

  void _showGenericDialog(String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This feature will be implemented in the next update.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}