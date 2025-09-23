import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and App Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.build_circle,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Marg Mitra',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // About Content
            _buildSectionCard(
              title: 'Our Mission',
              content:
              'The mission of Marg Mitra is to make travel safe and reliable in India. We use AI-powered technology to provide 24/7 roadside assistance.',
              icon: Icons.flag,
            ),

            _buildSectionCard(
              title: 'Our Services',
              content:
              '• Instant Roadside Assistance\n• Smart AI Matching\n• Real-Time Tracking\n• 24/7 Emergency Support\n• Preventive Maintenance Tips',
              icon: Icons.build_circle,
            ),

            _buildSectionCard(
              title: 'Contact Information',
              content:
              'Email: support@margmitra.com\nPhone: 1800-MARG-HELP\nWebsite: www.margmitra.com',
              icon: Icons.contact_support,
            ),

            const SizedBox(height: 20),

            // Team Section
            const Text(
              'Our Team',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamMember('Raj Sharma', 'Founder & CEO'),
                _buildTeamMember('Priya Patel', 'Tech Lead'),
                _buildTeamMember('Amit Singh', 'Operations Head'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF1E88E5),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF1E88E5),
          child: Text(
            name[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          role,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
