// lib/features/health_monitoring/widgets/realtime_health_graph.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/health_monitoring_providers.dart';
import '../models/health_data.dart';

class RealtimeHealthGraph extends ConsumerStatefulWidget {
  final HealthMetricType metricType;

  const RealtimeHealthGraph({
    super.key,
    this.metricType = HealthMetricType.heartRate,
  });

  @override
  ConsumerState<RealtimeHealthGraph> createState() => _RealtimeHealthGraphState();
}

class _RealtimeHealthGraphState extends ConsumerState<RealtimeHealthGraph> {
  late ChartSeriesController _chartSeriesController;
  final List<ChartData> _chartData = [];
  final int _maxDataPoints = 60; // Show last 60 seconds

  @override
  Widget build(BuildContext context) {
    final healthHistory = ref.watch(healthHistoryProvider);

    // Update chart data
    _updateChartData(healthHistory);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
              Icon(
                _getMetricIcon(),
                color: _getMetricColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getMetricTitle(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMetricColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: NumericAxis(
                isVisible: false,
                minimum: 0,
                maximum: _maxDataPoints.toDouble(),
              ),
              primaryYAxis: NumericAxis(
                isVisible: true,
                labelStyle: const TextStyle(fontSize: 10),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(
                  color: Colors.grey[200],
                  width: 1,
                ),
              ),
              series: <CartesianSeries<ChartData, int>>[
                SplineSeries<ChartData, int>(
                  dataSource: _chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  color: _getMetricColor(),
                  width: 3,
                  animationDuration: 0,
                  onRendererCreated: (ChartSeriesController controller) {
                    _chartSeriesController = controller;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateChartData(List<HealthData> healthHistory) {
    if (healthHistory.isEmpty) return;

    _chartData.clear();

    // Get last 60 data points
    final recentData = healthHistory.length > _maxDataPoints
        ? healthHistory.sublist(healthHistory.length - _maxDataPoints)
        : healthHistory;

    for (int i = 0; i < recentData.length; i++) {
      final value = _getMetricValue(recentData[i]);
      if (value != null) {
        _chartData.add(ChartData(i, value));
      }
    }
  }

  double? _getMetricValue(HealthData data) {
    switch (widget.metricType) {
      case HealthMetricType.heartRate:
        return data.heartRate.toDouble();
      case HealthMetricType.oxygenSaturation:
        return data.oxygenSaturation?.toDouble();
      case HealthMetricType.stressLevel:
        return data.stressLevel?.toDouble();
      case HealthMetricType.hrvScore:
        return data.hrvScore?.toDouble();
    }
  }

  String _getMetricTitle() {
    switch (widget.metricType) {
      case HealthMetricType.heartRate:
        return 'Heart Rate (BPM)';
      case HealthMetricType.oxygenSaturation:
        return 'Blood Oxygen (%)';
      case HealthMetricType.stressLevel:
        return 'Stress Level';
      case HealthMetricType.hrvScore:
        return 'HRV Score';
    }
  }

  IconData _getMetricIcon() {
    switch (widget.metricType) {
      case HealthMetricType.heartRate:
        return Icons.favorite;
      case HealthMetricType.oxygenSaturation:
        return Icons.air;
      case HealthMetricType.stressLevel:
        return Icons.psychology;
      case HealthMetricType.hrvScore:
        return Icons.timeline;
    }
  }

  Color _getMetricColor() {
    switch (widget.metricType) {
      case HealthMetricType.heartRate:
        return Colors.red;
      case HealthMetricType.oxygenSaturation:
        return Colors.blue;
      case HealthMetricType.stressLevel:
        return Colors.orange;
      case HealthMetricType.hrvScore:
        return Colors.purple;
    }
  }
}

class ChartData {
  final int x;
  final double y;

  ChartData(this.x, this.y);
}

enum HealthMetricType {
  heartRate,
  oxygenSaturation,
  stressLevel,
  hrvScore,
}