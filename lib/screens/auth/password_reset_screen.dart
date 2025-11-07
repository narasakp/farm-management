import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/production_auth_provider.dart';
import '../../services/email_otp_service.dart';
import '../../widgets/password_field.dart';
import '../../utils/password_validator.dart';
import 'unified_login_screen.dart'; // ✅ Use Unified Login
import 'email_otp_screen.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final EmailOTPService _otpService = EmailOTPService();
  
  bool _isLoading = false;
  String? _verificationId;
  bool _otpVerified = false;
  Map<String, dynamic>? _verifiedUser;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    print('ฟ้า [PASSWORD RESET] Starting OTP send for: ${_emailController.text.trim()}');
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('🟡 [PASSWORD RESET] Calling sendEmailOTP...');
      final result = await _otpService.sendEmailOTP(_emailController.text.trim());
      print('🟡 [PASSWORD RESET] Result: $result');
      print('🟡 [PASSWORD RESET] result[success] = ${result['success']}');
      print('🟡 [PASSWORD RESET] result[success] type = ${result['success'].runtimeType}');
      print('🟡 [PASSWORD RESET] result[success] == true? ${result['success'] == true}');
      
      if (result['success'] == true) {
        print('✅ [PASSWORD RESET] SUCCESS - Navigating to OTP screen');
        if (mounted) {
          // Navigate to EmailOTPScreen for OTP verification
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EmailOTPScreen(
                email: _emailController.text.trim(),
                isPasswordReset: true,
                onVerified: () {
                  // After OTP verification, allow password reset
                  setState(() {
                    _otpVerified = true;
                    _verifiedUser = result['user'];
                  });
                  Navigator.of(context).pop(); // Go back to password reset screen
                },
              ),
            ),
          );
        }
      } else {
        print('❌ [PASSWORD RESET] FAILED');
        print('❌ [PASSWORD RESET] Error message: ${result['message']}');
        final errorMsg = result['message'] ?? 'ไม่สามารถส่ง OTP ได้';
        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
            _successMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'เกิดข้อผิดพลาด: $e';
          _successMessage = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _otpService.resetPasswordWithOTP(
        _emailController.text.trim(),
        _newPasswordController.text,
      );
      
      print('✅ [PASSWORD_RESET] Reset password result: ${result['success']}');
      if (result['success'] == true) {
        print('✅ [PASSWORD_RESET] Success - navigating to login immediately');
        if (mounted) {
          // Navigate to login immediately with success message
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const UnifiedLoginScreen(
                successMessage: 'รีเซ็ตรหัสผ่านสำเร็จ!',
              ),
            ),
          );
        }
      } else {
        print('❌ [PASSWORD_RESET] Reset failed');
        final errorMsg = result['message'] ?? 'ไม่สามารถรีเซ็ตรหัสผ่านได้';
        print('❌ [PASSWORD_RESET] Error message: $errorMsg');
        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
            _successMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'เกิดข้อผิดพลาด: $e';
          _successMessage = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text(
          'รีเซ็ตรหัสผ่าน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Header
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'รีเซ็ตรหัสผ่าน',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  _otpVerified 
                    ? 'ตั้งรหัสผ่านใหม่'
                    : 'กรอกอีเมลเพื่อรับรหัส OTP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  enabled: !_otpVerified,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    hintText: 'กรอกอีเมลของคุณ',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),

                if (_otpVerified) ...[
                  const SizedBox(height: 24),
                  
                  // Verified user info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.green.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ตั้งรหัสผ่านใหม่',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              if (_verifiedUser != null)
                                Text(
                                  _verifiedUser!['full_name'] ?? _verifiedUser!['username'],
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // New password field with strength indicator
                  PasswordField(
                    controller: _newPasswordController,
                    label: 'รหัสผ่านใหม่',
                    hintText: 'ต้องมีทั้งตัวอักษรและตัวเลข เช่น suwan123',
                    showStrengthIndicator: true,
                    showSuggestions: true,
                    onChanged: (value) {
                      setState(() {
                        // Clear messages when user starts typing
                        _errorMessage = null;
                        _successMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'ยืนยันรหัสผ่าน',
                    hintText: 'พิมพ์รหัสผ่านเหมือนเดิมอีกครั้ง',
                    showStrengthIndicator: false,
                    showSuggestions: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณายืนยันรหัสผ่าน';
                      }
                      if (value != _newPasswordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_otpVerified ? _resetPassword : _sendOTP),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _otpVerified ? 'รีเซ็ตรหัสผ่าน' : 'ขอรหัส OTP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                // Success Message
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),

                // Back to Login
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const UnifiedLoginScreen()),
                    );
                  },
                  child: Text(
                    'กลับไปหน้าเข้าสู่ระบบ',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
