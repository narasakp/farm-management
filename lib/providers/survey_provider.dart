import 'package:flutter/foundation.dart';
import '../models/survey_form.dart';
import '../models/livestock.dart';

class SurveyProvider with ChangeNotifier {
  bool _isLoading = false;
  List<FarmSurvey> _allSurveys = [];
  List<FarmSurvey> _filteredSurveys = [];
  String? _error;

  // Filter state
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  bool get isLoading => _isLoading;
  List<FarmSurvey> get surveys => _filteredSurveys;
  String? get error => _error;

  // Submit new survey
  Future<bool> submitSurvey(FarmSurvey survey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Add to local list (in real app, this would be saved to backend)
      _allSurveys.add(survey);
      _applyFilters(); // Re-apply filters to include the new survey
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e';
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load sample data
      _allSurveys = _generateSampleSurveys();
      _filteredSurveys = List.from(_allSurveys);
      
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
    if (_allSurveys.isEmpty) {
      return {
        'totalSurveys': 0,
        'totalFarmers': 0,
        'totalAnimals': 0,
        'livestockByType': <String, int>{},
        'surveysByArea': <String, int>{},
      };
    }

    final livestockByType = <String, int>{};
    final surveysByArea = <String, int>{};
    int totalAnimals = 0;

    for (final survey in _allSurveys) {
      // Count animals by type
      for (final livestock in survey.livestockData) {
        final typeName = livestock.type.displayName;
        livestockByType[typeName] = (livestockByType[typeName] ?? 0) + livestock.count;
        totalAnimals += livestock.count;
      }

      // Count surveys by area
      final area = '${survey.farmerInfo.address.tambon}, ${survey.farmerInfo.address.amphoe}';
      surveysByArea[area] = (surveysByArea[area] ?? 0) + 1;
    }

    return {
      'totalSurveys': _allSurveys.length,
      'totalFarmers': _allSurveys.length, // Assuming one farmer per survey
      'totalAnimals': totalAnimals,
      'livestockByType': livestockByType,
      'surveysByArea': surveysByArea,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
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
