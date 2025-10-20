import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

/// Provider's interface for handling anonymous emergency video calls
class ProviderEmergencyVideoScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final Map<String, dynamic> emergencyData;

  const ProviderEmergencyVideoScreen({
    Key? key,
    required this.sessionId,
    required this.emergencyData,
  }) : super(key: key);

  @override
  ConsumerState<ProviderEmergencyVideoScreen> createState() =>
      _ProviderEmergencyVideoScreenState();
}

class _ProviderEmergencyVideoScreenState
    extends ConsumerState<ProviderEmergencyVideoScreen> {
  bool _videoEnabled = true;
  bool _audioEnabled = true;
  bool _isConnected = false;
  bool _isConnecting = true;
  String _connectionStatus = 'Connecting...';

  static const videoPlatform = MethodChannel('com.margmitra.app/video');

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  Future<void> _initializeVideoCall() async {
    try {
      setState(() {
        _isConnecting = true;
        _connectionStatus = 'Initializing video call...';
      });

      await videoPlatform.invokeMethod('providerJoinCall', {
        'sessionId': widget.sessionId,
        'emergencyData': widget.emergencyData,
      });

      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _connectionStatus = 'Connected';
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _connectionStatus = 'Connection failed';
      });
      _showErrorDialog('Failed to connect: $e');
    }
  }

  Future<void> _toggleVideo() async {
    try {
      setState(() => _videoEnabled = !_videoEnabled);
      await videoPlatform.invokeMethod('toggleVideo', {
        'enabled': _videoEnabled,
      });
    } catch (e) {
      print('Toggle video error: $e');
    }
  }

  Future<void> _toggleAudio() async {
    try {
      setState(() => _audioEnabled = !_audioEnabled);
      await videoPlatform.invokeMethod('toggleAudio', {
        'enabled': _audioEnabled,
      });
    } catch (e) {
      print('Toggle audio error: $e');
    }
  }

  Future<void> _endCall() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Video Call?'),
        content: const Text(
          'Are you sure you want to end this emergency video call?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Call'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await videoPlatform.invokeMethod('endCall', {
          'sessionId': widget.sessionId,
        });
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorDialog('Failed to end call: $e');
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openNavigation() async {
    final location = widget.emergencyData['location'];
    if (location != null) {
      try {
        await videoPlatform.invokeMethod('openNavigation', {
          'latitude': location['latitude'],
          'longitude': location['longitude'],
        });
      } catch (e) {
        _showErrorDialog('Failed to open navigation: $e');
      }
    }
  }

  Future<void> _sendQuickMessage(String message) async {
    try {
      await videoPlatform.invokeMethod('sendMessage', {
        'sessionId': widget.sessionId,
        'message': message,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent: $message'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Send message error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.emergencyData['location'];
    final contactInfo = widget.emergencyData['contactInfo'];
    final weatherContext = widget.emergencyData['weatherContext'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Display Area
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: _isConnecting
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _connectionStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : _isConnected
                  ? Center(
                child: Text(
                  'Video Call Active',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Video Unavailable',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Info Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.emergency, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'EMERGENCY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _connectionStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      contactInfo?['name'] ?? 'Anonymous User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (contactInfo?['phone'] != null)
                      Text(
                        contactInfo!['phone'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Emergency Info Panel (Expandable)
            Positioned(
              right: 16,
              top: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildInfoButton(
                    icon: Icons.location_on,
                    label: 'Navigate',
                    color: Colors.blue,
                    onTap: _openNavigation,
                  ),
                  const SizedBox(height: 8),
                  if (weatherContext != null)
                    _buildInfoButton(
                      icon: Icons.cloud,
                      label: '${weatherContext['temperature']}°C',
                      color: Colors.orange,
                      onTap: () => _showWeatherInfo(weatherContext),
                    ),
                  const SizedBox(height: 8),
                  _buildInfoButton(
                    icon: Icons.info_outline,
                    label: 'Details',
                    color: Colors.purple,
                    onTap: _showEmergencyDetails,
                  ),
                ],
              ),
            ),

            // Quick Message Buttons
            Positioned(
              left: 16,
              right: 16,
              bottom: 140,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickMessageButton(
                      'On my way',
                      Icons.directions_car,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickMessageButton(
                      '5 mins away',
                      Icons.schedule,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickMessageButton(
                      'Stay safe',
                      Icons.security,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickMessageButton(
                      'Help is coming',
                      Icons.support_agent,
                    ),
                  ],
                ),
              ),
            ),

            // Control Buttons
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: _audioEnabled ? Icons.mic : Icons.mic_off,
                      label: 'Mic',
                      isActive: _audioEnabled,
                      onTap: _toggleAudio,
                    ),
                    _buildControlButton(
                      icon: _videoEnabled ? Icons.videocam : Icons.videocam_off,
                      label: 'Video',
                      isActive: _videoEnabled,
                      onTap: _toggleVideo,
                    ),
                    _buildControlButton(
                      icon: Icons.call_end,
                      label: 'End',
                      isActive: true,
                      onTap: _endCall,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMessageButton(String message, IconData icon) {
    return GestureDetector(
      onTap: () => _sendQuickMessage(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? (isActive ? Colors.white : Colors.grey);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? buttonColor.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: buttonColor,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: buttonColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: buttonColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showWeatherInfo(Map<String, dynamic> weatherContext) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: Colors.orange[700], size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Weather Conditions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildWeatherRow(
              'Condition',
              weatherContext['description'] ?? 'Unknown',
              Icons.wb_sunny,
            ),
            _buildWeatherRow(
              'Temperature',
              '${weatherContext['temperature']}°C',
              Icons.thermostat,
            ),
            _buildWeatherRow(
              'Visibility',
              '${weatherContext['visibility']} m',
              Icons.visibility,
            ),
            _buildWeatherRow(
              'Wind Speed',
              '${weatherContext['windSpeed']} km/h',
              Icons.air,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDetails() {
    final location = widget.emergencyData['location'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Text(
                'Emergency Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailSection(
                'Session Information',
                [
                  _buildDetailRow('Session ID', widget.sessionId),
                  _buildDetailRow(
                    'Time',
                    widget.emergencyData['timestamp'] ?? 'Unknown',
                  ),
                  _buildDetailRow(
                    'Type',
                    widget.emergencyData['emergencyType'] ?? 'Unknown',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                'Location',
                [
                  _buildDetailRow(
                    'Coordinates',
                    '${location['latitude']}, ${location['longitude']}',
                  ),
                  _buildDetailRow(
                    'Accuracy',
                    '${location['accuracy']} meters',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                'Contact Information',
                [
                  _buildDetailRow(
                    'Name',
                    widget.emergencyData['contactInfo']?['name'] ?? 'Not provided',
                  ),
                  _buildDetailRow(
                    'Phone',
                    widget.emergencyData['contactInfo']?['phone'] ?? 'Not provided',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openNavigation,
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate to Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}