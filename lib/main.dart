import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/anonymous_sos_screen.dart';
import 'screens/user/user_dashboard_screen.dart';
import 'screens/user/sos_request_screen.dart';
import 'screens/user/tracking_screen.dart';
import 'screens/user/payment_screen.dart';
import 'screens/user/review_screen.dart';
import 'screens/user/user_service_provider_communication_screen.dart';
import 'screens/user/emergency_tracking_screen.dart';
import 'screens/user/video_call_screen.dart';
import 'screens/common/profile_screen.dart';
import 'screens/common/settings_screen.dart';
import 'screens/common/notifications_screen.dart';
import 'screens/common/about_screen.dart';
import 'screens/common/all_services_screen.dart';
import 'screens/common/find_garage_screen.dart';
import 'screens/common/insurance_screen.dart';
import 'screens/provider/provider_dashboard_screen.dart';
import 'screens/provider/provider_profile_screen.dart';
import 'screens/provider/job_management_screen.dart';
import 'screens/provider/navigation_screen.dart';
import 'screens/provider/customer_communication_screen.dart';
import 'screens/provider/document_verification_screen.dart';
import 'screens/provider/provider_settings_screen.dart';
import 'screens/provider/emergency_contact_screen.dart';
import 'screens/provider/service_management_screen.dart';
import 'screens/provider/earnings_screen.dart';
import 'screens/provider/request_detail_screen.dart';
import 'features/health_monitoring/screens/health_dashboard_screen.dart';
import 'features/health_monitoring/screens/device_settings_screen.dart';
import 'features/health_monitoring/screens/smartwatch_setup_screen.dart';
import 'services/notification_service.dart';
import 'config/theme_provider.dart';

final appTitleProvider = Provider<String>((ref) => 'Marg Mitra');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize();
  container.dispose();
  runApp(
    const ProviderScope(
      child: MargMitraApp(),
    ),
  );
}

class MargMitraApp extends ConsumerWidget {
  const MargMitraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTitle = ref.watch(appTitleProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        // Auth Routes
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const IntegratedLoginScreen(),
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.anonymousSos: (context) => AnonymousSosScreen(),
        AppRoutes.otpVerification: (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments;
          if (arguments is Map<String, dynamic>) {
            return OTPVerificationScreen(
              phoneNumber: arguments['phone'] as String,
              isProvider: arguments['isProvider'] as bool? ?? false,
            );
          } else if (arguments is String) {
            return OTPVerificationScreen(
              phoneNumber: arguments,
              isProvider: false,
            );
          } else {
            throw ArgumentError(
              'Invalid arguments passed to OTP verification screen',
            );
          }
        },

        // User Routes
        AppRoutes.userDashboard: (context) => UserDashboardScreen(),
        AppRoutes.sosRequest: (context) => SOSRequestScreen(),
        AppRoutes.tracking: (context) => const TrackingScreen(),
        AppRoutes.payment: (context) => PaymentScreen(),
        AppRoutes.review: (context) => const ReviewScreen(),
        AppRoutes.emergencyTracking: (context) => const EmergencyTrackingScreen(),
        AppRoutes.videoCall: (context) => const VideoCallScreen(),

        // User Service Provider Communication Route
        AppRoutes.userServiceProviderCommunication: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return UserProviderCommunicationScreen(
            providerId: args['providerId'] as String? ?? 'provider_${DateTime.now().millisecondsSinceEpoch}',
            providerName: args['providerName'] as String? ?? 'Service Provider',
            providerPhone: args['providerPhone'] as String? ?? '+91XXXXXXXXXX',
            providerVehicle: args['providerVehicle'] as String? ?? 'Vehicle Details',
            serviceType: args['serviceType'] as String? ?? 'General Service',
            requestId: args['requestId'] as String? ?? 'request_${DateTime.now().millisecondsSinceEpoch}',
            providerRating: args['providerRating'] as double? ?? 4.0,
          );
        },

        // Health Monitoring Routes
        AppRoutes.healthDashboard: (context) => const HealthDashboardScreen(),
        AppRoutes.deviceSettings: (context) => const DeviceSettingsScreen(),
        AppRoutes.smartwatchSetup: (context) => SmartwatchSetupScreen(),

        // Common Routes
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.notifications: (context) => const NotificationsScreen(),
        AppRoutes.about: (context) => const AboutScreen(),
        AppRoutes.findGarage: (context) => const FindGarageScreen(),
        AppRoutes.insurance: (context) => const InsuranceScreen(),
        AppRoutes.allServices: (context) => const AllServicesScreen(),

        // Provider Routes
        AppRoutes.providerDashboard: (context) => ProviderDashboardScreen(),
        AppRoutes.providerProfile: (context) => ProviderProfileScreen(),
        AppRoutes.jobManagement: (context) => JobManagementScreen(),
        AppRoutes.serviceManagement: (context) => ServiceManagementScreen(),
        AppRoutes.earnings: (context) => EarningsScreen(),
        AppRoutes.serviceHistory: (context) => const ServiceHistoryScreen(),
        AppRoutes.providerSettings: (context) => ProviderSettingsScreen(),
        AppRoutes.emergencyContact: (context) => EmergencyContactScreen(),
        AppRoutes.documentVerification: (context) => const DocumentVerificationScreen(),

        // Provider Routes with Arguments
        AppRoutes.requestDetail: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return RequestDetailScreen(
            requestId: args['requestId'] as String? ?? '',
            serviceData: args['serviceData'] as Map<String, dynamic>? ?? {},
          );
        },
        AppRoutes.navigation: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return NavigationScreen(
            customerName: args['customerName'] as String? ?? 'Unknown Customer',
            customerAddress: args['customerAddress'] as String? ?? 'Address not provided',
            customerPhone: args['customerPhone'] as String? ?? 'Phone not provided',
            serviceType: args['serviceType'] as String? ?? 'General Service',
          );
        },
        AppRoutes.customerCommunication: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return CustomerCommunicationScreen(
            customerId: args['customerId'] as String? ?? 'customer_${DateTime.now().millisecondsSinceEpoch}',
            customerName: args['customerName'] as String? ?? 'Customer',
            customerPhone: args['customerPhone'] as String? ?? '+91XXXXXXXXXX',
            serviceType: args['serviceType'] as String? ?? 'General Service',
            requestId: args['requestId'] as String? ?? 'request_${DateTime.now().millisecondsSinceEpoch}',
          );
        },
      },
    );
  }
}