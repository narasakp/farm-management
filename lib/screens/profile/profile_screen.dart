import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:js' as js;
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../../providers/production_auth_provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/password_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _originalImageBase64; // เก็บรูปต้นฉบับไว้ใช้ recrop
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _profileData;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }
    
    final profile = await ProfileService.getProfile(authState.accessToken!);
    
    if (profile != null && mounted) {
      setState(() {
        _profileData = profile;
        _emailController.text = profile['email'] ?? '';
        _displayNameController.text = profile['displayName'] ?? '';
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      _showModal(
        isSuccess: false,
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถโหลดข้อมูลโปรไฟล์ได้',
      );
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken == null) return;
    
    final result = await ProfileService.updateProfile(
      token: authState.accessToken!,
      email: _emailController.text.trim(),
      displayName: _displayNameController.text.trim(),
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      if (result['success']) {
        _showModal(
          isSuccess: true,
          title: 'สำเร็จ',
          message: result['message'] ?? 'บันทึกข้อมูลสำเร็จ',
        );
        
        // Refresh profile data
        await _loadProfile();
      } else {
        _showModal(
          isSuccess: false,
          title: 'เกิดข้อผิดพลาด',
          message: result['error'] ?? 'ไม่สามารถบันทึกข้อมูลได้',
        );
      }
    }
  }
  
  /// แสดง Modal Notification แบบ Login Screen
  void _showModal({
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    final icon = isSuccess ? '✅' : '❌';
    final titleColor = isSuccess ? '#228B22' : '#8B4513';
    
    js.context.callMethod('eval', ['''
      (function() {
        // Create overlay
        const overlay = document.createElement('div');
        overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);display:flex;align-items:center;justify-content:center;z-index:9999;';
        
        // Create modal
        const modal = document.createElement('div');
        modal.style.cssText = 'background:white;border-radius:16px;padding:32px;max-width:400px;box-shadow:0 8px 32px rgba(0,0,0,0.3);text-align:center;';
        
        // Icon
        const iconEl = document.createElement('div');
        iconEl.innerHTML = '$icon';
        iconEl.style.cssText = 'font-size:64px;margin-bottom:16px;';
        
        // Title
        const titleEl = document.createElement('h2');
        titleEl.textContent = '$title';
        titleEl.style.cssText = 'color:$titleColor;font-size:24px;font-weight:bold;margin:0 0 16px 0;';
        
        // Message
        const messageEl = document.createElement('p');
        messageEl.textContent = '$message';
        messageEl.style.cssText = 'color:#666;font-size:18px;margin:0 0 24px 0;line-height:1.5;';
        
        // OK Button
        const okButton = document.createElement('button');
        okButton.textContent = 'ตกลง';
        okButton.style.cssText = 'background:#228B22;color:white;border:none;border-radius:8px;padding:12px 32px;font-size:18px;font-weight:bold;cursor:pointer;min-width:120px;';
        okButton.onmouseover = function() { this.style.background='#1a6b1a'; };
        okButton.onmouseout = function() { this.style.background='#228B22'; };
        okButton.onclick = function() { document.body.removeChild(overlay); };
        
        // Assemble
        modal.appendChild(iconEl);
        modal.appendChild(titleEl);
        modal.appendChild(messageEl);
        modal.appendChild(okButton);
        overlay.appendChild(modal);
        document.body.appendChild(overlay);
      })();
    ''']);
  }
  
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยนรหัสผ่าน'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PasswordField(
                controller: currentPasswordController,
                label: 'ป้อนรหัสผ่านปัจจุบัน',
                autocorrect: false,
                enableSuggestions: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรหัสผ่านปัจจุบัน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: newPasswordController,
                label: 'ตั้งรหัสผ่านใหม่',
                showStrengthIndicator: true,
                showSuggestions: true,
                autocorrect: false,
                enableSuggestions: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรหัสผ่านใหม่';
                  }
                  if (value.length < 8) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: confirmPasswordController,
                label: 'ยืนยันรหัสผ่านใหม่',
                autocorrect: false,
                enableSuggestions: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณายืนยันรหัสผ่านใหม่';
                  }
                  if (value != newPasswordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              // ปิด dialog ก่อน
              Navigator.pop(context);
              
              // รอให้ dialog ปิดสนิท (animation เสร็จ)
              await Future.delayed(const Duration(milliseconds: 300));
              
              if (!mounted) return;
              
              setState(() => _isSaving = true);
              
              final authState = ref.read(productionAuthProvider);
              if (authState.accessToken == null) {
                setState(() => _isSaving = false);
                return;
              }
              
              final result = await ProfileService.changePassword(
                token: authState.accessToken!,
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
              );
              
              if (mounted) {
                setState(() => _isSaving = false);
                
                // แสดง Modal แบบ Login Screen
                if (result['success']) {
                  _showModal(
                    isSuccess: true,
                    title: 'สำเร็จ',
                    message: result['message'] ?? 'เปลี่ยนรหัสผ่านสำเร็จ',
                  );
                } else {
                  _showModal(
                    isSuccess: false,
                    title: 'เปลี่ยนรหัสผ่านไม่สำเร็จ',
                    message: result['error'] ?? 'มีข้อผิดพลาดในการเปลี่ยนรหัสผ่าน',
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showAvatarOptions() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'รูปโปรไฟล์',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const Divider(height: 1),
              
              if (_profileData?['avatarUrl'] != null)
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('ดูรูปขนาดใหญ่'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFullAvatar();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เปลี่ยนรูปโปรไฟล์'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_profileData?['avatarUrl'] != null)
                ListTile(
                  leading: const Icon(Icons.crop),
                  title: const Text('ปรับตำแหน่งรูป'),
                  onTap: () {
                    Navigator.pop(context);
                    _recropCurrentAvatar();
                  },
                ),
              if (_profileData?['avatarUrl'] != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('ลบรูปโปรไฟล์', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeAvatar();
                  },
                ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isEmpty) return;
      
      final file = files[0];
      final reader = html.FileReader();
      
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) async {
        if (reader.result != null) {
          final base64Image = reader.result as String;
          
          // เก็บรูปต้นฉบับไว้
          _originalImageBase64 = base64Image;
          
          // แสดง Image Cropper Dialog
          if (mounted) {
            final croppedImage = await _showImageCropDialog(base64Image);
            if (croppedImage != null) {
              await _uploadAvatar(croppedImage);
            }
          }
        }
      });
    });
  }
  
  Future<String?> _showImageCropDialog(String base64Image) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImageCropperDialog(base64Image: base64Image),
    );
  }
  
  Future<void> _recropCurrentAvatar() async {
    // ตรวจสอบว่ามีรูปต้นฉบับหรือไม่
    if (_originalImageBase64 == null) {
      // ไม่มีรูปต้นฉบับ แจ้งให้เลือกรูปใหม่
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ไม่พบรูปต้นฉบับ'),
          content: const Text(
            'ไม่สามารถปรับตำแหน่งรูปได้\n'
            'กรุณาเลือกรูปใหม่เพื่อปรับตำแหน่ง',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('เลือกรูปใหม่'),
            ),
          ],
        ),
      );
      
      if (confirmed == true && mounted) {
        _pickImage();
      }
      return;
    }
    
    // มีรูปต้นฉบับ แสดง Cropper
    if (mounted) {
      final croppedImage = await _showImageCropDialog(_originalImageBase64!);
      if (croppedImage != null) {
        await _uploadAvatar(croppedImage);
      }
    }
  }
  
  Future<void> _uploadAvatar(String base64Image) async {
    print('📤 Starting avatar upload...');
    print('📊 Image size: ${base64Image.length} characters');
    
    setState(() => _isSaving = true);
    
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken == null) {
      print('❌ No access token');
      return;
    }
    
    try {
      final result = await ProfileService.uploadAvatar(
        token: authState.accessToken!,
        avatarBase64: base64Image,
      );
      
      print('📥 Upload result: $result');
      
      if (mounted) {
        setState(() => _isSaving = false);
        
        if (result['success']) {
          _showModal(
            isSuccess: true,
            title: 'สำเร็จ',
            message: result['message'] ?? 'อัปเดตรูปโปรไฟล์สำเร็จ',
          );
          
          // Refresh profile data
          await _loadProfile();
        } else {
          _showModal(
            isSuccess: false,
            title: 'อัปโหลดไม่สำเร็จ',
            message: result['error'] ?? 'เกิดข้อผิดพลาดในการอัปโหลด',
          );
        }
      }
    } catch (e) {
      print('❌ Upload error: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        _showModal(
          isSuccess: false,
          title: 'เกิดข้อผิดพลาด',
          message: 'ไม่สามารถอัปโหลดรูปได้',
        );
      }
    }
  }
  
  Future<void> _removeAvatar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรูปโปรไฟล์'),
        content: const Text('คุณต้องการลบรูปโปรไฟล์หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _uploadAvatar(''); // Send empty string to remove
    }
  }
  
  void _showFullAvatar() {
    if (_profileData?['avatarUrl'] == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Full Size Image - Circle
            Container(
              width: 500,
              height: 500,
              constraints: const BoxConstraints(
                maxWidth: 500,
                maxHeight: 500,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.memory(
                  base64Decode(
                    _profileData!['avatarUrl'].split(',')[1],
                  ),
                  fit: BoxFit.contain,
                  width: 500,
                  height: 500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final thaiMonths = [
        'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
      ];
      final thaiYear = date.year + 543;
      return '${date.day} ${thaiMonths[date.month - 1]} $thaiYear';
    } catch (e) {
      return dateString;
    }
  }
  
  String _getRoleDisplayName(String? roleCode) {
    switch (roleCode?.toUpperCase()) {
      case 'FARMER':
        return 'เกษตรกร';
      case 'OFFICER':
        return 'เจ้าหน้าที่';
      case 'RESEARCHER':
        return 'นักวิจัย';
      case 'ADMIN':
        return 'ผู้ดูแลระบบ';
      case 'SUPER_ADMIN':
        return 'ผู้ดูแลระบบสูงสุด';
      default:
        return roleCode ?? 'ไม่ระบุ';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'โปรไฟล์',
        onBackPressed: () => context.go('/dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Avatar (Clickable)
                          GestureDetector(
                            onTap: () => _showAvatarOptions(),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.shade100,
                                  ),
                                  child: _profileData?['avatarUrl'] != null
                                      ? ClipOval(
                                          child: Image.memory(
                                            base64Decode(
                                              _profileData!['avatarUrl'].split(',')[1],
                                            ),
                                            fit: BoxFit.contain,
                                            width: 100,
                                            height: 100,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            (_profileData?['displayName'] ?? 'U')
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade600,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Display Name
                          Text(
                            _profileData?['displayName'] ?? 'ไม่ระบุชื่อ',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Username
                          Text(
                            '@${_profileData?['username'] ?? ''}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.shade300,
                              ),
                            ),
                            child: Text(
                              _getRoleDisplayName(_profileData?['role']),
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Member Since
                          if (_profileData?['createdAt'] != null)
                            Text(
                              'สมาชิกตั้งแต่: ${_formatDate(_profileData!['createdAt'])}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Edit Profile Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'แก้ไขข้อมูลส่วนตัว',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Username (Read-only)
                            TextFormField(
                              initialValue: _profileData?['username'] ?? '',
                              decoration: InputDecoration(
                                labelText: 'ชื่อผู้ใช้',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            
                            // Display Name (Editable)
                            TextFormField(
                              controller: _displayNameController,
                              decoration: InputDecoration(
                                labelText: 'ชื่อแสดง',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกชื่อแสดง';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Email (Editable)
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'อีเมล',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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
                            const SizedBox(height: 24),
                            
                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'บันทึกข้อมูล',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Change Password Card
                  Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: _showChangePasswordDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lock_outline,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'เปลี่ยนรหัสผ่าน',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'อัปเดตรหัสผ่านของคุณ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Image Cropper Dialog - Pan/Zoom Avatar like Facebook
class _ImageCropperDialog extends StatefulWidget {
  final String base64Image;
  
  const _ImageCropperDialog({required this.base64Image});
  
  @override
  State<_ImageCropperDialog> createState() => _ImageCropperDialogState();
}

class _ImageCropperDialogState extends State<_ImageCropperDialog> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;
  Uint8List? _imageBytes;
  double _imageAspectRatio = 1.0;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  
  Future<void> _loadImage() async {
    try {
      final base64String = widget.base64Image.split(',').last;
      final bytes = base64Decode(base64String);
      final image = img.decodeImage(bytes);
      
      if (image != null) {
        setState(() {
          _imageBytes = bytes;
          _imageAspectRatio = image.width / image.height;
        });
        print('📐 Image: ${image.width}x${image.height}, ratio: $_imageAspectRatio');
      }
    } catch (e) {
      print('❌ Load image error: $e');
      setState(() {
        _imageBytes = base64Decode(widget.base64Image.split(',').last);
      });
    }
  }
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
  
  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.25).clamp(0.5, 4.0);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }
  
  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.25).clamp(0.5, 4.0);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }
  
  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }
  
  Future<String?> _cropImage(double cropSize) async {
    try {
      // 1. Decode image
      final base64String = widget.base64Image.split(',').last;
      final bytes = base64Decode(base64String);
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;
      
      final imgWidth = originalImage.width.toDouble();
      final imgHeight = originalImage.height.toDouble();
      print('📐 Original image: ${imgWidth.toInt()}x${imgHeight.toInt()}');
      
      // 2. Calculate how image is displayed (AspectRatio with fit: contain)
      final imgAspect = imgWidth / imgHeight;
      double displayWidth, displayHeight, offsetX, offsetY;
      
      if (imgAspect > 1.0) {
        // Wider than square - fit by width
        displayWidth = cropSize;
        displayHeight = cropSize / imgAspect;
        offsetX = 0;
        offsetY = (cropSize - displayHeight) / 2;
      } else {
        // Taller than square - fit by height  
        displayWidth = cropSize * imgAspect;
        displayHeight = cropSize;
        offsetX = (cropSize - displayWidth) / 2;
        offsetY = 0;
      }
      
      print('📺 Display: ${displayWidth.toInt()}x${displayHeight.toInt()} at ($offsetX, $offsetY)');
      
      // 3. Circle crop area (center of screen, 70% of cropSize)
      final circleCenterX = cropSize / 2;
      final circleCenterY = cropSize / 2;
      final circleRadius = cropSize * 0.35; // 70% diameter = 35% radius
      
      print('⭕ Circle: center=($circleCenterX, $circleCenterY), radius=$circleRadius');
      
      // 4. Simple approach: Find where (0,0) of the CENTER-aligned display image is on screen
      final scale = _currentScale;
      final matrix = _transformationController.value;
      
      // The display image (displayWidth x displayHeight) is centered in the container
      // So (0,0) of display image is at (offsetX, offsetY) in container coordinates
      // After transformation, it moves to:
      final Vector3 imageTopLeft = matrix.transform3(Vector3(0, 0, 0));
      
      // But wait - the image in AspectRatio + Center is offset by (offsetX, offsetY)
      // So the actual (0,0) of the image data is at:
      final actualImageX = imageTopLeft.x + offsetX * scale;
      final actualImageY = imageTopLeft.y + offsetY * scale;
      
      print('🖼️ Image (0,0) at: ($actualImageX, $actualImageY), scale=$scale');
      
      // 5. Circle center relative to image (0,0)
      final relX = circleCenterX - actualImageX;
      final relY = circleCenterY - actualImageY;
      
      // Convert from screen pixels to display image pixels
      final imgCenterX = relX / scale;
      final imgCenterY = relY / scale;
      final imgRadius = circleRadius / scale;
      
      print('🎯 Image space: center=($imgCenterX, $imgCenterY), radius=$imgRadius');
      
      // 7. Convert from display coordinates to original image coordinates
      final scaleToOriginal = imgWidth / displayWidth;
      final origCenterX = imgCenterX * scaleToOriginal;
      final origCenterY = imgCenterY * scaleToOriginal;
      final origRadius = imgRadius * scaleToOriginal;
      
      print('🖼️ Original: center=($origCenterX, $origCenterY), radius=$origRadius');
      
      // 8. Calculate the FULL circle area (may extend beyond image bounds)
      final circleDiameter = (origRadius * 2).round();
      
      // Calculate crop area - allow it to extend beyond image
      var cropLeft = (origCenterX - origRadius).round();
      var cropTop = (origCenterY - origRadius).round();
      var cropRight = cropLeft + circleDiameter;
      var cropBottom = cropTop + circleDiameter;
      
      print('🎯 Target crop: ($cropLeft, $cropTop) to ($cropRight, $cropBottom) = ${circleDiameter}x$circleDiameter');
      
      // 9. Create a BLACK square canvas with circle diameter size
      final canvas = img.Image(width: circleDiameter, height: circleDiameter);
      img.fill(canvas, color: img.ColorRgb8(0, 0, 0)); // Fill with black
      
      // 10. Calculate which part of the original image to copy
      // and where to paste it on the canvas
      final srcLeft = cropLeft.clamp(0, imgWidth.toInt() - 1);
      final srcTop = cropTop.clamp(0, imgHeight.toInt() - 1);
      final srcRight = cropRight.clamp(0, imgWidth.toInt());
      final srcBottom = cropBottom.clamp(0, imgHeight.toInt());
      
      final srcWidth = srcRight - srcLeft;
      final srcHeight = srcBottom - srcTop;
      
      // Destination position on canvas (offset from black canvas)
      final dstLeft = (cropLeft < 0) ? -cropLeft : 0;
      final dstTop = (cropTop < 0) ? -cropTop : 0;
      
      print('📋 Copy from image: ($srcLeft, $srcTop) ${srcWidth}x$srcHeight');
      print('📋 Paste to canvas: ($dstLeft, $dstTop)');
      
      // 11. Copy the visible part of the image onto the black canvas
      if (srcWidth > 0 && srcHeight > 0) {
        final sourcePart = img.copyCrop(
          originalImage,
          x: srcLeft,
          y: srcTop,
          width: srcWidth,
          height: srcHeight,
        );
        
        img.compositeImage(
          canvas,
          sourcePart,
          dstX: dstLeft,
          dstY: dstTop,
        );
      }
      
      print('✂️ Final canvas: ${canvas.width}x${canvas.height} (with black padding)');
      
      // 12. Resize to 400x400
      final resizedImage = img.copyResize(
        canvas,
        width: 400,
        height: 400,
        interpolation: img.Interpolation.linear,
      );
      
      // 13. Encode to base64
      final pngBytes = img.encodePng(resizedImage);
      final result = 'data:image/png;base64,${base64Encode(pngBytes)}';
      
      print('✅ Crop completed: 400x400');
      return result;
    } catch (e) {
      print('❌ Crop error: $e');
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cropSize = screenSize.width > 600 
        ? 350.0 
        : (screenSize.width * 0.7).clamp(250.0, 350.0);
    
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: cropSize + 80,
            maxHeight: screenSize.height * 0.9,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Title
            const Text(
              'ปรับตำแหน่งรูปโปรไฟล์',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'เลื่อนรูปภาพเพื่อเลือกตำแหน่งที่ชอบ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Image Viewer with Circle Overlay
            Container(
              width: cropSize,
              height: cropSize,
              color: Colors.black,
              child: _imageBytes == null
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Stack(
                children: [
                  // Interactive Image
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 4.0,
                      boundaryMargin: const EdgeInsets.all(200),
                      panEnabled: true,
                      scaleEnabled: false, // ปิด gesture zoom, ใช้ปุ่มแทน
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _imageAspectRatio,
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Circle Overlay (Crop Area Indicator) - Ignore Pointer
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        width: cropSize * 0.7,
                        height: cropSize * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Dark Overlay (outside circle) - Ignore Pointer
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(cropSize, cropSize),
                      painter: _CircleOverlayPainter(
                        circleRadius: cropSize * 0.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Zoom Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Zoom Out Button
                IconButton(
                  onPressed: _zoomOut,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.white,
                  iconSize: 32,
                  tooltip: 'ซูมออก',
                ),
                const SizedBox(width: 16),
                
                // Zoom Level Text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(_currentScale * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Zoom In Button
                IconButton(
                  onPressed: _zoomIn,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.white,
                  iconSize: 32,
                  tooltip: 'ซูมเข้า',
                ),
                const SizedBox(width: 16),
                
                // Reset Button
                IconButton(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.refresh),
                  color: Colors.white70,
                  iconSize: 28,
                  tooltip: 'รีเซ็ต',
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Instructions
            const Text(
              'ลากเพื่อเลื่อน',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                
                // Save Button
                ElevatedButton(
                  onPressed: () async {
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                    
                    // Crop image
                    final croppedImage = await _cropImage(cropSize);
                    
                    // Close loading
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    
                    // Return result
                    if (context.mounted) {
                      Navigator.pop(context, croppedImage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Custom Painter for Circle Overlay (Dark area outside circle)
class _CircleOverlayPainter extends CustomPainter {
  final double circleRadius;
  
  _CircleOverlayPainter({required this.circleRadius});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: circleRadius,
        ),
      )
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
