import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Marg Mitra - Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              'Introduction',
              'Welcome to Marg Mitra ("we," "our," or "us"). By accessing or using our AI-powered smart roadside assistance platform and health monitoring services, you agree to be bound by these Terms and Conditions. Please read them carefully before using our services.',
            ),

            _buildSection(
              '1. Acceptance of Terms',
              'By registering for, accessing, or using Marg Mitra services, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions, along with our Privacy Policy. If you do not agree with any part of these terms, you must not use our services.',
            ),

            _buildSection(
              '2. Service Description',
              'Marg Mitra provides:\n\n'
                  '• AI-powered roadside assistance and emergency response services\n'
                  '• Smart health monitoring through wearable device integration\n'
                  '• Proactive accident detection and automatic emergency alerts\n'
                  '• Connection with verified service providers, hospitals, police, and ambulance services\n'
                  '• Real-time tracking and family notification systems\n'
                  '• Payment processing and service record management',
            ),

            _buildSection(
              '3. User Eligibility',
              '• You must be at least 18 years of age to use Marg Mitra services\n'
                  '• You must provide accurate and complete registration information\n'
                  '• You are responsible for maintaining the confidentiality of your account credentials\n'
                  '• You must have legal authority to enter into this agreement\n'
                  '• One person cannot maintain multiple accounts',
            ),

            _buildSection(
              '4. Health Monitoring & Emergency Services',
              '4.1 Smart Watch Integration:\n'
                  '• Our AI system monitors health vitals through connected wearable devices\n'
                  '• Accident detection algorithms analyze heart rate, impact sensors, and movement patterns\n'
                  '• You consent to continuous health monitoring when emergency features are enabled\n\n'
                  '4.2 Automatic Emergency Response:\n'
                  '• Our system may automatically trigger emergency alerts without your manual input\n'
                  '• Emergency contacts, hospitals, police, and ambulance services will be notified automatically\n'
                  '• You authorize us to share your location and health data with emergency responders\n\n'
                  '4.3 Medical Disclaimer:\n'
                  '• Marg Mitra is NOT a substitute for professional medical advice, diagnosis, or treatment\n'
                  '• Our accident detection system, while advanced, may not detect all emergency situations\n'
                  '• False positives or false negatives may occur\n'
                  '• Always seek professional medical help for health concerns\n'
                  '• We are not liable for medical outcomes or emergency response delays',
            ),

            _buildSection(
              '5. Privacy & Data Protection',
              '5.1 Data Collection:\n'
                  '• We collect personal information, location data, health vitals, and service history\n'
                  '• All data is encrypted and stored securely in compliance with GDPR and Indian data protection standards\n\n'
                  '5.2 Data Usage:\n'
                  '• Health data is used solely for emergency detection and response\n'
                  '• Location data is shared only with verified service providers and emergency services\n'
                  '• Medical history is accessible to first responders only during emergencies\n\n'
                  '5.3 Data Sharing:\n'
                  '• We share data with emergency services, verified service providers, and your designated emergency contacts\n'
                  '• We do not sell your personal or health information to third parties\n'
                  '• Anonymous aggregated data may be used for analytics and service improvement',
            ),

            _buildSection(
              '6. User Responsibilities',
              '• Provide accurate health information and emergency contact details\n'
                  '• Keep your smartwatch charged and properly connected\n'
                  '• Respond to verification requests during emergency situations when possible\n'
                  '• Pay for services as agreed upon\n'
                  '• Treat service providers with respect and professionalism\n'
                  '• Report any fraudulent or unsafe behavior immediately\n'
                  '• Do not misuse emergency features or create false alarms',
            ),

            _buildSection(
              '7. Service Provider Terms',
              '7.1 Verification:\n'
                  '• All service providers must undergo multi-layer credential verification\n'
                  '• Providers must maintain valid licenses, certifications, and insurance\n\n'
                  '7.2 Service Standards:\n'
                  '• Providers must respond to emergency requests promptly\n'
                  '• Emergency medical training certification is required for accident response\n'
                  '• Providers must follow transparent pricing and billing practices\n\n'
                  '7.3 Commission:\n'
                  '• Standard services: 15-20% platform commission\n'
                  '• Emergency services: 10% platform commission\n'
                  '• Payment processing fees apply as per payment gateway policies',
            ),

            _buildSection(
              '8. Payment Terms',
              '• All payments are processed through secure payment gateways\n'
                  '• Service charges are displayed transparently before confirmation\n'
                  '• Subscription fees are non-refundable unless specified otherwise\n'
                  '• Emergency service charges may vary based on urgency and distance\n'
                  '• Disputes regarding payments must be raised within 7 days of service completion\n'
                  '• We reserve the right to modify pricing with 30 days notice',
            ),

            _buildSection(
              '9. Limitation of Liability',
              '9.1 Service Limitations:\n'
                  '• We do not guarantee 100% accuracy in accident detection\n'
                  '• Response times may vary based on location, traffic, and service provider availability\n'
                  '• We are not responsible for actions or inactions of third-party service providers\n'
                  '• Network connectivity issues may affect emergency response\n\n'
                  '9.2 Disclaimer:\n'
                  '• Marg Mitra is provided "as is" without warranties of any kind\n'
                  '• We are not liable for indirect, incidental, or consequential damages\n'
                  '• Maximum liability is limited to the amount paid for services in the past 12 months\n'
                  '• We are not responsible for device compatibility or wearable device malfunctions',
            ),

            _buildSection(
              '10. Intellectual Property',
              '• All content, trademarks, and intellectual property belong to Marg Mitra\n'
                  '• You may not copy, modify, or distribute our platform without written permission\n'
                  '• User-generated content (reviews, ratings) grants us a non-exclusive license to use\n'
                  '• Our AI algorithms and proprietary technology are protected by copyright and trade secrets',
            ),

            _buildSection(
              '11. Prohibited Activities',
              'You must not:\n'
                  '• Misuse emergency features or create false alarms\n'
                  '• Provide false health or personal information\n'
                  '• Harass, abuse, or threaten service providers or other users\n'
                  '• Attempt to hack, reverse engineer, or compromise our security\n'
                  '• Use the platform for illegal activities\n'
                  '• Create fake reviews or manipulate ratings\n'
                  '• Share your account credentials with others',
            ),

            _buildSection(
              '12. Account Termination',
              'We reserve the right to suspend or terminate your account if:\n'
                  '• You violate these Terms and Conditions\n'
                  '• You engage in fraudulent or illegal activities\n'
                  '• You create false emergency situations\n'
                  '• You fail to pay for services\n'
                  '• Your account remains inactive for an extended period\n\n'
                  'You may terminate your account at any time through the app settings.',
            ),

            _buildSection(
              '13. Changes to Terms',
              'We reserve the right to modify these Terms and Conditions at any time. We will notify you of significant changes through:\n'
                  '• In-app notifications\n'
                  '• Email notifications\n'
                  '• Updated "Last Modified" date\n\n'
                  'Continued use of services after changes constitutes acceptance of modified terms.',
            ),

            _buildSection(
              '14. Dispute Resolution',
              '14.1 Governing Law:\n'
                  '• These terms are governed by the laws of India\n'
                  '• All disputes are subject to the exclusive jurisdiction of courts in Lucknow, Uttar Pradesh\n\n'
                  '14.2 Resolution Process:\n'
                  '• Initial disputes should be reported through the app\n'
                  '• We will attempt to resolve disputes within 15 business days\n'
                  '• Unresolved disputes may proceed to arbitration or legal proceedings',
            ),

            _buildSection(
              '15. Emergency Consent',
              'By using Marg Mitra, you explicitly consent to:\n'
                  '• Automatic emergency alert activation based on AI detection\n'
                  '• Sharing your location with emergency services without prior confirmation\n'
                  '• Sharing your health data with first responders during emergencies\n'
                  '• Notifying your emergency contacts automatically\n'
                  '• Recording of emergency communications for quality and legal purposes',
            ),

            _buildSection(
              '16. Contact Information',
              'For questions, concerns, or support regarding these Terms and Conditions:\n\n'
                  'Marg Mitra Support Team\n'
                  'Email: support@margmitra.com\n'
                  'Emergency Helpline: Available in-app\n'
                  'Business Hours: 24/7 Support Available',
            ),

            const SizedBox(height: 24),

            // Acknowledgment Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Important Notice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'By using Marg Mitra, you acknowledge that you have read, understood, and agree to these Terms and Conditions. Your safety and privacy are our top priorities.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}