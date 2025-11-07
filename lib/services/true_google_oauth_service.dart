import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:http/http.dart' as http;

/// Real Google OAuth Service using Google Identity Services
/// Based on Knowledge Base: GOOGLE_OAUTH_COMPLETE_SOLUTION.md
class TrueGoogleOAuthService {
  static const String _clientId = '222181744079-4qn8tac4a6cvpbbpvd2jn02u0s8ie21i.apps.googleusercontent.com';
  static const String _backendUrl = 'http://localhost:3000';
  
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    final completer = Completer<Map<String, dynamic>>();
    
    try {
      // Wait for Google API to load
      await _waitForGoogleAPI();
      
      print('✅ Google Identity Services API loaded');
      
      // Initialize Google Identity Services
      js.context.callMethod('eval', ['''
        (function() {
          try {
            google.accounts.id.initialize({
              client_id: '$_clientId',
              callback: function(response) {
                try {
                  const payload = JSON.parse(atob(response.credential.split('.')[1]));
                  console.log('✅ Google Identity Services callback received');
                  window.googleAuthResult = {
                    success: true,
                    email: payload.email,
                    name: payload.name,
                    picture: payload.picture,
                    id_token: response.credential,
                    uid: payload.sub
                  };
                } catch (error) {
                  console.error('❌ Error parsing Google JWT:', error);
                  window.googleAuthResult = {
                    success: false,
                    error: 'Failed to parse Google JWT'
                  };
                }
              },
              use_fedcm_for_prompt: false,
              auto_select: false,
              cancel_on_tap_outside: false,
              context: 'signin'
            });
            
            // Create sign-in dialog
            const overlay = document.createElement('div');
            overlay.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 9999; display: flex; align-items: center; justify-content: center;';
            overlay.id = 'google-oauth-overlay';
            
            const container = document.createElement('div');
            container.style.cssText = 'background: white; padding: 40px; border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,0.3); max-width: 400px; text-align: center;';
            
            const title = document.createElement('h2');
            title.textContent = 'เข้าสู่ระบบด้วย Google';
            title.style.cssText = 'margin: 0 0 20px 0; color: #333;';
            
            const buttonDiv = document.createElement('div');
            buttonDiv.style.cssText = 'margin: 20px 0;';
            
            const cancelButton = document.createElement('button');
            cancelButton.textContent = 'ยกเลิก';
            cancelButton.style.cssText = 'background: #f0f0f0; color: #333; border: none; padding: 12px 24px; border-radius: 6px; cursor: pointer; margin-top: 10px;';
            cancelButton.onclick = function() {
              document.body.removeChild(overlay);
              window.googleAuthResult = {
                success: false,
                error: 'User cancelled'
              };
            };
            
            container.appendChild(title);
            container.appendChild(buttonDiv);
            container.appendChild(cancelButton);
            overlay.appendChild(container);
            document.body.appendChild(overlay);
            
            // Render Google Sign-In button
            setTimeout(function() {
              google.accounts.id.renderButton(buttonDiv, {
                theme: 'outline',
                size: 'large',
                text: 'signin_with',
                width: 280
              });
            }, 500);
            
          } catch (error) {
            console.error('❌ Google OAuth initialization error:', error);
            window.googleAuthResult = {
              success: false,
              error: error.toString()
            };
          }
        })();
      ''']);
      
      // Poll for result
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        final result = js.context['googleAuthResult'];
        if (result != null) {
          timer.cancel();
          
          // Remove overlay
          js.context.callMethod('eval', ['''
            const overlay = document.getElementById('google-oauth-overlay');
            if (overlay) {
              document.body.removeChild(overlay);
            }
          ''']);
          
          if (result['success'] == true) {
            print('✅ TRUE Google OAuth result stored');
            completer.complete({
              'success': true,
              'email': result['email'],
              'name': result['name'],
              'photo_url': result['picture'],
              'id_token': result['id_token'],
              'uid': result['uid'],
            });
          } else {
            completer.complete({
              'success': false,
              'error': result['error'] ?? 'Google login failed'
            });
          }
          
          // Clear result
          js.context['googleAuthResult'] = null;
        }
      });
      
    } catch (e) {
      print('❌ Google OAuth error: $e');
      completer.complete({
        'success': false,
        'error': e.toString()
      });
    }
    
    return completer.future;
  }
  
  static Future<void> _waitForGoogleAPI() async {
    final completer = Completer<void>();
    var attempts = 0;
    const maxAttempts = 50; // 5 seconds max
    
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      attempts++;
      
      if (js.context['google'] != null && 
          js.context['google']['accounts'] != null) {
        timer.cancel();
        completer.complete();
      } else if (attempts >= maxAttempts) {
        timer.cancel();
        completer.completeError('Google Identity Services not loaded');
      }
    });
    
    return completer.future;
  }
  
  static Future<Map<String, dynamic>> sendToBackend(Map<String, dynamic> credentials) async {
    try {
      print('📡 Sending Google credentials to backend...');
      
      final response = await http.post(
        Uri.parse('$_backendUrl/api/auth/google-login'),
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
    // Clear Google session if available
    if (js.context['google'] != null && 
        js.context['google']['accounts'] != null) {
      try {
        js.context.callMethod('eval', ['google.accounts.id.disableAutoSelect();']);
      } catch (e) {
        print('⚠️ Google sign out warning: $e');
      }
    }
  }
  
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return null;
  }
}
