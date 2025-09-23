class ServiceRequestModel {
  final String id;
  final String userId;
  final String serviceType;
  final String location;
  final String distance;
  final String estimatedPrice;
  final String urgency;
  final DateTime createdAt;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String status;

  ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.location,
    required this.distance,
    required this.estimatedPrice,
    required this.urgency,
    DateTime? createdAt,
    this.description,
    this.latitude,
    this.longitude,
    this.status = 'pending',
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from JSON
  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      serviceType: json['serviceType'] ?? '',
      location: json['location'] ?? '',
      distance: json['distance'] ?? '',
      estimatedPrice: json['estimatedPrice'] ?? '',
      urgency: json['urgency'] ?? 'Low',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      description: json['description'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: json['status'] ?? 'pending',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceType': serviceType,
      'location': location,
      'distance': distance,
      'estimatedPrice': estimatedPrice,
      'urgency': urgency,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }

  // Create a copy with updated fields
  ServiceRequestModel copyWith({
    String? id,
    String? userId,
    String? serviceType,
    String? location,
    String? distance,
    String? estimatedPrice,
    String? urgency,
    DateTime? createdAt,
    String? description,
    double? latitude,
    double? longitude,
    String? status,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      urgency: urgency ?? this.urgency,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ServiceRequestModel(id: $id, serviceType: $serviceType, location: $location, urgency: $urgency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceRequestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}