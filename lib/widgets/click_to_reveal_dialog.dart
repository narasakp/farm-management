import 'package:flutter/material.dart';
import '../services/privacy_service.dart';
import '../utils/snackbar_helper.dart';

/// Dialog สำหรับขอดูข้อมูลเต็ม (Click-to-Reveal)
class ClickToRevealDialog extends StatefulWidget {
  final String targetUserId;
  final String token;
  final String fieldType; // 'id_card' หรือ 'phone'
  final Function(Map<String, dynamic>) onSuccess;

  const ClickToRevealDialog({
    Key? key,
    required this.targetUserId,
    required this.token,
    required this.fieldType,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<ClickToRevealDialog> createState() => _ClickToRevealDialogState();
}

class _ClickToRevealDialogState extends State<ClickToRevealDialog> {
  String? selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _isLoading = false;

  final List<String> reasons = [
    'นัดหมายเข้าสำรวจฟาร์ม',
    'ติดตามข้อมูลเพิ่มเติม',
    'แจ้งข้อมูลโครงการ',
    'ประสานงานด่วน',
    'อื่นๆ',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  String _getFieldLabel() {
    switch (widget.fieldType) {
      case 'id_card':
        return 'ขอดูเลขบัตรประชาชนเต็ม';
      case 'phone':
        return 'ขอดูเบอร์โทรศัพท์เต็ม';
      case 'gps':
        return 'ขอดูตำแหน่ง GPS เต็ม';
      case 'address':
        return 'ขอดูที่อยู่เต็ม';
      default:
        return 'ขอดูข้อมูลเต็ม';
    }
  }

  Future<void> _submit() async {
    // Validate
    if (selectedReason == null) {
      showWarningSnackBar(context, 'กรุณาเลือกเหตุผล');
      return;
    }

    if (selectedReason == 'อื่นๆ' && _otherReasonController.text.trim().isEmpty) {
      showWarningSnackBar(context, 'กรุณาระบุเหตุผล');
      return;
    }

    setState(() => _isLoading = true);

    final reason = selectedReason == 'อื่นๆ' 
        ? _otherReasonController.text.trim()
        : selectedReason!;

    final result = await PrivacyService.clickToReveal(
      targetUserId: widget.targetUserId,
      reason: reason,
      token: widget.token,
      accessFields: [widget.fieldType], // ส่ง field ที่ขอเข้าถึง
    );

    setState(() => _isLoading = false);

    if (result != null) {
      if (result['error'] != null) {
        if (mounted) {
          showErrorSnackBar(context, result['error']);
        }
      } else if (result['success'] == true) {
        if (mounted) {
          widget.onSuccess(result);
          Navigator.of(context).pop(result); // ส่ง result กลับไป
        }
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
          Icon(Icons.visibility, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Text(_getFieldLabel()),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'กรุณาระบุเหตุผลในการขอดูข้อมูล:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...reasons.map((reason) => RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: selectedReason,
              onChanged: _isLoading ? null : (value) {
                setState(() => selectedReason = value);
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
            
            if (selectedReason == 'อื่นๆ')
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 32),
                child: TextField(
                  controller: _otherReasonController,
                  decoration: const InputDecoration(
                    hintText: 'ระบุเหตุผล...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                  enabled: !_isLoading,
                ),
              ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'ข้อมูลที่ควรทราบ:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• สามารถดูข้อมูลเต็มได้ 2 ชั่วโมง\n'
                    '• กลับเป็น Masked อัตโนมัติเมื่อหมดเวลา\n'
                    '• ระบบจะบันทึก Audit Log\n'
                    '• จำกัด 10 ครั้ง/วัน',
                    style: TextStyle(fontSize: 11),
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
            backgroundColor: Colors.orange,
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
