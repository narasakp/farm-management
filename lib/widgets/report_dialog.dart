import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final String contentType; // 'thread' or 'reply'
  final String contentId;
  final Function(String reason, String description) onReport;

  const ReportDialog({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.onReport,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String _selectedReason = 'spam';
  final _descriptionController = TextEditingController();

  final Map<String, String> _reportReasons = {
    'spam': '🚫 สแปม หรือโฆษณา',
    'offensive': '😡 เนื้อหาไม่เหมาะสม หรือก้าวร้าว',
    'misinformation': '❌ ข้อมูลเท็จ หรือทำให้เข้าใจผิด',
    'harassment': '👿 การล่วงละเมิด หรือรบกวน',
    'copyright': '©️ ละเมิดลิขสิทธิ์',
    'duplicate': '📋 เนื้อหาซ้ำซ้อน',
    'other': '❓ อื่นๆ',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.report_problem, color: Colors.red),
          const SizedBox(width: 8),
          Text('รายงาน${widget.contentType == 'thread' ? 'กระทู้' : 'คำตอบ'}'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกเหตุผลในการรายงาน:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ..._reportReasons.entries.map((entry) {
              return RadioListTile<String>(
                value: entry.key,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
                title: Text(entry.value),
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียดเพิ่มเติม (ถ้ามี)',
                hintText: 'อธิบายปัญหาเพิ่มเติม...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Text(
              'การรายงานจะถูกส่งไปยังผู้ดูแลระบบเพื่อพิจารณา',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
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
          onPressed: () {
            widget.onReport(_selectedReason, _descriptionController.text);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('ส่งรายงาน'),
        ),
      ],
    );
  }
}
