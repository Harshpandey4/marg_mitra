import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class EmergencyContactScreen extends StatefulWidget {
  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyHeader(),
            SizedBox(height: 20),
            _buildQuickEmergencyActions(),
            SizedBox(height: 20),
            _buildEmergencyContacts(),
            SizedBox(height: 20),
            _buildPersonalEmergencyContacts(),
            SizedBox(height: 20),
            _buildSafetyTips(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      title: Text(
        'Emergency Contacts',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
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
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Assistance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quick access to help when you need it most',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEmergencyActions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Emergency Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'SOS Alert',
                  Icons.warning,
                  Colors.red,
                      () => _sendSOSAlert(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Share Location',
                  Icons.location_on,
                  Colors.blue,
                      () => _shareLocation(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    final emergencyServices = [
      {
        'name': 'Police',
        'number': '100',
        'icon': Icons.local_police,
        'color': Colors.blue,
        'description': 'For crimes and security issues',
      },
      {
        'name': 'Fire Brigade',
        'number': '101',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
        'description': 'For fire emergencies',
      },
      {
        'name': 'Ambulance',
        'number': '108',
        'icon': Icons.local_hospital,
        'color': Colors.green,
        'description': 'Medical emergencies',
      },
      {
        'name': 'Women Helpline',
        'number': '1091',
        'icon': Icons.support_agent,
        'color': Colors.purple,
        'description': 'For women in distress',
      },
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          ...emergencyServices.map((service) => _buildEmergencyContactCard(service)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(Map<String, dynamic> service) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _makeCall(service['number']);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (service['color'] as Color).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (service['color'] as Color).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (service['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          service['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        Text(
                          service['number'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: service['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      service['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: service['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalEmergencyContacts() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Personal Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              TextButton.icon(
                onPressed: _addPersonalContact,
                icon: Icon(Icons.add, size: 16),
                label: Text('Add'),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildPersonalContactCard(
            'Rajesh Kumar',
            '+91 9876543210',
            'Family',
            Icons.family_restroom,
            Colors.green,
          ),
          SizedBox(height: 12),
          _buildPersonalContactCard(
            'Marg Mitra Support',
            '+91 1800-123-456',
            'Company Support',
            Icons.support_agent,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalContactCard(String name, String number, String relation, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _makeCall(number);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    relation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.call, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Safety Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSafetyTip('Always share your location with family when going to remote areas'),
          _buildSafetyTip('Keep your phone charged and carry a power bank'),
          _buildSafetyTip('Trust your instincts if a situation feels unsafe'),
          _buildSafetyTip('Inform customers about your arrival time'),
        ],
      ),
    );
  }

  Widget _buildSafetyTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendSOSAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('SOS Alert'),
          ],
        ),
        content: Text('This will send your location and emergency alert to all your emergency contacts. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSOSConfirmation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Send Alert', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Location shared with emergency contacts'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _makeCall(String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Call $number?'),
        content: Text('This will make a call to $number'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement actual calling functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $number...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  void _addPersonalContact() {
    // Navigate to add contact screen or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add contact feature will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSOSConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('SOS alert sent successfully'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }
}