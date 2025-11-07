import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contact Info Model
class ContactInfo {
  final String email;
  final String phone;
  final String lineId;

  ContactInfo({
    required this.email,
    required this.phone,
    required this.lineId,
  });

  ContactInfo copyWith({
    String? email,
    String? phone,
    String? lineId,
  }) {
    return ContactInfo(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      lineId: lineId ?? this.lineId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'lineId': lineId,
    };
  }

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'] ?? 'admin@farm.com',
      phone: json['phone'] ?? '02-xxx-xxxx',
      lineId: json['lineId'] ?? '@farmadmin',
    );
  }

  static ContactInfo get defaults {
    return ContactInfo(
      email: 'admin@farm.com',
      phone: '02-xxx-xxxx',
      lineId: '@farmadmin',
    );
  }
}

/// Contact Info Provider (with SharedPreferences)
class ContactInfoNotifier extends StateNotifier<ContactInfo> {
  ContactInfoNotifier() : super(ContactInfo.defaults) {
    _loadFromStorage();
  }

  static const _storageKey = 'admin_contact_info';

  /// โหลดข้อมูลจาก SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final json = Map<String, dynamic>.from(
          // Parse JSON string if needed
          {'email': jsonString.split('|')[0], 'phone': jsonString.split('|')[1], 'lineId': jsonString.split('|')[2]}
        );
        state = ContactInfo.fromJson(json);
      }
    } catch (e) {
      print('Error loading contact info: $e');
      // Use defaults
    }
  }

  /// บันทึกข้อมูลลง SharedPreferences
  Future<void> updateContactInfo({
    required String email,
    required String phone,
    required String lineId,
  }) async {
    // Update state
    state = ContactInfo(
      email: email,
      phone: phone,
      lineId: lineId,
    );

    // Save to storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = '$email|$phone|$lineId';
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving contact info: $e');
    }
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    state = ContactInfo.defaults;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error resetting contact info: $e');
    }
  }
}

/// Global Provider
final contactInfoProvider = StateNotifierProvider<ContactInfoNotifier, ContactInfo>((ref) {
  return ContactInfoNotifier();
});
