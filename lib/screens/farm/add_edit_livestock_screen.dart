import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/livestock.dart';
import '../../providers/livestock_provider.dart';
import '../../providers/farm_provider.dart';

class AddEditLivestockScreen extends StatefulWidget {
  final Livestock? livestock;

  const AddEditLivestockScreen({super.key, this.livestock});

  @override
  State<AddEditLivestockScreen> createState() => _AddEditLivestockScreenState();
}

class _AddEditLivestockScreenState extends State<AddEditLivestockScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditMode;

  // Form controllers
  final _nameController = TextEditingController();
  final _earTagController = TextEditingController();
  final _breedController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();

  LivestockType? _selectedType;
  LivestockGender? _selectedGender;
  LivestockStatus? _selectedStatus;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.livestock != null;

    if (_isEditMode) {
      final animal = widget.livestock!;
      _nameController.text = animal.name ?? '';
      _earTagController.text = animal.earTag ?? '';
      _breedController.text = animal.breed ?? '';
      _selectedType = animal.type;
      _selectedGender = animal.gender;
      _selectedStatus = animal.status;
      if (animal.birthDate != null) {
        _selectedBirthDate = animal.birthDate;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(animal.birthDate!);
      }
      if (animal.weight != null) {
        _weightController.text = animal.weight.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _earTagController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final farmId = Provider.of<FarmProvider>(context, listen: false).selectedFarm?.id;
      if (farmId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกฟาร์มก่อนบันทึก')),
        );
        return;
      }

      final livestockProvider = Provider.of<LivestockProvider>(context, listen: false);

      final newAnimal = Livestock(
        id: _isEditMode ? widget.livestock!.id : DateTime.now().toIso8601String(),
        farmId: farmId,
        name: _nameController.text,
        earTag: _earTagController.text,
        type: _selectedType!,
        breed: _breedController.text,
        gender: _selectedGender!,
        birthDate: _selectedBirthDate,
        weight: double.tryParse(_weightController.text),
        status: _selectedStatus!,
        createdAt: _isEditMode ? widget.livestock!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        livestockProvider.updateLivestock(newAnimal);
      } else {
        livestockProvider.addLivestock(newAnimal);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'แก้ไขข้อมูลปศุสัตว์' : 'เพิ่มปศุสัตว์ใหม่'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อ (ถ้ามี)'),
              ),
              TextFormField(
                controller: _earTagController,
                decoration: const InputDecoration(labelText: 'หมายเลขประจำตัว (Ear Tag)'),
              ),
              DropdownButtonFormField<LivestockType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'ประเภทสัตว์'),
                items: LivestockType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.displayName));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) => value == null ? 'กรุณาเลือกประเภทสัตว์' : null,
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'สายพันธุ์'),
              ),
              DropdownButtonFormField<LivestockGender>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'เพศ'),
                items: LivestockGender.values.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender.displayName));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) => value == null ? 'กรุณาเลือกเพศ' : null,
              ),
               TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'วันเกิด',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'น้ำหนัก (กก.)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<LivestockStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'สถานะ'),
                items: LivestockStatus.values.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status.displayName));
                }).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value),
                validator: (value) => value == null ? 'กรุณาเลือกสถานะ' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('บันทึกข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
