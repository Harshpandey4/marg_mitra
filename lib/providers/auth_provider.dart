import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// Auth State class
class AuthState {
  final UserModel? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isLoggedIn;
  final bool otpSent;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.isLoggedIn = false,
    this.otpSent = false,
  });

  AuthState copyWith({
    UserModel? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
    bool? otpSent,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());


  Future<void> sendOTP(String phone, {bool isProvider = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, otpSent: false);

    try {
      // Call API to send OTP
      await Future.delayed(const Duration(seconds: 2));

      print('Sending OTP to $phone for ${isProvider ? 'Provider' : 'User'}');

      // In real implementation, you would call your backend API here
      // Example: await _authService.sendOTP(phone, userType: isProvider ? 'provider' : 'user');

      state = state.copyWith(
        isLoading: false,
        otpSent: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send OTP: ${e.toString()}',
        isLoading: false,
        otpSent: false,
      );
    }
  }

  // ✅ Updated login method to verify OTP with user type support
  Future<void> login(String phone, String otp, {bool isProvider = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Call API for OTP verification
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Simulate OTP validation (in real app, this would be done by backend)
      if (otp.isEmpty || otp.length < 4) {
        throw Exception('Invalid OTP');
      }

      // Create user with appropriate role based on isProvider flag
      final UserRole role = isProvider ? UserRole.provider : UserRole.user;

      final user = UserModel(
        id: DateTime.now().toString(),
        name: isProvider ? 'Service Provider' : 'User Name',
        phone: phone,
        email: isProvider ? 'provider@example.com' : 'user@example.com',
        role: role,
      );

      print('Login successful for ${isProvider ? 'Provider' : 'User'}: ${user.name}');

      state = state.copyWith(
        currentUser: user,
        isLoggedIn: true,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Login failed: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // ✅ Method to resend OTP
  Future<void> resendOTP(String phone, {bool isProvider = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Call API to resend OTP
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      print('Resending OTP to $phone for ${isProvider ? 'Provider' : 'User'}');

      // In real implementation: await _authService.resendOTP(phone, userType: isProvider ? 'provider' : 'user');

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to resend OTP: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // ✅ Updated register method with better role handling
  Future<void> register(String name, String phone, String userType, {String? email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Call API for registration
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Convert string userType to UserRole enum
      UserRole role;
      switch (userType.toLowerCase()) {
        case 'provider':
        case 'service_provider':
          role = UserRole.provider;
          break;
        case 'admin':
          role = UserRole.admin;
          break;
        case 'user':
        default:
          role = UserRole.user;
          break;
      }

      final user = UserModel(
        id: DateTime.now().toString(),
        name: name,
        phone: phone,
        email: email ?? (role == UserRole.provider ? 'provider@example.com' : 'user@example.com'),
        role: role,
      );

      print('Registration successful: ${user.name} as ${role.toString()}');

      state = state.copyWith(
        currentUser: user,
        isLoggedIn: true,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Registration failed: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // ✅ Method to verify phone number without OTP (for testing)
  Future<void> verifyPhoneNumber(String phone, {bool isProvider = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Just verify the phone number format
      if (phone.length != 10) {
        throw Exception('Invalid phone number');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Phone verification failed: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // ✅ Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // ✅ Logout method
  void logout() {
    state = const AuthState(
      currentUser: null,
      isLoggedIn: false,
      errorMessage: null,
      otpSent: false,
    );
  }

  // ✅ Check if user is provider
  bool get isProvider => state.currentUser?.role == UserRole.provider;

  // ✅ Check if user is admin
  bool get isAdmin => state.currentUser?.role == UserRole.admin;
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});