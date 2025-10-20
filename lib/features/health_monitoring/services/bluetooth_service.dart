import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';  // ✅ ADD THIS
import '../models/smartwatch_device.dart';

class DeviceBluetoothService {
  // FIXED: Changed constructor names to match class name
  static final DeviceBluetoothService _instance = DeviceBluetoothService._internal();
  factory DeviceBluetoothService() => _instance;
  DeviceBluetoothService._internal();

  // Stream controllers
  final _devicesController = StreamController<List<SmartwatchDevice>>.broadcast();
  final _connectionController = StreamController<ConnectionStatus>.broadcast();
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<List<SmartwatchDevice>> get devicesStream => _devicesController.stream;
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  // Current state
  List<SmartwatchDevice> _discoveredDevices = [];
  SmartwatchDevice? _connectedDevice;
  BluetoothDevice? _activeBluetoothDevice;

  // Characteristics for data reading
  BluetoothCharacteristic? _heartRateCharacteristic;
  BluetoothCharacteristic? _batteryCharacteristic;
  BluetoothCharacteristic? _accelerometerCharacteristic;

  // Standard UUIDs
  static const String HEART_RATE_SERVICE = "0000180d-0000-1000-8000-00805f9b34fb";
  static const String HEART_RATE_MEASUREMENT = "00002a37-0000-1000-8000-00805f9b34fb";
  static const String BATTERY_SERVICE = "0000180f-0000-1000-8000-00805f9b34fb";
  static const String BATTERY_LEVEL = "00002a19-0000-1000-8000-00805f9b34fb";

  // Check Bluetooth availability
  Future<bool> isBluetoothAvailable() async {
    try {
      return await FlutterBluePlus.isAvailable;
    } catch (e) {
      print('Bluetooth availability check failed: $e');
      return false;
    }
  }

  // Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      print('Bluetooth state check failed: $e');
      return false;
    }
  }

  // ✅ UPDATED: Request necessary permissions
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Get Android SDK version
        int androidVersion = 31; // Default to Android 12+

        try {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          androidVersion = androidInfo.version.sdkInt;
          print('📱 Android SDK version: $androidVersion');
        } catch (e) {
          print('⚠️ Could not get Android version: $e');
        }

        if (androidVersion >= 31) {
          // Android 12+ (API 31+)
          print('🔵 Requesting Android 12+ Bluetooth permissions...');

          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.locationWhenInUse,
          ].request();

          print('Permission results:');
          statuses.forEach((permission, status) {
            print('  ${permission.toString()}: ${status.toString()}');
          });

          bool allGranted = statuses.values.every((status) =>
          status.isGranted || status.isLimited
          );

          if (!allGranted) {
            print('❌ Some permissions were denied');
            // Show which permissions failed
            statuses.forEach((permission, status) {
              if (!status.isGranted && !status.isLimited) {
                print('  ❌ ${permission.toString()} was denied');
              }
            });
          } else {
            print('✅ All Bluetooth permissions granted!');
          }

          return allGranted;
        } else {
          // Android 11 and below
          print('🔵 Requesting Android 11- Bluetooth permissions...');

          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetooth,
            Permission.location,
          ].request();

          print('Permission results:');
          statuses.forEach((permission, status) {
            print('  ${permission.toString()}: ${status.toString()}');
          });

          bool allGranted = statuses.values.every((status) => status.isGranted);

          if (allGranted) {
            print('✅ All permissions granted!');
          } else {
            print('❌ Some permissions were denied');
          }

          return allGranted;
        }
      } else if (Platform.isIOS) {
        print('🍎 Requesting iOS Bluetooth permissions...');
        final status = await Permission.bluetooth.request();
        print('iOS Bluetooth permission: ${status.toString()}');
        return status.isGranted;
      }

      return false;
    } catch (e) {
      print('❌ Permission request error: $e');
      return false;
    }
  }

  // Start scanning for devices
  Future<void> startScanning({Duration timeout = const Duration(seconds: 15)}) async {
    try {
      print('🔍 Starting Bluetooth scan...');

      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Bluetooth permissions not granted');
      }

      final isEnabled = await isBluetoothEnabled();
      if (!isEnabled) {
        throw Exception('Bluetooth is not enabled');
      }

      _discoveredDevices.clear();
      _connectionController.add(ConnectionStatus.connecting);

      print('📡 Scanning for devices...');

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      FlutterBluePlus.scanResults.listen((results) {
        print('📱 Found ${results.length} devices');
        for (ScanResult result in results) {
          if (_isHealthDevice(result.device)) {
            final device = _createSmartwatchDevice(result);

            if (!_discoveredDevices.any((d) => d.id == device.id)) {
              print('✅ Found health device: ${device.name}');
              _discoveredDevices.add(device);
              _devicesController.add(_discoveredDevices);
            }
          }
        }
      });

      await Future.delayed(timeout);
      await stopScanning();

    } catch (e) {
      print('❌ Scanning error: $e');
      _connectionController.add(ConnectionStatus.error);
      rethrow;
    }
  }

  // Stop scanning
  Future<void> stopScanning() async {
    try {
      await FlutterBluePlus.stopScan();
      print('⏹️ Scanning stopped');
    } catch (e) {
      print('Stop scanning error: $e');
    }
  }

  // Check if device is a health device
  bool _isHealthDevice(BluetoothDevice device) {
    final name = device.platformName.toLowerCase();
    return name.contains('watch') ||
        name.contains('fit') ||
        name.contains('band') ||
        name.contains('health') ||
        name.contains('mi') ||
        name.contains('apple') ||
        name.contains('galaxy') ||
        name.contains('garmin');
  }

  // Create smartwatch device from scan result
  SmartwatchDevice _createSmartwatchDevice(ScanResult result) {
    final name = result.device.platformName;
    DeviceType type = DeviceType.other;

    if (name.toLowerCase().contains('apple')) {
      type = DeviceType.appleWatch;
    } else if (name.toLowerCase().contains('galaxy')) {
      type = DeviceType.galaxyWatch;
    } else if (name.toLowerCase().contains('fitbit')) {
      type = DeviceType.fitbit;
    } else if (name.toLowerCase().contains('mi')) {
      type = DeviceType.miWatch;
    }

    return SmartwatchDevice(
      id: result.device.remoteId.toString(),
      name: name.isNotEmpty ? name : 'Unknown Device',
      type: type,
      status: ConnectionStatus.disconnected,
      bluetoothDevice: result.device,
      signalStrength: result.rssi,
      supportedFeatures: [],
    );
  }

  // Connect to device
  Future<void> connectToDevice(SmartwatchDevice device) async {
    try {
      if (device.bluetoothDevice == null) {
        throw Exception('Invalid Bluetooth device');
      }

      _connectionController.add(ConnectionStatus.connecting);

      if (_activeBluetoothDevice != null) {
        await disconnectDevice();
      }

      // ✅ FIXED: Simple connect call
      print('🔗 Connecting to ${device.name}...');
      await device.bluetoothDevice!.connect();

      _activeBluetoothDevice = device.bluetoothDevice;
      _connectedDevice = device.copyWith(status: ConnectionStatus.connected);

      await _discoverServices(device.bluetoothDevice!);
      await _setupNotifications();

      _connectionController.add(ConnectionStatus.connected);

      print('✅ Successfully connected to ${device.name}');

    } catch (e) {
      print('❌ Connection error: $e');
      _connectionController.add(ConnectionStatus.error);
      rethrow;
    }
  }

  // Discover available services
  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      List<String> features = [];

      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == HEART_RATE_SERVICE) {
          features.add('heart_rate');
          _heartRateCharacteristic = service.characteristics.firstWhere(
                (c) => c.uuid.toString().toLowerCase() == HEART_RATE_MEASUREMENT,
            orElse: () => service.characteristics.first,
          );
        }

        if (service.uuid.toString().toLowerCase() == BATTERY_SERVICE) {
          features.add('battery');
          _batteryCharacteristic = service.characteristics.firstWhere(
                (c) => c.uuid.toString().toLowerCase() == BATTERY_LEVEL,
            orElse: () => service.characteristics.first,
          );
        }

        if (service.characteristics.any((c) =>
        c.properties.notify && c.uuid.toString().contains('acc'))) {
          features.add('accelerometer');
        }
      }

      if (_connectedDevice != null) {
        _connectedDevice = _connectedDevice!.copyWith(
          supportedFeatures: features,
        );
      }

    } catch (e) {
      print('Service discovery error: $e');
    }
  }

  // Setup notifications
  Future<void> _setupNotifications() async {
    try {
      if (_heartRateCharacteristic != null) {
        await _heartRateCharacteristic!.setNotifyValue(true);
        _heartRateCharacteristic!.value.listen((value) {
          if (value.isNotEmpty) {
            final heartRate = value[1];
            _dataController.add({
              'type': 'heart_rate',
              'value': heartRate,
              'timestamp': DateTime.now(),
            });
          }
        });
      }

      if (_batteryCharacteristic != null) {
        final batteryValue = await _batteryCharacteristic!.read();
        if (batteryValue.isNotEmpty) {
          _dataController.add({
            'type': 'battery',
            'value': batteryValue[0],
            'timestamp': DateTime.now(),
          });
        }
      }

    } catch (e) {
      print('Notification setup error: $e');
    }
  }

  // Disconnect from device
  Future<void> disconnectDevice() async {
    try {
      if (_activeBluetoothDevice != null) {
        await _activeBluetoothDevice!.disconnect();
        _activeBluetoothDevice = null;
        _connectedDevice = null;
        _heartRateCharacteristic = null;
        _batteryCharacteristic = null;
        _accelerometerCharacteristic = null;
        _connectionController.add(ConnectionStatus.disconnected);
      }
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  // Read heart rate
  Future<int?> readHeartRate() async {
    try {
      if (_heartRateCharacteristic != null) {
        final value = await _heartRateCharacteristic!.read();
        if (value.isNotEmpty) {
          return value[1];
        }
      }
      return null;
    } catch (e) {
      print('Heart rate read error: $e');
      return null;
    }
  }

  // Read battery level
  Future<int?> readBatteryLevel() async {
    try {
      if (_batteryCharacteristic != null) {
        final value = await _batteryCharacteristic!.read();
        if (value.isNotEmpty) {
          return value[0];
        }
      }
      return null;
    } catch (e) {
      print('Battery read error: $e');
      return null;
    }
  }

  SmartwatchDevice? get connectedDevice => _connectedDevice;

  bool get isConnected => _connectedDevice?.status == ConnectionStatus.connected;

  void dispose() {
    _devicesController.close();
    _connectionController.close();
    _dataController.close();
  }
}