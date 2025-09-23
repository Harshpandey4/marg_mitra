enum UserRole { user, provider, admin }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final List<String> emergencyContacts;
  final VehicleInfo? vehicleInfo;
  final LocationInfo? currentLocation;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.emergencyContacts = const [],
    this.vehicleInfo,
    this.currentLocation,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    List<String>? emergencyContacts,
    VehicleInfo? vehicleInfo,
    LocationInfo? currentLocation,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

class VehicleInfo {
  final String make;
  final String model;
  final String year;
  final String plateNumber;

  VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    required this.plateNumber,
  });
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });
}