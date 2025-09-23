import 'package:flutter/material.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Services aligned with Marg Mitra's features
    final emergencyServices = [
      {
        "icon": Icons.emergency,
        "title": "Emergency SOS",
        "subtitle": "Instant emergency alert",
        "color": Colors.red,
      },
      {
        "icon": Icons.health_and_safety,
        "title": "Medical Emergency",
        "subtitle": "Connect to nearest hospital",
        "color": Colors.pink,
      },
    ];

    final roadSideServices = [
      {
        "icon": Icons.build_circle,
        "title": "Mechanic Service",
        "subtitle": "On-demand roadside repair",
        "color": Colors.orange,
      },
      {
        "icon": Icons.local_gas_station,
        "title": "Fuel Delivery",
        "subtitle": "Emergency fuel service",
        "color": Colors.green,
      },
      {
        "icon": Icons.car_crash,
        "title": "Towing Service",
        "subtitle": "24/7 vehicle towing",
        "color": Colors.purple,
      },
      {
        "icon": Icons.battery_charging_full,
        "title": "Battery Jump-start",
        "subtitle": "Quick battery assistance",
        "color": Colors.amber,
      },
    ];

    final travelServices = [
      {
        "icon": Icons.map,
        "title": "Trip Planning",
        "subtitle": "AI-powered route optimization",
        "color": Colors.teal,
      },
      {
        "icon": Icons.people,
        "title": "Local Guides",
        "subtitle": "Connect with verified guides",
        "color": Colors.indigo,
      },
      {
        "icon": Icons.home,
        "title": "Homestays",
        "subtitle": "Verified accommodation",
        "color": Colors.brown,
      },
      {
        "icon": Icons.shield_outlined,
        "title": "Travel Insurance",
        "subtitle": "Comprehensive coverage",
        "color": Colors.blueGrey,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Text(
          "Marg Mitra Services",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Services Section
              _buildSectionHeader(
                "Emergency Services",
                Icons.warning_amber_rounded,
                Colors.red,
              ),
              const SizedBox(height: 12),
              _buildServiceGrid(context, emergencyServices, 2),

              const SizedBox(height: 24),

              // Roadside Assistance Section
              _buildSectionHeader(
                "Roadside Assistance",
                Icons.car_repair,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildServiceGrid(context, roadSideServices, 2),

              const SizedBox(height: 24),

              // Travel Services Section
              _buildSectionHeader(
                "Travel Services",
                Icons.flight_takeoff,
                Colors.teal,
              ),
              const SizedBox(height: 12),
              _buildServiceGrid(context, travelServices, 2),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showEmergencyDialog(context);
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.emergency, color: Colors.white),
        label: const Text(
          "Emergency SOS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
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
    );
  }

  Widget _buildServiceGrid(BuildContext context, List<Map<String, dynamic>> services, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(context, service);
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        _handleServiceTap(context, service["title"]);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (service["color"] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service["icon"] as IconData,
                size: 36,
                color: service["color"] as Color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service["title"] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                service["subtitle"] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleServiceTap(BuildContext context, String serviceName) {
    if (serviceName == "Emergency SOS" || serviceName == "Medical Emergency") {
      _showEmergencyDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text("Connecting to $serviceName..."),
            ],
          ),
          backgroundColor: Colors.blue[700],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.emergency, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              const Text("Emergency Alert"),
            ],
          ),
          content: const Text(
            "This will immediately alert emergency services and your emergency contacts. Are you sure you want to proceed?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Emergency alert sent! Help is on the way."),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Send SOS",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}