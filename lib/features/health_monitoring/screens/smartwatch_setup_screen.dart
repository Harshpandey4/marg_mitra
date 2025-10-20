// lib/features/health_monitoring/screens/smartwatch_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_monitoring_providers.dart';
import '../widgets/smartwatch_connection_widget.dart';
import 'health_dashboard_screen.dart';

class SmartwatchSetupScreen extends ConsumerStatefulWidget {
  const SmartwatchSetupScreen({super.key});

  @override
  ConsumerState<SmartwatchSetupScreen> createState() => _SmartwatchSetupScreenState();
}

class _SmartwatchSetupScreenState extends ConsumerState<SmartwatchSetupScreen> {
  int _currentStep = 0;
  bool _permissionsGranted = false;
  bool _deviceConnected = false;

  final List<SetupStep> _steps = [
    SetupStep(
      title: 'Welcome',
      description: 'Set up your smartwatch for health monitoring',
      icon: Icons.waving_hand,
      color: Colors.blue,

    ),
    SetupStep(
      title: 'Permissions',
      description: 'Grant necessary permissions for Bluetooth and location',
      icon: Icons.verified_user,
      color: Colors.green,
    ),
    SetupStep(
      title: 'Connect Device',
      description: 'Pair your smartwatch with the app',
      icon: Icons.watch,
      color: Colors.purple,
    ),
    SetupStep(
      title: 'Configure Alerts',
      description: 'Set up health monitoring alerts',
      icon: Icons.notifications_active,
      color: Colors.orange,
    ),
    SetupStep(
      title: 'All Set!',
      description: 'Your smartwatch is ready to use',
      icon: Icons.check_circle,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(isDeviceConnectedProvider);

    // Auto-update connection status
    if (isConnected && !_deviceConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _deviceConnected = true);
        if (_currentStep == 2) {
          _nextStep();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: _currentStep > 0
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: _previousStep,
        )
            : null,
        actions: [
          if (_currentStep < _steps.length - 1)
            TextButton(
              onPressed: _skipSetup,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: _buildStepContent(),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? _steps[index].color
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPermissionsStep();
      case 2:
        return _buildConnectDeviceStep();
      case 3:
        return _buildConfigureAlertsStep();
      case 4:
        return _buildCompletionStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(Icons.watch, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 40),
          const Text(
            'Welcome to\nSmart Health Monitoring',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connect your smartwatch to enable real-time health monitoring, accident detection, and emergency alerts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildFeatureCard(
            'Real-time Monitoring',
            'Track heart rate, SpO2, stress levels',
            Icons.monitor_heart,
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'AI Accident Detection',
            'Automatic emergency response on impact',
            Icons.emergency,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Safety Alerts',
            'Get notified of abnormal health conditions',
            Icons.notifications_active,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.verified_user, size: 100, color: Colors.green[400]),
          const SizedBox(height: 32),
          const Text(
            'Grant Permissions',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We need a few permissions to connect to your smartwatch and provide health monitoring',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          _buildPermissionItem(
            'Bluetooth',
            'Required to connect to your smartwatch',
            Icons.bluetooth,
            Colors.blue,
            true,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            'Location',
            'Needed for Bluetooth scanning on Android',
            Icons.location_on,
            Colors.orange,
            true,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            'Notifications',
            'Send health alerts and emergency notifications',
            Icons.notifications,
            Colors.purple,
            true,
          ),
          const SizedBox(height: 40),
          if (!_permissionsGranted)
            ElevatedButton.icon(
              onPressed: _requestPermissions,
              icon: const Icon(Icons.check_circle),
              label: const Text('Grant Permissions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All permissions granted!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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

  Widget _buildPermissionItem(
      String title,
      String description,
      IconData icon,
      Color color,
      bool granted,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: granted ? color.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            granted ? Icons.check_circle : Icons.circle_outlined,
            color: granted ? Colors.green : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectDeviceStep() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Connect Your Smartwatch',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Make sure your smartwatch is nearby and Bluetooth is enabled',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: SmartwatchConnectionWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigureAlertsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.notifications_active, size: 100, color: Colors.orange[400]),
          const SizedBox(height: 32),
          const Text(
            'Configure Alerts',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Customize when and how you want to be notified about health conditions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          _buildAlertOption(
            'Heart Rate Alerts',
            'Get notified when heart rate is abnormal',
            Icons.favorite,
            Colors.red,
            true,
          ),
          const SizedBox(height: 16),
          _buildAlertOption(
            'Impact Detection',
            'Automatic emergency response on accidents',
            Icons.emergency,
            Colors.orange,
            true,
          ),
          const SizedBox(height: 16),
          _buildAlertOption(
            'Stress Monitoring',
            'Track and alert on high stress levels',
            Icons.psychology,
            Colors.purple,
            true,
          ),
          const SizedBox(height: 16),
          _buildAlertOption(
            'Drowsiness Alerts',
            'Get warned when drowsiness is detected',
            Icons.bedtime,
            Colors.blue,
            false,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can change these settings anytime from the device settings',
                    style: TextStyle(
                      fontSize: 13,
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

  Widget _buildAlertOption(
      String title,
      String description,
      IconData icon,
      Color color,
      bool enabled,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {},
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[700]!, Colors.teal[500]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(Icons.check_circle, size: 100, color: Colors.white),
          ),
          const SizedBox(height: 40),
          const Text(
            'All Set!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your smartwatch is connected and ready to monitor your health',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.rocket_launch, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Ready to Go!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start monitoring your health on every journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _finishSetup,
            icon: const Icon(Icons.dashboard),
            label: const Text('Go to Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (_currentStep == _steps.length - 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _steps[_currentStep].color,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(_currentStep == _steps.length - 2 ? 'Finish' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 1:
        return _permissionsGranted;
      case 2:
        return _deviceConnected;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      HapticFeedback.mediumImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      HapticFeedback.lightImpact();
    }
  }

  void _requestPermissions() async {
    // Simulate permission request
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _permissionsGranted = true);
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permissions granted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _skipSetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Setup?'),
        content: const Text(
          'You can always set up your smartwatch later from settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close setup screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _finishSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HealthDashboardScreen(),
      ),
    );
  }
}

class SetupStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  SetupStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}