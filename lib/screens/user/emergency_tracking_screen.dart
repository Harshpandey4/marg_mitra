import 'package:flutter/material.dart';

class EmergencyTrackingScreen extends StatelessWidget {
  const EmergencyTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final sessionId = args?['sessionId'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Tracking'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text(
              'Tracking Session',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Session ID: $sessionId',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading tracking map...'),
          ],
        ),
      ),
    );
  }
}