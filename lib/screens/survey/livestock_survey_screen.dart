import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import '../../providers/survey_provider.dart';
import '../../providers/production_auth_provider.dart';
import '../../models/survey_form.dart';
import '../../models/livestock.dart';
import '../../models/thailand_address.dart';
import '../../services/thailand_address_service.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/standard_snackbar.dart';

class LivestockSurveyScreen extends ConsumerStatefulWidget {
  final FarmSurvey? editingSurvey;
  
  const LivestockSurveyScreen({super.key, this.editingSurvey});

  @override
  ConsumerState<LivestockSurveyScreen> createState() => _LivestockSurveyScreenState();
}

class _LivestockSurveyScreenState extends ConsumerState<LivestockSurveyScreen> {
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
  final _postalCodeController = TextEditingController();
  
  // Address data
  List<Province> _provinces = [];
  List<Amphoe> _amphoes = [];
  List<Tambon> _tambons = [];
  
  Province? _selectedProvince;
  Amphoe? _selectedAmphoe;
  Tambon? _selectedTambon;
  String? _postalCode;
  
  bool _isLoadingAddress = false;
  final _farmAreaController = TextEditingController();
  final _cropAreaController = TextEditingController();
  final _notesController = TextEditingController();
  
  // GPS Location
  double? _latitude;
  double? _longitude;
  String? _gpsAddress;
  bool _isLoadingGPS = false;
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  // Photo
  String? _farmerPhotoBase64;
  bool _isMobile = false;

  List<LivestockSurveyData> livestockData = [];
  int currentStep = 0;
  bool get isEditMode => widget.editingSurvey != null;

