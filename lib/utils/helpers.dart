import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  static Future<void> openMaps(double latitude, double longitude) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      query: 'api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not open maps';
    }
  }

  static String generateRequestId() {
    return 'REQ_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length >= 10) {
      return '${phoneNumber.substring(0, 2)}****${phoneNumber.substring(phoneNumber.length - 4)}';
    }
    return phoneNumber;
  }
}