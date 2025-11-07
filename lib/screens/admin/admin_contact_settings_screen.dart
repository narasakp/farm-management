import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../providers/contact_info_provider.dart';

class AdminContactSettingsScreen extends ConsumerStatefulWidget {
  const AdminContactSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminContactSettingsScreen> createState() =>
      _AdminContactSettingsScreenState();
}

class _AdminContactSettingsScreenState
    extends ConsumerState<AdminContactSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _lineController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    setState(() => _isLoading = true);
    
    try {
      // Load from provider
      final contactInfo = ref.read(contactInfoProvider);
      _emailController.text = contactInfo.email;
      _phoneController.text = contactInfo.phone;
      _lineController.text = contactInfo.lineId;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถโหลดข้อมูลได้: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveContactInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Save to provider (will auto-save to SharedPreferences)
      await ref.read(contactInfoProvider.notifier).updateContactInfo(
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        lineId: _lineController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ บันทึกข้อมูลเรียบร้อยแล้ว'),
            backgroundColor: Color(0xFF228B22), // Green
            duration: Duration(seconds: 2),
          ),
        );
        // กลับไปหน้า Contact Admin
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          context.go('/contact-admin');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ไม่สามารถบันทึกข้อมูลได้: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.detail,
        title: 'ตั้งค่าข้อมูลติดต่อ',
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9), // Light Green
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFF228B22), // Green
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF228B22),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ข้อมูลติดต่อจะแสดงในหน้า "ติดต่อผู้ดูแลระบบ" และข้อความแจ้งเตือนต่างๆ',
                              style: TextStyle(
                                color: Color(0xFF8B4513), // Brown
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Email Field
                    Text(
                      'อีเมล',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513), // Brown
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'admin@farm.com',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color(0xFF1976D2), // Blue
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF228B22), // Green
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกอีเมล';
                        }
                        if (!value.contains('@')) {
                          return 'รูปแบบอีเมลไม่ถูกต้อง';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Phone Field
                    Text(
                      'โทรศัพท์',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513), // Brown
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: '02-xxx-xxxx',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Color(0xFF228B22), // Green
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF228B22), // Green
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกเบอร์โทรศัพท์';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // LINE Field
                    Text(
                      'LINE ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513), // Brown
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _lineController,
                      decoration: InputDecoration(
                        hintText: '@farmadmin',
                        prefixIcon: Icon(
                          Icons.chat,
                          color: Color(0xFF00B900), // LINE Green
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF228B22), // Green
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอก LINE ID';
                        }
                        if (!value.startsWith('@')) {
                          return 'LINE ID ต้องขึ้นต้นด้วย @';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveContactInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF228B22), // Green
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'บันทึก',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Preview Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.go('/contact-admin');
                        },
                        icon: Icon(Icons.visibility),
                        label: Text('ดูตัวอย่างหน้าติดต่อ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF228B22), // Green
                          side: BorderSide(color: Color(0xFF228B22)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
