import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import 'production_auth_service.dart';

class EmailOTPService {
  // Google Apps Script Configuration
  static const String _appsScriptUrl = 'https://script.google.com/macros/s/AKfycbxv-mQTRbgoh6yVFMFOPihHmgugiWo0pQ5bgsHrAX2lIJPZxXNIFf0BRfi-wbjboi6rKQ/exec';
  
  // Generate random OTP
  String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  // Store OTPs for verification
  final Map<String, Map<String, dynamic>> _storedOTPs = {};
  
  
  // Send OTP via Email (Free) - with Production Auth integration
  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      print('🔵 [DEBUG] sendEmailOTP called for: $email');
      
      // Use production server to send OTP
      print('🔵 [DEBUG] Calling API: http://localhost:3000/api/auth/send-otp');
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      print('🔵 [DEBUG] Response status: ${response.statusCode}');
      print('🔵 [DEBUG] Response body: ${response.body}');

      final responseText = response.body;
      Map<String, dynamic> data;
      
      try {
        data = jsonDecode(responseText);
      } catch (e) {
        return {
          'success': false,
          'message': 'เกิดข้อผิดพลาดในการตอบสนองจากเซิร์ฟเวอร์'
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        // Store OTP for verification
        if (data['otp'] != null) {
          _storedOTPs[email] = {
            'otp': data['otp'],
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'attempts': 0,
          };
          
          // 📧 Send real email via Google Apps Script
          print('📧 [MAIN] Attempting to send real email...');
          try {
            await _sendRealEmail(email, data['otp']);
          } catch (emailError) {
            print('⚠️ [MAIN] Email sending failed but OTP is still valid: $emailError');
          }
        }
        
        return {
          'success': true,
          'message': data['message'] ?? 'OTP ส่งไปยัง $email แล้ว',
          'verificationId': 'email_${DateTime.now().millisecondsSinceEpoch}',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถส่ง OTP ได้',
        };
      }
    } catch (e) {
      print('❌ Email OTP Error: $e');
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้',
      };
    }
  }
  
  // Send real email via production service
  Future<bool> _sendRealEmail(String email, String otpCode) async {
    try {
      print('📧 Sending production email to: $email');
      
      // Try Google Apps Script first (NO CORS issues!)
      bool success = await _sendViaAppsScript(email, otpCode);
      
      // Remove Formspree fallback - focus on Google Apps Script only
      
      if (success) {
        print('✅ Email sent successfully to: $email');
        return true;
      } else {
        print('❌ Email sending failed for: $email');
        return false;
      }
      
    } catch (e) {
      print('❌ Email sending error: $e');
      return false;
    }
  }


  // Send via Google Apps Script (Primary - NO CORS issues)
  Future<bool> _sendViaAppsScript(String email, String otpCode) async {
    try {
      print('📧 Trying Google Apps Script for: $email');
      
      // Use form submission method to bypass CORS completely
      return await _sendViaFormSubmission(email, otpCode);
      
    } catch (e) {
      print('❌ Google Apps Script error: $e');
      return false;
    }
  }

  // Form submission method - bypasses CORS completely (from training-registration-new)
  Future<bool> _sendViaFormSubmission(String email, String otpCode) async {
    try {
      print('📧 Using JavaScript iframe form submission for: $email');
      
      // Use JavaScript interop to call the iframe method
      if (kIsWeb) {
        return await _sendViaJavaScriptIframe(email, otpCode);
      }
      
      // Fallback for non-web platforms
      final url = Uri.parse(_appsScriptUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'email=${Uri.encodeComponent(email)}&otpCode=${Uri.encodeComponent(otpCode)}',
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('✅ Google Apps Script email sent successfully');
          print('📧 Real email sent to: $email with OTP: $otpCode');
          return true;
        } else {
          print('❌ Google Apps Script failed: ${responseData['error']}');
          return false;
        }
      } else {
        print('❌ Google Apps Script failed: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Google Apps Script error: $e');
      return false;
    }
  }

  // Verify OTP code and return user info for password reset
  Future<Map<String, dynamic>> verifyOTP(String email, String otpCode) async {
    try {
      // Use production server to verify OTP
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otpCode}),
      );

      final responseText = response.body;
      Map<String, dynamic> data;
      
      try {
        data = jsonDecode(responseText);
      } catch (e) {
        return {
          'success': false,
          'error': 'เกิดข้อผิดพลาดในการตอบสนองจากเซิร์ฟเวอร์'
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'ไม่สามารถยืนยัน OTP ได้',
        };
      }
    } catch (e) {
      print('❌ Verify OTP Error: $e');
      return {
        'success': false,
          'error': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้',
      };
    }
  }

  // Reset password after OTP verification
  Future<Map<String, dynamic>> resetPasswordWithOTP(String email, String newPassword) async {
    try {
      final authService = ProductionAuthService();
      return await authService.resetPassword(email, newPassword);
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to reset password: $e',
      };
    }
  }
  
  // Get test emails for development
  Map<String, String> getTestEmails() {
    return {
      'test@farm.com': '123456',
      'demo@farm.com': '654321', 
      'admin@farm.com': '111111',
    };
  }

  // JavaScript interop method for iframe form submission
  Future<bool> _sendViaJavaScriptIframe(String email, String otpCode) async {
    try {
      print('📧 [IFRAME] Sending email via JavaScript to: $email');
      print('📧 [IFRAME] Apps Script URL: $_appsScriptUrl');
      
      // Check if JavaScript function is available
      if (kIsWeb) {
        try {
          // Check if function exists
          final functionExists = js.context.hasProperty('sendEmailViaIframe');
          
          if (functionExists) {
            print('✅ [IFRAME] sendEmailViaIframe function found');
            
            // Call the JavaScript function directly
            // Based on: EMAIL_OTP_COMPLETE_SOLUTION.md line 331-335
            js.context.callMethod('sendEmailViaIframe', [
              _appsScriptUrl,
              email,
              otpCode,
            ]);
            
            // Wait a moment for form submission
            await Future.delayed(Duration(milliseconds: 1500));
            
            print('✅ [IFRAME] Email form submitted successfully');
            return true;
          } else {
            print('❌ [IFRAME] sendEmailViaIframe function NOT found!');
            print('❌ [IFRAME] email_sender.js not loaded in index.html');
            return false;
          }
        } catch (jsError) {
          print('❌ [IFRAME] JavaScript call error: $jsError');
          return false;
        }
      }
      
      // Fallback for non-web platforms
      print('⚠️ [IFRAME] Not running on web platform');
      return false;
      
    } catch (e) {
      print('❌ [IFRAME] Error: $e');
      return false;
    }
  }
}
