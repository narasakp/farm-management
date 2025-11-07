import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:http/http.dart' as http;

/// Real Facebook OAuth Service using Facebook SDK for JavaScript
/// Based on Google OAuth success pattern from Knowledge Base
class FacebookOAuthService {
  // Facebook App ID from developers.facebook.com
  static const String _appId = '781015721365840';
  static const String _backendUrl = 'http://localhost:3000';
  
  static Future<Map<String, dynamic>> signInWithFacebook() async {
    final completer = Completer<Map<String, dynamic>>();
    
    try {
      // Wait for Facebook SDK to load
      await _waitForFacebookSDK();
      
      print('✅ Facebook SDK loaded');
      
      // Initialize Facebook SDK and show login dialog
      js.context.callMethod('eval', ['''
        (function() {
          try {
            // Initialize Facebook SDK
            FB.init({
              appId: '$_appId',
              cookie: true,
              xfbml: true,
              version: 'v18.0'
            });
            
            console.log('✅ Facebook SDK initialized');
            
            // Create login dialog
            const overlay = document.createElement('div');
            overlay.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 9999; display: flex; align-items: center; justify-content: center;';
            overlay.id = 'facebook-oauth-overlay';
            
            const container = document.createElement('div');
            container.style.cssText = 'background: white; padding: 40px; border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,0.3); max-width: 400px; text-align: center;';
            
            const title = document.createElement('h2');
            title.textContent = 'เข้าสู่ระบบด้วย Facebook';
            title.style.cssText = 'margin: 0 0 20px 0; color: #1877F2;';
            
            const loginButton = document.createElement('button');
            loginButton.textContent = '🔵 Continue with Facebook';
            loginButton.style.cssText = 'background: #1877F2; color: white; border: none; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: bold; width: 280px;';
            
            const cancelButton = document.createElement('button');
            cancelButton.textContent = 'ยกเลิก';
            cancelButton.style.cssText = 'background: #f0f0f0; color: #333; border: none; padding: 12px 24px; border-radius: 6px; cursor: pointer; margin-top: 10px;';
            
            // Login button click handler
            loginButton.onclick = function() {
              FB.login(function(response) {
                if (response.authResponse) {
                  console.log('✅ Facebook login successful');
                  
                  // Get user data
                  FB.api('/me', {fields: 'id,name,email,picture'}, function(userData) {
                    console.log('✅ Facebook user data received:', userData);
                    
                    document.body.removeChild(overlay);
                    
                    window.facebookAuthResult = {
                      success: true,
                      access_token: response.authResponse.accessToken,
                      user_id: response.authResponse.userID,
                      email: userData.email || '',
                      name: userData.name,
                      picture: userData.picture?.data?.url || ''
                    };
                  });
                } else {
                  console.log('❌ Facebook login cancelled or failed');
                  document.body.removeChild(overlay);
                  
                  window.facebookAuthResult = {
                    success: false,
                    error: 'User cancelled or login failed'
                  };
                }
              }, {scope: 'public_profile,email'});
            };
            
            // Cancel button click handler
            cancelButton.onclick = function() {
              document.body.removeChild(overlay);
              window.facebookAuthResult = {
                success: false,
                error: 'User cancelled'
              };
            };
            
            container.appendChild(title);
            container.appendChild(loginButton);
            container.appendChild(cancelButton);
            overlay.appendChild(container);
            document.body.appendChild(overlay);
            
          } catch (error) {
            console.error('❌ Facebook OAuth initialization error:', error);
            window.facebookAuthResult = {
              success: false,
              error: error.toString()
            };
          }
        })();
      ''']);
      
      // Poll for result
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        final result = js.context['facebookAuthResult'];
        if (result != null) {
          timer.cancel();
          
          // Remove overlay if still exists
          js.context.callMethod('eval', ['''
            const overlay = document.getElementById('facebook-oauth-overlay');
            if (overlay) {
              document.body.removeChild(overlay);
            }
          ''']);
          
          if (result['success'] == true) {
            print('✅ Facebook OAuth result stored');
            completer.complete({
              'success': true,
              'access_token': result['access_token'],
              'user_id': result['user_id'],
              'email': result['email'],
              'name': result['name'],
              'photo_url': result['picture'],
            });
          } else {
            completer.complete({
              'success': false,
              'error': result['error'] ?? 'Facebook login failed'
            });
          }
          
          // Clear result
          js.context['facebookAuthResult'] = null;
        }
      });
      
    } catch (e) {
      print('❌ Facebook OAuth error: $e');
      completer.complete({
        'success': false,
        'error': e.toString()
      });
    }
    
    return completer.future;
  }
  
  static Future<void> _waitForFacebookSDK() async {
    final completer = Completer<void>();
    var attempts = 0;
    const maxAttempts = 50; // 5 seconds max
    
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      attempts++;
      
      if (js.context['FB'] != null) {
        timer.cancel();
        completer.complete();
      } else if (attempts >= maxAttempts) {
        timer.cancel();
        completer.completeError('Facebook SDK not loaded');
      }
    });
    
    return completer.future;
  }
  
  static Future<Map<String, dynamic>> sendToBackend(Map<String, dynamic> credentials) async {
    try {
      print('📡 Sending Facebook credentials to backend...');
      
      final response = await http.post(
        Uri.parse('$_backendUrl/api/auth/facebook-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(credentials),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Backend authentication successful');
        return data;
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        print('🚫 Account suspended: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'บัญชีนี้ถูกระงับการใช้งาน กรุณาติดต่อผู้ดูแลระบบ'
        };
      } else {
        final data = json.decode(response.body);
        print('❌ Backend authentication failed: ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Backend authentication failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Backend request error: $e');
      return {
        'success': false,
        'message': 'Backend request error: $e'
      };
    }
  }

  static Future<void> signOut() async {
    // Facebook logout
    if (js.context['FB'] != null) {
      try {
        js.context.callMethod('eval', ['FB.logout();']);
        print('✅ Facebook sign out');
      } catch (e) {
        print('⚠️ Facebook sign out warning: \$e');
      }
    }
  }
}
