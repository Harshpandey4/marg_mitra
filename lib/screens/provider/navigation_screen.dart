import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/theme.dart';
import '../../config/app_routes.dart';

class NavigationScreen extends StatefulWidget {
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String serviceType;
  final bool isUserView;

  const NavigationScreen({
    Key? key,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.serviceType,
    this.isUserView = false,
  }) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  Position? _currentPosition;
  LatLng? _customerLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  bool _isLocationPermissionGranted = false;
  bool _isNavigating = false;
  bool _isMapLoading = true;
  bool _hasArrivedAtCustomer = false;

  double _totalDistance = 0.0;
  double _estimatedTime = 0.0;
  String _navigationStatus = 'Initializing...';

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _navigationTimer;

  // Sample route coordinates for demonstration
  List<LatLng> _routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeNavigation();
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _positionStreamSubscription?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    try {
      // Request location permissions
      await _requestLocationPermission();

      if (_isLocationPermissionGranted) {
        // Get current location
        await _getCurrentLocation();

        // Get customer location from address
        await _getCustomerLocation();

        // Set up real-time location tracking
        _startLocationTracking();

        // Calculate route
        _calculateRoute();
      }
    } catch (e) {
      setState(() {
        _navigationStatus = 'Navigation setup failed: ${e.toString()}';
        _isMapLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _isLocationPermissionGranted = status == PermissionStatus.granted;
    });

    if (!_isLocationPermissionGranted) {
      setState(() {
        _navigationStatus = 'Location permission required for navigation';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _navigationStatus = 'Location acquired';
      });

      _addCurrentLocationMarker();
    } catch (e) {
      setState(() {
        _navigationStatus = 'Failed to get current location';
      });
    }
  }

  Future<void> _getCustomerLocation() async {
    try {
      final locations = await locationFromAddress(widget.customerAddress);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _customerLocation = LatLng(location.latitude, location.longitude);
        });
        _addCustomerLocationMarker();
      }
    } catch (e) {
      // Fallback to demo coordinates if geocoding fails
      setState(() {
        _customerLocation = LatLng(28.6139, 77.2090); // Delhi coordinates
        _navigationStatus = 'Using demo customer location';
      });
      _addCustomerLocationMarker();
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'Service Provider',
          ),
        ),
      );
    }
  }

  void _addCustomerLocationMarker() {
    if (_customerLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('customer_location'),
          position: _customerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: widget.customerName,
            snippet: widget.serviceType,
          ),
        ),
      );
    }
  }

  void _calculateRoute() {
    if (_currentPosition != null && _customerLocation != null) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _customerLocation!.latitude,
        _customerLocation!.longitude,
      );

      setState(() {
        _totalDistance = distance / 1000; // Convert to kilometers
        _estimatedTime = (_totalDistance / 40) * 60; // Assuming 40 km/h average speed
        _navigationStatus = 'Route calculated';
        _isMapLoading = false;
      });

      // Create a simple straight line route for demo
      _createDemoRoute();
    }
  }

  void _createDemoRoute() {
    if (_currentPosition != null && _customerLocation != null) {
      _routeCoordinates = [
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _customerLocation!,
      ];

      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: AppTheme.primaryColor,
          width: 4,
          points: _routeCoordinates,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }
  }

  void _startLocationTracking() {
    if (!_isLocationPermissionGranted) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateCurrentLocation(position);
    });
  }

  void _updateCurrentLocation(Position position) {
    setState(() {
      _currentPosition = position;
    });

    // Update marker
    _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
    _addCurrentLocationMarker();

    // Check if arrived at customer location
    if (_customerLocation != null) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _customerLocation!.latitude,
        _customerLocation!.longitude,
      );

      if (distance <= 100 && !_hasArrivedAtCustomer) { // Within 100 meters
        _hasArrivedAtCustomer = true;
        _showArrivalDialog();
      }

      setState(() {
        _totalDistance = distance / 1000;
        _estimatedTime = (_totalDistance / 40) * 60;
      });
    }
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('Arrived!'),
          ],
        ),
        content: Text('You have arrived at ${widget.customerName}\'s location.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _contactCustomer();
            },
            child: Text('Contact Customer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markAsArrived();
            },
            child: Text('Mark as Arrived'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _startNavigation() {
    setState(() {
      _isNavigating = true;
      _navigationStatus = 'Navigation started';
    });

    // Start navigation timer for demo
    _navigationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_totalDistance > 0.1) {
        setState(() {
          _totalDistance -= 0.1; // Simulate movement
          _estimatedTime = (_totalDistance / 40) * 60;
        });
      } else {
        timer.cancel();
        _hasArrivedAtCustomer = true;
        _showArrivalDialog();
      }
    });
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _navigationStatus = 'Navigation stopped';
    });
    _navigationTimer?.cancel();
  }

  void _markAsArrived() {
    Navigator.pop(context, {
      'arrived': true,
      'customerName': widget.customerName,
    });
  }

  void _contactCustomer() {
    Navigator.pushNamed(
      context,
      AppRoutes.customerCommunication,
      arguments: {
        'customerId': 'customer_nav_${DateTime.now().millisecondsSinceEpoch}',
        'customerName': widget.customerName,
        'customerPhone': widget.customerPhone,
        'serviceType': widget.serviceType,
        'requestId': 'nav_request_${DateTime.now().millisecondsSinceEpoch}',
      },
    );
  }

  void _openInGoogleMaps() async {
    if (_customerLocation != null) {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${_customerLocation!.latitude},${_customerLocation!.longitude}&travelmode=driving';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  void _callCustomer() async {
    final url = 'tel:${widget.customerPhone}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildTopOverlay(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (!_isLocationPermissionGranted) {
      return _buildPermissionDeniedView();
    }

    if (_isMapLoading) {
      return _buildLoadingView();
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (_currentPosition != null && _customerLocation != null) {
          _fitMarkersInView();
        }
      },
      initialCameraPosition: CameraPosition(
        target: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : LatLng(28.6139, 77.2090), // Default to Delhi
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Widget _buildPermissionDeniedView() {
    return Container(
      color: Colors.blue[00],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Location Permission Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Enable location access to start navigation',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestLocationPermission,
              child: Text('Enable Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 2 * pi,
                  child: Icon(Icons.navigation, size: 60, color: AppTheme.primaryColor),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Initializing Navigation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_navigationStatus, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigating to',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    widget.customerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.serviceType,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.phone, color: AppTheme.primaryColor),
                onPressed: _callCustomer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    Icons.straighten,
                    'Distance',
                    '${_totalDistance.toStringAsFixed(1)} km',
                    AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    Icons.access_time,
                    'ETA',
                    '${_estimatedTime.toInt()} min',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openInGoogleMaps,
                    icon: Icon(Icons.map),
                    label: Text('Open in Maps'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isNavigating ? _stopNavigation : _startNavigation,
                    icon: Icon(_isNavigating ? Icons.stop : Icons.navigation),
                    label: Text(_isNavigating ? 'Stop' : 'Start Navigation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isNavigating ? Colors.red : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _contactCustomer,
                icon: Icon(Icons.message),
                label: Text('Message Customer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _fitMarkersInView() {
    if (_currentPosition != null && _customerLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          min(_currentPosition!.latitude, _customerLocation!.latitude) - 0.01,
          min(_currentPosition!.longitude, _customerLocation!.longitude) - 0.01,
        ),
        northeast: LatLng(
          max(_currentPosition!.latitude, _customerLocation!.latitude) + 0.01,
          max(_currentPosition!.longitude, _customerLocation!.longitude) + 0.01,
        ),
      );

      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }
}