// lib/features/health_monitoring/widgets/smartwatch_connection_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_monitoring_providers.dart';
import '../models/smartwatch_device.dart';


class SmartwatchConnectionWidget extends ConsumerWidget {
  const SmartwatchConnectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedDevice = ref.watch(connectedDeviceProvider);
    final isConnected = ref.watch(isDeviceConnectedProvider);
    final smartwatchState = ref.watch(smartwatchControllerProvider);

    return GestureDetector(
      onTap: () => _showConnectionSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isConnected
                ? [Colors.green[700]!, Colors.green[500]!]
                : [Colors.grey[700]!, Colors.grey[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isConnected ? Colors.green : Colors.grey).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Watch Icon with Animation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.watch,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Connection Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Smartwatch Connected' : 'Connect Smartwatch',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConnected
                        ? connectedDevice?.name ?? 'Unknown Device'
                        : 'Tap to scan for devices',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  if (isConnected && connectedDevice != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(
                          'Battery',
                          '${connectedDevice.batteryLevel ?? 0}%',
                          Icons.battery_charging_full,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          'Signal',
                          _getSignalText(connectedDevice.connectionQuality ?? ConnectionQuality.fair),
                          Icons.signal_cellular_alt,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action Icon
            Icon(
              isConnected ? Icons.settings : Icons.bluetooth_searching,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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

  void _showConnectionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConnectionBottomSheet(),
    );
  }
}

// ========================================
// CONNECTION BOTTOM SHEET
// ========================================

class _ConnectionBottomSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ConnectionBottomSheet> createState() => _ConnectionBottomSheetState();
}

class _ConnectionBottomSheetState extends ConsumerState<_ConnectionBottomSheet> {
  List<SmartwatchDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Auto-start scanning when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });

    // Listen to device stream
    _listenToDevices();
  }

  void _listenToDevices() {
    // ✅ FIXED: Properly listen to stream
    ref.listenManual(availableDevicesProvider, (previous, next) {
      next.whenData((devices) {
        if (mounted) {
          setState(() {
            _devices = devices;
            print('📱 Devices updated: ${devices.length} found');
          });
        }
      });
    });
  }

  void _startScanning() {
    setState(() => _isScanning = true);
    ref.read(smartwatchControllerProvider.notifier).startScanning();

    // Stop scanning indicator after 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final smartwatchState = ref.watch(smartwatchControllerProvider);
    final connectedDevice = ref.watch(connectedDeviceProvider);
    final isConnected = ref.watch(isDeviceConnectedProvider);

    // ✅ Also watch the async provider for real-time updates
    final availableDevicesAsync = ref.watch(availableDevicesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[500]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.watch, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Smartwatch Connection',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConnected
                              ? 'Connected Device'
                              : _isScanning
                              ? 'Scanning...'
                              : '${_devices.length} devices found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Connected Device Section
            if (isConnected && connectedDevice != null)
              _buildConnectedDeviceSection(connectedDevice),

            // Scanning Status
            if (_isScanning)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Scanning for devices... (${_devices.length} found)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ Show error if permissions denied
            if (smartwatchState.error != null)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        smartwatchState.error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),

            // Available Devices List
            Expanded(
              child: _buildDevicesList(_devices),
            ),

            // Scan Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _startScanning,
                icon: Icon(_isScanning ? Icons.hourglass_empty : Icons.bluetooth_searching),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceSection(SmartwatchDevice device) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[100]!, Colors.green[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getDeviceTypeText(device.type),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(smartwatchControllerProvider.notifier).disconnectDevice();
                },
                child: const Text('Disconnect'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDeviceInfoChip(
                  'Battery',
                  '${device.batteryLevel ?? 0}%',
                  Icons.battery_charging_full,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDeviceInfoChip(
                  'Signal',
                  _getSignalText(device.connectionQuality ?? ConnectionQuality.fair),
                  Icons.signal_cellular_alt,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(List<SmartwatchDevice> devices) {
    if (_isScanning && devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Searching for smartwatches...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure your device is nearby\nand Bluetooth is enabled',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No devices found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure your smartwatch is nearby\nand Bluetooth is enabled',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(SmartwatchDevice device) {
    final smartwatchState = ref.watch(smartwatchControllerProvider);
    final isConnecting = smartwatchState.isConnecting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getDeviceIcon(device.type),
            color: Colors.blue[700],
            size: 28,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_getDeviceTypeText(device.type)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.signal_cellular_alt,
                  size: 16,
                  color: _getSignalColor(device.signalStrength ?? -100),
                ),
                const SizedBox(width: 4),
                Text(
                  _getSignalStrengthText(device.signalStrength ?? -100),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isConnecting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(smartwatchControllerProvider.notifier).connectToDevice(device);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Connect'),
        ),
      ),
    );
  }

  Widget _buildDeviceInfoChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.appleWatch:
        return Icons.watch;
      case DeviceType.galaxyWatch:
        return Icons.watch;
      case DeviceType.fitbit:
        return Icons.fitness_center;
      case DeviceType.miWatch:
        return Icons.watch;
      default:
        return Icons.watch_outlined;
    }
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

  String _getSignalStrengthText(int rssi) {
    if (rssi >= -50) return 'Excellent signal';
    if (rssi >= -70) return 'Good signal';
    if (rssi >= -85) return 'Fair signal';
    return 'Weak signal';
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.blue;
    if (rssi >= -85) return Colors.orange;
    return Colors.red;
  }
}