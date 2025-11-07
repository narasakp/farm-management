import 'package:flutter/material.dart';

class BanUserDialog extends StatefulWidget {
  final String userId;
  final String username;
  final Function(String reason, String banType, String? banUntil) onBan;

  const BanUserDialog({
    super.key,
    required this.userId,
    required this.username,
    required this.onBan,
  });

  @override
  State<BanUserDialog> createState() => _BanUserDialogState();
}

class _BanUserDialogState extends State<BanUserDialog> {
  String _banType = 'temporary';
  final _reasonController = TextEditingController();
  DateTime? _banUntil;
  int _selectedDays = 7;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.block, color: Colors.red),
          const SizedBox(width: 8),
          const Text('แบนผู้ใช้'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'คุณกำลังแบนผู้ใช้: ${widget.username}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ประเภทการแบน:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              value: 'temporary',
              groupValue: _banType,
              onChanged: (value) {
                setState(() {
                  _banType = value!;
                });
              },
              title: const Text('แบนชั่วคราว'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            if (_banType == 'temporary') ...[
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            value: 1,
                            groupValue: _selectedDays,
                            onChanged: (value) {
                              setState(() {
                                _selectedDays = value!;
                              });
                            },
                            title: const Text('1 วัน'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            value: 3,
                            groupValue: _selectedDays,
                            onChanged: (value) {
                              setState(() {
                                _selectedDays = value!;
                              });
                            },
                            title: const Text('3 วัน'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            value: 7,
                            groupValue: _selectedDays,
                            onChanged: (value) {
                              setState(() {
                                _selectedDays = value!;
                              });
                            },
                            title: const Text('7 วัน'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            value: 30,
                            groupValue: _selectedDays,
                            onChanged: (value) {
                              setState(() {
                                _selectedDays = value!;
                              });
                            },
                            title: const Text('30 วัน'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            RadioListTile<String>(
              value: 'permanent',
              groupValue: _banType,
              onChanged: (value) {
                setState(() {
                  _banType = value!;
                });
              },
              title: const Text('แบนถาวร'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'เหตุผลในการแบน *',
                hintText: 'ระบุเหตุผล...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              'ผู้ใช้ที่ถูกแบนจะไม่สามารถสร้างกระทู้หรือแสดงความคิดเห็นได้',
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
            if (_reasonController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('กรุณาระบุเหตุผลในการแบน')),
              );
              return;
            }

            String? banUntil;
            if (_banType == 'temporary') {
              final until = DateTime.now().add(Duration(days: _selectedDays));
              banUntil = until.toIso8601String();
            }

            widget.onBan(_reasonController.text, _banType, banUntil);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('ยืนยันการแบน'),
        ),
      ],
    );
  }
}
