import 'package:flutter/material.dart';
import '../services/privacy_service.dart';
import '../utils/snackbar_helper.dart';

/// Dialog สำหรับขอเข้าถึงฉุกเฉิน
class EmergencyAccessDialog extends StatefulWidget {
  final String targetUserId;
  final String token;
  final String fieldType; // 'id_card' หรือ 'phone'
  final Function(Map<String, dynamic>) onSuccess;

  const EmergencyAccessDialog({
    Key? key,
    required this.targetUserId,
    required this.token,
    required this.fieldType,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<EmergencyAccessDialog> createState() => _EmergencyAccessDialogState();
}

class _EmergencyAccessDialogState extends State<EmergencyAccessDialog> {
  String? selectedType;
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> emergencyTypes = [
    {'value': 'โรคระบาด', 'icon': Icons.coronavirus, 'color': Colors.red},
    {'value': 'อุบัติเหตุ', 'icon': Icons.local_hospital, 'color': Colors.orange},
    {'value': 'ภัยพิบัติ', 'icon': Icons.warning, 'color': Colors.deepOrange},
    {'value': 'อื่นๆ', 'icon': Icons.emergency, 'color': Colors.red[900]},
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate
    if (selectedType == null) {
      showWarningSnackBar(context, 'กรุณาเลือกประเภทความฉุกเฉิน');
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      showWarningSnackBar(context, 'กรุณาระบุเหตุผล');
      return;
    }

    setState(() => _isLoading = true);

    final result = await PrivacyService.emergencyAccess(
      targetUserId: widget.targetUserId,
      reason: _reasonController.text.trim(),
      emergencyType: selectedType!,
      token: widget.token,
      accessFields: [widget.fieldType], // ส่ง field ที่ขอเข้าถึง
    );

    setState(() => _isLoading = false);

    if (result != null && result['success'] == true) {
      if (mounted) {
        widget.onSuccess(result);
        Navigator.of(context).pop(result); // ส่ง result กลับไป
      }
    } else {
      if (mounted) {
        showErrorSnackBar(context, 'เกิดข้อผิดพลาด');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.emergency, color: Colors.red[700]),
          const SizedBox(width: 8),
          const Text('ขอเข้าถึงฉุกเฉิน'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ประเภทความฉุกเฉิน:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ...emergencyTypes.map((type) => Card(
              elevation: selectedType == type['value'] ? 2 : 0,
              color: selectedType == type['value'] 
                  ? (type['color'] as Color).withOpacity(0.1)
                  : null,
              child: RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(type['icon'], size: 20, color: type['color']),
                    const SizedBox(width: 8),
                    Text(type['value']),
                  ],
                ),
                value: type['value'],
                groupValue: selectedType,
                onChanged: _isLoading ? null : (value) {
                  setState(() => selectedType = value);
                },
                dense: true,
              ),
            )),
            
            const SizedBox(height: 16),
            
            const Text(
              'รายละเอียด/เหตุผล:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'ระบุรายละเอียดความฉุกเฉิน...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'คำเตือน:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• ใช้เฉพาะกรณีฉุกเฉินจริงๆ เท่านั้น\n'
                    '• ระบบจะบันทึก Audit Log (High Priority)\n'
                    '• ผู้บังคับบัญชาจะได้รับแจ้งเตือน\n'
                    '• การใช้ในทางที่ผิดอาจมีโทษทางวินัย',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('ยืนยัน'),
        ),
      ],
    );
  }
}
