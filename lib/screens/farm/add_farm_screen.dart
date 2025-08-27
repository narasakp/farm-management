import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../providers/farm_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/farm.dart';

class AddFarmScreen extends StatefulWidget {
  final Farm? farm;

  const AddFarmScreen({super.key, this.farm});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _tambonController = TextEditingController();
  final _amphoeController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _areaSizeController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  
  String? selectedFarmType;
  final List<String> farmTypes = [
    'โคเนื้อ',
    'โคนม',
    'กระบือ',
    'สุกร',
    'สัตว์ปีก',
    'แพะ',
    'แกะ',
    'ฟาร์มผสม',
    'อื่นๆ',
  ];

  bool get isEditing => widget.farm != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final farm = widget.farm!;
    _nameController.text = farm.name;
    _addressController.text = farm.address;
    _tambonController.text = farm.tambon;
    _amphoeController.text = farm.amphoe;
    _provinceController.text = farm.province;
    _postalCodeController.text = farm.postalCode;
    _areaSizeController.text = farm.areaSize?.toString() ?? '';
    _registrationNumberController.text = farm.registrationNumber ?? '';
    selectedFarmType = farm.farmType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _tambonController.dispose();
    _amphoeController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _areaSizeController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveFarm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = context.read<AuthProvider>();
        final farmProvider = context.read<FarmProvider>();
        
        final farm = Farm(
          id: isEditing ? widget.farm!.id : DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: authProvider.currentUser!.id,
          name: _nameController.text,
          address: _addressController.text,
          tambon: _tambonController.text,
          amphoe: _amphoeController.text,
          province: _provinceController.text,
          postalCode: _postalCodeController.text,
          areaSize: _areaSizeController.text.isNotEmpty 
              ? double.tryParse(_areaSizeController.text) 
              : null,
          farmType: selectedFarmType,
          registrationNumber: _registrationNumberController.text.isNotEmpty 
              ? _registrationNumberController.text 
              : null,
          registrationDate: isEditing ? widget.farm!.registrationDate : DateTime.now(),
          createdAt: isEditing ? widget.farm!.createdAt : DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (isEditing) {
          await farmProvider.updateFarm(farm);
        } else {
          await farmProvider.addFarm(farm);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'อัปเดตฟาร์มสำเร็จ' : 'เพิ่มฟาร์มสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).equals(MOBILE);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขฟาร์ม' : 'เพิ่มฟาร์มใหม่'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ข้อมูลฟาร์ม',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Farm Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'ชื่อฟาร์ม',
                            prefixIcon: Icon(Icons.agriculture),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกชื่อฟาร์ม';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Farm Type
                        DropdownButtonFormField<String>(
                          value: selectedFarmType,
                          decoration: const InputDecoration(
                            labelText: 'ประเภทฟาร์ม',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: farmTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFarmType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Area Size
                        TextFormField(
                          controller: _areaSizeController,
                          decoration: const InputDecoration(
                            labelText: 'ขนาดพื้นที่ (ไร่)',
                            prefixIcon: Icon(Icons.square_foot),
                            suffixText: 'ไร่',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (double.tryParse(value) == null) {
                                return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          'ที่อยู่ฟาร์ม',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'บ้านเลขที่ หมู่ที่',
                            prefixIcon: Icon(Icons.home),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกที่อยู่';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Tambon
                        TextFormField(
                          controller: _tambonController,
                          decoration: const InputDecoration(
                            labelText: 'ตำบล',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกตำบล';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Amphoe and Province
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _amphoeController,
                                decoration: const InputDecoration(
                                  labelText: 'อำเภอ',
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกอำเภอ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _provinceController,
                                decoration: const InputDecoration(
                                  labelText: 'จังหวัด',
                                  prefixIcon: Icon(Icons.map),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกจังหวัด';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Postal Code
                        TextFormField(
                          controller: _postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'รหัสไปรษณีย์',
                            prefixIcon: Icon(Icons.local_post_office),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสไปรษณีย์';
                            }
                            if (value.length != 5) {
                              return 'รหัสไปรษณีย์ต้องมี 5 หลัก';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Registration Number (Optional)
                        TextFormField(
                          controller: _registrationNumberController,
                          decoration: const InputDecoration(
                            labelText: 'เลขทะเบียนฟาร์ม (ไม่บังคับ)',
                            prefixIcon: Icon(Icons.verified),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Save Button
                        Consumer<FarmProvider>(
                          builder: (context, farmProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: farmProvider.isLoading ? null : _saveFarm,
                                child: farmProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(isEditing ? 'อัปเดตฟาร์ม' : 'เพิ่มฟาร์ม'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
