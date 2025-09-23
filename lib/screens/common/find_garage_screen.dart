import 'package:flutter/material.dart';

class FindGarageScreen extends StatefulWidget {
  const FindGarageScreen({super.key});

  @override
  State<FindGarageScreen> createState() => _FindGarageScreenState();
}

class _FindGarageScreenState extends State<FindGarageScreen> {
  String selectedServiceType = 'All Services';
  String searchQuery = '';
  bool isEmergencyMode = false;

  final List<String> serviceTypes = [
    'All Services',
    'Emergency Repair',
    'Engine Service',
    'Tire Service',
    'Battery Service',
    'Fuel Service',
    'Towing Service',
    'AC Repair',
    'Brake Service'
  ];

  final List<Map<String, dynamic>> garages = [
    {
      "name": "24/7 AutoCare Garage",
      "location": "Near City Mall, Sector 18",
      "distance": "2.5 km",
      "rating": 4.8,
      "reviews": 156,
      "services": ["Emergency Repair", "Engine Service", "Battery Service"],
      "isVerified": true,
      "isEmergencyAvailable": true,
      "price": "₹500-2000",
      "responseTime": "15 min",
      "contact": "+91 98765 43210",
      "isOpen": true
    },
    {
      "name": "QuickFix Emergency Hub",
      "location": "Highway Road, NH-48",
      "distance": "4.1 km",
      "rating": 4.6,
      "reviews": 203,
      "services": ["Emergency Repair", "Towing Service", "Tire Service"],
      "isVerified": true,
      "isEmergencyAvailable": true,
      "price": "₹400-1800",
      "responseTime": "12 min",
      "contact": "+91 87654 32109",
      "isOpen": true
    },
    {
      "name": "Super Wheels Service Center",
      "location": "Green Park Area, Block-C",
      "distance": "3.3 km",
      "rating": 4.5,
      "reviews": 89,
      "services": ["Engine Service", "AC Repair", "Brake Service"],
      "isVerified": true,
      "isEmergencyAvailable": false,
      "price": "₹600-2500",
      "responseTime": "25 min",
      "contact": "+91 76543 21098",
      "isOpen": true
    },
    {
      "name": "Mitra Auto Solutions",
      "location": "Industrial Area, Phase-2",
      "distance": "5.8 km",
      "rating": 4.7,
      "reviews": 124,
      "services": ["All Services"],
      "isVerified": true,
      "isEmergencyAvailable": true,
      "price": "₹450-2200",
      "responseTime": "20 min",
      "contact": "+91 65432 10987",
      "isOpen": false
    },
  ];

  List<Map<String, dynamic>> get filteredGarages {
    return garages.where((garage) {
      bool matchesSearch = garage['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          garage['location'].toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesService = selectedServiceType == 'All Services' ||
          garage['services'].contains(selectedServiceType);

      bool matchesEmergency = !isEmergencyMode || garage['isEmergencyAvailable'];

      return matchesSearch && matchesService && matchesEmergency;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Text(
          "Find Garage - Marg Mitra",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isEmergencyMode ? Icons.emergency : Icons.emergency_outlined,
              color: isEmergencyMode ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isEmergencyMode = !isEmergencyMode;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEmergencyMode
                        ? "Emergency Mode Activated - Showing only emergency services"
                        : "Emergency Mode Deactivated",
                  ),
                  backgroundColor: isEmergencyMode ? Colors.red : Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Alert Banner
          if (isEmergencyMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[800], size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "EMERGENCY MODE: Showing verified emergency services only",
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Map View Container
          Container(
            height: 180,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.blue[50],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            "🗺️ Live Map Integration",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Real-time garage locations",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Live GPS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search garages by name or location...",
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Service Type Filter
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: serviceTypes.length,
                    itemBuilder: (context, index) {
                      final serviceType = serviceTypes[index];
                      final isSelected = selectedServiceType == serviceType;

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            serviceType,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedServiceType = serviceType;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue[800],
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Results Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  "${filteredGarages.length} Verified Garages Found",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isEmergencyMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "EMERGENCY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Garage List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredGarages.length,
              itemBuilder: (context, index) {
                final garage = filteredGarages[index];
                return _buildGarageCard(garage);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGarageCard(Map<String, dynamic> garage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and verification
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              garage['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (garage['isVerified'])
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, color: Colors.green[800], size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    "Verified",
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              garage['location'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: garage['isOpen'] ? Colors.green[100] : Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    garage['isOpen'] ? Icons.check_circle : Icons.cancel,
                    color: garage['isOpen'] ? Colors.green[800] : Colors.red[800],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatItem(Icons.star, "${garage['rating']}", Colors.orange),
                const SizedBox(width: 16),
                _buildStatItem(Icons.reviews, "${garage['reviews']} reviews", Colors.blue),
                const SizedBox(width: 16),
                _buildStatItem(Icons.location_on, garage['distance'], Colors.green),
                const Spacer(),
                if (garage['isEmergencyAvailable'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "24/7 Emergency",
                      style: TextStyle(
                        color: Colors.red[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Services and Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.build, color: Colors.blue[800], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Services:",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: garage['services'].take(3).map<Widget>((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Price and Response Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    garage['price'],
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.orange[800]),
                      const SizedBox(width: 2),
                      Text(
                        garage['responseTime'],
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: garage['isOpen'] ? () {
                      _handleNavigation(garage);
                    } : null,
                    icon: const Icon(Icons.navigation, size: 18),
                    label: const Text("Navigate"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _handleCall(garage);
                    },
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("Call Now"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      side: BorderSide(color: Colors.blue[800]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showGarageDetails(garage);
                    },
                    icon: Icon(Icons.info_outline, color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleNavigation(Map<String, dynamic> garage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Navigate to ${garage['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: ${garage['location']}"),
            Text("Distance: ${garage['distance']}"),
            Text("Estimated Time: ${garage['responseTime']}"),
            if (isEmergencyMode)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "⚠️ Emergency navigation activated - Priority route will be provided",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("🚗 Navigating to ${garage['name']}..."),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Start Navigation"),
          ),
        ],
      ),
    );
  }

  void _handleCall(Map<String, dynamic> garage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Call ${garage['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Contact: ${garage['contact']}"),
            if (isEmergencyMode)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "🚨 Emergency call - Your location and health data will be shared automatically",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("📞 Calling ${garage['name']}..."),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text("Call Now"),
          ),
        ],
      ),
    );
  }

  void _showGarageDetails(Map<String, dynamic> garage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    garage['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "📍 ${garage['location']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "📞 ${garage['contact']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Services Offered:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: garage['services'].map<Widget>((service) {
                return Chip(
                  label: Text(service),
                  backgroundColor: Colors.blue[100],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(garage['price']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text("Response Time", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(garage['responseTime']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (garage['isVerified'])
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green[800]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "✅ Verified by Marg Mitra\n• Identity verified\n• Service quality assured\n• Secure payments",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}