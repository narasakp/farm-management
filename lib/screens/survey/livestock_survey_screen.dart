import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/livestock.dart';
import '../../models/survey_form.dart';
import '../../providers/auth_provider.dart';
import '../../providers/survey_provider.dart';
import '../../utils/app_theme.dart';

class LivestockSurveyScreen extends StatefulWidget {
  const LivestockSurveyScreen({super.key});

  @override
  State<LivestockSurveyScreen> createState() => _LivestockSurveyScreenState();
}

class _LivestockSurveyScreenState extends State<LivestockSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmerInfoFormKey = GlobalKey<FormState>();
  
  // Farmer Info Controllers
  final _titleController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _villageController = TextEditingController();
  final _mooController = TextEditingController();
  final _tambonController = TextEditingController();
  final _amphoeController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cropAreaController = TextEditingController();
  final _notesController = TextEditingController();

  List<LivestockSurveyData> livestockData = [];
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with default values for Chaiyaphum
    _amphoeController.text = 'เนินสง่า';
    _provinceController.text = 'ชัยภูมิ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สำรวจข้อมูลปศุสัตว์'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Consumer<SurveyProvider>(
        builder: (context, surveyProvider, child) {
          return Stepper(
            currentStep: currentStep,
            onStepTapped: (step) {
              setState(() {
                currentStep = step;
              });
            },
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  if (details.stepIndex < 2)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: const Text('ถัดไป'),
                    ),
                  if (details.stepIndex == 2)
                    ElevatedButton(
                      onPressed: () => _submitSurvey(surveyProvider),
                      child: surveyProvider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('บันทึกข้อมูล'),
                    ),
                  const SizedBox(width: 8),
                  if (details.stepIndex > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('ย้อนกลับ'),
                    ),
                ],
              );
            },
            steps: [
              Step(
                title: const Text('ข้อมูลเกษตรกร'),
                content: _buildFarmerInfoForm(),
                isActive: currentStep >= 0,
              ),
              Step(
                title: const Text('ข้อมูลปศุสัตว์'),
                content: _buildLivestockForm(),
                isActive: currentStep >= 1,
              ),
              Step(
                title: const Text('สรุปและบันทึก'),
                content: _buildSummaryForm(),
                isActive: currentStep >= 2,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFarmerInfoForm() {
    return Form(
      key: _farmerInfoFormKey,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ข้อมูลส่วนตัว',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _titleController.text.isEmpty ? null : _titleController.text,
                          decoration: const InputDecoration(
                            labelText: 'คำนำหน้า',
                            border: OutlineInputBorder(),
                          ),
                          items: ['นาย', 'นาง', 'นางสาว']
                              .map((title) => DropdownMenuItem(
                                    value: title,
                                    child: Text(title),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _titleController.text = value ?? '';
                          },
                          validator: (value) => value == null ? 'กรุณาเลือกคำนำหน้า' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'ชื่อ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกชื่อ' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'นามสกุล',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกนามสกุล' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _idCardController,
                          decoration: const InputDecoration(
                            labelText: 'เลขบัตรประจำตัว',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'กรุณากรอกเลขบัตรประจำตัว';
                            if (value!.length != 13) return 'เลขบัตรประจำตัวต้องมี 13 หลัก';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'เบอร์มือถือ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกเบอร์มือถือ' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ที่อยู่',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _houseNumberController,
                          decoration: const InputDecoration(
                            labelText: 'บ้านเลขที่',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกบ้านเลขที่' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _villageController,
                          decoration: const InputDecoration(
                            labelText: 'บ้าน (ถ้ามี)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _mooController,
                          decoration: const InputDecoration(
                            labelText: 'หมู่ที่',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกหมู่ที่' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tambonController,
                          decoration: const InputDecoration(
                            labelText: 'ตำบล',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกตำบล' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _amphoeController,
                          decoration: const InputDecoration(
                            labelText: 'อำเภอ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกอำเภอ' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _provinceController,
                          decoration: const InputDecoration(
                            labelText: 'จังหวัด',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกจังหวัด' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockForm() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ข้อมูลปศุสัตว์',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addLivestockEntry,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มปศุสัตว์'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (livestockData.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'ยังไม่มีข้อมูลปศุสัตว์\nกดปุ่ม "เพิ่มปศุสัตว์" เพื่อเริ่มต้น',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...livestockData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(data.type.displayName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.breed != null) Text('พันธุ์: ${data.breed}'),
                            if (data.ageGroup != null) Text('กลุ่มอายุ: ${data.ageGroup}'),
                            Text('จำนวน: ${data.count} ตัว'),
                            if (data.dailyMilkProduction != null)
                              Text('ผลผลิตนม: ${data.dailyMilkProduction} กก./วัน'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeLivestockEntry(index),
                        ),
                        onTap: () => _editLivestockEntry(index),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ข้อมูลเพิ่มเติม',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cropAreaController,
                  decoration: const InputDecoration(
                    labelText: 'พื้นที่พืชอาหารสัตว์ (ไร่)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'หมายเหตุ',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryForm() {
    final farmerInfo = FarmerInfo(
      title: _titleController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      idCard: _idCardController.text,
      phoneNumber: _phoneController.text,
      address: FarmerAddress(
        houseNumber: _houseNumberController.text,
        village: _villageController.text,
        moo: _mooController.text,
        tambon: _tambonController.text,
        amphoe: _amphoeController.text,
        province: _provinceController.text,
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สรุปข้อมูลการสำรวจ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummarySection('ข้อมูลเกษตรกร', [
              'ชื่อ: ${farmerInfo.title}${farmerInfo.firstName} ${farmerInfo.lastName}',
              'เลขบัตรประจำตัว: ${farmerInfo.idCard}',
              'เบอร์มือถือ: ${farmerInfo.phoneNumber}',
              'ที่อยู่: ${farmerInfo.address.fullAddress}',
            ]),
            const SizedBox(height: 16),
            _buildSummarySection('ข้อมูลปศุสัตว์', [
              ...livestockData.map((data) {
                final details = <String>[
                  data.type.displayName,
                  if (data.breed != null) 'พันธุ์: ${data.breed}',
                  if (data.ageGroup != null) 'กลุ่มอายุ: ${data.ageGroup}',
                  'จำนวน: ${data.count} ตัว',
                  if (data.dailyMilkProduction != null) 'ผลผลิตนม: ${data.dailyMilkProduction} กก./วัน',
                ];
                return details.join(', ');
              }).toList(),
              if (livestockData.isEmpty) 'ไม่มีข้อมูลปศุสัตว์',
            ]),
            if (_cropAreaController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSummarySection('ข้อมูลเพิ่มเติม', [
                'พื้นที่พืชอาหารสัตว์: ${_cropAreaController.text} ไร่',
                if (_notesController.text.isNotEmpty) 'หมายเหตุ: ${_notesController.text}',
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text('• $item'),
            )),
      ],
    );
  }

  void _addLivestockEntry() {
    showDialog(
      context: context,
      builder: (context) => LivestockEntryDialog(
        onSave: (data) {
          setState(() {
            livestockData.add(data);
          });
        },
      ),
    );
  }

  void _editLivestockEntry(int index) {
    showDialog(
      context: context,
      builder: (context) => LivestockEntryDialog(
        initialData: livestockData[index],
        onSave: (data) {
          setState(() {
            livestockData[index] = data;
          });
        },
      ),
    );
  }

  void _removeLivestockEntry(int index) {
    setState(() {
      livestockData.removeAt(index);
    });
  }

  Future<void> _submitSurvey(SurveyProvider surveyProvider) async {
    if (!_farmerInfoFormKey.currentState!.validate()) {
      setState(() {
        currentStep = 0;
      });
      return;
    }

    if (livestockData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเพิ่มข้อมูลปศุสัตว์อย่างน้อย 1 รายการ')),
      );
      setState(() {
        currentStep = 1;
      });
      return;
    }

    final survey = FarmSurvey(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: 'farmer_${_idCardController.text}',
      surveyorId: context.read<AuthProvider>().currentUser?.phoneNumber ?? 'unknown_user',
      surveyDate: DateTime.now(),
      farmerInfo: FarmerInfo(
        title: _titleController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        idCard: _idCardController.text,
        phoneNumber: _phoneController.text,
        address: FarmerAddress(
          houseNumber: _houseNumberController.text,
          village: _villageController.text,
          moo: _mooController.text,
          tambon: _tambonController.text,
          amphoe: _amphoeController.text,
          province: _provinceController.text,
        ),
      ),
      livestockData: livestockData,
      cropArea: _cropAreaController.text.isNotEmpty 
          ? double.tryParse(_cropAreaController.text) 
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
    );

    final success = await surveyProvider.submitSurvey(survey);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลการสำรวจเรียบร้อยแล้ว')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idCardController.dispose();
    _phoneController.dispose();
    _houseNumberController.dispose();
    _villageController.dispose();
    _mooController.dispose();
    _tambonController.dispose();
    _amphoeController.dispose();
    _provinceController.dispose();
    _cropAreaController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class LivestockEntryDialog extends StatefulWidget {
  final LivestockSurveyData? initialData;
  final Function(LivestockSurveyData) onSave;

  const LivestockEntryDialog({
    super.key,
    this.initialData,
    required this.onSave,
  });

  @override
  State<LivestockEntryDialog> createState() => _LivestockEntryDialogState();
}

class _LivestockEntryDialogState extends State<LivestockEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  
  LivestockType? selectedType;
  String? selectedBreed;
  String? selectedAgeGroup;
  final _countController = TextEditingController();
  final _milkProductionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      selectedType = widget.initialData!.type;
      selectedBreed = widget.initialData!.breed;
      selectedAgeGroup = widget.initialData!.ageGroup;
      _countController.text = widget.initialData!.count.toString();
      _milkProductionController.text = 
          widget.initialData!.dailyMilkProduction?.toString() ?? '';
      _notesController.text = widget.initialData!.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'เพิ่มข้อมูลปศุสัตว์' : 'แก้ไขข้อมูลปศุสัตว์'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LivestockType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'ประเภทปศุสัตว์',
                  border: OutlineInputBorder(),
                ),
                items: LivestockType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    selectedAgeGroup = null; // Reset age group when type changes
                  });
                },
                validator: (value) => value == null ? 'กรุณาเลือกประเภทปศุสัตว์' : null,
              ),
              const SizedBox(height: 16),
              if (selectedType != null) ...[
                DropdownButtonFormField<String>(
                  value: selectedAgeGroup,
                  decoration: const InputDecoration(
                    labelText: 'กลุ่มอายุ/เพศ',
                    border: OutlineInputBorder(),
                  ),
                  items: SurveyTemplate.getAgeGroupsForType(selectedType!)
                      .map((group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAgeGroup = value;
                    });
                  },
                  validator: (value) => value == null ? 'กรุณาเลือกกลุ่มอายุ/เพศ' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _countController,
                decoration: const InputDecoration(
                  labelText: 'จำนวน (ตัว)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'กรุณากรอกจำนวน';
                  if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                    return 'กรุณากรอกจำนวนที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (selectedType != null && SurveyTemplate.requiresMilkProduction(selectedType!)) ...[
                TextFormField(
                  controller: _milkProductionController,
                  decoration: const InputDecoration(
                    labelText: 'ผลผลิตนม (กก./วัน)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'หมายเหตุ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('บันทึก'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final data = LivestockSurveyData(
        type: selectedType!,
        breed: selectedBreed,
        ageGroup: selectedAgeGroup,
        count: int.parse(_countController.text),
        dailyMilkProduction: _milkProductionController.text.isNotEmpty
            ? double.tryParse(_milkProductionController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      widget.onSave(data);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _milkProductionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
