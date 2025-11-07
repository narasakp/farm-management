import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:js' as js;
import '../../providers/production_auth_provider.dart';
import '../../providers/social_auth_provider.dart';
import '../../widgets/app_bars/standard_app_bar.dart'; // StandardAppBar + AppBarType
import '../../utils/snackbar_helper.dart'; // ✅ SnackBar Helper
import 'password_reset_screen.dart';

class UnifiedLoginScreen extends ConsumerStatefulWidget {
  final String? showSuccessMessage;
  final String? successMessage;
  
  const UnifiedLoginScreen({super.key, this.showSuccessMessage, this.successMessage});

  @override
  ConsumerState<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends ConsumerState<UnifiedLoginScreen> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage; // เก็บ error message แสดงใน UI
  String? _successMessage; // เก็บ success message จาก password reset

  @override
  void initState() {
    super.initState();
    js.context.callMethod('eval', ['console.log("🟢 LOGIN SCREEN LOADED - VERSION: 2025-10-12-09:00")']);
    
    // Set success message from password reset
    if (widget.successMessage != null) {
      _successMessage = widget.successMessage;
    }
    
    // Check for error in URL query parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = Uri.base;
      final error = uri.queryParameters['error'];
      if (error != null && mounted) {
        setState(() => _errorMessage = Uri.decodeComponent(error));
      }
    });
    
    // Show success message if passed
    if (widget.showSuccessMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.showSuccessMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
    
    // Listen to auth changes and auto-navigate
    _setupAuthListener();
  }
  
  void _setupAuthListener() {
    ref.listenManual(
      productionAuthProvider,
      (previous, next) {
        if (!next.isLoading && next.isAuthenticated && previous?.isAuthenticated != true) {
          // Auth state changed from not authenticated to authenticated
          print('🎉 Auth state changed to authenticated! Navigating to market...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/market');
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(productionAuthProvider);
    final socialAuthState = ref.watch(socialAuthProvider);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: StandardAppBar(
          type: AppBarType.main, // ใช้ main เพื่อแสดงปุ่ม back
          title: 'เข้าสู่ระบบ',
          onBackPressed: () {
            // กลับไปหน้า Market (หน้าแรกสำหรับ guest)
            context.go('/market');
          },
          showSearch: false, // ไม่ต้องมี search ในหน้า login
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // CPRU Logo - Minimal & Responsive Design
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive logo size based on screen width
                  double logoSize = MediaQuery.of(context).size.width * 0.25;
                  logoSize = logoSize.clamp(80.0, 150.0); // Min 80px, Max 150px
                  
                  // CPRU Logo - Real Image with Fallback
                return Container(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    'assets/images/cpru_logo.gif',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                    key: const ValueKey('cpru_logo_real'), // Force rebuild
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ CPRU Logo loading error: $error');
                      // Fallback to beautiful CPRU design if image fails
                      return Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF228B22), Color(0xFF32CD32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: const Color(0xFFDAA520), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CPRU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: logoSize * 0.15,
                                ),
                              ),
                              Icon(
                                Icons.school,
                                color: Colors.white,
                                size: logoSize * 0.18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Column(
              children: [
                Text(
                  'ระบบบริหารจัดการฟาร์มปศุสัตว์',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Farm Management System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF228B22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Username/Password Login Form
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'เข้าสู่ระบบด้วยชื่อผู้ใช้',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อผู้ใช้',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (value) {
                          // ล้าง success/error message เมื่อพิมพ์
                          if (_successMessage != null || _errorMessage != null) {
                            setState(() {
                              _successMessage = null;
                              _errorMessage = null;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณาใส่ชื่อผู้ใช้';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          // ล้าง success/error message เมื่อพิมพ์
                          if (_successMessage != null || _errorMessage != null) {
                            setState(() {
                              _successMessage = null;
                              _errorMessage = null;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณาใส่รหัสผ่าน';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : _loginWithUsername,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authState.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                      
                      // แสดง Success Message ถ้ามี (จาก password reset)
                      if (_successMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // แสดง Error Message ถ้ามี
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade700, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                            onPressed: () => _showForgotPasswordDialog(),
                            child: const Text('ลืมรหัสผ่าน?'),
                          ),
                          TextButton(
                            onPressed: () => _showRegisterScreen(),
                            child: const Text('สมัครสมาชิก?'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Social Login Section
            const Text(
              'หรือเข้าสู่ระบบด้วย',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Social Login Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton.icon(
                      onPressed: socialAuthState.isGoogleLoading
                          ? null
                          : () => _loginWithGoogle(),
                      icon: socialAuthState.isGoogleLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Transform.translate(
                                  offset: const Offset(0, -0.5), // ปรับตำแหน่งให้ตรงกลางมากขึ้น
                                  child: const Text(
                                    'g',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                      label: const Text('Google', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton.icon(
                      onPressed: socialAuthState.isFacebookLoading
                          ? null
                          : () => _loginWithFacebook(),
                      icon: socialAuthState.isFacebookLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Transform.translate(
                                  offset: const Offset(0, -0.5), // ปรับตำแหน่งให้ตรงกลางมากขึ้น
                                  child: const Text(
                                    'f',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                      label: const Text('Facebook', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Error message display - TEMPORARILY DISABLED FOR TESTING
            // if (socialAuthState.error != null)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 16),
            //     child: Container(
            //       padding: const EdgeInsets.all(12),
            //       decoration: BoxDecoration(
            //         color: Colors.orange.shade100,
            //         borderRadius: BorderRadius.circular(8),
            //         border: Border.all(color: Colors.orange),
            //       ),
            //       child: Text(
            //         socialAuthState.error!,
            //         style: const TextStyle(color: Colors.orange),
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
            //   ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _loginWithUsername() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear previous messages
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    print('🔐 Attempting login with username: ${_usernameController.text}');
    
    final result = await ref.read(productionAuthProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
    );

    print('🔐 Login result: ${result['success']}');
    print('🔐 Result object: $result');

    if (result['success'] == true) {
      print('✅ Login successful!');
      
      // ✅ No need to invalidate - provider already updated by login()
      // Navigate directly to dashboard
      if (mounted) {
        // Small delay to ensure state is fully updated
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          context.go('/dashboard');
        }
      }
    } else {
      print('❌ Login failed: ${result['error']}');
      
      // Use custom JavaScript modal with PRD colors
      // Escape newlines for JavaScript string
      final errorMsg = (result['error'] ?? 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง').replaceAll('\n', '<br>');
      final hasContactAdmin = errorMsg.contains('ติดต่อผู้ดูแลระบบ');
      
      js.context.callMethod('eval', ['''
        (function() {
          // Create overlay
          const overlay = document.createElement('div');
          overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);display:flex;align-items:center;justify-content:center;z-index:9999;';
          
          // Create modal
          const modal = document.createElement('div');
          modal.style.cssText = 'background:white;border-radius:16px;padding:32px;max-width:400px;box-shadow:0 8px 32px rgba(0,0,0,0.3);text-align:center;';
          
          // Error icon (red circle with X)
          const icon = document.createElement('div');
          icon.innerHTML = '❌';
          icon.style.cssText = 'font-size:64px;margin-bottom:16px;';
          
          // Title
          const title = document.createElement('h2');
          title.textContent = 'เข้าสู่ระบบไม่สำเร็จ';
          title.style.cssText = 'color:#8B4513;font-size:24px;font-weight:bold;margin:0 0 16px 0;';
          
          // Message (use innerHTML to support <br> tags)
          const message = document.createElement('p');
          message.innerHTML = '$errorMsg';
          message.style.cssText = 'color:#666;font-size:18px;margin:0 0 24px 0;line-height:1.5;';
          
          // Buttons container
          const buttonsContainer = document.createElement('div');
          buttonsContainer.style.cssText = 'display:flex;gap:12px;justify-content:center;flex-wrap:wrap;';
          
          // OK Button
          const okButton = document.createElement('button');
          okButton.textContent = 'ตกลง';
          okButton.style.cssText = 'background:#228B22;color:white;border:none;border-radius:8px;padding:12px 32px;font-size:18px;font-weight:bold;cursor:pointer;flex:1;min-width:120px;';
          okButton.onmouseover = function() { this.style.background='#1a6b1a'; };
          okButton.onmouseout = function() { this.style.background='#228B22'; };
          okButton.onclick = function() { document.body.removeChild(overlay); };
          
          buttonsContainer.appendChild(okButton);
          
          // Contact Admin Button (only if message contains "ติดต่อผู้ดูแลระบบ")
          if ($hasContactAdmin) {
            const contactButton = document.createElement('button');
            contactButton.textContent = 'ติดต่อผู้ดูแลระบบ';
            contactButton.style.cssText = 'background:#1976D2;color:white;border:none;border-radius:8px;padding:12px 32px;font-size:18px;font-weight:bold;cursor:pointer;flex:1;min-width:180px;';
            contactButton.onmouseover = function() { this.style.background='#1565C0'; };
            contactButton.onmouseout = function() { this.style.background='#1976D2'; };
            contactButton.onclick = function() { 
              document.body.removeChild(overlay); 
              window.location.hash = '#/contact-admin';
            };
            buttonsContainer.appendChild(contactButton);
          }
          
          // Assemble
          modal.appendChild(icon);
          modal.appendChild(title);
          modal.appendChild(message);
          modal.appendChild(buttonsContainer);
          overlay.appendChild(modal);
          document.body.appendChild(overlay);
        })();
      ''']);
    }
  }

  Future<void> _loginWithGoogle() async {
    print('🔐 Attempting Google OAuth login');
    final success = await ref.read(socialAuthProvider.notifier).loginWithGoogle();
    print('🔐 Google OAuth result: $success');
    
    if (success && mounted) {
      print('✅ Google OAuth successful!');
      
      // ✅ Wait for tokens to be saved to SharedPreferences
      await Future.delayed(const Duration(milliseconds: 300));
      
      // ✅ Force productionAuthProvider to refresh and load tokens
      print('🔄 Refreshing auth provider...');
      ref.invalidate(productionAuthProvider);
      
      // ✅ Wait for provider to initialize and load tokens
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        print('✅ Navigating to dashboard...');
        context.go('/dashboard');
      }
    } else if (mounted) {
      print('❌ Google OAuth failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(socialAuthProvider).error ?? 'การเข้าสู่ระบบด้วย Google ไม่สำเร็จ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginWithFacebook() async {
    js.context.callMethod('eval', ['console.log("🔵 Facebook button clicked!")']);
    final success = await ref.read(socialAuthProvider.notifier).loginWithFacebook();
    js.context.callMethod('eval', ['console.log("🔵 Facebook login completed, success: $success")']);
    
    if (success && mounted) {
      js.context.callMethod('eval', ['console.log("✅ Facebook OAuth successful!")']);
      
      // ✅ Wait for tokens to be saved to SharedPreferences
      await Future.delayed(const Duration(milliseconds: 300));
      
      // ✅ Force productionAuthProvider to refresh and load tokens
      js.context.callMethod('eval', ['console.log("🔄 Refreshing auth provider...")']);
      ref.invalidate(productionAuthProvider);
      
      // ✅ Wait for provider to initialize and load tokens
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        js.context.callMethod('eval', ['console.log("✅ Navigating to dashboard...")']);
        context.go('/dashboard');
      }
    } else if (mounted) {
      js.context.callMethod('eval', ['console.log("❌ Facebook OAuth failed")']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(socialAuthProvider).error ?? 'การเข้าสู่ระบบด้วย Facebook ไม่สำเร็จ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _showForgotPasswordDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PasswordResetScreen(),
      ),
    );
  }

  void _showRegisterScreen() {
    // Navigate to register screen
    context.go('/register');
  }
}
