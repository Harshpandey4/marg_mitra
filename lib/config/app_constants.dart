class AppConstants {
  static const String appName = 'Marg Mitra';
  static const String tagline = 'Aapki Roadside Suraksha Ka Saathi';
  // API endpoints
  static const String baseUrl = 'https://api.margmitra.com';
  static const String authEndpoint = '/auth';
  static const String serviceEndpoint = '/services';
  // Emergency contacts
  static const String policeNumber = '100';
  static const String ambulanceNumber = '108';
  // Service types
  static const List<String> serviceTypes = [
    'Towing',
    'E- Charging Service',
    'Battery Jump Start',
    'Flat Tire',
    'Fuel Delivery',
    'Lockout Service',
    'Mechanical Repair',
    'Public Transport',
    'Public Help',

  ];
}
