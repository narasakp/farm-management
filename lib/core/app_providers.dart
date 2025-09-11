import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Connectivity provider to check network status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Network status provider
final networkStatusProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) => results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    ),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // Add interceptors for logging in debug mode
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  
  return dio;
});

/// Base URL provider for API endpoints
final baseUrlProvider = Provider<String>((ref) {
  // This will be updated when Firebase project is configured
  return 'https://farm-management-system-default-rtdb.firebaseio.com/';
});
