import 'package:flutter/material.dart';

class AppRoutes {
  // Auth routes
  static const String home = '/';
  static const String history = '/history';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String anonymousSos = '/anonymous-sos';

  // User routes
  static const String userDashboard = '/user-dashboard';
  static const String sosRequest = '/sos-request';
  static const String tracking = '/tracking';
  static const String payment = '/payment';
  static const String review = '/review';
  static const String rewards = '/rewards';
  static const String userServiceProviderCommunication = '/user-service-provider-communication';
  static const String emergencyTracking = '/emergency-tracking';
  static const String videoCall = '/video-call';

  // Health Monitoring routes
  static const String healthDashboard = '/health-dashboard';
  static const String deviceSettings = '/device-settings';
  static const String smartwatchSetup = '/smartwatch-setup';

  // Common routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String about = '/about';
  static const String findGarage = '/find-garage';
  static const String insurance = '/insurance';
  static const String allServices = '/all-services';

  // Provider routes
  static const String providerDashboard = '/provider-dashboard';
  static const String providerProfile = '/provider-profile';
  static const String jobManagement = '/job-management';
  static const String serviceManagement = '/service-management';
  static const String earnings = '/earnings';
  static const String requestDetail = '/request-detail';
  static const String serviceHistory = '/service-history';
  static const String navigation = '/navigation';
  static const String customerCommunication = '/customer-communication';
  static const String documentVerification = '/document-verification';
  static const String providerSettings = '/provider-settings';
  static const String emergencyContact = '/emergency-contact';

  // Helper methods for navigation
  static Future<dynamic> navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<dynamic> navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static Future<dynamic> navigateAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  // Helper method to go back
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  // Helper method for conditional navigation
  static void navigateToUserOrProvider(BuildContext context, bool isProvider) {
    if (isProvider) {
      navigateAndClearStack(context, providerDashboard);
    } else {
      navigateAndClearStack(context, userDashboard);
    }
  }

  // Helper method to navigate to document verification
  static void navigateToDocumentVerification(BuildContext context) {
    navigateTo(context, documentVerification);
  }

  // Helper method to navigate to request detail with arguments
  static void navigateToRequestDetail(
      BuildContext context, {
        required String requestId,
        Map<String, dynamic>? serviceData,
      }) {
    navigateTo(
      context,
      requestDetail,
      arguments: {
        'requestId': requestId,
        'serviceData': serviceData ?? {},
      },
    );
  }

  // Helper method to navigate to navigation screen with customer details
  static void navigateToNavigation(
      BuildContext context, {
        required String customerName,
        required String customerAddress,
        required String customerPhone,
        required String serviceType,
      }) {
    navigateTo(
      context,
      navigation,
      arguments: {
        'customerName': customerName,
        'customerAddress': customerAddress,
        'customerPhone': customerPhone,
        'serviceType': serviceType,
      },
    );
  }

  // Helper method to navigate to customer communication (Provider side)
  static void navigateToCustomerCommunication(
      BuildContext context, {
        required String customerName,
        required String customerPhone,
        required String requestId,
      }) {
    navigateTo(
      context,
      customerCommunication,
      arguments: {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'requestId': requestId,
      },
    );
  }

  // Helper method to navigate to user service provider communication (User side)
  static void navigateToUserServiceProviderCommunication(
      BuildContext context, {
        required String providerId,
        required String providerName,
        required String providerPhone,
        required String providerVehicle,
        required String serviceType,
        required String requestId,
        required double providerRating,
      }) {
    navigateTo(
      context,
      userServiceProviderCommunication,
      arguments: {
        'providerId': providerId,
        'providerName': providerName,
        'providerPhone': providerPhone,
        'providerVehicle': providerVehicle,
        'serviceType': serviceType,
        'requestId': requestId,
        'providerRating': providerRating,
      },
    );
  }

  // Helper method to navigate to emergency tracking (User side)
  static void navigateToEmergencyTracking(
      BuildContext context, {
        String? requestId,
      }) {
    navigateTo(
      context,
      emergencyTracking,
      arguments: {
        'requestId': requestId,
      },
    );
  }

  // Helper method to navigate to video call (User & Provider)
  static void navigateToVideoCall(
      BuildContext context, {
        required String callId,
        required String otherPersonName,
        required String otherPersonPhone,
      }) {
    navigateTo(
      context,
      videoCall,
      arguments: {
        'callId': callId,
        'otherPersonName': otherPersonName,
        'otherPersonPhone': otherPersonPhone,
      },
    );
  }

  // Helper method to navigate to anonymous SOS
  static void navigateToAnonymousSos(BuildContext context) {
    navigateTo(context, anonymousSos);
  }

  // Helper method to navigate to health dashboard
  static void navigateToHealthDashboard(BuildContext context) {
    navigateTo(context, healthDashboard);
  }

  // Helper method to navigate to device settings
  static void navigateToDeviceSettings(
      BuildContext context, {
        String? deviceId,
      }) {
    navigateTo(
      context,
      deviceSettings,
      arguments: {
        'deviceId': deviceId,
      },
    );
  }

  // Helper method to navigate to smartwatch setup
  static void navigateToSmartWatchSetup(BuildContext context) {
    navigateTo(context, smartwatchSetup);
  }

  // Helper method to navigate to OTP verification with arguments
  static void navigateToOTPVerification(
      BuildContext context, {
        required String phoneNumber,
        bool isProvider = false,
      }) {
    navigateTo(
      context,
      otpVerification,
      arguments: {
        'phone': phoneNumber,
        'isProvider': isProvider,
      },
    );
  }
}