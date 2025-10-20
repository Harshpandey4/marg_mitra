import 'enums.dart';  // ADD THIS
import 'safety_factor.dart';  // ADD THIS

class SafetyAssessment {
  final DateTime timestamp;
  final SafetyLevel overallSafety;
  final List<SafetyFactor> factors;
  final List<String> warnings;
  final List<String> recommendations;
  final double confidenceScore;

  final bool impactDetected;
  final bool suddenMovement;
  final bool abnormalHeartRate;
  final bool lowOxygen;
  final bool highStress;

  final DrivingCondition? drivingCondition;
  final WeatherImpact? weatherImpact;

  // ADD CONSTRUCTOR - Ye neeche add karo
  SafetyAssessment({
    required this.timestamp,
    required this.overallSafety,
    required this.factors,
    required this.warnings,
    required this.recommendations,
    required this.confidenceScore,
    required this.impactDetected,
    required this.suddenMovement,
    required this.abnormalHeartRate,
    required this.lowOxygen,
    required this.highStress,
    this.drivingCondition,
    this.weatherImpact,
  });

  // ADD YE GETTERS - Ye bhi add karo
  bool get requiresAlert => overallSafety != SafetyLevel.safe;

  bool get requiresEmergencyResponse => overallSafety == SafetyLevel.critical;

  String get primaryWarning {
    if (warnings.isNotEmpty) {
      return warnings.first;
    }
    return 'No alerts';
  }
}