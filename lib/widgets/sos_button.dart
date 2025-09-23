import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../services/sos_service.dart';

class SosButton extends ConsumerStatefulWidget {
  const SosButton({Key? key}) : super(key: key);

  @override
  ConsumerState<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends ConsumerState<SosButton>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isLoading = false;
  bool _isCountingDown = false;
  int _countdownSeconds = 0;
  bool _autoDetectionActive = true;
  String _emergencyStatus = 'ready';

  AnimationController? _pulseController;
  AnimationController? _rotateController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    try {
      _pulseController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );

      _rotateController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      // Start pulse animation
      _pulseController?.repeat(reverse: true);
    } catch (e) {
      debugPrint('Animation initialization error: $e');
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _rotateController?.dispose();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 5;
      _emergencyStatus = 'countdown';
    });

    HapticFeedback.heavyImpact();

    for (int i = 5; i > 0; i--) {
      if (!mounted || !_isCountingDown) return;

      setState(() => _countdownSeconds = i);

      if (i <= 3) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted && _isCountingDown) {
      await _executeEmergency();
    }
  }

  void _cancelCountdown() {
    if (!mounted) return;

    setState(() {
      _isCountingDown = false;
      _countdownSeconds = 0;
      _emergencyStatus = 'ready';
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency cancelled'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _executeEmergency() async {
    setState(() {
      _isLoading = true;
      _isCountingDown = false;
      _emergencyStatus = 'activating';
    });

    _rotateController?.repeat();
    HapticFeedback.heavyImpact();

    try {
      // Show immediate feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 Emergency Alert Activated!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      final sosService = ref.read(sosServiceProvider);
      final weatherState = ref.read(weatherNotifierProvider);

      Map<String, dynamic> emergencyData = {
        'timestamp': DateTime.now().toIso8601String(),
        'emergencyType': 'manual_advanced_trigger',
        'autoDetection': _autoDetectionActive,
        'aiConfidence': _calculateAiConfidence(weatherState.getRoadSafety()),
        'sensorData': {
          'accelerometer': 'active',
          'gyroscope': 'active',
          'heartRate': 'monitoring',
          'gps': 'tracking_enabled',
        },
        'userInitiated': true,
      };

      setState(() => _emergencyStatus = 'coordinating');

      if (weatherState.currentWeather != null) {
        emergencyData['weather'] = {
          'temperature': weatherState.currentWeather!.temperature,
          'condition': weatherState.currentWeather!.condition,
          'description': weatherState.currentWeather!.description,
        };
        emergencyData['roadSafety'] = weatherState.getRoadSafety().toString();

        await sosService.triggerAdvancedSos(
          emergencyData: emergencyData,
          multiAgencyCoordination: true,
          familyNotification: true,
        );
      } else {
        await sosService.triggerAdvancedSos(
          emergencyData: emergencyData,
          multiAgencyCoordination: true,
          familyNotification: true,
        );
      }

      setState(() => _emergencyStatus = 'active');

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _emergencyStatus = 'error');

      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _rotateController?.stop();
        _rotateController?.reset();

        if (_emergencyStatus != 'active' && _emergencyStatus != 'error') {
          setState(() => _emergencyStatus = 'ready');
        }
      }
    }
  }

  double _calculateAiConfidence(RoadSafetyLevel safetyLevel) {
    switch (safetyLevel) {
      case RoadSafetyLevel.dangerous:
        return 0.95;
      case RoadSafetyLevel.moderate:
        return 0.85;
      case RoadSafetyLevel.safe:
      default:
        return 0.80;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 600;
        final isVerySmallScreen = screenWidth < 360;

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16)
          ),
          contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 40,
            vertical: 24,
          ),
          title: Container(
            padding: EdgeInsets.all(isVerySmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: isVerySmallScreen ? 20 : 24
                ),
                SizedBox(width: isVerySmallScreen ? 6 : 8),
                Flexible(
                  child: Text(
                    'Emergency Alert Sent',
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 16 : 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              maxHeight: screenHeight * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency services have been notified:',
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildServiceStatus(
                    'Police Department',
                    Icons.local_police,
                    true,
                    isSmallScreen: isSmallScreen,
                    isVerySmallScreen: isVerySmallScreen,
                  ),
                  _buildServiceStatus(
                    'Emergency Medical',
                    Icons.local_hospital,
                    true,
                    isSmallScreen: isSmallScreen,
                    isVerySmallScreen: isVerySmallScreen,
                  ),
                  _buildServiceStatus(
                    'Family Contacts',
                    Icons.contacts,
                    true,
                    isSmallScreen: isSmallScreen,
                    isVerySmallScreen: isVerySmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Container(
                    padding: EdgeInsets.all(isVerySmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: isVerySmallScreen ? 16 : 20
                        ),
                        SizedBox(width: isVerySmallScreen ? 6 : 8),
                        Expanded(
                          child: Text(
                            'Your location is being tracked and shared with emergency services.',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 12 : 13,
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
          actions: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _emergencyStatus = 'ready');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceStatus(
      String service,
      IconData icon,
      bool status, {
        bool isSmallScreen = false,
        bool isVerySmallScreen = false,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 2 : 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: isVerySmallScreen ? 16 : 20,
          ),
          SizedBox(width: isVerySmallScreen ? 6 : 8),
          Icon(
              icon,
              size: isVerySmallScreen ? 14 : 18,
              color: Colors.grey[600]
          ),
          SizedBox(width: isVerySmallScreen ? 6 : 8),
          Expanded(
            child: Text(
              service,
              style: TextStyle(
                fontSize: isVerySmallScreen ? 12 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 600;
        final isVerySmallScreen = screenWidth < 360;

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16)
          ),
          contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 40,
            vertical: 24,
          ),
          title: Row(
            children: [
              Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: isVerySmallScreen ? 20 : 24
              ),
              SizedBox(width: isVerySmallScreen ? 6 : 8),
              Flexible(
                child: Text(
                  'Alert Failed',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 16 : 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              maxHeight: screenHeight * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Emergency alert failed: $error',
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Container(
                    padding: EdgeInsets.all(isVerySmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            Icons.phone,
                            color: Colors.orange,
                            size: isVerySmallScreen ? 16 : 20
                        ),
                        SizedBox(width: isVerySmallScreen ? 6 : 8),
                        Expanded(
                          child: Text(
                            'Call 112 for immediate help',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 12 : 14,
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
          actions: isSmallScreen
              ? [
            // Stack buttons vertically on small screens
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _emergencyStatus = 'ready');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _executeEmergency();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
          ]
              : [
            // Keep buttons horizontal on larger screens
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _emergencyStatus = 'ready');
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeEmergency();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final safetyLevel = weatherState.getRoadSafety();

    return GestureDetector(
      onTap: () {
        print('SOS Button tapped!'); // Debug print
        if (_isCountingDown) {
          _cancelCountdown();
        } else if (!_isLoading) {
          _startCountdown();
        }
      },
      onLongPress: () {
        print('SOS Button long pressed!'); // Debug print
        if (!_isLoading && !_isCountingDown) {
          HapticFeedback.heavyImpact();
          _executeEmergency();
        }
      },
      child: AnimatedBuilder(
        animation: _pulseController ?? AnimationController(vsync: this, duration: Duration.zero),
        builder: (context, child) {
          final pulseValue = _pulseController?.value ?? 0.0;
          final scale = _isLoading ? 1.0 : (1.0 + (pulseValue * 0.1));

          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isCountingDown ? 160 : 140,
              height: _isCountingDown ? 160 : 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _getGradientForStatus(safetyLevel),
                boxShadow: [
                  BoxShadow(
                    color: _getShadowColor(safetyLevel).withOpacity(0.4),
                    blurRadius: _isPressed ? 10 : 20,
                    spreadRadius: _isPressed ? 3 : 8,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 3,
                ),
              ),
              child: _buildButtonContent(safetyLevel),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonContent(RoadSafetyLevel safetyLevel) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_rotateController?.isAnimating == true)
            RotationTransition(
              turns: _rotateController!,
              child: const Icon(Icons.refresh, color: Colors.white, size: 32),
            )
          else
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          const SizedBox(height: 12),
          Text(
            _getStatusText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_isCountingDown) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _countdownSeconds.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'TAP TO CANCEL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getIconForStatus(safetyLevel),
          size: 40,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          _emergencyStatus == 'active' ? 'ACTIVE' : 'SOS',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        if (_emergencyStatus == 'active')
          const Text(
            'EMERGENCY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
        else if (safetyLevel != RoadSafetyLevel.safe)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getSafetyText(safetyLevel),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  String _getStatusText() {
    switch (_emergencyStatus) {
      case 'activating':
        return 'Activating\nEmergency';
      case 'coordinating':
        return 'Coordinating\nResponse';
      default:
        return 'Alerting\nServices';
    }
  }

  LinearGradient _getGradientForStatus(RoadSafetyLevel safetyLevel) {
    if (_emergencyStatus == 'active') {
      return const LinearGradient(
        colors: [Color(0xFFFF1744), Color(0xFFB71C1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (_isCountingDown) {
      return const LinearGradient(
        colors: [Color(0xFFFF5722), Color(0xFFD84315)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return _getGradientForSafety(safetyLevel);
  }

  Color _getShadowColor(RoadSafetyLevel safetyLevel) {
    if (_emergencyStatus == 'active') return Colors.red;
    if (_isCountingDown) return Colors.deepOrange;
    return _getColorForSafety(safetyLevel);
  }

  IconData _getIconForStatus(RoadSafetyLevel safetyLevel) {
    if (_emergencyStatus == 'active') return Icons.emergency;
    return _getIconForSafety(safetyLevel);
  }

  LinearGradient _getGradientForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return const LinearGradient(
          colors: [Color(0xFFFF1744), Color(0xFFD50000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RoadSafetyLevel.moderate:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RoadSafetyLevel.safe:
      default:
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getColorForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return Colors.red;
      case RoadSafetyLevel.moderate:
        return Colors.orange;
      case RoadSafetyLevel.safe:
      default:
        return Colors.blue;
    }
  }

  IconData _getIconForSafety(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return Icons.warning;
      case RoadSafetyLevel.moderate:
        return Icons.error_outline;
      case RoadSafetyLevel.safe:
      default:
        return Icons.emergency;
    }
  }

  String _getSafetyText(RoadSafetyLevel level) {
    switch (level) {
      case RoadSafetyLevel.dangerous:
        return 'CRITICAL';
      case RoadSafetyLevel.moderate:
        return 'CAUTION';
      case RoadSafetyLevel.safe:
      default:
        return '';
    }
  }
}