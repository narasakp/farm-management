import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/survey_form.dart';
import '../../providers/production_auth_provider.dart';
import '../../services/privacy_service.dart';
import '../../widgets/masked_data_widget.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/emergency_access_dialog.dart';
import '../../widgets/click_to_reveal_dialog.dart';
import '../../utils/snackbar_helper.dart';

/// Survey Detail Screen with Privacy Controls
class SurveyDetailWithPrivacyScreen extends ConsumerStatefulWidget {
  final FarmSurvey survey;

  const SurveyDetailWithPrivacyScreen({Key? key, required this.survey}) : super(key: key);

  @override
  ConsumerState<SurveyDetailWithPrivacyScreen> createState() => _SurveyDetailWithPrivacyScreenState();
}

class _SurveyDetailWithPrivacyScreenState extends ConsumerState<SurveyDetailWithPrivacyScreen> {
  Map<String, dynamic>? _temporaryAccess;
  Map<String, dynamic>? _featureFlags; // Feature flags from backend
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkTemporaryAccess();
  }

  Future<void> _checkTemporaryAccess() async {
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken == null) return;

    setState(() => _isLoading = true);

    final result = await PrivacyService.getFarmerData(
      farmerId: widget.survey.farmerInfo.idCard, // ใช้เลขบัตรจาก farmerInfo
      token: authState.accessToken!,
    );

    if (result != null && result['success'] == true) {
      final data = result['data'];
      print('📦 Farmer data received: ${data.keys}');
      print('🔑 Temporary Access: ${data['_temporary_access']}');
      print('🔍 Full data._temporary_access: ${data['_temporary_access']}');
      print('🔍 data._unmasked_data: ${data['_unmasked_data']}');
      
      if (data['_temporary_access'] != null) {
        // รวม _unmasked_data เข้าไปใน _temporaryAccess
        final tempAccess = Map<String, dynamic>.from(data['_temporary_access']);
        if (data['_unmasked_data'] != null) {
          tempAccess['_unmasked_data'] = data['_unmasked_data'];
          print('✅ Added _unmasked_data to _temporaryAccess: ${data['_unmasked_data']}');
        }
        
        setState(() {
          _temporaryAccess = tempAccess;
          print('✅ Updated _temporaryAccess: $_temporaryAccess');
        });
      } else {
        print('❌ No temporary access in response');
      }
      
      // ✅ อ่าน Feature Flags
      if (data['_feature_flags'] != null) {
        setState(() {
          _featureFlags = data['_feature_flags'];
          print('✅ Feature flags: $_featureFlags');
        });
      }
    } else {
      print('❌ Failed to get farmer data: $result');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleClickToReveal(String fieldType) async {
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ClickToRevealDialog(
        targetUserId: widget.survey.farmerInfo.idCard, // ใช้เลขบัตรจาก farmerInfo
        token: authState.accessToken!,
        fieldType: fieldType,
        onSuccess: (data) {},
      ),
    );

    if (result != null && result['success'] == true) {
      print('✅ Click-to-Reveal Success, refreshing...');
      
      // Refresh temporary access data
      await _checkTemporaryAccess();
      
      // Show success message
      if (mounted) {
        showSuccessSnackBar(
          context, 
          result['message'] ?? 'สามารถดูข้อมูลเต็มได้ 2 ชั่วโมง'
        );
      }
    }
  }

  Future<void> _handleEmergencyAccess(String fieldType) async {
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EmergencyAccessDialog(
        targetUserId: widget.survey.farmerInfo.idCard, // ใช้เลขบัตรจาก farmerInfo
        token: authState.accessToken!,
        fieldType: fieldType,
        onSuccess: (data) {},
      ),
    );

    if (result != null && result['success'] == true) {
      print('🚨 Emergency Access Success, refreshing...');
      
      // Refresh temporary access data
      await _checkTemporaryAccess();
      
      // Show success message
      if (mounted) {
        showSuccessSnackBar(
          context, 
          result['message'] ?? 'ได้รับสิทธิ์เข้าถึงฉุกเฉินแล้ว'
        );
      }
    }
  }

  Future<void> _handleRequestCallback() async {
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken == null) return;

    final messageController = TextEditingController(text: 'ขอนัดหมายเข้าสำรวจฟาร์ม');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone_callback, color: Colors.green),
            SizedBox(width: 8),
            Text('ขอให้โทรกลับ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ส่งข้อความขอให้ ${widget.survey.farmerInfo.fullName} โทรกลับ'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'ข้อความ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('ส่งข้อความ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      print('📞 Calling requestCallback...');
      print('📋 Target Farmer: ${widget.survey.farmerInfo.idCard}');
      print('💬 Message: ${messageController.text}');

      final result = await PrivacyService.requestCallback(
        targetUserId: widget.survey.farmerInfo.idCard, // ใช้เลขบัตรจาก farmerInfo
        message: messageController.text,
        token: authState.accessToken!,
      );

      setState(() => _isLoading = false);

      print('📊 Result: $result');

      if (mounted) {
        if (result != null && result['success'] == true) {
          showSuccessSnackBar(context, result['message'] ?? 'ส่งข้อความสำเร็จ');
        } else {
          final errorMsg = result?['message'] ?? 'เกิดข้อผิดพลาด';
          print('❌ Error: $errorMsg');
          showErrorSnackBar(context, errorMsg);
        }
      }
    }

    messageController.dispose();
  }

  String _formatIdCard(String idCard) {
    print('🔍 _formatIdCard input: $idCard');
    
    // ลบตัวอักษรที่ไม่ใช่ตัวเลข
    final digitsOnly = idCard.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.length != 13) {
      print('⚠️ Not 13 digits: $digitsOnly (${digitsOnly.length})');
      return idCard; // ไม่ใช่เลขบัตร 13 หลัก
    }
    
    // Format: X-XXXX-XXXXX-XX-X
    final formatted = '${digitsOnly[0]}-${digitsOnly.substring(1, 5)}-${digitsOnly.substring(5, 10)}-${digitsOnly.substring(10, 12)}-${digitsOnly[12]}';
    print('✅ Formatted ID Card: $formatted');
    return formatted;
  }

  String _formatPhone(String phone) {
    print('🔍 _formatPhone input: $phone');
    
    // ลบตัวอักษรที่ไม่ใช่ตัวเลข
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.length != 10) {
      print('⚠️ Not 10 digits: $digitsOnly (${digitsOnly.length})');
      return phone; // ไม่ใช่เบอร์โทร 10 หลัก
    }
    
    // Format: XXX-XXX-XXXX
    final formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, 10)}';
    print('✅ Formatted Phone: $formatted');
    return formatted;
  }

  String _getRoleDisplayName(String? role) {
    if (role == null) return '';
    final roleMap = {
      'SUPER_ADMIN': 'ผู้ดูแลระบบ',
      'OFFICER': 'เจ้าหน้าที่',
      'RESEARCHER': 'นักวิจัย',
      'FARMER': 'เกษตรกร',
    };
    return roleMap[role.toUpperCase()] ?? role;
  }

  String _getSurveyorDisplay() {
    final name = widget.survey.surveyorName ?? widget.survey.surveyorId;
    final role = widget.survey.surveyorRole;
    if (role != null && role.isNotEmpty) {
      return '$name: ${_getRoleDisplayName(role)}';
    }
    return name;
  }

  String _getMaskedValue(String value, String type) {
    final authState = ref.read(productionAuthProvider);
    final role = (authState.user?['role'] ?? 'farmer').toString().toUpperCase();

    // ถ้ามี Temporary Access สำหรับ field นี้โดยเฉพาะ → แสดงเต็ม
    if (_temporaryAccess != null && _temporaryAccess!['granted'] == true) {
      final accessFields = _temporaryAccess!['access_fields'] as List?;
      print('🔍 _getMaskedValue - type: $type, accessFields: $accessFields');
      
      if (accessFields != null && accessFields.contains(type)) {
        // ใช้ข้อมูลจาก _unmasked_data ที่ Backend ส่งมา
        final unmaskedData = _temporaryAccess!['_unmasked_data'] as Map<String, dynamic>?;
        print('🔍 _unmasked_data: $unmaskedData');
        
        if (unmaskedData != null && unmaskedData[type] != null) {
          final unmasked = unmaskedData[type].toString();
          print('✅ Returning unmasked: $unmasked');
          
          // Format เลขบัตรประชาชน
          if (type == 'id_card') {
            return _formatIdCard(unmasked);
          }
          
          // Format เบอร์โทรศัพท์
          if (type == 'phone') {
            return _formatPhone(unmasked);
          }
          
          return unmasked;
        }
        print('⚠️ No unmasked data, using value: $value');
        return value; // fallback
      }
    }

    // Mask ตาม Role
    if (role == 'SUPER_ADMIN') {
      // Format เลขบัตรสำหรับ SUPER_ADMIN
      if (type == 'id_card') {
        return _formatIdCard(value);
      }
      return value; // เห็นเต็ม
    }

    if (type == 'id_card') {
      // OFFICER, RESEARCHER: 1-3017-00***-**-9 (masked format)
      if (role.contains('OFFICER') || role == 'RESEARCHER') {
        if (value.length >= 13) {
          final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
          return '${digitsOnly[0]}-${digitsOnly.substring(1, 5)}-${digitsOnly.substring(5, 7)}***-**-${digitsOnly[12]}';
        }
      }
      // FARMER: *-****-*****-**-*
      return '*-****-*****-**-*';
    }

    if (type == 'phone') {
      print('🔍 Phone masking - value: $value, role: $role');
      
      // ถ้าไม่มีเบอร์โทร → แสดง -
      if (value == '-' || value.isEmpty) {
        print('ℹ️ No phone number in database');
        return '-';
      }
      
      // ลบตัวอักษรที่ไม่ใช่ตัวเลข
      final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
      print('🔍 Phone digits only: $digitsOnly (length: ${digitsOnly.length})');
      
      // เบอร์ไม่ครบ 10 หลัก → แสดง -
      if (digitsOnly.length < 10) {
        print('⚠️ Invalid phone number length');
        return '-';
      }
      
      // OFFICER, RESEARCHER: 090-359-xxxx
      if (role.contains('OFFICER') || role == 'RESEARCHER') {
        final masked = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-xxxx';
        print('✅ OFFICER/RESEARCHER phone masked: $masked');
        return masked;
      }
      
      // FARMER: xxx-xxx-xxxx
      print('⚠️ Fully masked phone');
      return 'xxx-xxx-xxxx';
    }

    if (type == 'gps') {
      // OFFICER, RESEARCHER: ซ่อน GPS (ต้อง Click-to-Reveal)
      if (role.contains('OFFICER') || role == 'RESEARCHER') {
        return '***.*****,***.*****';
      }
      // FARMER: ซ่อนทั้งหมด
      return '***.*****,***.*****';
    }

    if (type == 'address') {
      // ถ้ามี temporary access แล้ว → ใช้ข้อมูลจาก _unmasked_data
      if (_temporaryAccess != null && _temporaryAccess!['granted'] == true) {
        final accessFields = _temporaryAccess!['access_fields'] as List?;
        if (accessFields != null && accessFields.contains('address')) {
          final unmaskedData = _temporaryAccess!['_unmasked_data'] as Map<String, dynamic>?;
          if (unmaskedData != null && unmaskedData['address'] != null) {
            return unmaskedData['address'].toString();
          }
        }
      }
      
      // OFFICER, RESEARCHER: แสดง masked address (ตำบล+อำเภอ+จังหวัด+รหัสไปรษณีย์)
      if (role.contains('OFFICER') || role == 'RESEARCHER') {
        return widget.survey.farmerInfo.address.maskedAddress;
      }
      // FARMER: ซ่อนทั้งหมด
      return 'ไม่มีสิทธิ์เข้าถึง';
    }

    return value;
  }

  bool _isMasked(String type) {
    final authState = ref.read(productionAuthProvider);
    final role = (authState.user?['role'] ?? 'farmer').toString().toUpperCase();

    // ถ้ามี Temporary Access สำหรับ field นี้โดยเฉพาะ → ไม่ Mask
    if (_temporaryAccess != null && _temporaryAccess!['granted'] == true) {
      final accessFields = _temporaryAccess!['access_fields'] as List?;
      if (accessFields != null && accessFields.contains(type)) {
        return false; // field นี้ไม่ masked
      }
    }

    // SUPER_ADMIN → ไม่ Mask
    if (role == 'SUPER_ADMIN') {
      return false;
    }

    // อื่นๆ → Masked
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(productionAuthProvider);
    
    // ✅ ถ้า Session หมดอายุ redirect ไป login
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final userRole = (authState.user?['role'] ?? 'farmer').toString();

    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.detail,
        title: 'รายละเอียดการสำรวจ',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))  // Primary Green
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF1F8E9)],  // White → Soft Green Background (5%)
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('โปรไฟล์เกษตรกร', Icons.person, const Color(0xFF2E7D32)),  // Primary Green
                    _buildDetailCard([
                    // รูปภาพเกษตรกร
                    if (widget.survey.farmerInfo.photoBase64 != null && widget.survey.farmerInfo.photoBase64!.isNotEmpty)
                      _buildFarmerPhoto(widget.survey.farmerInfo.photoBase64!, widget.survey.farmerInfo.fullName),
                    
                    // Masked ID Card
                    MaskedDataWidget(
                      label: 'เลขบัตรประชาชน:',
                      value: _getMaskedValue(widget.survey.farmerInfo.idCard, 'id_card'),
                      rawValue: widget.survey.farmerInfo.idCard, // Plain text สำหรับ copy
                      isMasked: _isMasked('id_card'),
                      userRole: authState.user?['role'],
                      fieldType: 'id_card',
                      onClickToReveal: () => _handleClickToReveal('id_card'),
                      onRequestCallback: null, // ไม่แสดงปุ่ม "ขอให้โทรกลับ" สำหรับเลขบัตร
                      onEmergencyAccess: () => _handleEmergencyAccess('id_card'),
                      temporaryAccess: _temporaryAccess,
                      featureFlags: _featureFlags, // Feature flags
                    ),
                    
                    // Masked Phone
                    MaskedDataWidget(
                      label: 'เบอร์โทรศัพท์:',
                      value: _getMaskedValue(widget.survey.farmerInfo.phoneNumber, 'phone'),
                      rawValue: widget.survey.farmerInfo.phoneNumber, // Plain text สำหรับ copy
                      isMasked: _isMasked('phone'),
                      userRole: authState.user?['role'],
                      fieldType: 'phone',
                      onClickToReveal: () => _handleClickToReveal('phone'),
                      onRequestCallback: _handleRequestCallback,
                      onEmergencyAccess: () => _handleEmergencyAccess('phone'),
                      temporaryAccess: _temporaryAccess,
                      featureFlags: _featureFlags, // Feature flags
                    ),
                    
                    // Masked Address
                    MaskedDataWidget(
                      label: 'ที่อยู่:',
                      value: _getMaskedValue(widget.survey.farmerInfo.address.fullAddress, 'address'),
                      rawValue: widget.survey.farmerInfo.address.fullAddress, // Plain text สำหรับ copy
                      isMasked: _isMasked('address'),
                      userRole: authState.user?['role'],
                      fieldType: 'address',
                      onClickToReveal: () => _handleClickToReveal('address'),
                      onRequestCallback: null, // ไม่แสดงปุ่ม "ขอให้โทรกลับ" สำหรับที่อยู่
                      onEmergencyAccess: () => _handleEmergencyAccess('address'),
                      temporaryAccess: _temporaryAccess,
                      featureFlags: _featureFlags, // Feature flags
                    ),
                    ]),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('ข้อมูลฟาร์ม', Icons.location_on, const Color(0xFF388E3C)),  // Farm Green
                    _buildDetailCard([
                      // ตำแหน่งที่ตั้งฟาร์ม (GPS) - With Privacy
                      if (widget.survey.gpsLocation != null && widget.survey.gpsLocation!.isNotEmpty)
                        MaskedDataWidget(
                          label: 'ตำแหน่งที่ตั้งฟาร์ม (GPS):',
                          value: _getMaskedValue(widget.survey.gpsLocation!, 'gps'),
                          rawValue: widget.survey.gpsLocation!, // Plain text สำหรับ copy
                          isMasked: _isMasked('gps'),
                          userRole: authState.user?['role'],
                          fieldType: 'gps',
                          onClickToReveal: () => _handleClickToReveal('gps'),
                          onRequestCallback: null, // ไม่แสดงปุ่ม "ขอให้โทรกลับ" สำหรับ GPS
                          onEmergencyAccess: () => _handleEmergencyAccess('gps'),
                          temporaryAccess: _temporaryAccess,
                          featureFlags: _featureFlags,
                          customDisplay: _buildGPSLocation(widget.survey.gpsLocation!),
                        ),
                      // ขนาดพื้นที่ฟาร์ม
                      _buildDetailRow('ขนาดพื้นที่ฟาร์ม (ไร่):', widget.survey.farmArea?.toStringAsFixed(2) ?? 'N/A'),
                      // พื้นที่ปลูกพืชอาหารสัตว์
                      _buildDetailRow('พื้นที่ปลูกพืชอาหารสัตว์ (ไร่):', widget.survey.cropArea?.toStringAsFixed(2) ?? 'N/A'),
                    ]),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('ข้อมูลการสำรวจ', Icons.assignment, const Color(0xFF2E7D32)),  // Primary Green
                    _buildDetailCard([
                    _buildDetailRow('วันที่สำรวจ:', DateFormat('dd/MM/yyyy').format(widget.survey.surveyDate)),
                    _buildDetailRow('ผู้สำรวจ:', _getSurveyorDisplay()),
                    ]),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('ข้อมูลปศุสัตว์', Icons.pets, const Color(0xFF5D4037)),  // Primary Brown (30%)
                    _buildDetailCard(
                    widget.survey.livestockData.map((entry) {
                      final breedText = entry.breed != null && entry.breed!.isNotEmpty 
                          ? ' (${entry.breed})' 
                          : '';
                      final ageGroupText = entry.ageGroup != null && entry.ageGroup!.isNotEmpty
                          ? ' - ${entry.ageGroup}' 
                          : '';
                      return _buildDetailRow(
                        '${entry.type.displayName}$breedText$ageGroupText:',
                        '${entry.count} ตัว',
                      );
                    }).toList(),
                  ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('ข้อมูลอื่นๆ', Icons.info_outline, const Color(0xFF1976D2)),  // Primary Blue (15%)
                    _buildDetailCard([
                      _buildDetailRow('หมายเหตุ:', widget.survey.notes ?? 'ไม่มี'),
                    ]),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF5D4037).withOpacity(0.1),  // Primary Brown border
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9).withOpacity(0.3),  // Soft Green background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF5D4037),  // Primary Brown (30%)
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF2E7D32),  // Primary Green (40%)
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerPhoto(String photoBase64, String farmerName) {
    try {
      final imageBytes = base64Decode(photoBase64);
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // แสดงรูปขนาดใหญ่ (เหมือน survey-list)
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                              maxHeight: MediaQuery.of(context).size.height * 0.9,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.contain, // แสดงรูปเต็มไม่ crop
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 40,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                width: 150,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('ไม่สามารถโหลดรูปภาพ', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              farmerName,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange),
            const SizedBox(width: 8),
            Text('ไม่สามารถแสดงรูปภาพได้: ${e.toString()}'),
          ],
        ),
      );
    }
  }

  Widget _buildGPSLocation(String gpsLocation) {
    // Parse GPS format: "latitude,longitude" or "lat: X, lng: Y"
    final parts = gpsLocation.split(',');
    if (parts.length == 2) {
      final lat = parts[0].trim().replaceAll(RegExp(r'[^0-9.-]'), '');
      final lng = parts[1].trim().replaceAll(RegExp(r'[^0-9.-]'), '');
      
      return Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF388E3C).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF388E3C), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ตำแหน่งที่ตั้งฟาร์ม (GPS)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Latitude: $lat',
              style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
            ),
            Text(
              'Longitude: $lng',
              style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (mounted) {
                      showErrorSnackBar(context, 'ไม่สามารถเปิด Google Maps ได้');
                    }
                  }
                },
                icon: const Icon(Icons.map, size: 18),
                label: const Text('เปิดใน Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return _buildDetailRow('ตำแหน่งที่ตั้งฟาร์ม (GPS):', gpsLocation);
    }
  }
}
