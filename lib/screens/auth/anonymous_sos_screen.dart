import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/enhanced_sos_service.dart';
import '../../providers/weather_provider.dart';

class AnonymousSosScreen extends ConsumerStatefulWidget {
  const AnonymousSosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnonymousSosScreen> createState() => _AnonymousSosScreenState();
}

class _AnonymousSosScreenState extends ConsumerState<AnonymousSosScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _requestVideoCall = true;
  bool _providingContact = false;
  bool _isProcessing = false;
  String? _sessionId;
  String? _videoCallToken;

  late AnimationController _pulseController;
  late AnimationController _emergencyController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _pulseController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  //   helper methods
  double _getResponsiveSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return size * 0.85; // Small phones
    if (width < 400) return size * 0.95; // Medium phones
    return size; // Large phones and tablets
  }

  double _getResponsiveFontSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return size * 0.9;
    if (width < 400) return size * 0.95;
    return size;
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return const EdgeInsets.all(12);
    if (width < 400) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  Future<void> _triggerEmergencySos() async {
    HapticFeedback.heavyImpact();
    _emergencyController.forward();

    setState(() => _isProcessing = true);

    try {
      final sosService = ref.read(enhancedSosServiceProvider);
      final weatherState = ref.read(weatherNotifierProvider);

      final result = await sosService.triggerAnonymousSos(
        phoneNumber: _providingContact ? _phoneController.text : null,
        name: _providingContact ? _nameController.text : null,
        requestVideoCall: _requestVideoCall,
        weather: weatherState.currentWeather,
      );

      setState(() {
        _sessionId = result['sessionId'];
        _videoCallToken = result['videoCallToken'];
        _isProcessing = false;
      });

      if (mounted) {
        _showEmergencyActiveDialog(result);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showEmergencyActiveDialog(Map<String, dynamic> result) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width < 360 ? 12 : 16,
            vertical: 24,
          ),
          content: Container(
            width: size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: size.height * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red[700]!, Colors.red[900]!],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(_getResponsiveSize(context, 20)),
                    child: Column(
                      children: [
                        Container(
                          width: _getResponsiveSize(context, 70),
                          height: _getResponsiveSize(context, 70),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emergency,
                            size: _getResponsiveSize(context, 42),
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: _getResponsiveSize(context, 12)),
                        Text(
                          'Emergency Alert Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getResponsiveFontSize(context, 22),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: _getResponsiveSize(context, 6)),
                        Text(
                          'Session ID: ${result['sessionId']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: _getResponsiveFontSize(context, 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Cards
                  Container(
                    padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildStatusCard(
                          icon: Icons.location_on,
                          title: 'Location Tracking',
                          subtitle: 'Real-time location shared',
                          color: Colors.blue,
                          isActive: true,
                        ),
                        SizedBox(height: _getResponsiveSize(context, 10)),
                        _buildStatusCard(
                          icon: Icons.local_police,
                          title: 'Emergency Services',
                          subtitle: 'Notified (112)',
                          color: Colors.orange,
                          isActive: true,
                        ),
                        SizedBox(height: _getResponsiveSize(context, 10)),
                        _buildStatusCard(
                          icon: Icons.handyman,
                          title: 'Service Providers',
                          subtitle: result['nearbyProvidersAlerted']
                              ? 'Nearby providers alerted'
                              : 'Searching...',
                          color: Colors.green,
                          isActive: result['nearbyProvidersAlerted'],
                        ),
                        if (_requestVideoCall && result['videoCallToken'] != null) ...[
                          SizedBox(height: _getResponsiveSize(context, 10)),
                          _buildStatusCard(
                            icon: Icons.video_call,
                            title: 'Video Call Ready',
                            subtitle: 'Tap to connect when provider joins',
                            color: Colors.purple,
                            isActive: true,
                          ),
                        ],

                        SizedBox(height: _getResponsiveSize(context, 16)),

                        // ETA Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getResponsiveSize(context, 14),
                            vertical: _getResponsiveSize(context, 7),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: _getResponsiveSize(context, 16),
                                color: Colors.green[700],
                              ),
                              SizedBox(width: _getResponsiveSize(context, 6)),
                              Flexible(
                                child: Text(
                                  'ETA: ${result['estimatedResponseTime']}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getResponsiveFontSize(context, 13),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: _getResponsiveSize(context, 16)),

                        // Action Buttons
                        if (_requestVideoCall && result['videoCallToken'] != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _joinVideoCall(
                                result['sessionId'],
                                result['videoCallToken'],
                              ),
                              icon: Icon(
                                Icons.video_call,
                                size: _getResponsiveSize(context, 20),
                              ),
                              label: Text(
                                'Join Video Call',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 14),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: _getResponsiveSize(context, 14),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: _getResponsiveSize(context, 10)),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _viewTrackingMap(result['sessionId']),
                            icon: Icon(
                              Icons.map,
                              size: _getResponsiveSize(context, 20),
                            ),
                            label: Text(
                              'View Live Tracking',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 14),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                              side: BorderSide(color: Colors.blue[300]!),
                              padding: EdgeInsets.symmetric(
                                vertical: _getResponsiveSize(context, 14),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: _getResponsiveSize(context, 10)),

                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () => _cancelEmergency(result['sessionId']),
                            icon: Icon(
                              Icons.close,
                              size: _getResponsiveSize(context, 20),
                            ),
                            label: Text(
                              'Cancel Emergency',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 14),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                vertical: _getResponsiveSize(context, 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveSize(context, 10)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _getResponsiveSize(context, 36),
            height: _getResponsiveSize(context, 36),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: _getResponsiveSize(context, 20),
            ),
          ),
          SizedBox(width: _getResponsiveSize(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _getResponsiveFontSize(context, 13),
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 11),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              width: _getResponsiveSize(context, 7),
              height: _getResponsiveSize(context, 7),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _joinVideoCall(String sessionId, String token) async {
    try {
      final sosService = ref.read(enhancedSosServiceProvider);
      await sosService.joinVideoCall(sessionId, token);

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/video-call',
          arguments: {
            'sessionId': sessionId,
            'token': token,
            'isAnonymous': true,
          },
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to join video call: $e');
    }
  }

  void _viewTrackingMap(String sessionId) {
    Navigator.pushNamed(
      context,
      '/emergency-tracking',
      arguments: {'sessionId': sessionId},
    );
  }

  void _cancelEmergency(String sessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Emergency?',
          style: TextStyle(fontSize: _getResponsiveFontSize(context, 18)),
        ),
        content: Text(
          'Are you sure you want to cancel the emergency alert? '
              'This will stop all notifications and tracking.',
          style: TextStyle(fontSize: _getResponsiveFontSize(context, 14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No, Keep Active',
              style: TextStyle(fontSize: _getResponsiveFontSize(context, 14)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Yes, Cancel',
              style: TextStyle(fontSize: _getResponsiveFontSize(context, 14)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final sosService = ref.read(enhancedSosServiceProvider);
        await sosService.cancelAnonymousSos(sessionId);

        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency alert cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to cancel: $e');
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: _getResponsiveSize(context, 22),
            ),
            SizedBox(width: _getResponsiveSize(context, 8)),
            Text(
              'Error',
              style: TextStyle(fontSize: _getResponsiveFontSize(context, 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error,
              style: TextStyle(fontSize: _getResponsiveFontSize(context, 14)),
            ),
            SizedBox(height: _getResponsiveSize(context, 12)),
            Container(
              padding: EdgeInsets.all(_getResponsiveSize(context, 10)),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.orange[700],
                    size: _getResponsiveSize(context, 20),
                  ),
                  SizedBox(width: _getResponsiveSize(context, 8)),
                  Expanded(
                    child: Text(
                      'Call 112 for immediate help',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                        fontSize: _getResponsiveFontSize(context, 13),
                      ),
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
            child: Text(
              'OK',
              style: TextStyle(fontSize: _getResponsiveFontSize(context, 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveSize(context, 14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsiveSize(context, 9)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: _getResponsiveSize(context, 22),
            ),
          ),
          SizedBox(width: _getResponsiveSize(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _getResponsiveFontSize(context, 13),
                  ),
                ),
                SizedBox(height: _getResponsiveSize(context, 3)),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: _getResponsiveFontSize(context, 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final size = MediaQuery.of(context).size;
    final padding = _getResponsivePadding(context);

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        title: Text(
          'Emergency Assistance',
          style: TextStyle(fontSize: _getResponsiveFontSize(context, 18)),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Header
              Container(
                padding: EdgeInsets.all(_getResponsiveSize(context, 20)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[600]!, Colors.red[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: Container(
                            width: _getResponsiveSize(context, 70),
                            height: _getResponsiveSize(context, 70),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 20 * _pulseController.value,
                                  spreadRadius: 10 * _pulseController.value,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.emergency,
                              size: _getResponsiveSize(context, 42),
                              color: Colors.red[700],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: _getResponsiveSize(context, 12)),
                    Text(
                      'Get Help Without Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getResponsiveFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: _getResponsiveSize(context, 6)),
                    Text(
                      'Emergency services will be notified immediately',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: _getResponsiveFontSize(context, 13),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: _getResponsiveSize(context, 20)),

              // Optional Contact Information
              Container(
                padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: _getResponsiveSize(context, 20),
                        ),
                        SizedBox(width: _getResponsiveSize(context, 8)),
                        Expanded(
                          child: Text(
                            'Optional: Provide your contact info',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _getResponsiveFontSize(context, 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSize(context, 6)),
                    Text(
                      'This helps us send you updates and tracking links',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: _getResponsiveFontSize(context, 12),
                      ),
                    ),
                    SizedBox(height: _getResponsiveSize(context, 12)),
                    SwitchListTile(
                      value: _providingContact,
                      onChanged: (value) {
                        setState(() => _providingContact = value);
                      },
                      title: Text(
                        'I want to provide my details',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.blue[700],
                    ),
                    if (_providingContact) ...[
                      SizedBox(height: _getResponsiveSize(context, 12)),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          labelStyle: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 13),
                          ),
                          hintText: 'John Doe',
                          hintStyle: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 13),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            size: _getResponsiveSize(context, 20),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: _getResponsiveSize(context, 12),
                            vertical: _getResponsiveSize(context, 14),
                          ),
                        ),
                      ),
                      SizedBox(height: _getResponsiveSize(context, 10)),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 13),
                          ),
                          hintText: '8268444498',
                          hintStyle: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 13),
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            size: _getResponsiveSize(context, 20),
                          ),
                          prefix: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '+91',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize: _getResponsiveFontSize(context, 14),
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: _getResponsiveSize(context, 12),
                            vertical: _getResponsiveSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: _getResponsiveSize(context, 16)),

              // Video Call Option
              Container(
                padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_getResponsiveSize(context, 7)),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.video_call,
                            color: Colors.purple[700],
                            size: _getResponsiveSize(context, 22),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSize(context, 10)),
                        Expanded(
                          child: Text(
                            'Video Call Assistance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _getResponsiveFontSize(context, 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSize(context, 10)),
                    Text(
                      'Connect via video call with service provider to show your exact situation and get better help',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: _getResponsiveFontSize(context, 12),
                      ),
                    ),
                    SizedBox(height: _getResponsiveSize(context, 10)),
                    SwitchListTile(
                      value: _requestVideoCall,
                      onChanged: (value) {
                        setState(() => _requestVideoCall = value);
                      },
                      title: Text(
                        'Enable video call support',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                      subtitle: Text(
                        'Recommended for faster help',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 12),
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.purple[700],
                    ),
                  ],
                ),
              ),

              SizedBox(height: _getResponsiveSize(context, 16)),

              // Weather Warning (if applicable)
              if (weatherState.currentWeather != null &&
                  weatherState.getRoadSafety() != RoadSafetyLevel.safe)
                Container(
                  padding: EdgeInsets.all(_getResponsiveSize(context, 12)),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange[700],
                        size: _getResponsiveSize(context, 22),
                      ),
                      SizedBox(width: _getResponsiveSize(context, 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weather Alert',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                                fontSize: _getResponsiveFontSize(context, 13),
                              ),
                            ),
                            Text(
                              '${weatherState.currentWeather!.description} - Drive carefully',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: _getResponsiveFontSize(context, 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (weatherState.currentWeather != null &&
                  weatherState.getRoadSafety() != RoadSafetyLevel.safe)
                SizedBox(height: _getResponsiveSize(context, 16)),

              // Main Emergency Button
              AnimatedBuilder(
                animation: _emergencyController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_emergencyController.value * 0.05),
                    child: Container(
                      height: _getResponsiveSize(context, 120),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[600]!, Colors.red[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isProcessing ? null : _triggerEmergencySos,
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: _isProcessing
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                                SizedBox(height: _getResponsiveSize(context, 10)),
                                Text(
                                  'Activating Emergency...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _getResponsiveFontSize(context, 15),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emergency_rounded,
                                  size: _getResponsiveSize(context, 42),
                                  color: Colors.white,
                                ),
                                SizedBox(height: _getResponsiveSize(context, 10)),
                                Text(
                                  'EMERGENCY SOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _getResponsiveFontSize(context, 22),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: _getResponsiveSize(context, 4)),
                                Text(
                                  'Tap to activate',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: _getResponsiveFontSize(context, 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: _getResponsiveSize(context, 16)),

              // Information Cards
              _buildInfoCard(
                icon: Icons.security,
                title: 'Safe & Secure',
                description: 'Your privacy is protected. Emergency data is encrypted.',
                color: Colors.green,
              ),
              SizedBox(height: _getResponsiveSize(context, 10)),
              _buildInfoCard(
                icon: Icons.location_on,
                title: 'Real-time Tracking',
                description: 'Service providers will see your live location for faster help.',
                color: Colors.blue,
              ),
              SizedBox(height: _getResponsiveSize(context, 10)),
              _buildInfoCard(
                icon: Icons.support_agent,
                title: 'Multi-Agency Response',
                description: 'Emergency services (112) and nearby providers notified.',
                color: Colors.orange,
              ),

              SizedBox(height: _getResponsiveSize(context, 20)),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: _getResponsiveFontSize(context, 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}