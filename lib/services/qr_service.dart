import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service สำหรับจัดการ QR Code
class QRService {
  // Secret key สำหรับ signature (ควรเก็บใน environment variable)
  static const String _secretKey = 'your_secret_key_here_change_in_production';

  /// สร้าง QR Code data สำหรับการจอง
  /// Format: JSON string with signature
  String generateBookingQR(String bookingId, String queueNumber) {
    try {
      final timestamp = DateTime.now().toIso8601String();
      
      // สร้าง data
      final data = {
        'id': bookingId,
        'queue': queueNumber,
        'timestamp': timestamp,
      };

      // สร้าง signature
      final signature = _generateSignature(bookingId, timestamp);
      data['signature'] = signature;

      // Convert to JSON string
      final qrData = json.encode(data);
      
      print('✅ Generated QR for booking: $bookingId');
      return qrData;
    } catch (e) {
      print('❌ Error generating QR: $e');
      rethrow;
    }
  }

  /// ตรวจสอบ QR Code
  bool verifyQR(String qrData) {
    try {
      final data = json.decode(qrData) as Map<String, dynamic>;
      
      final bookingId = data['id'] as String;
      final timestamp = data['timestamp'] as String;
      final signature = data['signature'] as String;

      // ตรวจสอบ signature
      final expectedSignature = _generateSignature(bookingId, timestamp);
      if (signature != expectedSignature) {
        print('⚠️ Invalid QR signature');
        return false;
      }

      // ตรวจสอบเวลา (QR หมดอายุภายใน 24 ชม.)
      final qrTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(qrTime);
      if (diff.inHours > 24) {
        print('⚠️ QR expired');
        return false;
      }

      print('✅ QR verified: $bookingId');
      return true;
    } catch (e) {
      print('❌ Error verifying QR: $e');
      return false;
    }
  }

  /// Parse QR data
  Map<String, dynamic>? parseQR(String qrData) {
    try {
      return json.decode(qrData) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error parsing QR: $e');
      return null;
    }
  }

  /// สร้าง signature สำหรับ QR
  String _generateSignature(String bookingId, String timestamp) {
    final data = '$bookingId|$timestamp|$_secretKey';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// สร้าง QR Code URL สำหรับ PromptPay (Payment)
  String generatePromptPayQR(String phoneNumber, double amount) {
    try {
      // PromptPay QR Format: https://promptpay.io/PHONE_NUMBER/AMOUNT.png
      // Remove leading 0 and add 66 country code
      String formattedPhone = phoneNumber;
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '66' + formattedPhone.substring(1);
      }

      final url = 'https://promptpay.io/$formattedPhone/${amount.toStringAsFixed(2)}.png';
      
      print('✅ Generated PromptPay QR: $amount THB');
      return url;
    } catch (e) {
      print('❌ Error generating PromptPay QR: $e');
      rethrow;
    }
  }
}
