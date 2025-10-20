// lib/features/health_monitoring/screens/device_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_monitoring_providers.dart';
import '../models/smartwatch_device.dart';
import '../models/safety_assessment.dart';
import '../models/alert_config.dart';
class DeviceSettingsScreen extends ConsumerStatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  ConsumerState<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends ConsumerState<DeviceSettingsScreen> {
  late AlertConfig _alertConfig;

  @override
  void initState() {
    super.initState();
    _alertConfig = ref.read(smartwatchControllerProvider).alertConfig;
  }

  @override
  Widget build(BuildContext context) {
    final connectedDevice = ref.watch(connectedDeviceProvider);
    final isConnected = ref.watch(isDeviceConnectedProvider);
    final smartwatchState = ref.watch(smartwatchControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        title: const Text(
          'Device Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isConnected && connectedDevice != null
          ? _buildSettingsContent(connectedDevice)
          : _buildNotConnectedState(),
    );
  }

  Widget _buildSettingsContent(SmartwatchDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceInfoCard(device),
          const SizedBox(height: 20),
          _buildAlertSettingsSection(),
          const SizedBox(height: 20),
          _buildThresholdSettingsSection(),
          const SizedBox(height: 20),
          _buildEmergencySettingsSection(),
          const SizedBox(height: 20),
          _buildAdvancedSettingsSection(),
          const SizedBox(height: 20),
          _buildDangerZone(device),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(SmartwatchDevice device) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.watch, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDeviceTypeText(device.type),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Connected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDeviceInfoItem(
                  'Battery',
                  '${device.batteryLevel}%',
                  Icons.battery_charging_full,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeviceInfoItem(
                  'Signal',
                  _getSignalText(device.connectionQuality),
                  Icons.signal_cellular_alt,
                  _getSignalColor(device.connectionQuality),
                ),
              ),
            ],
          ),
          if (device.firmwareVersion != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Firmware Version',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    device.firmwareVersion!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDeviceInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSettingsSection() {
    return _buildSection(
      'Alert Settings',
      Icons.notifications_active,
      Colors.orange,
      [
        _buildSwitchTile(
          'Heart Rate Alerts',
          'Get notified when heart rate is abnormal',
          _alertConfig.enableHeartRateAlerts,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: value,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
            _updateConfig();
          },
        ),
        _buildSwitchTile(
          'Impact Detection',
          'Automatically detect accidents and falls',
          _alertConfig.enableImpactDetection,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: value,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
            _updateConfig();
          },
        ),
        _buildSwitchTile(
          'Drowsiness Detection',
          'Alert when signs of drowsiness detected',
          _alertConfig.enableDrowsinessAlerts,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: value,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
            _updateConfig();
          },
        ),
        _buildSwitchTile(
          'Stress Monitoring',
          'Track and alert on high stress levels',
          _alertConfig.enableStressAlerts,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: value,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
            _updateConfig();
          },
        ),
      ],
    );
  }

  Widget _buildThresholdSettingsSection() {
    return _buildSection(
      'Health Thresholds',
      Icons.tune,
      Colors.blue,
      [
        _buildSliderTile(
          'Low Heart Rate Threshold',
          'Alert when below ${_alertConfig.heartRateThresholdLow} BPM',
          _alertConfig.heartRateThresholdLow.toDouble(),
          30.0,
          60.0,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: value.round(),
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
          },
              () => _updateConfig(),
        ),
        _buildSliderTile(
          'High Heart Rate Threshold',
          'Alert when above ${_alertConfig.heartRateThresholdHigh} BPM',
          _alertConfig.heartRateThresholdHigh.toDouble(),
          100.0,
          180.0,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: value.round(),
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
          },
              () => _updateConfig(),
        ),
        _buildSliderTile(
          'Oxygen Saturation Threshold',
          'Alert when below ${_alertConfig.oxygenThreshold}%',
          _alertConfig.oxygenThreshold.toDouble(),
          85.0,
          95.0,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: value.round(),
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
          },
              () => _updateConfig(),
        ),
      ],
    );
  }

  Widget _buildEmergencySettingsSection() {
    return _buildSection(
      'Emergency Response',
      Icons.emergency,
      Colors.red,
      [
        _buildSwitchTile(
          'Auto-Call Emergency',
          'Automatically call emergency services on critical alerts',
          _alertConfig.autoCallEmergency,
              (value) {
            if (value) {
              _showAutoCallWarning(() {
                setState(() {
                  _alertConfig = AlertConfig(
                    enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                    enableImpactDetection: _alertConfig.enableImpactDetection,
                    enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                    enableStressAlerts: _alertConfig.enableStressAlerts,
                    heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                    heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                    oxygenThreshold: _alertConfig.oxygenThreshold,
                    stressThreshold: _alertConfig.stressThreshold,
                    autoCallEmergency: value,
                    notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                    shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
                  );
                });
                _updateConfig();
              });
            } else {
              setState(() {
                _alertConfig = AlertConfig(
                  enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                  enableImpactDetection: _alertConfig.enableImpactDetection,
                  enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                  enableStressAlerts: _alertConfig.enableStressAlerts,
                  heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                  heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                  oxygenThreshold: _alertConfig.oxygenThreshold,
                  stressThreshold: _alertConfig.stressThreshold,
                  autoCallEmergency: value,
                  notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                  shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
                );
              });
              _updateConfig();
            }
          },
        ),
        _buildSwitchTile(
          'Notify Emergency Contacts',
          'Send alerts to your emergency contacts',
          _alertConfig.notifyEmergencyContacts,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: value,
                shareLocationOnAlert: _alertConfig.shareLocationOnAlert,
              );
            });
            _updateConfig();
          },
        ),
        _buildSwitchTile(
          'Share Location on Alert',
          'Share your live location during emergencies',
          _alertConfig.shareLocationOnAlert,
              (value) {
            setState(() {
              _alertConfig = AlertConfig(
                enableHeartRateAlerts: _alertConfig.enableHeartRateAlerts,
                enableImpactDetection: _alertConfig.enableImpactDetection,
                enableDrowsinessAlerts: _alertConfig.enableDrowsinessAlerts,
                enableStressAlerts: _alertConfig.enableStressAlerts,
                heartRateThresholdLow: _alertConfig.heartRateThresholdLow,
                heartRateThresholdHigh: _alertConfig.heartRateThresholdHigh,
                oxygenThreshold: _alertConfig.oxygenThreshold,
                stressThreshold: _alertConfig.stressThreshold,
                autoCallEmergency: _alertConfig.autoCallEmergency,
                notifyEmergencyContacts: _alertConfig.notifyEmergencyContacts,
                shareLocationOnAlert: value,
              );
            });
            _updateConfig();
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedSettingsSection() {
    return _buildSection(
      'Advanced Settings',
      Icons.settings,
      Colors.purple,
      [
        _buildActionTile(
          'Calibrate Sensors',
          'Recalibrate smartwatch sensors',
          Icons.straighten,
              () => _showComingSoonDialog('Sensor Calibration'),
        ),
        _buildActionTile(
          'Data Sync',
          'Sync health data with cloud',
          Icons.cloud_sync,
              () => _showComingSoonDialog('Cloud Sync'),
        ),
        _buildActionTile(
          'Export Health Data',
          'Download your health history',
          Icons.download,
              () => _showComingSoonDialog('Data Export'),
        ),
      ],
    );
  }

  Widget _buildDangerZone(SmartwatchDevice device) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showDisconnectDialog(device),
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Disconnect Device'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          onChanged(newValue);
        },
        activeColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildSliderTile(
      String title,
      String subtitle,
      double value,
      double min,
      double max,
      Function(double) onChanged,
      Function() onChangeEnd,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue[700],
              inactiveTrackColor: Colors.blue[100],
              thumbColor: Colors.blue[700],
              overlayColor: Colors.blue.withOpacity(0.2),
              valueIndicatorColor: Colors.blue[700],
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              label: value.round().toString(),
              onChanged: onChanged,
              onChangeEnd: (_) {
                HapticFeedback.mediumImpact();
                onChangeEnd();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildNotConnectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.watch_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No Device Connected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect a smartwatch to access settings',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _updateConfig() {
    ref.read(smartwatchControllerProvider.notifier).updateAlertConfig(_alertConfig);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAutoCallWarning(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Auto-Call Emergency'),
          ],
        ),
        content: const Text(
          'This will automatically call emergency services when a critical health alert is detected. '
              'Make sure you understand the implications before enabling this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(SmartwatchDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Device?'),
        content: Text(
          'Are you sure you want to disconnect from ${device.name}? '
              'Health monitoring will be stopped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(smartwatchControllerProvider.notifier).disconnectDevice();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device disconnected'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 12),
            const Text('Coming Soon'),
          ],
        ),
        content: Text(
          '$feature feature will be available in a future update.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getDeviceTypeText(DeviceType type) {
    switch (type) {
      case DeviceType.appleWatch:
        return 'Apple Watch';
      case DeviceType.galaxyWatch:
        return 'Galaxy Watch';
      case DeviceType.fitbit:
        return 'Fitbit';
      case DeviceType.miWatch:
        return 'Mi Watch';
      default:
        return 'Smartwatch';
    }
  }

  String _getSignalText(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return 'Excellent';
      case ConnectionQuality.good:
        return 'Good';
      case ConnectionQuality.fair:
        return 'Fair';
      case ConnectionQuality.poor:
        return 'Poor';
    }
  }

  Color _getSignalColor(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return Colors.green;
      case ConnectionQuality.good:
        return Colors.blue;
      case ConnectionQuality.fair:
        return Colors.orange;
      case ConnectionQuality.poor:
        return Colors.red;
    }
  }
}