  @override
  void initState() {
    super.initState();
    _detectPlatform();
    
    // ✅ ตั้งค่า default สำหรับพื้นที่ปลูกพืช
    if (!isEditMode) {
      _cropAreaController.text = '0';
    }
    
    // ถ้าเป็น edit mode ให้ pre-fill ข้อมูล (หลัง UI สร้างเสร็จ)
    if (isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _prefillSurveyData();
        }
      });
    }
  }
  
  Future<void> _prefillSurveyData() async {
    final survey = widget.editingSurvey!;
    
    // 🔧 FIX: โหลด provinces ก่อน (ถ้ายังไม่ได้โหลด)
    if (_provinces.isEmpty) {
      await _loadProvincesForEdit();
    }
    
    // หา Province object ที่ตรงกับข้อมูลที่บันทึกไว้
    _selectedProvince = _provinces.firstWhere(
      (p) => p.nameTh == survey.farmerInfo.address.province,
      orElse: () => _provinces.first,
    );
    
    // โหลด amphoes ของจังหวัดที่เลือก
    final amphoes = await ThailandAddressService.getAmphoesByProvince(_selectedProvince!.id);
    
    // หา Amphoe object
    _selectedAmphoe = amphoes.firstWhere(
      (a) => a.nameTh == survey.farmerInfo.address.amphoe,
      orElse: () => amphoes.first,
    );
    
    // โหลด tambons ของอำเภอที่เลือก
    final tambons = await ThailandAddressService.getTambonsByAmphoe(_selectedAmphoe!.id);
    
    // หา Tambon object
    _selectedTambon = tambons.firstWhere(
      (t) => t.nameTh == survey.farmerInfo.address.tambon,
      orElse: () => tambons.first,
    );
    
    setState(() {
      _amphoes = amphoes;
      _tambons = tambons;
      
      // Pre-fill farmer info
      _titleController.text = survey.farmerInfo.title;
      _firstNameController.text = survey.farmerInfo.firstName;
      _lastNameController.text = survey.farmerInfo.lastName;
      _idCardController.text = survey.farmerInfo.idCard;
      _phoneController.text = survey.farmerInfo.phoneNumber;
      _houseNumberController.text = survey.farmerInfo.address.houseNumber;
      _villageController.text = survey.farmerInfo.address.village ?? '';
      _mooController.text = survey.farmerInfo.address.moo;
      _provinceController.text = survey.farmerInfo.address.province;
      _amphoeController.text = survey.farmerInfo.address.amphoe;
      _tambonController.text = survey.farmerInfo.address.tambon;
      
      // 🔧 FIX: ตั้งรหัสไปรษณีย์จาก survey หรือ ดึงจาก tambon
      _postalCode = survey.farmerInfo.address.postalCode ?? _selectedTambon?.zipCode.toString();
      _postalCodeController.text = _postalCode ?? '';
      
      _farmerPhotoBase64 = survey.farmerInfo.photoBase64;
      
      // Pre-fill other info
      _farmAreaController.text = survey.farmArea?.toString() ?? '';
      _cropAreaController.text = survey.cropArea?.toString() ?? '';
      _notesController.text = survey.notes ?? '';
      
      // Pre-fill GPS
      if (survey.gpsLocation != null) {
        final parts = survey.gpsLocation!.split(',');
        if (parts.length == 2) {
          _latitude = double.tryParse(parts[0].trim());
          _longitude = double.tryParse(parts[1].trim());
          
          // แสดงค่าใน TextField ด้วย
          if (_latitude != null && _longitude != null) {
            _latitudeController.text = _latitude!.toStringAsFixed(6);
            _longitudeController.text = _longitude!.toStringAsFixed(6);
            _gpsAddress = 'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}';
            
            // Debug log
            print('✅ GPS Pre-filled: Lat=${_latitudeController.text}, Lng=${_longitudeController.text}');
          }
        }
      }
      
      // Pre-fill livestock data
      livestockData = List.from(survey.livestockData);
      
      print('✅ รหัสไปรษณีย์ Pre-filled: $_postalCode');
    });
  }
  
  // 🔧 NEW: โหลด provinces สำหรับ edit mode
  Future<void> _loadProvincesForEdit() async {
    final provinces = await ThailandAddressService.getProvinces();
    setState(() {
      _provinces = provinces;
    });
  }
  
  void _detectPlatform() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    _isMobile = userAgent.contains('mobile') || 
                userAgent.contains('android') || 
                userAgent.contains('iphone') ||
                userAgent.contains('ipad');
  }
  
  Future<void> _loadProvinces() async {
    setState(() {
      _isLoadingAddress = true;
    });
    
    final provinces = await ThailandAddressService.getProvinces();
    
    setState(() {
      _provinces = provinces;
      _isLoadingAddress = false;
      
      // Set default to Chaiyaphum
      _selectedProvince = provinces.firstWhere(
        (p) => p.nameTh == 'ชัยภูมิ',
        orElse: () => provinces.first,
      );
      _provinceController.text = _selectedProvince!.nameTh;
      _loadAmphoesWithDefault(_selectedProvince!.id);
    });
  }
  
  Future<void> _loadAmphoesWithDefault(int provinceId) async {
    final amphoes = await ThailandAddressService.getAmphoesByProvince(provinceId);
    
    setState(() {
      _amphoes = amphoes;
      
      // Set default to Noen Sa-nga (เนินสง่า)
      _selectedAmphoe = amphoes.firstWhere(
        (a) => a.nameTh == 'เนินสง่า',
        orElse: () => amphoes.first,
      );
      _amphoeController.text = _selectedAmphoe!.nameTh;
    });
    
    // โหลดตำบลและตั้งรหัสไปรษณีย์จากอำเภอ
    await _loadTambonsWithDefault(_selectedAmphoe!.id);
    await _setPostalCodeFromAmphoe(_selectedAmphoe!.id);
  }
  
  Future<void> _loadAmphoes(int provinceId) async {
    final amphoes = await ThailandAddressService.getAmphoesByProvince(provinceId);
    
    setState(() {
      _amphoes = amphoes;
      _selectedAmphoe = null;
      _selectedTambon = null;
      _tambons = [];
      _amphoeController.text = '';
      _tambonController.text = '';
      _postalCode = null;
      _postalCodeController.text = '';
    });
  }
  
  Future<void> _loadTambonsWithDefault(int amphoeId) async {
    final tambons = await ThailandAddressService.getTambonsByAmphoe(amphoeId);
    
    setState(() {
      _tambons = tambons;
      
      // Set default to Kahat (กะฮาด)
      _selectedTambon = tambons.firstWhere(
        (t) => t.nameTh == 'กะฮาด',
        orElse: () => tambons.first,
      );
      _tambonController.text = _selectedTambon!.nameTh;
      // รหัสไปรษณีย์ตั้งแล้วตอนเลือกอำเภอ ไม่ต้องตั้งใหม่
    });
  }
  
  Future<void> _loadTambons(int amphoeId) async {
    final tambons = await ThailandAddressService.getTambonsByAmphoe(amphoeId);
    
    setState(() {
      _tambons = tambons;
      _selectedTambon = null;
      _tambonController.text = '';
      _postalCode = null;
      _postalCodeController.text = '';
    });
  }
  
  // ตั้งรหัสไปรษณีย์จากอำเภอ (ดึงจากตำบลแรกของอำเภอนั้น)
  Future<void> _setPostalCodeFromAmphoe(int amphoeId) async {
    final tambons = await ThailandAddressService.getTambonsByAmphoe(amphoeId);
    
    if (tambons.isNotEmpty) {
      setState(() {
        _postalCode = tambons.first.zipCode.toString();
        _postalCodeController.text = _postalCode!;
      });
    }
  }

  // ถ่ายรูปด้วยกล้อง
  Future<void> _takePhoto() async {
    if (_isMobile) {
      // Mobile: ใช้ HTML5 capture attribute เปิดกล้องโดยตรง
      _capturePhotoMobile();
    } else {
      // Desktop: เปิด webcam dialog
      _capturePhotoDesktop();
    }
  }
  
  // สำหรับ Mobile - เปิดแอปกล้องโดยตรง
  Future<void> _capturePhotoMobile() async {
    try {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.setAttribute('capture', 'camera');
      uploadInput.click();
      
      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          
          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final dataUrl = reader.result as String;
              
              // บีบอัดรูปภาพก่อนบันทึก
              final compressedBase64 = await _compressImage(dataUrl);
              
              setState(() {
                _farmerPhotoBase64 = compressedBase64;
              });
              
              if (mounted) {
                StandardSnackbar.showSuccess(context, 'บันทึกรูปภาพแล้ว');
              }
            }
          });
          
          reader.readAsDataUrl(file);
        }
      });
    } catch (e) {
      if (mounted) {
        StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด: $e');
      }
    }
  }
  
  // สำหรับ Desktop - เปิด webcam popup window
  Future<void> _capturePhotoDesktop() async {
    try {
      // คำนวณตำแหน่งกลางจอ - ขนาดหน้าต่าง 4/5 ของหน้าจอ
      final screenWidth = html.window.screen?.width ?? 1920;
      final screenHeight = html.window.screen?.height ?? 1080;
      final windowHeight = (screenHeight * 0.8).round();  // 4/5 ของหน้าจอ
      final windowWidth = (windowHeight * 0.85).round();   // เพิ่มความกว้าง 0.7→0.85
      final left = ((screenWidth - windowWidth) / 2).round();
      final top = ((screenHeight - windowHeight) / 2).round();
      
      // เปิดหน้าต่าง camera.html พร้อม cache busting และตำแหน่งกลางจอ
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final popup = html.window.open(
        'camera.html?v=$timestamp',
        'Camera',
        'width=$windowWidth,height=$windowHeight,left=$left,top=$top,resizable=yes,scrollbars=no'
      );
      
      if (popup == null) {
        throw Exception('ไม่สามารถเปิดหน้าต่างกล้องได้ กรุณาอนุญาต popup');
      }
      
      // รอรับข้อมูลจาก popup
      html.window.onMessage.listen((event) async {
        if (event.data is Map && event.data['type'] == 'camera_photo') {
          final dataUrl = 'data:image/jpeg;base64,' + (event.data['data'] as String);
          
          // บีบอัดรูปภาพก่อนบันทึก
          final compressedBase64 = await _compressImage(dataUrl);
          
          setState(() {
            _farmerPhotoBase64 = compressedBase64;
          });
          
          if (mounted) {
            StandardSnackbar.showSuccess(context, 'บันทึกรูปภาพแล้ว');
          }
        }
      });
      
    } catch (e) {
      if (mounted) {
        StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด: ${e.toString()}');
      }
    }
  }

  // เลือกรูปจากคลังภาพ (สำหรับ Web)
  Future<void> _pickImage() async {
    try {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      
      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          
          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final dataUrl = reader.result as String;
              
              // บีบอัดรูปภาพก่อนบันทึก
              final base64String = await _compressImage(dataUrl);
              
              setState(() {
                _farmerPhotoBase64 = base64String;
              });
              
              if (mounted) {
                StandardSnackbar.showSuccess(context, 'บันทึกรูปภาพแล้ว');
              }
            }
          });
          
          reader.readAsDataUrl(file);
        }
      });
    } catch (e) {
      if (mounted) {
        StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด: $e');
      }
    }
  }

  // ดึงตำแหน่ง GPS
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingGPS = true;
    });
    
    try {
      // ใช้ HTML5 Geolocation API
      final position = await html.window.navigator.geolocation.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 10),
        maximumAge: const Duration(seconds: 0),
      );
      
      final coords = position.coords;
      
      if (coords != null) {
        final lat = coords.latitude?.toDouble();
        final lng = coords.longitude?.toDouble();
        
        if (lat != null && lng != null) {
          setState(() {
            _latitude = lat;
            _longitude = lng;
            _latitudeController.text = lat.toStringAsFixed(6);
            _longitudeController.text = lng.toStringAsFixed(6);
            _gpsAddress = 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
            _isLoadingGPS = false;
          });
          
          if (mounted) {
            StandardSnackbar.showSuccess(
              context, 
              'บันทึกตำแหน่ง GPS สำเร็จ\nLat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}'
            );
          }
        } else {
          throw Exception('ไม่สามารถอ่านพิกัด GPS ได้');
        }
      } else {
        throw Exception('ไม่พบข้อมูลพิกัด');
      }
    } catch (e) {
      setState(() {
        _isLoadingGPS = false;
      });
      
      // ตรวจสอบว่าเป็น Mobile หรือ Desktop (สำหรับข้อความ)
      final isMobile = MediaQuery.of(context).size.width < 600;
      
      String errorMessage = 'ดึงตำแหน่งจริงไม่ได้';
      
      // แยกประเภท error
      if (e.toString().contains('User denied')) {
        errorMessage = isMobile ? 'ไม่อนุญาตใช้ตำแหน่ง' : 'คุณปฏิเสธการเข้าถึงตำแหน่ง GPS';
      } else if (e.toString().contains('timeout')) {
        errorMessage = isMobile ? 'หาตำแหน่งไม่เจอ' : 'หมดเวลารอข้อมูล GPS (Timeout)';
      } else if (e.toString().contains('unavailable')) {
        errorMessage = isMobile ? 'GPS ใช้ไม่ได้' : 'GPS ไม่สามารถใช้งานได้ในขณะนี้';
      }
      
      if (mounted) {
        StandardSnackbar.showWarning(
          context, 
          '$errorMessage\nกรุณากรอกพิกัดเอง',
          duration: const Duration(seconds: 5),
        );
      }
    }
  }
  
  // กรอกพิกัดเอง (สำหรับ Desktop ที่ไม่มี GPS)
  Future<void> _enterManualGPS() async {
    // ใช้ controllers ถาวรแทนสร้างใหม่
    // ถ้ามีพิกัดเดิม ให้แสดง
    if (_latitude != null && _longitude != null) {
      _latitudeController.text = _latitude!.toStringAsFixed(6);
      _longitudeController.text = _longitude!.toStringAsFixed(6);
    }
    
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_location, color: Color(0xFF228B22)),
            SizedBox(width: 8),
            Text('กรอกพิกัด GPS'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude (ละติจูด)',
                  hintText: 'เช่น 15.837841',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude (ลองจิจูด)',
                  hintText: 'เช่น 102.086058',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'วิธีหาพิกัด GPS:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            html.window.open('https://www.google.com/maps', '_blank');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade300,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Google Maps',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // แยกคำแนะนำตาม Device
                    Builder(
                      builder: (context) {
                        final isMobile = MediaQuery.of(context).size.width < 600;
                        
                        if (isMobile) {
                          // คำแนะนำสำหรับมือถือ
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📱 สำหรับมือถือ:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              SizedBox(height: 4),
                              Text('1. แตะปุ่ม Google Maps ด้านบน', style: TextStyle(fontSize: 11)),
                              Text('2. แตะค้างบนแผนที่ ~2 วินาที', style: TextStyle(fontSize: 11)),
                              Text('3. หมุดแดงจะปรากฏ พิกัดแสดงด้านล่าง', style: TextStyle(fontSize: 11)),
                              Text('4. แตะที่พิกัดเพื่อคัดลอก', style: TextStyle(fontSize: 11)),
                              Text('5. กรอกในฟอร์ม (แยก ละติจูด, ลองจิจูด)', style: TextStyle(fontSize: 11)),
                            ],
                          );
                        } else {
                          // คำแนะนำสำหรับ Desktop/Laptop
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💻 สำหรับ Desktop/Laptop:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              SizedBox(height: 4),
                              Text('1. คลิกปุ่ม Google Maps ด้านบน', style: TextStyle(fontSize: 11)),
                              Text('2. คลิกตำแหน่งจริงบนแผนที่', style: TextStyle(fontSize: 11)),
                              Text('3. หมุดแดงปรากฏ พิกัดแสดงด้านล่าง', style: TextStyle(fontSize: 11)),
                              Text('4. คลิกที่พิกัดเพื่อคัดลอก', style: TextStyle(fontSize: 11)),
                              Text('5. กรอกในฟอร์ม (แยก ละติจูด, ลองจิจูด)', style: TextStyle(fontSize: 11)),
                            ],
                          );
                        }
                      },
                    ),
                  ],
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
              final lat = double.tryParse(_latitudeController.text);
              final lng = double.tryParse(_longitudeController.text);
              
              if (lat != null && lng != null) {
                // ตรวจสอบค่าอยู่ในช่วงที่ถูกต้อง
                if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                  Navigator.pop(context, {'lat': lat, 'lng': lng});
                } else {
                  StandardSnackbar.showError(
                    context,
                    'พิกัดไม่ถูกต้อง: Lat (-90 ถึง 90), Lng (-180 ถึง 180)',
                  );
                }
              } else {
                StandardSnackbar.showError(context, 'กรุณากรอกพิกัดให้ถูกต้อง');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
            ),
            child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (result != null) {
      setState(() {
        _latitude = result['lat'];
        _longitude = result['lng'];
        _latitudeController.text = _latitude!.toStringAsFixed(6);
        _longitudeController.text = _longitude!.toStringAsFixed(6);
        _gpsAddress = 'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}';
      });
      
      if (mounted) {
        StandardSnackbar.showSuccess(context, 'บันทึกพิกัด GPS สำเร็จ\n${_gpsAddress}');
      }
    }
  }
  
  // เปิด Google Maps
  void _openGoogleMaps() {
    if (_latitude != null && _longitude != null) {
      final url = 'https://www.google.com/maps?q=$_latitude,$_longitude';
      html.window.open(url, '_blank');
    } else {
      StandardSnackbar.showWarning(context, 'กรุณาบันทึกตำแหน่ง GPS ก่อน');
    }
  }

  // ฟังก์ชันบีบอัดรูปภาพ
  Future<String> _compressImage(String dataUrl) async {
    try {
      // สร้าง Image element
      final img = html.ImageElement();
      img.src = dataUrl;
      
      // รอให้รูปโหลดเสร็จ
      await img.onLoad.first;
      
      // คำนวณขนาดใหม่ (จำกัดไม่เกิน 800px)
      int targetWidth = 800;
      int targetHeight = 800;
      
      final aspectRatio = img.width! / img.height!;
      if (aspectRatio > 1) {
        // รูปแนวนอน
        targetHeight = (targetWidth / aspectRatio).round();
      } else {
        // รูปแนวตั้ง
        targetWidth = (targetHeight * aspectRatio).round();
      }
      
      // สร้าง Canvas เพื่อรีไซส์รูป
      final canvas = html.CanvasElement(width: targetWidth, height: targetHeight);
      final ctx = canvas.context2D;
      
      // วาดรูปลงบน Canvas แบบรีไซส์
      ctx.drawImageScaled(img, 0, 0, targetWidth, targetHeight);
      
      // แปลงเป็น Base64 (JPEG quality 0.7 เพื่อลดขนาดไฟล์)
      final compressedDataUrl = canvas.toDataUrl('image/jpeg', 0.7);
      final base64String = compressedDataUrl.split(',')[1];
      
      print('📸 Image compressed: Original size vs Compressed');
      print('   Original: ${dataUrl.length} chars');
      print('   Compressed: ${base64String.length} chars');
      print('   Reduction: ${((1 - base64String.length / dataUrl.length) * 100).toStringAsFixed(1)}%');
      
      return base64String;
    } catch (e) {
      print('❌ Error compressing image: $e');
      // ถ้าบีบอัดไม่ได้ ให้คืนค่าเดิม (แต่ตัดส่วน data:image prefix)
      return dataUrl.split(',')[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ตรวจสอบ Authentication State
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
    
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main, // ชั้นที่ 1 - ไม่มีปุ่ม Home
        title: isEditMode ? 'แก้ไขข้อมูลการสำรวจ' : 'สำรวจปศุสัตว์',
        onBackPressed: () {
          // Smart Back: กลับหน้าก่อนหน้า หรือไป Dashboard ถ้าไม่มีประวัติ
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/dashboard');
          }
        },
      ),
      body: Consumer<SurveyProvider>(
        builder: (context, surveyProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ส่วนฟอร์มสำรวจ
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF228B22).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stepper(
                    currentStep: currentStep,
                    onStepTapped: (step) {
                      setState(() {
                        currentStep = step;
                      });
                    },
                    controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          // ปุ่มบันทึกข้อมูล - แสดงเฉพาะขั้นตอนที่ 2 (สรุปและบันทึก)
                          if (details.stepIndex == 2)
                            ElevatedButton(
                              onPressed: () => _submitSurvey(surveyProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF228B22),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: surveyProvider.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'บันทึกข้อมูล',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                        ],
                      ),
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
                ), // ปิด Stepper
                ), // ปิด Container ของฟอร์ม
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFarmerInfoForm() {
    // 🔧 FIX: Lazy load provinces เฉพาะ NEW mode (ไม่ใช่ EDIT mode)
    // เพราะ EDIT mode โหลดข้อมูลใน _prefillSurveyData() แล้ว
    if (_provinces.isEmpty && !_isLoadingAddress && !isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadProvinces();
      });
    }
    
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
                  // ✅ Responsive: Column บน Mobile, Row บน Desktop
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        // 📱 Mobile: 1 input per row
                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _titleController.text.isEmpty ? null : _titleController.text,
                              decoration: const InputDecoration(
                                labelText: 'คำนำหน้า',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'ชื่อ *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกชื่อ' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'นามสกุล *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'กรุณากรอกนามสกุล' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _idCardController,
                              decoration: const InputDecoration(
                                labelText: 'เลขบัตรประจำตัวประชาชน 13 หลัก *',
                                border: OutlineInputBorder(),
                                counterText: '',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(13),
                              ],
                              maxLength: 13,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'กรุณากรอกเลขบัตรประจำตัวประชาชน';
                                if (value!.length != 13) return 'ต้องมี 13 หลักพอดี';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'เบอร์มือถือ 10 หลัก (ไม่บังคับ)',
                                border: OutlineInputBorder(),
                                counterText: '',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              maxLength: 10,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return null;
                                if (value!.length != 10) return 'ต้องมี 10 หลักพอดี';
                                return null;
                              },
                            ),
                          ],
                        );
                      } else {
                        // 💻 Desktop: Row layout (เดิม)
                        return Column(
                          children: [
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
                                      labelText: 'ชื่อ *',
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
                                      labelText: 'นามสกุล *',
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
                                      labelText: 'เลขบัตรประจำตัวประชาชน 13 หลัก *',
                                      border: OutlineInputBorder(),
                                      counterText: '',
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(13),
                                    ],
                                    maxLength: 13,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) return 'กรุณากรอกเลขบัตรประจำตัวประชาชน';
                                      if (value!.length != 13) return 'ต้องมี 13 หลักพอดี';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'เบอร์มือถือ 10 หลัก (ไม่บังคับ)',
                                      border: OutlineInputBorder(),
                                      counterText: '',
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    maxLength: 10,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) return null;
                                      if (value!.length != 10) return 'ต้องมี 10 หลักพอดี';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // รูปภาพเกษตรกร
                  const Text(
                    'รูปภาพเกษตรกร (ไม่บังคับ)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // แสดงรูปตัวอย่าง
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: _farmerPhotoBase64 != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64Decode(_farmerPhotoBase64!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                      ),
                      const SizedBox(width: 16),
                      // ปุ่มเลือกรูป
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('ถ่ายรูป'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('เลือกจากคลังภาพ'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            if (_farmerPhotoBase64 != null) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _farmerPhotoBase64 = null;
                                  });
                                },
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('ลบรูปภาพ'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ],
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
                  // ✅ Responsive Layout: Column บน Mobile, Row บน Desktop
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        // 📱 Mobile: 1 แถว 1 input
                        return Column(
                          children: [
                            TextFormField(
                              controller: _houseNumberController,
                              decoration: const InputDecoration(
                                labelText: 'บ้านเลขที่ *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาระบุ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _mooController.text.isEmpty ? null : _mooController.text,
                              decoration: const InputDecoration(
                                labelText: 'หมู่ที่ *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) => value == null ? 'กรุณาเลือกหมู่ที่' : null,
                              items: List.generate(30, (index) {
                                final mooNumber = '${index + 1}';
                                return DropdownMenuItem(
                                  value: mooNumber,
                                  child: Text('หมู่ $mooNumber'),
                                );
                              }),
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    _mooController.text = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _villageController,
                              decoration: const InputDecoration(
                                labelText: 'บ้าน',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // 💻 Desktop: แสดงแบบ Row (แนวนอน)
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _houseNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'บ้านเลขที่ *',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณาระบุ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: _villageController,
                                decoration: const InputDecoration(
                                  labelText: 'บ้าน',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _mooController.text.isEmpty ? null : _mooController.text,
                                decoration: const InputDecoration(
                                  labelText: 'หมู่ที่ *',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                validator: (value) => value == null ? 'กรุณาเลือกหมู่ที่' : null,
                                items: List.generate(30, (index) {
                                  final mooNumber = '${index + 1}';
                                  return DropdownMenuItem(
                                    value: mooNumber,
                                    child: Text('หมู่ $mooNumber'),
                                  );
                                }),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _mooController.text = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // จังหวัด / อำเภอ / ตำบล / รหัสไปรษณีย์
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        // 📱 Mobile: แสดงแบบ Column (แนวตั้ง)
                        return Column(
                          children: [
                            DropdownButtonFormField<Province>(
                              value: _selectedProvince,
                              decoration: const InputDecoration(
                                labelText: 'จังหวัด *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              validator: (value) => value == null ? 'กรุณาเลือกจังหวัด' : null,
                              items: _provinces.map((province) {
                                return DropdownMenuItem(
                                  value: province,
                                  child: Text(province.nameTh),
                                );
                              }).toList(),
                              onChanged: (Province? value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedProvince = value;
                                    _provinceController.text = value.nameTh;
                                  });
                                  _loadAmphoes(value.id);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Amphoe>(
                              value: _selectedAmphoe,
                              decoration: const InputDecoration(
                                labelText: 'อำเภอ *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (value) => value == null ? 'กรุณาเลือกอำเภอ' : null,
                              items: _amphoes.map((amphoe) {
                                return DropdownMenuItem(
                                  value: amphoe,
                                  child: Text(amphoe.nameTh),
                                );
                              }).toList(),
                              onChanged: (Amphoe? value) async {
                                if (value != null) {
                                  setState(() {
                                    _selectedAmphoe = value;
                                    _amphoeController.text = value.nameTh;
                                  });
                                  await _loadTambons(value.id);
                                  await _setPostalCodeFromAmphoe(value.id);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Tambon>(
                              value: _selectedTambon,
                              decoration: const InputDecoration(
                                labelText: 'ตำบล *',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) => value == null ? 'กรุณาเลือกตำบล' : null,
                              items: _tambons.map((tambon) {
                                return DropdownMenuItem(
                                  value: tambon,
                                  child: Text(tambon.nameTh),
                                );
                              }).toList(),
                              onChanged: (Tambon? value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedTambon = value;
                                    _tambonController.text = value.nameTh;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _postalCodeController,
                              decoration: const InputDecoration(
                                labelText: 'รหัสไปรษณีย์ *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.markunread_mailbox),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'เลือกอำเภอ';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      } else {
                        // 💻 Desktop: แสดงแบบ Row (แนวนอน)
                        return Row(
                          children: [
                            Expanded(
                              flex: 15,
                              child: DropdownButtonFormField<Province>(
                                value: _selectedProvince,
                                decoration: const InputDecoration(
                                  labelText: 'จังหวัด *',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                validator: (value) => value == null ? 'กรุณาเลือกจังหวัด' : null,
                                items: _provinces.map((province) {
                                  return DropdownMenuItem(
                                    value: province,
                                    child: Text(province.nameTh),
                                  );
                                }).toList(),
                                onChanged: (Province? value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedProvince = value;
                                      _provinceController.text = value.nameTh;
                                    });
                                    _loadAmphoes(value.id);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 18,
                              child: DropdownButtonFormField<Amphoe>(
                                value: _selectedAmphoe,
                                decoration: const InputDecoration(
                                  labelText: 'อำเภอ *',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                validator: (value) => value == null ? 'กรุณาเลือกอำเภอ' : null,
                                items: _amphoes.map((amphoe) {
                                  return DropdownMenuItem(
                                    value: amphoe,
                                    child: Text(amphoe.nameTh),
                                  );
                                }).toList(),
                                onChanged: (Amphoe? value) async {
                                  if (value != null) {
                                    setState(() {
                                      _selectedAmphoe = value;
                                      _amphoeController.text = value.nameTh;
                                    });
                                    await _loadTambons(value.id);
                                    await _setPostalCodeFromAmphoe(value.id);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 14,
                              child: DropdownButtonFormField<Tambon>(
                                value: _selectedTambon,
                                decoration: const InputDecoration(
                                  labelText: 'ตำบล *',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                validator: (value) => value == null ? 'กรุณาเลือกตำบล' : null,
                                items: _tambons.map((tambon) {
                                  return DropdownMenuItem(
                                    value: tambon,
                                    child: Text(tambon.nameTh),
                                  );
                                }).toList(),
                                onChanged: (Tambon? value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedTambon = value;
                                      _tambonController.text = value.nameTh;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 8,
                              child: TextFormField(
                                controller: _postalCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'รหัสไปรษณีย์ *',
                                  hintText: 'อำเภอ',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.markunread_mailbox),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'เลือกอำเภอ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // GPS และพื้นที่ฟาร์ม
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF228B22), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'ตำแหน่งที่ตั้งฟาร์ม (GPS)',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ✅ ปุ่มบันทึก GPS - Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        // 📱 Mobile: Column
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoadingGPS ? null : _getCurrentLocation,
                              icon: _isLoadingGPS
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.my_location),
                              label: Text(_isLoadingGPS ? 'กำลังดึงตำแหน่ง...' : 'บันทึกตำแหน่ง GPS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF228B22),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _enterManualGPS,
                              icon: const Icon(Icons.edit_location, size: 20),
                              label: const Text('กรอกพิกัดเอง'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            if (_latitude != null && _longitude != null) ...[
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: _openGoogleMaps,
                                icon: const Icon(Icons.map, size: 20),
                                label: const Text('เปิดดูแผนที่'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF228B22),
                                  side: const BorderSide(color: Color(0xFF228B22)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ],
                          ],
                        );
                      } else {
                        // 💻 Desktop: Row
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: _isLoadingGPS ? null : _getCurrentLocation,
                                icon: _isLoadingGPS
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.my_location),
                                label: Text(_isLoadingGPS ? 'กำลังดึงตำแหน่ง...' : 'บันทึกตำแหน่ง GPS'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF228B22),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton.icon(
                                onPressed: _enterManualGPS,
                                icon: const Icon(Icons.edit_location, size: 20),
                                label: const Text('กรอกพิกัดเอง'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            if (_latitude != null && _longitude != null) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _openGoogleMaps,
                                icon: const Icon(Icons.map, size: 20),
                                label: const Text('แผนที่'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF228B22),
                                  side: const BorderSide(color: Color(0xFF228B22)),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                ),
                              ),
                            ],
                          ],
                        );
                      }
                    },
                  ),
                  
                  // ✅ แสดง TextField สำหรับ GPS - Responsive
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        // 📱 Mobile: Column (1 input/row)
                        return Column(
                          children: [
                            TextFormField(
                              controller: _latitudeController,
                              decoration: InputDecoration(
                                labelText: 'Latitude (ละติจูด) *',
                                hintText: _latitudeController.text.isEmpty ? 'กดปุ่มด้านบนเพื่อดึง GPS' : null,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.location_on),
                                filled: _latitudeController.text.isNotEmpty,
                                fillColor: _latitudeController.text.isNotEmpty 
                                    ? const Color(0xFF228B22).withOpacity(0.05)
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากดปุ่มด้านบนเพื่อดึง GPS';
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: _latitudeController.text.isNotEmpty 
                                    ? Colors.black87 
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _longitudeController,
                              decoration: InputDecoration(
                                labelText: 'Longitude (ลองจิจูด) *',
                                hintText: _longitudeController.text.isEmpty ? 'กดปุ่มด้านบนเพื่อดึง GPS' : null,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.location_on),
                                filled: _longitudeController.text.isNotEmpty,
                                fillColor: _longitudeController.text.isNotEmpty 
                                    ? const Color(0xFF228B22).withOpacity(0.05)
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากดปุ่มด้านบนเพื่อดึง GPS';
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: _longitudeController.text.isNotEmpty 
                                    ? Colors.black87 
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // 💻 Desktop: Row
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Latitude (ละติจูด) *',
                                  hintText: _latitudeController.text.isEmpty ? 'กดปุ่มด้านบนเพื่อดึง GPS' : null,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.location_on),
                                  filled: _latitudeController.text.isNotEmpty,
                                  fillColor: _latitudeController.text.isNotEmpty 
                                      ? const Color(0xFF228B22).withOpacity(0.05)
                                      : null,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                readOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากดปุ่มด้านบนเพื่อดึง GPS';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  color: _latitudeController.text.isNotEmpty 
                                      ? Colors.black87 
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _longitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Longitude (ลองจิจูด) *',
                                  hintText: _longitudeController.text.isEmpty ? 'กดปุ่มด้านบนเพื่อดึง GPS' : null,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.location_on),
                                  filled: _longitudeController.text.isNotEmpty,
                                  fillColor: _longitudeController.text.isNotEmpty 
                                      ? const Color(0xFF228B22).withOpacity(0.05)
                                      : null,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                readOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากดปุ่มด้านบนเพื่อดึง GPS';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  color: _longitudeController.text.isNotEmpty 
                                      ? Colors.black87 
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // ขนาดพื้นที่ฟาร์ม
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      return TextFormField(
                        controller: _farmAreaController,
                        decoration: InputDecoration(
                          labelText: 'ขนาดพื้นที่ฟาร์ม (ไร่) *',
                          hintText: 'เช่น 5, 10.5',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.agriculture),
                          suffixText: 'ไร่',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isMobile ? 16 : 12,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณาระบุขนาดพื้นที่ฟาร์ม';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // คำแนะนำ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ตำแหน่ง GPS ช่วยให้เจ้าหน้าที่สามารถค้นหาฟาร์มและวิเคราะห์ข้อมูลตามพื้นที่ได้',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      // 📱 Mobile: Column
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'ข้อมูลปศุสัตว์',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _addLivestockEntry,
                            icon: const Icon(Icons.add),
                            label: const Text('เพิ่มปศุสัตว์'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // 💻 Desktop: Row
                      return Row(
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
                      );
                    }
                  },
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
                  controller: _farmAreaController,
                  decoration: const InputDecoration(
                    labelText: 'ขนาดพื้นที่ฟาร์ม (ไร่) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุขนาดพื้นที่ฟาร์ม';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cropAreaController,
                  decoration: const InputDecoration(
                    labelText: 'พื้นที่ปลูกพืชอาหารสัตว์ (ไร่)',
                    border: OutlineInputBorder(),
                    hintText: 'ค่าเริ่มต้น: 0',
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
        postalCode: _postalCodeController.text,
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
              'เลขบัตรประจำตัวประชาชน: ${farmerInfo.idCard}',
              'เบอร์มือถือ: ${farmerInfo.phoneNumber}',
              'ที่อยู่: ${farmerInfo.address.fullAddress}',
              if (_farmerPhotoBase64 != null) 'รูปภาพ: ✅ อัปโหลดแล้ว',
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
            const SizedBox(height: 16),
            _buildSummarySection('ข้อมูลเพิ่มเติม', [
              // GPS
              if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty)
                'ตำแหน่ง GPS: ${_latitudeController.text}, ${_longitudeController.text}',
              // ขนาดพื้นที่
              if (_farmAreaController.text.isNotEmpty)
                'ขนาดพื้นที่ฟาร์ม: ${_farmAreaController.text} ไร่',
              if (_cropAreaController.text.isNotEmpty)
                'พื้นที่ปลูกพืชอาหารสัตว์: ${_cropAreaController.text} ไร่',
              // หมายเหตุ
              if (_notesController.text.isNotEmpty)
                'หมายเหตุ: ${_notesController.text}',
            ]),
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
      StandardSnackbar.showWarning(context, 'กรุณาเพิ่มข้อมูลปศุสัตว์อย่างน้อย 1 รายการ');
      setState(() {
        currentStep = 1;
      });
      return;
    }

    final authState = ref.read(productionAuthProvider);
    final currentUser = authState.user;
    
    final survey = FarmSurvey(
      id: isEditMode ? widget.editingSurvey!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: _idCardController.text, // ใช้เลขบัตรประชาชนโดยตรง
      surveyorId: isEditMode ? widget.editingSurvey!.surveyorId : (currentUser?['username'] as String? ?? 'unknown_user'),
      surveyorName: isEditMode ? widget.editingSurvey!.surveyorName : (currentUser?['display_name'] as String? ?? currentUser?['username'] as String?),
      surveyorRole: isEditMode ? widget.editingSurvey!.surveyorRole : (currentUser?['role'] as String?),
      surveyDate: isEditMode ? widget.editingSurvey!.surveyDate : DateTime.now(),
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
          postalCode: _postalCodeController.text,
        ),
        photoBase64: _farmerPhotoBase64,
      ),
      livestockData: livestockData,
      farmArea: _farmAreaController.text.isNotEmpty 
          ? double.tryParse(_farmAreaController.text) 
          : null,
      cropArea: _cropAreaController.text.isNotEmpty 
          ? double.tryParse(_cropAreaController.text) 
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      gpsLocation: () {
        // อ่านค่าจาก controllers (อัปเดตล่าสุด)
        final lat = double.tryParse(_latitudeController.text);
        final lng = double.tryParse(_longitudeController.text);
        if (lat != null && lng != null) {
          final gpsData = '$lat, $lng';
          print('💾 Saving GPS: $gpsData (Lat=${_latitudeController.text}, Lng=${_longitudeController.text})');
          return gpsData;
        }
        // ถ้าไม่มีใน controllers ให้ใช้ค่าเดิม (กรณี edit mode)
        final fallback = widget.editingSurvey?.gpsLocation;
        print('⚠️ No GPS in controllers, using fallback: $fallback');
        return fallback;
      }(),
      createdAt: isEditMode ? widget.editingSurvey!.createdAt : DateTime.now(),
    );

    final success = isEditMode 
        ? await surveyProvider.updateSurvey(survey)
        : await surveyProvider.submitSurvey(survey);
    
    if (!mounted) return;
    
    if (success) {
      // แสดง Dialog แจ้งความสำเร็จ
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Text(isEditMode ? 'อัปเดตข้อมูลสำเร็จ' : 'บันทึกข้อมูลสำเร็จ'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEditMode ? 'ข้อมูลการสำรวจถูกอัปเดตเรียบร้อยแล้ว' : 'ข้อมูลการสำรวจถูกบันทึกเรียบร้อยแล้ว'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('ข้อมูลที่บันทึก:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('• เกษตรกร: ${survey.farmerInfo.fullName}'),
                    Text('• ปศุสัตว์: ${livestockData.length} รายการ'),
                    Text('• จำนวนสัตว์: ${livestockData.fold<int>(0, (sum, item) => sum + item.count)} ตัว'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
                context.go('/survey-list'); // ไปหน้าประวัติการสำรวจ
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      // แสดง Dialog แจ้งข้อผิดพลาด
      final errorMessage = surveyProvider.error ?? 'ไม่สามารถบันทึกข้อมูลได้\nกรุณาลองใหม่อีกครั้ง';
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Text('เกิดข้อผิดพลาด'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'หากปัญหายังคงอยู่ โปรดติดต่อผู้ดูแลระบบ',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
          ],
        ),
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
    _farmAreaController.dispose();
    _cropAreaController.dispose();
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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
    final dialogWidth = MediaQuery.of(context).size.width * 0.9;
    final maxDialogWidth = 500.0;
    final dropdownWidth = dialogWidth > maxDialogWidth ? maxDialogWidth - 64 : dialogWidth - 64;
    
    return AlertDialog(
      title: Text(widget.initialData == null ? 'เพิ่มข้อมูลปศุสัตว์' : 'แก้ไขข้อมูลปศุสัตว์'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SizedBox(
        width: dialogWidth > maxDialogWidth ? maxDialogWidth : dialogWidth,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownMenu<LivestockType>(
                  width: dropdownWidth,
                  initialSelection: selectedType,
                  label: const Text('ประเภทปศุสัตว์'),
                  enableFilter: true,
                  enableSearch: true,
                  requestFocusOnTap: true,
                  hintText: 'พิมพ์เพื่อค้นหา...',
                  menuHeight: 300,
                  dropdownMenuEntries: LivestockType.values
                      .map((type) => DropdownMenuEntry(
                            value: type,
                            label: type.displayName,
                          ))
                      .toList(),
                  onSelected: (value) {
                    setState(() {
                      selectedType = value;
                      selectedAgeGroup = null; // Reset age group when type changes
                    });
                  },
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedType != null && SurveyTemplate.getAgeGroupsForType(selectedType!).isNotEmpty) ...[
                  DropdownMenu<String>(
                    width: dropdownWidth,
                    initialSelection: selectedAgeGroup,
                    label: const Text('กลุ่มอายุ/เพศ'),
                    enableFilter: true,
                    enableSearch: true,
                    requestFocusOnTap: true,
                    hintText: 'พิมพ์เพื่อค้นหา...',
                    menuHeight: 200,
                    dropdownMenuEntries: SurveyTemplate.getAgeGroupsForType(selectedType!)
                        .map((group) => DropdownMenuEntry(
                              value: group,
                              label: group,
                            ))
                        .toList(),
                    onSelected: (value) {
                      setState(() {
                        selectedAgeGroup = value;
                      });
                    },
                    inputDecorationTheme: const InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: dropdownWidth,
                  child: TextFormField(
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
                ),
                const SizedBox(height: 16),
                if (selectedType != null && SurveyTemplate.requiresMilkProduction(selectedType!)) ...[
                  SizedBox(
                    width: dropdownWidth,
                    child: TextFormField(
                      controller: _milkProductionController,
                      decoration: const InputDecoration(
                        labelText: 'ผลผลิตนม (กก./วัน)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: dropdownWidth,
                  child: TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'หมายเหตุ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 24),
            ],
          ),
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
