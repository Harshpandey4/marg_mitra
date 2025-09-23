import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import 'dart:async';
import 'dart:math';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  GoogleMapController? _mapController;
  String providerStatus = 'On the way';
  String estimatedArrival = '12 minutes';
  bool _isDarkMode = false;
  bool _isMapLoaded = false;

  // Map related variables
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Position? _currentPosition;

  // Service provider location (simulated)
  final LatLng _providerLocation = const LatLng(25.4358, 81.8463); // Prayagraj
  final LatLng _customerLocation = const LatLng(25.4484, 81.8397);

  // Service details
  final Map<String, dynamic> serviceDetails = {
    'providerName': 'Rajesh Kumar',
    'serviceType': 'Towing Service',
    'vehicleNumber': 'DL 8C 1234',
    'rating': 4.8,
    'phone': '+91 9876543210',
    'distance': '2.3 km',
    'estimatedCost': '₹450'
  };

  Timer? _locationUpdateTimer;
  int _currentStep = 2; // Current step in service timeline

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentLocation();
    _startLocationUpdates();
    _initializeMap();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  void _initializeMap() {
    // Add markers
    _markers.addAll([
      Marker(
        markerId: const MarkerId('customer'),
        position: _customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Waiting for service provider',
        ),
      ),
      Marker(
        markerId: const MarkerId('provider'),
        position: _providerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: serviceDetails['providerName'],
          snippet: serviceDetails['serviceType'],
        ),
      ),
    ]);

    // Add route polyline
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_providerLocation, _customerLocation],
        color: AppTheme.primaryColor,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Simulate provider moving closer
          final random = Random();
          final timeLeft = int.parse(estimatedArrival.split(' ')[0]);
          if (timeLeft > 1) {
            estimatedArrival = '${timeLeft - 1} minutes';
          }
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(constraints),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildMapContainer(constraints),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                        child: Column(
                          children: [
                            _buildEnhancedProviderCard(constraints),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            _buildServiceDetailsCard(constraints),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            _buildEnhancedStatusTimeline(constraints),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            _buildActionButtons(constraints),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            _buildEmergencyCard(constraints),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButtons(),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BoxConstraints constraints) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isDarkMode
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)]
                  : [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Tracking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Provider arriving in $estimatedArrival',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              _refreshLocation();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapContainer(BoxConstraints constraints) {
    return Container(
      height: constraints.maxHeight * 0.4,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                setState(() => _isMapLoaded = true);
              },
              initialCameraPosition: CameraPosition(
                target: _customerLocation,
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              mapType: MapType.normal,
              style: _isDarkMode ? _darkMapStyle : null,
            ),
            // Floating info card on map
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Provider ${serviceDetails['distance']} away',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'ETA: $estimatedArrival',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Map controls
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: "zoom_in",
                    onPressed: () => _zoomIn(),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.add, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: "zoom_out",
                    onPressed: () => _zoomOut(),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.remove, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: "my_location",
                    onPressed: () => _goToMyLocation(),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedProviderCard(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth * 0.05),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: const NetworkImage('https://via.placeholder.com/80'),
                    radius: constraints.maxWidth * 0.08,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: constraints.maxWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceDetails['providerName'],
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceDetails['serviceType'],
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' ${serviceDetails['rating']} • ${serviceDetails['vehicleNumber']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'En Route',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoColumn(
                  Icons.access_time,
                  "ETA",
                  estimatedArrival,
                  AppTheme.primaryColor,
                  constraints,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildInfoColumn(
                  Icons.location_on,
                  "Distance",
                  serviceDetails['distance'],
                  Colors.orange,
                  constraints,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildInfoColumn(
                  Icons.currency_rupee,
                  "Cost",
                  serviceDetails['estimatedCost'],
                  Colors.green,
                  constraints,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Service Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Towing',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Service Type', serviceDetails['serviceType']),
          _buildDetailRow('Vehicle Number', serviceDetails['vehicleNumber']),
          _buildDetailRow('Distance to You', serviceDetails['distance']),
          _buildDetailRow('Estimated Cost', serviceDetails['estimatedCost']),
          _buildDetailRow('Service ID', 'MGM${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatusTimeline(BoxConstraints constraints) {
    final steps = [
      {
        "title": "Request Received",
        "subtitle": "Your service request was confirmed",
        "time": "10:30 AM",
        "done": true,
        "icon": Icons.assignment_turned_in
      },
      {
        "title": "Provider Assigned",
        "subtitle": "Rajesh Kumar accepted your request",
        "time": "10:32 AM",
        "done": true,
        "icon": Icons.person_add
      },
      {
        "title": "Provider En Route",
        "subtitle": "Provider is on the way to your location",
        "time": "10:35 AM",
        "done": true,
        "icon": Icons.directions_car
      },
      {
        "title": "Arrived at Location",
        "subtitle": "Provider will arrive soon",
        "time": null,
        "done": false,
        "icon": Icons.location_on
      },
      {
        "title": "Service Completed",
        "subtitle": "Service will be marked as complete",
        "time": null,
        "done": false,
        "icon": Icons.check_circle
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              const Text(
                "Service Timeline",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text(
                '${steps.where((s) => s["done"] == true).length}/${steps.length}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            final isDone = step["done"] as bool;
            final isCurrent = !isDone && index <= _currentStep;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDone
                              ? Colors.green
                              : isCurrent
                              ? AppTheme.primaryColor
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step["icon"] as IconData,
                          color: isDone || isCurrent ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: isDone ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step["title"] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDone
                                  ? Colors.green
                                  : _isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step["subtitle"] as String,
                            style: TextStyle(
                              color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          if (step["time"] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                step["time"] as String,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openChat(),
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: const Text("Chat with Provider"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _callProvider(),
              icon: const Icon(Icons.call, size: 20),
              label: const Text("Call Provider"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Emergency Help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap for immediate assistance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showEmergencyOptions(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SOS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: "share",
          onPressed: () => _shareLocation(),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.share_location, color: Colors.white),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "refresh",
          onPressed: () => _refreshLocation(),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(
      IconData icon,
      String label,
      String value,
      Color color,
      BoxConstraints constraints,
      ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.03,
            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: constraints.maxWidth * 0.035,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  // Map control methods
  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToMyLocation() {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  // Action methods
  void _refreshLocation() {
    HapticFeedback.lightImpact();
    setState(() {
      providerStatus = "Refreshing...";
    });

    // Simulate refresh
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          providerStatus = "On the way";
          final random = Random();
          final newEta = 8 + random.nextInt(7); // 8-14 minutes
          estimatedArrival = '$newEta minutes';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${serviceDetails['providerName']}...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Navigate to chat screen
  }

  void _callProvider() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.call, color: Colors.green),
            const SizedBox(width: 12),
            Text('Call ${serviceDetails['providerName']}?'),
          ],
        ),
        content: Text(
          'You are about to call ${serviceDetails['phone']}',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${serviceDetails['phone']}...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location shared with emergency contacts'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showEmergencyOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            const Text(
              'Emergency Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services, color: Colors.red),
              ),
              title: const Text('Call Ambulance'),
              subtitle: const Text('Emergency medical assistance'),
              onTap: () {
                Navigator.pop(context);
                _callEmergencyService('Ambulance');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_police, color: Colors.blue),
              ),
              title: const Text('Call Police'),
              subtitle: const Text('Police emergency assistance'),
              onTap: () {
                Navigator.pop(context);
                _callEmergencyService('Police');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.family_restroom, color: Colors.orange),
              ),
              title: const Text('Notify Family'),
              subtitle: const Text('Send alert to emergency contacts'),
              onTap: () {
                Navigator.pop(context);
                _notifyFamily();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _callEmergencyService(String service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Text('Calling $service'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 16),
            Text('Connecting to $service emergency services...'),
            const SizedBox(height: 8),
            const Text(
              'Your location has been shared automatically',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _notifyFamily() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alert sent to family members'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Dark map style
  static const String _darkMapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#181818"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#1b1b1b"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#2c2c2c"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8a8a8a"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#373737"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#3c3c3c"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#4e4e4e"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#3d3d3d"
          }
        ]
      }
    ]
  ''';
}