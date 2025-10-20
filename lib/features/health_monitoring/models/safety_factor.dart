import 'enums.dart';

class SafetyFactor {
  final FactorType type;
  final String name;
  final double severity; // 0.0 to 1.0
  final String description;
  final String actionRequired;
  final DateTime timestamp;

  SafetyFactor({
    required this.type,
    required this.name,
    required this.severity,
    required this.description,
    required this.actionRequired,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'name': name,
      'severity': severity,
      'description': description,
      'actionRequired': actionRequired,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SafetyFactor.fromMap(Map<String, dynamic> map) {
    return SafetyFactor(
      type: FactorType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => FactorType.health,
      ),
      name: map['name'] ?? '',
      severity: (map['severity'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      actionRequired: map['actionRequired'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}