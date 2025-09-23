import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


// Profile state provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

// State model
class ProfileState {
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool isEditing;

  ProfileState({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.isEditing,
  });

  ProfileState copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? isEditing,
  }) {
    return ProfileState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

// State Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
    name: 'Raj Kumar',
    phone: '+91 98765 43210',
    email: 'raj.kumar@email.com',
    address: 'New Delhi, India',
    isEditing: false,
  ));

  void toggleEdit() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void saveProfile(BuildContext context) {
    state = state.copyWith(isEditing: false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(profile.isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (profile.isEditing) {
                notifier.saveProfile(context);
              } else {
                notifier.toggleEdit();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(profile, notifier),
            const SizedBox(height: 20),
            _buildStats(),
            const SizedBox(height: 25),
            _buildProfileForm(profile, notifier, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState profile, ProfileNotifier notifier) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E88E5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
              if (profile.isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Color(0xFF1E88E5),
                      ),
                      onPressed: () {
                        // Change profile picture logic
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Traveler',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Trips', '25', Icons.directions_car)),
          const SizedBox(width: 15),
          Expanded(child: _buildStatCard('Service Calls', '8', Icons.build)),
          const SizedBox(width: 15),
          Expanded(child: _buildStatCard('Rating', '4.8', Icons.star)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1E88E5), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(ProfileState profile, ProfileNotifier notifier, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileField(
            label: 'Name',
            icon: Icons.person,
            value: profile.name,
            enabled: profile.isEditing,
            onChanged: notifier.updateName,
          ),
          _buildProfileField(
            label: 'Mobile Number',
            icon: Icons.phone,
            value: profile.phone,
            enabled: profile.isEditing,
            onChanged: notifier.updatePhone,
          ),
          _buildProfileField(
            label: 'Email',
            icon: Icons.email,
            value: profile.email,
            enabled: profile.isEditing,
            onChanged: notifier.updateEmail,
          ),
          _buildProfileField(
            label: 'Address',
            icon: Icons.location_on,
            value: profile.address,
            enabled: profile.isEditing,
            onChanged: notifier.updateAddress,
          ),
          const SizedBox(height: 30),
          _buildActionButton('Service History', Icons.history, () {
            Navigator.pushNamed(context, '/service-history');
          }),
          _buildActionButton('Favorite Technicians', Icons.favorite, () {}),
          _buildActionButton('Emergency Contacts', Icons.emergency, () {}),
          _buildActionButton('Help', Icons.help, () {}),
          _buildActionButton(
            'Logout',
            Icons.logout,
                () => _logout(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required IconData icon,
    required String value,
    required bool enabled,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: value,
        enabled: enabled,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF1E88E5),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : const Color(0xFF212121),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
