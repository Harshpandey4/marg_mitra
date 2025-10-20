class AlertConfig {
  final bool enableHeartRateAlerts;
  final bool enableImpactDetection;
  final bool enableDrowsinessAlerts;
  final bool enableStressAlerts;
  final int heartRateThresholdLow;
  final int heartRateThresholdHigh;
  final int oxygenThreshold;
  final int stressThreshold;
  final bool autoCallEmergency;
  final bool notifyEmergencyContacts;
  final bool shareLocationOnAlert;

  AlertConfig({
    this.enableHeartRateAlerts = true,
    this.enableImpactDetection = true,
    this.enableDrowsinessAlerts = true,
    this.enableStressAlerts = true,
    this.heartRateThresholdLow = 50,
    this.heartRateThresholdHigh = 120,
    this.oxygenThreshold = 90,
    this.stressThreshold = 70,
    this.autoCallEmergency = false,
    this.notifyEmergencyContacts = true,
    this.shareLocationOnAlert = true,
  });

  AlertConfig copyWith({
    bool? enableHeartRateAlerts,
    bool? enableImpactDetection,
    bool? enableDrowsinessAlerts,
    bool? enableStressAlerts,
    int? heartRateThresholdLow,
    int? heartRateThresholdHigh,
    int? oxygenThreshold,
    int? stressThreshold,
    bool? autoCallEmergency,
    bool? notifyEmergencyContacts,
    bool? shareLocationOnAlert,
  }) {
    return AlertConfig(
      enableHeartRateAlerts: enableHeartRateAlerts ?? this.enableHeartRateAlerts,
      enableImpactDetection: enableImpactDetection ?? this.enableImpactDetection,
      enableDrowsinessAlerts: enableDrowsinessAlerts ?? this.enableDrowsinessAlerts,
      enableStressAlerts: enableStressAlerts ?? this.enableStressAlerts,
      heartRateThresholdLow: heartRateThresholdLow ?? this.heartRateThresholdLow,
      heartRateThresholdHigh: heartRateThresholdHigh ?? this.heartRateThresholdHigh,
      oxygenThreshold: oxygenThreshold ?? this.oxygenThreshold,
      stressThreshold: stressThreshold ?? this.stressThreshold,
      autoCallEmergency: autoCallEmergency ?? this.autoCallEmergency,
      notifyEmergencyContacts: notifyEmergencyContacts ?? this.notifyEmergencyContacts,
      shareLocationOnAlert: shareLocationOnAlert ?? this.shareLocationOnAlert,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableHeartRateAlerts': enableHeartRateAlerts,
      'enableImpactDetection': enableImpactDetection,
      'enableDrowsinessAlerts': enableDrowsinessAlerts,
      'enableStressAlerts': enableStressAlerts,
      'heartRateThresholdLow': heartRateThresholdLow,
      'heartRateThresholdHigh': heartRateThresholdHigh,
      'oxygenThreshold': oxygenThreshold,
      'stressThreshold': stressThreshold,
      'autoCallEmergency': autoCallEmergency,
      'notifyEmergencyContacts': notifyEmergencyContacts,
      'shareLocationOnAlert': shareLocationOnAlert,
    };
  }

  factory AlertConfig.fromMap(Map<String, dynamic> map) {
    return AlertConfig(
      enableHeartRateAlerts: map['enableHeartRateAlerts'] ?? true,
      enableImpactDetection: map['enableImpactDetection'] ?? true,
      enableDrowsinessAlerts: map['enableDrowsinessAlerts'] ?? true,
      enableStressAlerts: map['enableStressAlerts'] ?? true,
      heartRateThresholdLow: map['heartRateThresholdLow'] ?? 50,
      heartRateThresholdHigh: map['heartRateThresholdHigh'] ?? 120,
      oxygenThreshold: map['oxygenThreshold'] ?? 90,
      stressThreshold: map['stressThreshold'] ?? 70,
      autoCallEmergency: map['autoCallEmergency'] ?? false,
      notifyEmergencyContacts: map['notifyEmergencyContacts'] ?? true,
      shareLocationOnAlert: map['shareLocationOnAlert'] ?? true,
    );
  }
}