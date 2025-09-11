import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Firebase initialization service
class FirebaseService {
  static bool _initialized = false;

  /// Initialize Firebase with proper configuration
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      
      if (kDebugMode) {
        print('✅ Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;
}
