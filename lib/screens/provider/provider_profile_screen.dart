import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';

class DocumentStatus {
  final bool isUploaded;
  final String status;
  final Color color;

  DocumentStatus(this.isUploaded, this.status, this.color);
}

class ProviderProfileScreen extends StatefulWidget {
  @override
  _ProviderProfileScreenState createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isEditing = false;
  bool _isAvailable = true;
  bool _isLoading = false;
  double _serviceRadius = 15.0;
  String _selectedLanguage = 'Hindi';
  String _profileImagePath = '';

  AnimationController? _animationController;
  AnimationController? _pulseController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _pulseAnimation;

  // Verification states
  Map<String, DocumentStatus> _documents = {
    'Driving License': DocumentStatus(false, 'Not Uploaded', Colors.grey),
    'Aadhaar Card': DocumentStatus(false, 'Not Uploaded', Colors.grey),
    'Service Certificate': DocumentStatus(false, 'Not Uploaded', Colors.grey),
    'Insurance Papers': DocumentStatus(false, 'Not Uploaded', Colors.grey),
    'Police Verification': DocumentStatus(false, 'Not Uploaded', Colors.grey),
    'PAN Card': DocumentStatus(false, 'Not Uploaded', Colors.grey),
  };

  List<String> _services = [];
  List<String> _availableServices = [
    'Vehicle Repair', 'Towing', 'Battery Jump Start', 'Tire Change',
    'Emergency Fuel', 'Breakdown Service', 'Car Wash', 'Oil Change',
    'Engine Diagnostics', 'Brake Service'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    // Start loading and animations
    _loadProviderData();
    _animationController!.forward();
    _pulseController!.repeat(reverse: true);
  }

  Future<void> _loadProviderData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _nameController.text = 'Rajesh Kumar Patel';
        _phoneController.text = '+91 9876543210';
        _emailController.text = 'rajesh.kumar@roadside.com';
        _addressController.text = 'Shop No. 15, Highway Service Center, Near City Mall, Rajkot, Gujarat - 360001';
        _experienceController.text = '8';
        _bioController.text = 'Experienced multi-service provider with 8+ years in automotive industry. Specialized in emergency roadside assistance and vehicle repairs. Available 24/7 for all your automotive needs.';
        _services = ['Vehicle Repair', 'Towing', 'Battery Jump Start', 'Emergency Fuel'];

