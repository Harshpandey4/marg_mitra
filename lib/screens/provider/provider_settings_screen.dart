import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class ProviderSettingsScreen extends StatefulWidget {
  @override
  _ProviderSettingsScreenState createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationTracking = true;
  bool _autoAcceptJobs = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  bool _availabilityStatus = true;

  String _selectedLanguage = 'English';
  String _serviceRadius = '15 km';
  String _workingHours = '9 AM - 6 PM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            SizedBox(height: 20),
            _buildServiceSettings(),
            SizedBox(height: 20),
            _buildNotificationSettings(),
            SizedBox(height: 20),
            _buildLocationSettings(),
            SizedBox(height: 20),
            _buildAppSettings(),
            SizedBox(height: 20),
            _buildAccountSettings(),
            SizedBox(height: 20),
            _buildSupportSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      title: Text(
        'Settings',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _saveSettings,
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.all(20),
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
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Rajesh Kumar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'Vehicle Repair Specialist',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStat('Rating', '4.8'),
              _buildProfileStat('Jobs', '156'),
              _buildProfileStat('Experience', '3 Years'),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _editProfile,
            icon: Icon(Icons.edit, size: 16),
            label: Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSettings() {
    return _buildSettingsSection(
      'Service Settings',
      Icons.build,
      [
        _buildSwitchTile(
          'Availability Status',
          'Accept new service requests',
          _availabilityStatus,
              (value) => setState(() => _availabilityStatus = value),
        ),
        _buildSwitchTile(
          'Auto Accept Jobs',
          'Automatically accept matching jobs',
          _autoAcceptJobs,
              (value) => setState(() => _autoAcceptJobs = value),
        ),
        _buildSelectTile(
          'Service Radius',
          'How far you\'re willing to travel',
          _serviceRadius,
          ['5 km', '10 km', '15 km', '20 km', '25 km'],
              (value) => setState(() => _serviceRadius = value),
        ),
        _buildSelectTile(
          'Working Hours',
          'Your availability hours',
          _workingHours,
          ['6 AM - 8 PM', '8 AM - 6 PM', '9 AM - 6 PM', '24/7'],
              (value) => setState(() => _workingHours = value),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      'Notifications',
      Icons.notifications,
      [
        _buildSwitchTile(
          'Push Notifications',
          'Receive job alerts and updates',
          _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
        ),
        _buildSwitchTile(
          'Sound Alerts',
          'Play sound for new notifications',
          _soundEnabled,
              (value) => setState(() => _soundEnabled = value),
        ),
        _buildSwitchTile(
          'Vibration',
          'Vibrate for notifications',
          _vibrationEnabled,
              (value) => setState(() => _vibrationEnabled = value),
        ),
        _buildTile(
          'Notification Schedule',
          'Set quiet hours',
          Icons.schedule,
              () => _showNotificationSchedule(),
        ),
      ],
    );
  }

  Widget _buildLocationSettings() {
    return _buildSettingsSection(
      'Location & Privacy',
      Icons.location_on,
      [
        _buildSwitchTile(
          'Location Tracking',
          'Allow location tracking for jobs',
          _locationTracking,
              (value) => setState(() => _locationTracking = value),
        ),
        _buildTile(
          'Location History',
          'View your location history',
          Icons.history,
              () => _showLocationHistory(),
        ),
        _buildTile(
          'Privacy Settings',
          'Manage your privacy preferences',
          Icons.privacy_tip,
              () => _showPrivacySettings(),
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _buildSettingsSection(
      'App Settings',
      Icons.settings,
      [
        _buildSwitchTile(
          'Dark Mode',
          'Use dark theme',
          _darkMode,
              (value) => setState(() => _darkMode = value),
        ),
        _buildSelectTile(
          'Language',
          'Choose your preferred language',
          _selectedLanguage,
          ['English', 'Hindi', 'Gujarati', 'Marathi'],
              (value) => setState(() => _selectedLanguage = value),
        ),
        _buildTile(
          'Cache Settings',
          'Manage app data and cache',
          Icons.storage,
              () => _showCacheSettings(),
        ),
        _buildTile(
          'App Version',
          'v1.2.3 (Latest)',
          Icons.info,
          null,
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _buildSettingsSection(
      'Account',
      Icons.account_circle,
      [
        _buildTile(
          'Change Password',
          'Update your account password',
          Icons.lock,
              () => _changePassword(),
        ),
        _buildTile(
          'Bank Details',
          'Manage payment information',
          Icons.account_balance,
              () => _manageBankDetails(),
        ),
        _buildTile(
          'Documents',
          'Verify and update documents',
          Icons.description,
              () => _manageDocuments(),
        ),
        _buildTile(
          'Delete Account',
          'Permanently delete your account',
          Icons.delete_forever,
              () => _deleteAccount(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSettingsSection(
      'Support',
      Icons.help,
      [
        _buildTile(
          'Help Center',
          'Get answers to common questions',
          Icons.help_center,
              () => _openHelpCenter(),
        ),
        _buildTile(
          'Contact Support',
          'Get in touch with our team',
          Icons.support_agent,
              () => _contactSupport(),
        ),
        _buildTile(
          'Report Issue',
          'Report bugs or problems',
          Icons.bug_report,
              () => _reportIssue(),
        ),
        _buildTile(
          'Rate App',
          'Rate us on Play Store',
          Icons.star_rate,
              () => _rateApp(),
        ),
        _buildTile(
          'Terms & Privacy',
          'Read our terms and privacy policy',
          Icons.gavel,
              () => _showTermsAndPrivacy(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Container(
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
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
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          onChanged(newValue);
        },
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSelectTile(String title, String subtitle, String currentValue, List<String> options, ValueChanged<String> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentValue,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
      onTap: () => _showSelectionDialog(title, options, currentValue, onChanged),
    );
  }

  Widget _buildTile(String title, String subtitle, IconData icon, VoidCallback? onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? Colors.red : AppTheme.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: onTap != null
          ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400])
          : null,
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap();
      } : null,
    );
  }

  void _showSelectionDialog(String title, List<String> options, String currentValue, ValueChanged<String> onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: currentValue,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              Navigator.pop(context);
              if (value != null) onChanged(value);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _saveSettings() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Settings saved successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Edit Profile'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 80, color: AppTheme.primaryColor),
                SizedBox(height: 20),
                Text(
                  'Edit Profile Screen',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Under development',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Notification Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set quiet hours when you don\'t want to receive notifications'),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('From: 10:00 PM')),
                Expanded(child: Text('To: 7:00 AM')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Save')),
        ],
      ),
    );
  }

  void _showLocationHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location history feature coming soon')),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy settings feature coming soon')),
    );
  }

  void _showCacheSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cache Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Clear app cache to free up storage space'),
            SizedBox(height: 16),
            Text('Cache size: 45.2 MB', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Change Password'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password changed successfully')),
                    );
                  },
                  child: Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _manageBankDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bank details management coming soon')),
    );
  }

  void _manageDocuments() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document management coming soon')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening help center...')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting support...')),
    );
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report issue feature coming soon')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening Play Store...')),
    );
  }

  void _showTermsAndPrivacy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening terms and privacy...')),
    );
  }
}