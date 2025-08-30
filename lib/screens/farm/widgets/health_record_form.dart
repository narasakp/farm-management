import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/health_record.dart';
import '../../../providers/livestock_provider.dart';

class HealthRecordForm extends StatefulWidget {
  final String livestockId;

  const HealthRecordForm({super.key, required this.livestockId});

  @override
  State<HealthRecordForm> createState() => _HealthRecordFormState();
}

class _HealthRecordFormState extends State<HealthRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedType;
  final List<String> _recordTypes = ['vaccination', 'treatment', 'checkup'];

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newRecord = HealthRecord(
        id: DateTime.now().toIso8601String(),
        livestockId: widget.livestockId,
        date: _selectedDate!,
        recordType: _selectedType!,
        notes: _notesController.text,
        createdAt: DateTime.now(),
      );
      Provider.of<LivestockProvider>(context, listen: false).addHealthRecord(newRecord);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'วันที่บันทึก',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) => value == null || value.isEmpty ? 'กรุณาเลือกวันที่' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'ประเภทการบันทึก'),
              items: _recordTypes.map((recordType) {
                return DropdownMenuItem(value: recordType, child: Text(recordType));
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value),
              validator: (value) => value == null ? 'กรุณาเลือกประเภท' : null,
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'หมายเหตุ/รายละเอียด'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: const Text('บันทึก'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
