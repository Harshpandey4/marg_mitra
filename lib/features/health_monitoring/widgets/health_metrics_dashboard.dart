// lib/features/health_monitoring/widgets/health_metrics_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_monitoring_providers.dart';
import '../models/health_data.dart';
import '../models/safety_assessment.dart';
import '../models/enums.dart';
class HealthMetricsDashboard extends ConsumerWidget {
  const HealthMetricsDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthDataAsync = ref.watch(healthDataStreamProvider);
    final safetyAssessmentAsync = ref.watch(safetyAssessmentStreamProvider);
    final isConnected = ref.watch(isDeviceConnectedProvider);

    if (!isConnected) {
      return _buildNotConnectedState();
    }

    return healthDataAsync.when(
      data: (healthData) => _buildDashboard(context, ref, healthData, safetyAssessmentAsync),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildDashboard(
      BuildContext context,
      WidgetRef ref,
      HealthData healthData,
      AsyncValue<SafetyAssessment> safetyAssessmentAsync,
      ) {
    return Column(
      children: [
        // Real-time Health Metrics
        _buildHealthMetricsGrid(healthData),
        const SizedBox(height: 16),

        // Safety Assessment
        safetyAssessmentAsync.when(
          data: (assessment) => _buildSafetyAssessmentCard(assessment),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),

        // Activity Status
        _buildActivityCard(healthData),
      ],
    );
  }

  Widget _buildHealthMetricsGrid(HealthData healthData) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildMetricCard(
          'Heart Rate',
          '${healthData.heartRate}',
          'BPM',
          Icons.favorite,
          _getHeartRateColor(healthData.heartRate),
          healthData.isHeartRateAbnormal,
        ),
        _buildMetricCard(
          'SpO2',
          '${healthData.oxygenSaturation ?? '--'}',
          '%',
          Icons.air,
          _getSpO2Color(healthData.oxygenSaturation),
          healthData.isOxygenLow,
        ),
        _buildMetricCard(
          'Stress Level',
          '${healthData.stressLevel ?? '--'}',
          '/100',
          Icons.psychology,
          _getStressColor(healthData.stressLevel),
          healthData.isStressHigh,
        ),
        _buildMetricCard(
          'HRV Score',
          '${healthData.hrvScore ?? '--'}',
          '',
          Icons.timeline,
          Colors.purple,
          false,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title,
      String value,
      String unit,
      IconData icon,
      Color color,
      bool isAbnormal,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbnormal ? Colors.red : color.withOpacity(0.3),
          width: isAbnormal ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAbnormal ? Colors.red : color).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (isAbnormal)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning, color: Colors.white, size: 12),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isAbnormal ? Colors.red : Colors.grey[800],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyAssessmentCard(SafetyAssessment assessment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getSafetyGradient(assessment.overallSafety),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getSafetyColor(assessment.overallSafety).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSafetyIcon(assessment.overallSafety),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Safety Assessment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSafetyText(assessment.overallSafety),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(assessment.confidenceScore * 100).toInt()}% confident',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (assessment.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Warnings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...assessment.warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.white, size: 6),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],

          if (assessment.recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Recommendations',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...assessment.recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityCard(HealthData healthData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_run, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Real-time motion tracking',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActivityStat(
                  'Activity',
                  _getActivityText(healthData.currentActivity),
                  _getActivityIcon(healthData.currentActivity),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivityStat(
                  'Steps',
                  '${healthData.steps ?? 0}',
                  Icons.directions_walk,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivityStat(
                  'Calories',
                  '${healthData.calories?.toStringAsFixed(0) ?? 0}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotConnectedState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.watch_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Smartwatch Connected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your smartwatch to start\nreal-time health monitoring',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading health data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Helper methods for colors and icons
  Color _getHeartRateColor(int heartRate) {
    if (heartRate < 40 || heartRate > 140) return Colors.red;
    if (heartRate < 50 || heartRate > 120) return Colors.orange;
    return Colors.green;
  }

  Color _getSpO2Color(int? spO2) {
    if (spO2 == null) return Colors.grey;
    if (spO2 < 90) return Colors.red;
    if (spO2 < 95) return Colors.orange;
    return Colors.green;
  }

  Color _getStressColor(int? stress) {
    if (stress == null) return Colors.grey;
    if (stress > 70) return Colors.red;
    if (stress > 50) return Colors.orange;
    return Colors.green;
  }

  Color _getSafetyColor(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.critical:
        return Colors.red;
      case SafetyLevel.warning:
        return Colors.orange;
      case SafetyLevel.caution:
        return Colors.yellow;
      case SafetyLevel.safe:
        return Colors.green;
    }
  }

  List<Color> _getSafetyGradient(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.critical:
        return [Colors.red[700]!, Colors.red[500]!];
      case SafetyLevel.warning:
        return [Colors.orange[700]!, Colors.orange[500]!];
      case SafetyLevel.caution:
        return [Colors.yellow[700]!, Colors.yellow[500]!];
      case SafetyLevel.safe:
        return [Colors.green[700]!, Colors.green[500]!];
    }
  }

  IconData _getSafetyIcon(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.critical:
        return Icons.dangerous;
      case SafetyLevel.warning:
        return Icons.warning;
      case SafetyLevel.caution:
        return Icons.info;
      case SafetyLevel.safe:
        return Icons.check_circle;
    }
  }

  String _getSafetyText(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.critical:
        return 'CRITICAL';
      case SafetyLevel.warning:
        return 'WARNING';
      case SafetyLevel.caution:
        return 'CAUTION';
      case SafetyLevel.safe:
        return 'SAFE';
    }
  }

  String _getActivityText(ActivityType activity) {
    switch (activity) {
      case ActivityType.stationary:
        return 'Stationary';
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.running:
        return 'Running';
      case ActivityType.driving:
        return 'Driving';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.unknown:
        return 'Unknown';
    }
  }

  IconData _getActivityIcon(ActivityType activity) {
    switch (activity) {
      case ActivityType.stationary:
        return Icons.airlines;
      case ActivityType.walking:
        return Icons.directions_walk;
      case ActivityType.running:
        return Icons.directions_run;
      case ActivityType.driving:
        return Icons.drive_eta;
      case ActivityType.cycling:
        return Icons.directions_bike;
      case ActivityType.unknown:
        return Icons.help_outline;
    }
  }
}