import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:excel/excel.dart' as excel;

import '../../providers/survey_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_auth_provider.dart';
import '../../providers/rbac_provider.dart';
import '../../models/survey_form.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/standard_snackbar.dart';

class SurveyListScreen extends ConsumerStatefulWidget {
  static const routeName = '/survey-list';

  const SurveyListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends ConsumerState<SurveyListScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider_pkg.Provider.of<SurveyProvider>(context, listen: false).loadSurveys();
    });
  }

  // เช็คว่าผู้ใช้มีสิทธิ์แก้ไข survey หรือไม่
  bool canEditSurvey(FarmSurvey survey) {
    final rbacState = ref.read(rbacProvider);
    final permissions = rbacState.permissions;
    
    if (permissions == null) return false;
    
    // SUPER_ADMIN แก้ไขได้ทั้งหมด
    if (permissions.role == 'SUPER_ADMIN') return true;
    
    // RESEARCHER แก้ไขได้ทั้งหมด (role หลักในโครงการ)
    if (permissions.role == 'RESEARCHER') return true;
    
    // เจ้าของ survey แก้ไขได้
    if (survey.surveyorId == permissions.username) return true;
    
    // เจ้าหน้าที่ระดับอำเภอและตำบล แก้ไขได้
    if (permissions.role == 'AMPHOE_OFFICER' || permissions.role == 'TAMBON_OFFICER') {
      return true;
    }
    
    return false;
  }

  // แสดงหน้าแก้ไขข้อมูลแบบเต็มรูปแบบ
  void _showEditDialog(FarmSurvey survey, SurveyProvider surveyProvider) {
    context.push('/survey', extra: survey);
  }

  Future<void> _showFilterDialog() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      helpText: 'เลือกช่วงวันที่',
      cancelText: 'ยกเลิก',
      confirmText: 'ตรวจสอบ',
      saveText: 'บันทึก',
      errorFormatText: 'รูปแบบวันที่ไม่ถูกต้อง',
      errorInvalidText: 'วันที่ไม่ถูกต้อง',
      errorInvalidRangeText: 'ช่วงวันที่ไม่ถูกต้อง',
      fieldStartHintText: 'วว/ดด/ปปปป',
      fieldEndHintText: 'วว/ดด/ปปปป',
      fieldStartLabelText: 'วันที่เริ่มต้น',
      fieldEndLabelText: 'วันที่สิ้นสุด',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF228B22),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      provider_pkg.Provider.of<SurveyProvider>(context, listen: false).setDateRange(_startDate, _endDate);
    }
  }

  void _showPhotoDialog(String photoBase64) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    base64Decode(photoBase64),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: Colors.grey.shade50,
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'สถิติการสำรวจ',
        customActions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'กรองตามวันที่',
          ),
          if (_startDate != null || _endDate != null || _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                  _searchController.clear();
                });
                provider_pkg.Provider.of<SurveyProvider>(context, listen: false).clearFilters();
              },
              tooltip: 'ล้างตัวกรอง',
              color: Colors.red.shade400,
            ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Section
          provider_pkg.Consumer<SurveyProvider>(
            builder: (context, surveyProvider, child) {
              if (surveyProvider.surveys.isNotEmpty) {
                final totalSurveys = surveyProvider.surveys.length;
                final totalAnimals = surveyProvider.surveys.fold<int>(
                  0,
                  (sum, survey) => sum + survey.livestockData.fold<int>(0, (s, item) => s + item.count),
                );
                final uniqueFarmers = surveyProvider.surveys.map((s) => s.farmerInfo.fullName).toSet().length;
                final now = DateTime.now();
                final thisMonthSurveys = surveyProvider.surveys.where((survey) {
                  return survey.surveyDate.year == now.year && survey.surveyDate.month == now.month;
                }).length;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF228B22).withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF228B22).withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(Icons.calendar_month, 'เดือนนี้', '$thisMonthSurveys ครั้ง'),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _buildStatItem(Icons.people, 'เกษตรกร', '$uniqueFarmers ราย'),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _buildStatItem(Icons.pets, 'ปศุสัตว์', '$totalAnimals ตัว'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Search Bar with Download Button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'ค้นหาตามชื่อเกษตรกร',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF228B22),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF228B22),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) {
                      provider_pkg.Provider.of<SurveyProvider>(context, listen: false).searchSurveys(value);
                    },
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Download Button
                provider_pkg.Consumer<SurveyProvider>(
                  builder: (context, surveyProvider, child) {
                    return ElevatedButton.icon(
                      onPressed: surveyProvider.surveys.isEmpty
                          ? null
                          : () => _exportSurveyData(surveyProvider),
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: const Text('ดาวน์โหลดข้อมูล'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Survey List
          Expanded(
            child: provider_pkg.Consumer<SurveyProvider>(
              builder: (context, surveyProvider, child) {
                if (surveyProvider.isLoading && surveyProvider.surveys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF228B22),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'กำลังโหลดข้อมูล...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (surveyProvider.surveys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ไม่พบข้อมูลการสำรวจ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: surveyProvider.surveys.length,
                  itemBuilder: (context, index) {
                    final survey = surveyProvider.surveys[index];
                    final totalAnimals = survey.livestockData.fold<int>(
                      0,
                      (sum, item) => sum + item.count,
                    );

                    // รวมกลุ่มปศุสัตว์ตาม type เท่านั้น (ไม่แยกตาม ageGroup)
                    final livestockGrouped = <String, LivestockSurveyData>{};
                    for (final livestock in survey.livestockData) {
                      final key = livestock.type.name; // ใช้ enum name เป็น key
                      if (livestockGrouped.containsKey(key)) {
                        // รวมจำนวน
                        livestockGrouped[key] = LivestockSurveyData(
                          type: livestock.type,
                          count: livestockGrouped[key]!.count + livestock.count,
                        );
                      } else {
                        // เพิ่มใหม่
                        livestockGrouped[key] = LivestockSurveyData(
                          type: livestock.type,
                          count: livestock.count,
                        );
                      }
                    }
                    
                    // แปลงเป็น List และเรียงลำดับตามจำนวน
                    final sortedLivestock = livestockGrouped.values.toList()
                      ..sort((a, b) => b.count.compareTo(a.count));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shadowColor: const Color(0xFF228B22).withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: const Color(0xFF228B22).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push('/survey-detail', extra: survey);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header - Farmer Info
                              Row(
                                children: [
                                  // Farmer Photo
                                  GestureDetector(
                                    onTap: () {
                                      if (survey.farmerInfo.photoBase64 != null &&
                                          survey.farmerInfo.photoBase64!.isNotEmpty) {
                                        _showPhotoDialog(survey.farmerInfo.photoBase64!);
                                      }
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF228B22).withOpacity(0.15),
                                            const Color(0xFF228B22).withOpacity(0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF228B22).withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: survey.farmerInfo.photoBase64 != null &&
                                                survey.farmerInfo.photoBase64!.isNotEmpty
                                            ? Image.memory(
                                                base64Decode(survey.farmerInfo.photoBase64!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.person_rounded,
                                                    color: Color(0xFF228B22),
                                                    size: 32,
                                                  );
                                                },
                                              )
                                            : const Icon(
                                                Icons.person_rounded,
                                                color: Color(0xFF228B22),
                                                size: 32,
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Farmer Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'เกษตรกร',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          survey.farmerInfo.fullName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimaryColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Edit button (แสดงเฉพาะผู้ที่มีสิทธิ์)
                                  if (canEditSurvey(survey))
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded),
                                      color: const Color(0xFF228B22),
                                      tooltip: 'แก้ไขข้อมูล',
                                      onPressed: () => _showEditDialog(survey, surveyProvider),
                                    ),

                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: const Color(0xFF228B22).withOpacity(0.4),
                                    size: 32,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Stats Section
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF228B22).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildSurveyStatItem(
                                        Icons.calendar_today,
                                        'วันที่สำรวจ',
                                        DateFormat('dd/MM/yyyy').format(survey.surveyDate),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: const Color(0xFF228B22).withOpacity(0.2),
                                    ),
                                    Expanded(
                                      child: _buildSurveyStatItem(
                                        Icons.pets,
                                        'ปศุสัตว์รวม',
                                        '$totalAnimals ตัว',
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: const Color(0xFF228B22).withOpacity(0.2),
                                    ),
                                    Expanded(
                                      child: _buildSurveyStatItem(
                                        Icons.category,
                                        'ชนิด',
                                        '${livestockGrouped.length} ชนิด',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Livestock List
                              if (sortedLivestock.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'ปศุสัตว์ที่เลี้ยง',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF228B22).withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: sortedLivestock.map((livestock) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF228B22).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFF228B22).withOpacity(0.25),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _getLivestockEmoji(livestock.type.displayName),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            livestock.type.displayName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF228B22).withOpacity(0.9),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF228B22).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${livestock.count}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF228B22).withOpacity(0.9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFF228B22).withOpacity(0.15),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFF228B22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF228B22),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSurveyStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF228B22).withOpacity(0.8),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondaryColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ฟังก์ชันส่งออกข้อมูลเป็น Excel (1 เกษตรกร = 1 แถว, ปศุสัตว์เป็นคอลัมน์)
  void _exportSurveyData(SurveyProvider surveyProvider) {
    if (surveyProvider.surveys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่มีข้อมูลการสำรวจที่จะส่งออก'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // ✅ สร้าง Excel workbook
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['ข้อมูลการสำรวจ'];
      
      // ✅ ลบ default sheet
      excelFile.delete('Sheet1');
      
      // ✅ สร้างลำดับคอลัมน์ปศุสัตว์ทั้งหมดตามที่กำหนด (type + ageGroup)
      final livestockColumns = [
        // โคเนื้อพื้นเมือง
        'โคเนื้อพื้นเมือง_เพศผู้',
        'โคเนื้อพื้นเมือง_เพศเมีย (แรกเกิด-โคสาว)',
        'โคเนื้อพื้นเมือง_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // โคเนื้อพันธุ์แท้
        'โคเนื้อพันธุ์แท้_เพศผู้',
        'โคเนื้อพันธุ์แท้_เพศเมีย (แรกเกิด-โคสาว)',
        'โคเนื้อพันธุ์แท้_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // โคเนื้อลูกผสม
        'โคเนื้อลูกผสม_เพศผู้',
        'โคเนื้อลูกผสม_เพศเมีย (แรกเกิด-โคสาว)',
        'โคเนื้อลูกผสม_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // โคนม
        'โคนม_เพศเมีย แรกเกิด-1ปี',
        'โคนม_เพศเมีย 1ปี-ตั้งท้องแรก',
        'โคนม_เพศเมีย โคกำลังรีดนม',
        'โคนม_เพศเมีย โคแห้งนม',
        'โคนม_เพศผู้',
        // กระบือพื้นเมือง
        'กระบือพื้นเมือง_เพศผู้',
        'กระบือพื้นเมือง_เพศเมีย (แรกเกิด-กระบือสาว)',
        'กระบือพื้นเมือง_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // กระบือนม
        'กระบือนม_เพศผู้',
        'กระบือนม_เพศเมีย (แรกเกิด-กระบือสาว)',
        'กระบือนม_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // สุกรพื้นเมือง (ไม่แยก)
        'สุกรพื้นเมือง_',
        // สุกรพันธุ์
        'สุกรพันธุ์_พ่อพันธุ์',
        'สุกรพันธุ์_แม่พันธุ์',
        // สุกรขุน
        'สุกรขุน_ลูกสุกรขุน',
        'สุกรขุน_สุกรขุน',
        // ลูกสุกรพันธุ์
        'ลูกสุกรพันธุ์_เพศเมีย',
        'ลูกสุกรพันธุ์_เพศผู้',
        // ไก่ (ไม่แยก)
        'ไก่พื้นเมือง_',
        'ไก่ลูกผสม_',
        'ไก่เนื้อ (Boiler)_',
        'ไก่ไข่ (Layer)_',
        'ไก่พ่อ-แม่พันธุ์ ผลิตลูกไก่เนื้อ (PS)_',
        'ไก่พ่อ-แม่พันธุ์ ผลิตลูกไก่ไข่ (PS)_',
        'ไก่ปู่-ย่าพันธุ์ ผลิตลูกไก่เนื้อ (GP)_',
        'ไก่ปู่-ย่าพันธุ์ ผลิตลูกไก่ไข่ (GP)_',
        // เป็ด (ไม่แยก)
        'เป็ดเทศ_',
        'เป็ดเนื้อ_',
        'เป็ดไข่_',
        'เป็ดเนื้อ ไล่ทุ่ง_',
        'เป็ดไข่ ไล่ทุ่ง_',
        // แพะเนื้อ
        'แพะเนื้อ_เพศผู้',
        'แพะเนื้อ_เพศเมีย (แรกเกิด-แพะสาว)',
        'แพะเนื้อ_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // แพะนม
        'แพะนม_เพศผู้',
        'แพะนม_เพศเมีย (แรกเกิด-แพะสาว)',
        'แพะนม_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // แกะ
        'แกะ_เพศผู้',
        'แกะ_เพศเมีย (แรกเกิด-แกะสาว)',
        'แกะ_เพศเมีย (ตั้งท้องแรกขึ้นไป)',
        // นกกระทา (ไม่แยก)
        'นกกระทาเนื้อ_',
        'นกกระทาไข่_',
        // สัตว์เลี้ยง
        'สุนัข_เพศผู้',
        'สุนัข_เพศเมีย',
        'แมว_เพศผู้',
        'แมว_เพศเมีย',
      ];
      
      // ✅ สร้าง Multi-Row Header (3 rows) แบบรายงานจริง
      int currentCol = 0;
      
      // === Header Style ===
      final headerStyle = excel.CellStyle(
        bold: true,
        fontSize: 9,
        backgroundColorHex: excel.ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: excel.ExcelColor.white,
        horizontalAlign: excel.HorizontalAlign.Center,
        verticalAlign: excel.VerticalAlign.Center,
        textWrapping: excel.TextWrapping.WrapText, // ✅ Wrap text
        leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      );
      
      // === ฟังก์ชันช่วย: merge และ set value ===
      void setHeaderCell(int col, int row, String text) {
        final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
        cell.value = excel.TextCellValue(text);
        cell.cellStyle = headerStyle;
      }
      
      void mergeHeader(int startCol, int startRow, int endCol, int endRow, String text) {
        sheet.merge(
          excel.CellIndex.indexByColumnRow(columnIndex: startCol, rowIndex: startRow),
          excel.CellIndex.indexByColumnRow(columnIndex: endCol, rowIndex: endRow),
        );
        setHeaderCell(startCol, startRow, text);
        
        // ✅ ใส่ border ให้ทุก cell ใน merged range
        for (var col = startCol; col <= endCol; col++) {
          for (var row = startRow; row <= endRow; row++) {
            if (col != startCol || row != startRow) {
              // ใส่ style (เฉพาะ border) ให้ cell อื่นๆ
              final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
              cell.cellStyle = headerStyle;
            }
          }
        }
      }
      
      // === กลุ่มที่ 1: ข้อมูลทั่วไป (merge 3 rows) ===
      mergeHeader(currentCol, 0, currentCol, 2, 'ลำดับ'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'วันที่สำรวจ'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'ชื่อ-สกุล'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'เลขบัตรฯ'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'เบอร์โทร'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'ที่อยู่'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'ฟาร์ม\n(ไร่)'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'พืช\n(ไร่)'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'GPS'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'ผู้สำรวจ'); currentCol++;
      mergeHeader(currentCol, 0, currentCol, 2, 'ตำแหน่ง'); currentCol++;
      
      final fixedCols = currentCol; // จำนวนคอลัมน์ข้อมูลทั่วไป
      
      // === กลุ่มที่ 2: ปศุสัตว์ (3-level headers) ===
      // โคเนื้อ (9 cols)
      final beefStart = currentCol;
      mergeHeader(currentCol, 0, currentCol + 8, 0, 'โคเนื้อ (ตัว)');
      // พื้นเมือง
      mergeHeader(currentCol, 1, currentCol + 2, 1, 'พื้นเมือง');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-โคสาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      // พันธุ์แท้
      mergeHeader(currentCol, 1, currentCol + 2, 1, 'พันธุ์แท้');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-โคสาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      // ลูกผสม
      mergeHeader(currentCol, 1, currentCol + 2, 1, 'ลูกผสม');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-โคสาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      
      // โคนม (5 cols)
      mergeHeader(currentCol, 0, currentCol + 4, 0, 'โคนม (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 4, 1, '');
      setHeaderCell(currentCol++, 2, 'เมีย\nแรกเกิด-1ปี');
      setHeaderCell(currentCol++, 2, 'เมีย\n1ปี-ตั้งท้องแรก');
      setHeaderCell(currentCol++, 2, 'เมีย\nรีดนม');
      setHeaderCell(currentCol++, 2, 'เมีย\nแห้งนม');
      setHeaderCell(currentCol++, 2, 'ผู้');
      
      // กระบือ (6 cols)
      mergeHeader(currentCol, 0, currentCol + 5, 0, 'กระบือ (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 2, 1, 'พื้นเมือง');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-สาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      mergeHeader(currentCol, 1, currentCol + 2, 1, 'นม');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-สาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      
      // สุกร (7 cols)
      mergeHeader(currentCol, 0, currentCol + 6, 0, 'สุกร (ตัว)');
      mergeHeader(currentCol, 1, currentCol, 2, 'พื้นเมือง'); currentCol++;
      mergeHeader(currentCol, 1, currentCol + 1, 1, 'พันธุ์');
      setHeaderCell(currentCol++, 2, 'พ่อพันธุ์');
      setHeaderCell(currentCol++, 2, 'แม่พันธุ์');
      mergeHeader(currentCol, 1, currentCol + 1, 1, 'ขุน');
      setHeaderCell(currentCol++, 2, 'ลูกสุกร');
      setHeaderCell(currentCol++, 2, 'สุกรขุน');
      mergeHeader(currentCol, 1, currentCol + 1, 1, 'ลูกพันธุ์');
      setHeaderCell(currentCol++, 2, 'เมีย');
      setHeaderCell(currentCol++, 2, 'ผู้');
      
      // ไก่ (8 cols)
      mergeHeader(currentCol, 0, currentCol + 7, 0, 'ไก่ (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 7, 1, '');
      setHeaderCell(currentCol++, 2, 'พื้นเมือง');
      setHeaderCell(currentCol++, 2, 'ลูกผสม');
      setHeaderCell(currentCol++, 2, 'เนื้อ');
      setHeaderCell(currentCol++, 2, 'ไข่');
      setHeaderCell(currentCol++, 2, 'พ่อแม่\nเนื้อ(PS)');
      setHeaderCell(currentCol++, 2, 'พ่อแม่\nไข่(PS)');
      setHeaderCell(currentCol++, 2, 'ปู่ย่า\nเนื้อ(GP)');
      setHeaderCell(currentCol++, 2, 'ปู่ย่า\nไข่(GP)');
      
      // เป็ด (5 cols)
      mergeHeader(currentCol, 0, currentCol + 4, 0, 'เป็ด (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 4, 1, '');
      setHeaderCell(currentCol++, 2, 'เทศ');
      setHeaderCell(currentCol++, 2, 'เนื้อ');
      setHeaderCell(currentCol++, 2, 'ไข่');
      setHeaderCell(currentCol++, 2, 'เนื้อ\nไล่ทุ่ง');
      setHeaderCell(currentCol++, 2, 'ไข่\nไล่ทุ่ง');
      
      // แพะ (6 cols)
      mergeHeader(currentCol, 0, currentCol + 5, 0, 'แพะ (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 2, 1, 'เนื้อ');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-สาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      mergeHeader(currentCol, 1, currentCol + 2, 1, 'นม');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-สาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      
      // แกะ (3 cols)
      mergeHeader(currentCol, 0, currentCol + 2, 0, 'แกะ (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 2, 1, '');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย\n(แรกเกิด-สาว)');
      setHeaderCell(currentCol++, 2, 'เมีย\n(ตั้งท้องแรกขึ้นไป)');
      
      // นกกระทา (2 cols)
      mergeHeader(currentCol, 0, currentCol + 1, 0, 'นกกระทา (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 1, 1, '');
      setHeaderCell(currentCol++, 2, 'เนื้อ');
      setHeaderCell(currentCol++, 2, 'ไข่');
      
      // สุนัข (2 cols)
      mergeHeader(currentCol, 0, currentCol + 1, 0, 'สุนัข (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 1, 1, '');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย');
      
      // แมว (2 cols)
      mergeHeader(currentCol, 0, currentCol + 1, 0, 'แมว (ตัว)');
      mergeHeader(currentCol, 1, currentCol + 1, 1, '');
      setHeaderCell(currentCol++, 2, 'ผู้');
      setHeaderCell(currentCol++, 2, 'เมีย');
      
      // หมายเหตุ
      mergeHeader(currentCol, 0, currentCol, 2, 'หมายเหตุ'); currentCol++;
      
      // ✅ Data rows - 1 เกษตรกร = 1 แถว (Pivot format)
      int rowIndex = 3; // เริ่มที่ row 3 เพราะ header ใช้ row 0-2
      int rowNumber = 1; // ลำดับที่
      
      for (final survey in surveyProvider.surveys) {
        final date = DateFormat('dd/MM/yyyy').format(survey.surveyDate);
        final farmer = '${survey.farmerInfo.title}${survey.farmerInfo.firstName} ${survey.farmerInfo.lastName}';
        final idCard = survey.farmerInfo.idCard;
        final phone = survey.farmerInfo.phoneNumber;
        final address = survey.farmerInfo.address.fullAddress;
        
        // ✅ ข้อมูลฟาร์ม
        final farmArea = survey.farmArea?.toStringAsFixed(2) ?? '-';
        final cropArea = survey.cropArea?.toStringAsFixed(2) ?? '-';
        final surveyor = survey.surveyorName ?? '-';
        final surveyorRole = survey.surveyorRole ?? '-';
        final gps = survey.gpsLocation ?? '-';
        final surveyNotes = survey.notes ?? '-';
        
        // ✅ สร้าง Map: type_ageGroup → จำนวนรวม
        final Map<String, int> livestockCounts = {};
        for (final livestock in survey.livestockData) {
          final type = livestock.type.displayName;
          final ageGroup = livestock.ageGroup ?? '';
          final key = '${type}_$ageGroup';
          livestockCounts[key] = (livestockCounts[key] ?? 0) + livestock.count;
        }
        
        // ✅ สร้างแถวข้อมูล (เพิ่มลำดับที่)
        final rowData = [
          rowNumber.toString(), // ลำดับที่
          date, farmer, idCard, phone, address,
          farmArea, cropArea, gps,
          surveyor, surveyorRole,
        ];
        
        // ✅ เพิ่มจำนวนปศุสัตว์แต่ละคอลัมน์ (ตามลำดับที่กำหนด)
        for (final colKey in livestockColumns) {
          final count = livestockCounts[colKey] ?? 0;
          rowData.add(count > 0 ? count.toString() : '-');
        }
        
        // ✅ เพิ่มคอลัมน์ท้าย
        rowData.add(surveyNotes);
        
        // ✅ เขียนข้อมูลลง Excel
        for (var i = 0; i < rowData.length; i++) {
          final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
          cell.value = excel.TextCellValue(rowData[i].toString());
          
          // ✅ Style สำหรับ data cells
          final dataCellStyle = excel.CellStyle(
            fontSize: 8,
            horizontalAlign: (i == 0 || i >= fixedCols) 
                ? excel.HorizontalAlign.Center 
                : excel.HorizontalAlign.Left,
            verticalAlign: excel.VerticalAlign.Center,
            leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin, borderColorHex: excel.ExcelColor.fromHexString('#CCCCCC')),
            rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin, borderColorHex: excel.ExcelColor.fromHexString('#CCCCCC')),
            topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin, borderColorHex: excel.ExcelColor.fromHexString('#CCCCCC')),
            bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin, borderColorHex: excel.ExcelColor.fromHexString('#CCCCCC')),
          );
          
          cell.cellStyle = dataCellStyle;
        }
        rowIndex++;
        rowNumber++;
      }
      
      // ✅ Auto-fit columns (set reasonable widths) สำหรับ A3
      sheet.setColumnWidth(0, 5);   // ลำดับ
      sheet.setColumnWidth(1, 10);  // วันที่
      sheet.setColumnWidth(2, 20);  // ชื่อ-สกุล
      sheet.setColumnWidth(3, 14);  // เลขบัตร
      sheet.setColumnWidth(4, 11);  // เบอร์โทร
      sheet.setColumnWidth(5, 35);  // ที่อยู่
      sheet.setColumnWidth(6, 6);   // ฟาร์ม (ไร่)
      sheet.setColumnWidth(7, 6);   // พืช (ไร่)
      sheet.setColumnWidth(8, 15);  // GPS
      sheet.setColumnWidth(9, 18);  // ผู้สำรวจ
      sheet.setColumnWidth(10, 12); // ตำแหน่ง
      
      // คอลัมน์ปศุสัตว์ - ตั้งค่าเล็กลงเพื่อให้พอดี A3
      for (var i = fixedCols; i < fixedCols + livestockColumns.length; i++) {
        sheet.setColumnWidth(i, 5); // ความกว้างเล็กลงเพื่อพอดี A3
      }
      
      // หมายเหตุ (คอลัมน์สุดท้าย)
      final notesColumnIndex = fixedCols + livestockColumns.length;
      sheet.setColumnWidth(notesColumnIndex, 15);
      
      // ✅ ตั้ง row height สำหรับ header
      sheet.setRowHeight(0, 30);
      sheet.setRowHeight(1, 25);
      sheet.setRowHeight(2, 40); // row 3 สูงขึ้นเพราะมี wrap text
      
      // Note: Freeze panes not supported in excel package v4.0.6
      // Users can freeze panes manually in Excel after opening the file
      
      // ✅ สร้างไฟล์และดาวน์โหลด
      final bytes = excelFile.encode();
      if (bytes == null) {
        throw Exception('Failed to encode Excel file');
      }
      
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'survey_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ส่งออกข้อมูล ${surveyProvider.surveys.length} รายการเป็น Excel สำเร็จ'),
          backgroundColor: const Color(0xFF228B22),
          action: SnackBarAction(
            label: 'ตกลง',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      print('❌ Error exporting Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการส่งออก Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getLivestockEmoji(String displayName) {
    if (displayName.contains('โค')) return '🐂';
    if (displayName.contains('กระบือ')) return '🐃';
    if (displayName.contains('สุกร')) return '🐷';
    if (displayName.contains('ไก่')) return '🐔';
    if (displayName.contains('เป็ด')) return '🦆';
    if (displayName.contains('ห่าน')) return '🦢';
    if (displayName.contains('แกะ')) return '🐑';
    if (displayName.contains('แพะ')) return '🐐';
    if (displayName.contains('ม้า')) return '🐴';
    if (displayName.contains('กวาง')) return '🦌';
    if (displayName.contains('กระต่าย')) return '🐰';
    if (displayName.contains('นกกระทา')) return '🦜';
    if (displayName.contains('จิ้งหรีด')) return '🦗';
    if (displayName.contains('หนอนไหม')) return '🐛';
    if (displayName.contains('ผึ้ง')) return '🐝';
    if (displayName.contains('ปลา')) return '🐟';
    if (displayName.contains('กุ้ง')) return '🦐';
    if (displayName.contains('ปู')) return '🦀';
    if (displayName.contains('สุนัข')) return '🐕';
    if (displayName.contains('แมว')) return '🐈';
    if (displayName.contains('นก') && !displayName.contains('นกกระทา')) return '🦜';
    return '🐾';
  }
}
