import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ❌ REMOVED: dart:js (ไม่ใช้ JavaScript modal แล้ว)
import '../../providers/production_auth_provider.dart';
import '../../widgets/password_field.dart';
import '../../utils/password_validator.dart';

class ProductionRegisterScreen extends ConsumerStatefulWidget {
  const ProductionRegisterScreen({super.key});

  @override
  ConsumerState<ProductionRegisterScreen> createState() => _ProductionRegisterScreenState();
}

class _ProductionRegisterScreenState extends ConsumerState<ProductionRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รหัสผ่านไม่ตรงกัน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🔄 Starting registration process...');
    print('📋 Username: ${_usernameController.text}');
    print('📋 Email: ${_emailController.text}');
    print('📋 Display Name: ${_displayNameController.text}');

    final authNotifier = ref.read(productionAuthProvider.notifier);
    final result = await authNotifier.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim(),
      displayName: _displayNameController.text.trim().isEmpty 
        ? _usernameController.text.trim() 
        : _displayNameController.text.trim(),
      role: 'farmer', // Always register as farmer, Super Admin can upgrade later
    );

    // ✅ Handle success with proper Flutter navigation (ตาม Knowledge Base Pattern)
    if (result['success']) {
      print('✅ Registration successful! Auto-logging in...');
      
      // Auto login with same credentials
      final loginResult = await authNotifier.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      
      if (loginResult['success'] && mounted) {
        print('✅ Auto-login successful! Forcing app rebuild...');
        
        // ✅ Force productionAuthProvider to rebuild (ตาม Knowledge Base)
        ref.invalidate(productionAuthProvider);
        
        // ✅ Wait for provider to initialize and load tokens (ตาม Knowledge Base)
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          print('🚀 Navigating to root, redirect should trigger...');
          // ✅ Navigate to root, let redirect logic handle (ตาม Knowledge Base)
          context.go('/');
        }
      } else if (mounted) {
        // Auto-login failed, show success message and go to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          context.go('/login');
        }
      }
    } else if (mounted) {
      // Registration failed - show error
      final errorMsg = result['message'] ?? result['error'] ?? 'เกิดข้อผิดพลาดในการสมัครสมาชิก';
      print('❌ Registration failed: $errorMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(productionAuthProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header
                Text(
                  'สร้างบัญชีใหม่',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'กรอกข้อมูลเพื่อสร้างบัญชีในระบบ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Display Name
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    hintText: 'กรอกชื่อ-นามสกุลของคุณ',
                    prefixIcon: const Icon(Icons.person_outline),
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
                      return 'กรุณากรอกชื่อ-นามสกุล';
                    }
                    if (!value.trim().contains(' ')) {
                      return 'กรุณากรอกทั้งชื่อและนามสกุล (คั่นด้วยช่องว่าง)';
                    }
                    if (value.trim().split(' ').where((s) => s.isNotEmpty).length < 2) {
                      return 'กรุณากรอกทั้งชื่อและนามสกุล';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'ชื่อผู้ใช้',
                    hintText: 'กรอกชื่อผู้ใช้ (ภาษาอังกฤษ)',
                    prefixIcon: const Icon(Icons.account_circle_outlined),
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
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    if (value.length < 3) {
                      return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    hintText: 'กรอกอีเมลของคุณ',
                    prefixIcon: const Icon(Icons.email_outlined),
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
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'กรุณากรอกอีเมลที่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role Info Box (Read-only)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'บทบาท: เกษตรกร',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'หากต้องการเป็นเจ้าหน้าที่หรือนักวิจัย กรุณา',
                                  ),
                                  TextSpan(
                                    text: 'ติดต่อผู้ดูแลระบบ',
                                    style: TextStyle(
                                      color: Color(0xFF1976D2), // Blue
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.go('/contact-admin');
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Password with Strength Indicator
                PasswordField(
                  controller: _passwordController,
                  label: 'รหัสผ่าน',
                  hintText: 'ต้องมีทั้งตัวอักษรและตัวเลข เช่น suwan123',
                  showStrengthIndicator: true,
                  showSuggestions: true,
                  onChanged: (value) {
                    setState(() {}); // Rebuild for confirm password validation
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
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
                    if (value != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'สมัครสมาชิก',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Back to Login - ลิงก์เฉพาะข้อความ (ไม่ใช่ทั้งแถบ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'มีบัญชีแล้ว? ',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
