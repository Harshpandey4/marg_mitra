import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/service_request_model.dart';

// Service State class
class ServiceState {
  final List<ServiceRequestModel> availableRequests;
  final ServiceRequestModel? activeRequest;
  final bool isOnline;
  final bool isLoading;

  const ServiceState({
    this.availableRequests = const [],
    this.activeRequest,
    this.isOnline = false,
    this.isLoading = false,
  });

  ServiceState copyWith({
    List<ServiceRequestModel>? availableRequests,
    ServiceRequestModel? activeRequest,
    bool? isOnline,
    bool? isLoading,
  }) {
    return ServiceState(
      availableRequests: availableRequests ?? this.availableRequests,
      activeRequest: activeRequest ?? this.activeRequest,
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Service Notifier
class ServiceNotifier extends StateNotifier<ServiceState> {
  ServiceNotifier() : super(const ServiceState());

  void toggleOnlineStatus() {
    if (state.isOnline) {
      // Going offline
      state = state.copyWith(
        isOnline: false,
        availableRequests: [],
      );
    } else {
      // Going online
      state = state.copyWith(isOnline: true);
      _loadAvailableRequests();
    }
  }

  Future<void> _loadAvailableRequests() async {
    state = state.copyWith(isLoading: true);

    try {
      // Simulate API call to get nearby requests
      await Future.delayed(const Duration(seconds: 1));

      final requests = [
        ServiceRequestModel(
          id: '1',
          userId: 'user1',
          serviceType: 'Flat Tire',
          location: 'Near City Mall',
          distance: '2.5 km',
          estimatedPrice: '₹500',
          urgency: 'Medium',
        ),
        ServiceRequestModel(
          id: '2',
          userId: 'user2',
          serviceType: 'Battery Jump Start',
          location: 'Highway Exit 12',
          distance: '1.8 km',
          estimatedPrice: '₹300',
          urgency: 'High',
        ),
        ServiceRequestModel(
          id: '3',
          userId: 'user3',
          serviceType: 'Fuel Delivery',
          location: 'Main Street',
          distance: '3.2 km',
          estimatedPrice: '₹400',
          urgency: 'Low',
        ),
      ];

      state = state.copyWith(
        availableRequests: requests,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading requests: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      final requestIndex = state.availableRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex != -1) {
        final request = state.availableRequests[requestIndex];
        final updatedRequests = List<ServiceRequestModel>.from(state.availableRequests)
          ..removeAt(requestIndex);

        state = state.copyWith(
          activeRequest: request,
          availableRequests: updatedRequests,
        );
      }
    } catch (e) {
      debugPrint('Error accepting request: $e');
    }
  }

  void completeRequest() {
    state = state.copyWith(activeRequest: null);
  }

  Future<void> refreshRequests() async {
    if (state.isOnline) {
      await _loadAvailableRequests();
    }
  }

  void rejectRequest(String requestId) {
    final updatedRequests = state.availableRequests
        .where((r) => r.id != requestId)
        .toList();

    state = state.copyWith(availableRequests: updatedRequests);
  }

  void updateActiveRequestStatus(String status) {
    if (state.activeRequest != null) {
      final updatedRequest = state.activeRequest!.copyWith(status: status);
      state = state.copyWith(activeRequest: updatedRequest);
    }
  }

  void clearAllRequests() {
    state = state.copyWith(
      availableRequests: [],
      activeRequest: null,
    );
  }
}

// Provider
final serviceProvider = StateNotifierProvider<ServiceNotifier, ServiceState>((ref) {
  return ServiceNotifier();
});