        // Sample verified documents
        _documents['Aadhaar Card'] = DocumentStatus(true, 'Verified', Colors.green);
        _documents['Driving License'] = DocumentStatus(true, 'Verified', Colors.green);
        _documents['PAN Card'] = DocumentStatus(true, 'Verified', Colors.green);
        _documents['Insurance Papers'] = DocumentStatus(true, 'Under Review', Colors.orange);
        _documents['Service Certificate'] = DocumentStatus(false, 'Pending Upload', Colors.red);
        _documents['Police Verification'] = DocumentStatus(true, 'Verified', Colors.green);

        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    await _loadProviderData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading ? _buildLoadingScreen() : _buildMainContent(isTablet),
      floatingActionButton: !_isLoading && _isEditing ? _buildSaveFAB() : null,
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: Text('Provider Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation ?? AlwaysStoppedAnimation(1.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading Profile...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait while we fetch your information',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation ?? AlwaysStoppedAnimation(1.0),
      child: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: _refreshProfile,
              color: AppTheme.primaryColor,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24.0 : 16.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (isTablet)
                        _buildTabletLayout()
                      else
                        _buildMobileLayout(),
                      SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildPersonalInfoSection(),
              SizedBox(height: 20),
              _buildServiceInfoSection(),
              SizedBox(height: 20),
              _buildServicesSection(),
            ],
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildVerificationSection(),
              SizedBox(height: 20),
              _buildPerformanceSection(),
              SizedBox(height: 20),
              _buildSettingsSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildPersonalInfoSection(),
        SizedBox(height: 20),
        _buildServiceInfoSection(),
        SizedBox(height: 20),
        _buildServicesSection(),
        SizedBox(height: 20),
        _buildVerificationSection(),
        SizedBox(height: 20),
        _buildPerformanceSection(),
        SizedBox(height: 20),
        _buildSettingsSection(),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: Icon(
              _isEditing ? Icons.close : Icons.edit,
              key: ValueKey(_isEditing),
              color: Colors.white,
            ),
          ),
          onPressed: () {
            setState(() => _isEditing = !_isEditing);
            HapticFeedback.selectionClick();
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'share':
                _shareProfile();
                break;
              case 'export':
                _exportProfile();
                break;
              case 'verify':
                _startVerificationProcess();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 18),
                  SizedBox(width: 12),
                  Text('Share Profile'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 18),
                  SizedBox(width: 12),
                  Text('Export Data'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'verify',
              child: Row(
                children: [
                  Icon(Icons.verified_user, size: 18),
                  SizedBox(width: 12),
                  Text('Start Verification'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                _buildProfileAvatar(),
                SizedBox(height: 16),
                Text(
                  _nameController.text.isEmpty ? 'Provider Name' : _nameController.text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Multi-Service Provider',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusChip('Verified', Icons.verified, Colors.green),
                    SizedBox(width: 8),
                    _buildStatusChip('Premium', Icons.star, Colors.orange),
                    SizedBox(width: 8),
                    _buildStatusChip(
                      _isAvailable ? 'Available' : 'Offline',
                      _isAvailable ? Icons.online_prediction : Icons.offline_pin,
                      _isAvailable ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: _profileImagePath.isNotEmpty
                ? NetworkImage(_profileImagePath) // In real app, use proper image loading
                : null,
            child: _profileImagePath.isEmpty
                ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                : null,
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _updateProfilePhoto,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            enabled: _isEditing,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Name is required';
              if (value!.length < 2) return 'Name too short';
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            enabled: false,
            keyboardType: TextInputType.phone,
            suffix: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Service Address',
            icon: Icons.location_on,
            enabled: _isEditing,
            maxLines: 3,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Address is required';
              if (value!.length < 10) return 'Address too short';
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _bioController,
            label: 'Bio/Description',
            icon: Icons.description,
            enabled: _isEditing,
            maxLines: 4,
            validator: (value) {
              if (value != null && value.length > 300) {
                return 'Bio must be less than 300 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoSection() {
    return _buildSectionCard(
      title: 'Service Information',
      icon: Icons.build,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _experienceController,
                  label: 'Experience (Years)',
                  icon: Icons.work,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final years = int.tryParse(value!);
                    if (years == null) return 'Invalid number';
                    if (years < 0 || years > 50) return 'Invalid experience';
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(child: _buildLanguageDropdown()),
            ],
          ),
          SizedBox(height: 20),
          _buildServiceRadiusSlider(),
          SizedBox(height: 16),
          _buildAvailabilityToggle(),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _isEditing ? AppTheme.primaryColor : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: _isEditing ? Colors.white : Colors.grey[50],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLanguage,
        decoration: InputDecoration(
          labelText: 'Primary Language',
          prefixIcon: Icon(Icons.language, color: Colors.grey[600], size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        items: ['Hindi', 'Gujarati', 'English', 'Marathi', 'Punjabi'].map((lang) {
          return DropdownMenuItem(
            value: lang,
            child: Text(lang, style: TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: _isEditing ? (value) {
          setState(() => _selectedLanguage = value!);
          HapticFeedback.selectionClick();
        } : null,
      ),
    );
  }

  Widget _buildServiceRadiusSlider() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.my_location, color: AppTheme.primaryColor),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Service Coverage Radius',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_serviceRadius.round()} km',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.3),
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.2),
              valueIndicatorColor: AppTheme.primaryColor,
              valueIndicatorTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _serviceRadius,
              min: 5.0,
              max: 50.0,
              divisions: 9,
              label: '${_serviceRadius.round()} km radius',
              onChanged: _isEditing ? (value) {
                setState(() => _serviceRadius = value);
                HapticFeedback.selectionClick();
              } : null,
            ),
          ),
          Text(
            'You can serve customers within ${_serviceRadius.round()} kilometers',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isAvailable
              ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
              : [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAvailable ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_isAvailable ? Colors.green : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isAvailable ? Icons.online_prediction : Icons.offline_pin,
              color: _isAvailable ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Availability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isAvailable
                      ? 'You are currently accepting new service requests'
                      : 'You are currently offline and not accepting requests',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() => _isAvailable = value);
              HapticFeedback.selectionClick();
              _showSnackBar(
                value ? 'You are now available for service' : 'You are now offline',
                value ? Colors.green : Colors.orange,
              );
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return _buildSectionCard(
      title: 'Service Categories',
      icon: Icons.category,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select services you provide:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!_isEditing)
                Text(
                  '${_services.length} selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableServices.map((service) {
              final isSelected = _services.contains(service);
              return GestureDetector(
                onTap: _isEditing ? () {
                  setState(() {
                    if (isSelected) {
                      _services.remove(service);
                    } else {
                      _services.add(service);
                    }
                  });
                  HapticFeedback.lightImpact();
                } : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isSelected ? null : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(Icons.check_circle, size: 16, color: AppTheme.primaryColor),
                      if (isSelected) SizedBox(width: 4),
                      Text(
                        service,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_services.isEmpty && !_isEditing)
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please select at least one service category',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
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

  Widget _buildVerificationSection() {
    final verifiedCount = _documents.values.where((doc) => doc.status == 'Verified').length;
    final totalCount = _documents.length;
    final completionPercentage = (verifiedCount / totalCount * 100).round();

    return _buildSectionCard(
      title: 'Documents & Verification',
      icon: Icons.verified_user,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Verification Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    Text(
                      '$completionPercentage%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 6,
                ),
                SizedBox(height: 8),
                Text(
                  '$verifiedCount of $totalCount documents verified',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ..._documents.entries.map((entry) {
            return _buildDocumentItem(entry.key, entry.value);
          }).toList(),
          SizedBox(height: 16),
          if (_isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _uploadDocuments,
                icon: Icon(Icons.upload_file),
                label: Text('Upload New Documents'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          if (completionPercentage < 100)
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete verification to access premium features',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  Widget _buildDocumentItem(String title, DocumentStatus status) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: status.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            status.isUploaded ? Icons.check_circle : Icons.upload_file,
            color: status.color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: status.isUploaded
            ? Text(
          'Last updated: 2 months ago',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.status,
                style: TextStyle(
                  fontSize: 11,
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (status.isUploaded) ...[
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.visibility, size: 18, color: Colors.grey[600]),
                onPressed: () => _viewDocument(title),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ],
        ),
        onTap: () => _handleDocumentTap(title, status),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return _buildSectionCard(
      title: 'Performance Metrics',
      icon: Icons.analytics,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total Jobs', '248', Icons.work, Colors.blue)),
              SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Success Rate', '96%', Icons.check_circle, Colors.green)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Avg Rating', '4.8/5', Icons.star, Colors.orange)),
              SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Response Time', '2.5 min', Icons.timer, Colors.purple)),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: Colors.green, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Excellent Performance!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'You are in the top 10% of providers in your area',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildSectionCard(
      title: 'Account Settings',
      icon: Icons.settings,
      child: Column(
        children: [
          _buildSettingItem(
            'Notification Settings',
            'Manage push notifications and alerts',
            Icons.notifications,
                () => _openNotificationSettings(),
          ),
          _buildSettingItem(
            'Payment Settings',
            'Bank account and payment preferences',
            Icons.payment,
                () => _openPaymentSettings(),
          ),
          _buildSettingItem(
            'Privacy Settings',
            'Manage your privacy and data preferences',
            Icons.privacy_tip,
                () => _openPrivacySettings(),
          ),
          _buildSettingItem(
            'Help & Support',
            'Get help or contact our support team',
            Icons.help,
                () => _openHelpSupport(),
          ),
          _buildSettingItem(
            'Rate Our App',
            'Help us improve with your feedback',
            Icons.star_rate,
                () => _rateApp(),
          ),
          Divider(height: 32, color: Colors.grey[300]),
          _buildSettingItem(
            'Logout',
            'Sign out from your account',
            Icons.logout,
                () => _logout(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : Colors.grey[400])!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.grey[600],
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSaveFAB() {
    return FloatingActionButton.extended(
      onPressed: _saveProfile,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      icon: Icon(Icons.save),
      label: Text('Save Profile'),
      elevation: 4,
    );
  }

  // Action Methods
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_services.isEmpty) {
        _showSnackBar('Please select at least one service category', Colors.orange);
        return;
      }

      setState(() {
        _isEditing = false;
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(Duration(milliseconds: 2000));

      if (mounted) {
        setState(() => _isLoading = false);

        _showSnackBar('Profile updated successfully!', Colors.green);
        HapticFeedback.lightImpact();
      }
    } else {
      _showSnackBar('Please fix the errors before saving', Colors.red);
    }
  }

  void _updateProfilePhoto() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Update Profile Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildPhotoOption(
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    subtitle: 'Use camera to take a new photo',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                  SizedBox(height: 12),
                  _buildPhotoOption(
                    icon: Icons.photo_library,
                    title: 'Choose from Gallery',
                    subtitle: 'Select from your photo gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                    },
                  ),
                  if (_profileImagePath.isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildPhotoOption(
                      icon: Icons.delete,
                      title: 'Remove Photo',
                      subtitle: 'Remove current profile photo',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _profileImagePath = '');
                        _showSnackBar('Profile photo removed', Colors.orange);
                      },
                      isDestructive: true,
                    ),
                  ],
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : Colors.grey[400])!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.grey[600],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
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
      ),
    );
  }

  void _takePhoto() async {
    // In a real app, implement image picker from camera
    _showSnackBar('Camera feature will be implemented with image_picker package', Colors.blue);
  }

  void _pickFromGallery() async {
    // In a real app, implement image picker from gallery
    _showSnackBar('Gallery feature will be implemented with image_picker package', Colors.blue);
  }

  void _uploadDocuments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Upload Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select document type to upload:'),
            SizedBox(height: 16),
            ..._documents.entries.where((entry) => !entry.value.isUploaded).map((entry) {
              return ListTile(
                title: Text(entry.key),
                leading: Icon(Icons.upload_file),
                onTap: () {
                  Navigator.pop(context);
                  _uploadSpecificDocument(entry.key);
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _uploadSpecificDocument(String documentName) {
    _showSnackBar('Upload feature for $documentName will be implemented', Colors.blue);
    // In real app, implement file picker and upload logic
  }

  void _viewDocument(String documentName) {
    _showSnackBar('Viewing $documentName', Colors.blue);
    // In real app, implement document viewer
  }

  void _handleDocumentTap(String title, DocumentStatus status) {
    if (status.isUploaded) {
      _viewDocument(title);
    } else if (_isEditing) {
      _uploadSpecificDocument(title);
    }
  }

  void _startVerificationProcess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.verified_user, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Start Verification'),
          ],
        ),
        content: Text(
          'Begin the verification process to unlock premium features and gain customer trust. This includes document verification and background checks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Verification process started', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Start Now'),
          ),
        ],
      ),
    );
  }

  void _shareProfile() {
    _showSnackBar('Profile sharing feature will be implemented', Colors.blue);
    // Implement share functionality
  }

  void _exportProfile() {
    _showSnackBar('Profile export feature will be implemented', Colors.blue);
    // Implement data export functionality
  }

  void _openNotificationSettings() {
    _showSnackBar('Opening notification settings...', Colors.blue);
    // Navigate to notification settings page
  }

  void _openPaymentSettings() {
    _showSnackBar('Opening payment settings...', Colors.blue);
    // Navigate to payment settings page
  }

  void _openPrivacySettings() {
    _showSnackBar('Opening privacy settings...', Colors.blue);
    // Navigate to privacy settings page
  }

  void _openHelpSupport() {
    _showSnackBar('Opening help & support...', Colors.blue);
    // Navigate to help & support page
  }

  void _rateApp() {
    _showSnackBar('Opening app store for rating...', Colors.blue);
    // Implement app rating functionality
  }

  void _logout() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              _showSnackBar('Logged out successfully', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle :
              color == Colors.red ? Icons.error :
              color == Colors.orange ? Icons.warning :
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _pulseController?.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}