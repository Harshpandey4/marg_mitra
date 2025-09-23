import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _autoSosEnabled = false;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Englissh';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings
            _buildSectionHeader('General Settings'),
            _buildSettingsCard([
              _buildSwitchTile(
                title: 'Notifications',
                subtitle: 'Enable/Disable app notifications',
                icon: Icons.notifications,
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildListTile(
                title: 'Clear Cache',
                subtitle: 'Remove temporary files',
                icon: Icons.cleaning_services,
                onTap: () {
                  _clearCache();
                },
              ),
              _buildListTile(
                title: 'App Version',
                subtitle: 'v1.0.0 (Build 1)',
                icon: Icons.info,
                onTap: null,
              ),
            ]),

            const SizedBox(height: 20),

            // Support & Feedback
            _buildSectionHeader('Support & Feedback'),
            _buildSettingsCard([
              _buildListTile(
                title: 'Help Center',
                subtitle: 'FAQ and support guides',
                icon: Icons.help_center,
                onTap: () {
                  // Navigate to help center
                },
              ),
              _buildListTile(
                title: 'Send Feedback',
                subtitle: 'Share your opinion about the app',
                icon: Icons.feedback,
                onTap: () {
                  // Navigate to feedback
                },
              ),
              _buildListTile(
                title: 'Rate Us',
                subtitle: 'Rate the app on Play Store',
                icon: Icons.star_rate,
                onTap: () {
                  // Open play store rating
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Legal
            _buildSectionHeader('Legal'),
            _buildSettingsCard([
              _buildListTile(
                title: 'Terms & Conditions',
                subtitle: 'Read terms of use',
                icon: Icons.description,
                onTap: () {
                  // Navigate to terms
                },
              ),
              _buildListTile(
                title: 'Privacy Policy',
                subtitle: 'Data usage policy',
                icon: Icons.policy,
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              _buildListTile(
                title: 'Licenses',
                subtitle: 'Open source licenses',
                icon: Icons.copyright,
                onTap: () {
                  // Navigate to licenses
                },
              ),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E88E5)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E88E5),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E88E5)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E88E5)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
