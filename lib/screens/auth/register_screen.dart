import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prefixController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _tambonController = TextEditingController();
  final _amphoeController = TextEditingController();
  final _provinceController = TextEditingController();

  final List<String> prefixes = ['นาย', 'นาง', 'นางสาว'];
  String selectedPrefix = 'นาย';

  @override
  void initState() {
    super.initState();
    _prefixController.text = selectedPrefix;
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idCardController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _tambonController.dispose();
    _amphoeController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().register(
          prefix: selectedPrefix,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          idCard: _idCardController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          tambon: _tambonController.text,
          amphoe: _amphoeController.text,
          province: _provinceController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
        );
        
        if (mounted) {
          Navigator.pop(context);
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
        title: const Text('ลงทะเบียนสมาชิก'),
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
          child: Center(
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
                            'ข้อมูลส่วนตัว',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Prefix Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedPrefix,
                            decoration: const InputDecoration(
                              labelText: 'คำนำหน้า',
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: prefixes.map((prefix) {
                              return DropdownMenuItem(
                                value: prefix,
                                child: Text(prefix),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPrefix = value!;
                                _prefixController.text = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Name Fields
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'ชื่อ',
                                    prefixIcon: Icon(Icons.badge),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรุณากรอกชื่อ';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'นามสกุล',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรุณากรอกนามสกุล';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // ID Card
                          TextFormField(
                            controller: _idCardController,
                            decoration: const InputDecoration(
                              labelText: 'เลขบัตรประจำตัวประชาชน',
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 13,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกเลขบัตรประจำตัวประชาชน';
                              }
                              if (value.length != 13) {
                                return 'เลขบัตรประจำตัวประชาชนต้องมี 13 หลัก';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'เบอร์โทรศัพท์',
                              hintText: '08xxxxxxxx',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกเบอร์โทรศัพท์';
                              }
                              if (value.length != 10 || !value.startsWith('0')) {
                                return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Email (Optional)
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'อีเมล (ไม่บังคับ)',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!value.contains('@')) {
                                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          Text(
                            'ที่อยู่',
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
                          
                          // Tambon, Amphoe, Province
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
                          const SizedBox(height: 32),
                          
                          // Register Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _register,
                                  child: authProvider.isLoading
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
                                      : const Text('ลงทะเบียน'),
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
      ),
    );
  }
}
