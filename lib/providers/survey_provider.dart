import 'package:flutter/foundation.dart';
import '../models/survey_form.dart';
import '../models/livestock.dart';
import '../services/farm_survey_service.dart';

class SurveyProvider with ChangeNotifier {
  bool _isLoading = false;
  List<FarmSurvey> _allSurveys = [];
  List<FarmSurvey> _filteredSurveys = [];
  String? _error;
  final _surveyService = FarmSurveyService();

  // Statistics from database
  Map<String, dynamic> _statistics = {
    'totalLivestock': 0,
    'totalFarms': 0,
    'livestockByType': <String, int>{}
  };

  // Filter state
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  bool get isLoading => _isLoading;
  List<FarmSurvey> get surveys => _filteredSurveys;
  String? get error => _error;
  Map<String, dynamic> get statistics => _statistics;

  // Submit new survey
  Future<bool> submitSurvey(FarmSurvey survey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // บันทึกลง database จริง
      final success = await _surveyService.submitSurvey(survey);
      
      if (success) {
        // เพิ่มลง local list ด้วย
        _allSurveys.add(survey);
        _applyFilters();
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update existing survey
  Future<bool> updateSurvey(FarmSurvey survey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // อัปเดตใน database
      final success = await _surveyService.updateSurvey(survey);
      
      if (success) {
        // อัปเดต local list
        final index = _allSurveys.indexWhere((s) => s.id == survey.id);
        if (index != -1) {
          _allSurveys[index] = survey;
          _applyFilters();
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการอัปเดตข้อมูล: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load surveys
  Future<void> loadSurveys() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ดึงข้อมูลจาก database จริง (ตาราง farm_surveys)
      _allSurveys = await _surveyService.getSurveys(limit: 100);
      _filteredSurveys = List.from(_allSurveys);
      
      // ดึงสถิติจาก API (จากตาราง survey_livestock)
      _statistics = await _surveyService.getLivestockStatistics();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredSurveys = _allSurveys.where((survey) {
      // Search query filter
      final farmerName = survey.farmerInfo.fullName.toLowerCase();
      final searchMatch = _searchQuery.isEmpty || farmerName.contains(_searchQuery.toLowerCase());

      // Date range filter
      final dateMatch = _startDate == null || _endDate == null || 
                        (survey.surveyDate.isAfter(_startDate!.subtract(const Duration(days: 1))) && 
                         survey.surveyDate.isBefore(_endDate!.add(const Duration(days: 1))));

      return searchMatch && dateMatch;
    }).toList();
    notifyListeners();
  }

  void searchSurveys(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _startDate = null;
    _endDate = null;
    _applyFilters();
  }

  // Get surveys by area
  List<FarmSurvey> getSurveysByArea(String tambon, String amphoe) {
    return _allSurveys.where((survey) =>
        survey.farmerInfo.address.tambon == tambon &&
        survey.farmerInfo.address.amphoe == amphoe).toList();
  }

  // Get surveys by date range
  List<FarmSurvey> getSurveysByDateRange(DateTime startDate, DateTime endDate) {
    return _allSurveys.where((survey) =>
        survey.surveyDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
        survey.surveyDate.isBefore(endDate.add(const Duration(days: 1)))).toList();
  }

  // Generate summary statistics
  Map<String, dynamic> getSurveyStatistics() {
    // ใช้ข้อมูลสถิติจาก API (ดึงจาก survey_livestock โดยตรง)
    return {
      'totalSurveys': _statistics['totalFarms'] ?? 0,
      'totalFarmers': _statistics['totalFarms'] ?? 0,
      'totalAnimals': _statistics['totalLivestock'] ?? 0,
      'livestockByType': _statistics['livestockByType'] ?? <String, int>{},
      'surveysByArea': <String, int>{}, // TODO: สามารถเพิ่ม API สำหรับนับตามพื้นที่ได้
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get all livestock from surveys (รวมข้อมูลจาก survey_livestock)
  List<Map<String, dynamic>> getAllLivestockFromSurveys() {
    final List<Map<String, dynamic>> allLivestock = [];
    
    for (var survey in _allSurveys) {
      for (var livestock in survey.livestockData) {
        allLivestock.add({
          'surveyId': survey.id,
          'farmerId': survey.farmerId,
          'farmerName': survey.farmerInfo.fullName,
          'farmerAddress': '${survey.farmerInfo.address.village} ม.${survey.farmerInfo.address.moo} ต.${survey.farmerInfo.address.tambon}',
          'type': livestock.type,
          'typeName': livestock.type.displayName,
          'ageGroup': livestock.ageGroup,
          'count': livestock.count,
          'surveyDate': survey.surveyDate,
          'notes': livestock.notes,
        });
      }
    }
    
    return allLivestock;
  }

  // Get livestock grouped by survey + type (สำหรับแสดงแบบรวม)
  List<Map<String, dynamic>> getGroupedLivestockFromSurveys() {
    final Map<String, Map<String, dynamic>> grouped = {};
    
    for (var survey in _allSurveys) {
      for (var livestock in survey.livestockData) {
        final key = '${survey.id}_${livestock.type.name}';
        
        if (!grouped.containsKey(key)) {
          grouped[key] = {
            'surveyId': survey.id,
            'farmerId': survey.farmerId,
            'farmerName': survey.farmerInfo.fullName,
            'farmerAddress': '${survey.farmerInfo.address.village} ม.${survey.farmerInfo.address.moo} ต.${survey.farmerInfo.address.tambon}',
            'type': livestock.type,
            'typeName': livestock.type.displayName,
            'surveyDate': survey.surveyDate,
            'totalCount': 0,
            'details': <Map<String, dynamic>>[],
          };
        }
        
        grouped[key]!['totalCount'] = (grouped[key]!['totalCount'] as int) + livestock.count;
        (grouped[key]!['details'] as List).add({
          'ageGroup': livestock.ageGroup,
          'count': livestock.count,
          'notes': livestock.notes,
        });
      }
    }
    
    return grouped.values.toList();
  }

  // Generate sample surveys for demonstration
  List<FarmSurvey> _generateSampleSurveys() {
    final now = DateTime.now();
    return [
      FarmSurvey(
        id: 'survey_001',
        farmerId: 'farmer_001',
        surveyorId: 'officer_001',
        surveyDate: now.subtract(const Duration(days: 1)),
        farmerInfo: FarmerInfo(
          title: 'นาย',
          firstName: 'สมชาย',
          lastName: 'ใจดี',
          idCard: '1234567890123',
          phoneNumber: '081-234-5678',
          address: FarmerAddress(
            houseNumber: '123',
            village: 'บ้านสวนดอก',
            moo: '5',
            tambon: 'เนินสง่า',
            amphoe: 'เนินสง่า',
            province: 'ชัยภูมิ',
          ),
        ),
        livestockData: [
          LivestockSurveyData(
            type: LivestockType.beefCattleLocal,
            ageGroup: 'เพศเมีย (ตั้งท้องแรกขึ้นไป)',
            count: 5,
          ),
          LivestockSurveyData(
            type: LivestockType.beefCattleLocal,
            ageGroup: 'เพศผู้',
            count: 2,
          ),
          LivestockSurveyData(
            type: LivestockType.chickenLocal,
            ageGroup: 'เพศเมีย',
            count: 20,
          ),
        ],
        cropArea: 2.5,
        notes: 'ฟาร์มมีการจัดการดี สัตว์มีสุขภาพแข็งแรง',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      FarmSurvey(
        id: 'survey_002',
        farmerId: 'farmer_002',
        surveyorId: 'officer_001',
        surveyDate: now.subtract(const Duration(days: 2)),
        farmerInfo: FarmerInfo(
          title: 'นาง',
          firstName: 'มาลี',
          lastName: 'รักสัตว์',
          idCard: '9876543210987',
          phoneNumber: '089-876-5432',
          address: FarmerAddress(
            houseNumber: '456',
            village: 'บ้านทุ่งใหญ่',
            moo: '3',
            tambon: 'โนนสะอาด',
            amphoe: 'เนินสง่า',
            province: 'ชัยภูมิ',
          ),
        ),
        livestockData: [
          LivestockSurveyData(
            type: LivestockType.dairyCow,
            ageGroup: 'กำลังรีดนม',
            count: 3,
            dailyMilkProduction: 45.0,
          ),
          LivestockSurveyData(
            type: LivestockType.dairyCow,
            ageGroup: '1ปี-ตั้งท้องแรก',
            count: 2,
          ),
          LivestockSurveyData(
            type: LivestockType.pigFattening,
            ageGroup: 'สุกรขุน',
            count: 15,
          ),
        ],
        cropArea: 1.8,
        notes: 'โคนมให้ผลผลิตดี ต้องการคำแนะนำเรื่องอาหาร',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      FarmSurvey(
        id: 'survey_003',
        farmerId: 'farmer_003',
        surveyorId: 'officer_002',
        surveyDate: now.subtract(const Duration(days: 3)),
        farmerInfo: FarmerInfo(
          title: 'นาย',
          firstName: 'วิชัย',
          lastName: 'เลี้ยงไก่',
          idCard: '5555666677778',
          phoneNumber: '092-555-6666',
          address: FarmerAddress(
            houseNumber: '789',
            village: 'บ้านไผ่ล้อม',
            moo: '7',
            tambon: 'หนองบัวใต้',
            amphoe: 'เนินสง่า',
            province: 'ชัยภูมิ',
          ),
        ),
        livestockData: [
          LivestockSurveyData(
            type: LivestockType.chickenLayer,
            ageGroup: 'เพศเมีย',
            count: 500,
          ),
          LivestockSurveyData(
            type: LivestockType.chickenBroiler,
            ageGroup: 'เพศผู้',
            count: 200,
          ),
          LivestockSurveyData(
            type: LivestockType.chickenBroiler,
            ageGroup: 'เพศเมีย',
            count: 300,
          ),
        ],
        cropArea: 0.5,
        notes: 'ฟาร์มไก่ขนาดใหญ่ มีระบบการจัดการที่ดี',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
