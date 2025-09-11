import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Hive local storage service for offline support
class HiveService {
  static bool _initialized = false;

  /// Initialize Hive with Flutter support
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      _initialized = true;
      
      if (kDebugMode) {
        print('✅ Hive initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Hive initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Open a box for caching data
  static Future<Box<T>> openBox<T>(String boxName) async {
    if (!_initialized) {
      await initialize();
    }
    return await Hive.openBox<T>(boxName);
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _initialized;
}
