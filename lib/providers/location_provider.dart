import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:geolocator/geolocator.dart';

// Location State class
class LocationState {
  final Position? currentPosition;
  final bool isLoading;
  final String? errorMessage;
  final bool locationPermissionGranted;

  const LocationState({
    this.currentPosition,
    this.isLoading = false,
    this.errorMessage,
    this.locationPermissionGranted = false,
  });

  LocationState copyWith({
    Position? currentPosition,
    bool? isLoading,
    String? errorMessage,
    bool? locationPermissionGranted,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
    );
  }
}

// Location Notifier
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition();

      state = state.copyWith(
        locationPermissionGranted: true,
        currentPosition: position,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  void startLocationTracking() {
    Geolocator.getPositionStream().listen((Position position) {
      state = state.copyWith(currentPosition: position);
    });
  }
}

// Provider
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});