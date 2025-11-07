import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/livestock_survey_detailed.dart';
import '../services/livestock_survey_service.dart';

// State สำหรับข้อมูลสำรวจ
class LivestockSurveyState {
  final List<LivestockSurveyDetailed> surveys;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? pagination;
  final Map<String, dynamic>? stats;

  const LivestockSurveyState({
    this.surveys = const [],
    this.isLoading = false,
    this.error,
    this.pagination,
    this.stats,
  });

  LivestockSurveyState copyWith({
    List<LivestockSurveyDetailed>? surveys,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
    Map<String, dynamic>? stats,
  }) {
    return LivestockSurveyState(
      surveys: surveys ?? this.surveys,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pagination: pagination ?? this.pagination,
      stats: stats ?? this.stats,
    );
  }
}

// Provider สำหรับจัดการข้อมูลสำรวจปศุสัตว์
class LivestockSurveyNotifier extends StateNotifier<LivestockSurveyState> {
  LivestockSurveyNotifier() : super(const LivestockSurveyState());

  // ดึงรายการข้อมูลสำรวจ
  Future<void> loadSurveys({
    int page = 1,
    int limit = 10,
    String? animalType,
    String? surveyorId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await LivestockSurveyService.getSurveys(
        page: page,
        limit: limit,
        animalType: animalType,
        surveyorId: surveyorId,
      );

      if (result['success']) {
        state = state.copyWith(
          surveys: result['surveys'],
          pagination: result['pagination'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result['message'],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'เกิดข้อผิดพลาด: $e',
        isLoading: false,
      );
    }
  }

  // เพิ่มข้อมูลสำรวจใหม่
  Future<Map<String, dynamic>> createSurvey(LivestockSurveyDetailed survey) async {
    try {
      final result = await LivestockSurveyService.createSurvey(survey);
      
      if (result['success']) {
        // รีเฟรชรายการหลังจากเพิ่มสำเร็จ
        await loadSurveys();
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // แก้ไขข้อมูลสำรวจ
  Future<Map<String, dynamic>> updateSurvey(String id, LivestockSurveyDetailed survey) async {
    try {
      final result = await LivestockSurveyService.updateSurvey(id, survey);
      
      if (result['success']) {
        // อัปเดต state โดยแทนที่รายการที่แก้ไข
        final updatedSurveys = state.surveys.map((s) {
          return s.id == id ? survey.copyWith(id: id) : s;
        }).toList();
        
        state = state.copyWith(surveys: updatedSurveys);
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // ลบข้อมูลสำรวจ
  Future<Map<String, dynamic>> deleteSurvey(String id) async {
    try {
      final result = await LivestockSurveyService.deleteSurvey(id);
      
      if (result['success']) {
        // ลบออกจาก state
        final updatedSurveys = state.surveys.where((s) => s.id != id).toList();
        state = state.copyWith(surveys: updatedSurveys);
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // ดึงสถิติ
  Future<void> loadStats() async {
    try {
      final result = await LivestockSurveyService.getSurveyStats();
      
      if (result['success']) {
        state = state.copyWith(stats: result['stats']);
      }
    } catch (e) {
      // ไม่แสดง error สำหรับสถิติ เพราะไม่ critical
      print('Error loading stats: $e');
    }
  }

  // ค้นหาข้อมูลสำรวจ
  List<LivestockSurveyDetailed> searchSurveys(String query) {
    if (query.isEmpty) return state.surveys;
    
    final lowercaseQuery = query.toLowerCase();
    return state.surveys.where((survey) {
      return survey.fullName.toLowerCase().contains(lowercaseQuery) ||
             survey.idCardNumber.contains(query) ||
             survey.animalType.toLowerCase().contains(lowercaseQuery) ||
             (survey.phoneNumber?.contains(query) ?? false);
    }).toList();
  }

  // กรองข้อมูลตามประเภทสัตว์
  List<LivestockSurveyDetailed> filterByAnimalType(String? animalType) {
    if (animalType == null || animalType.isEmpty) return state.surveys;
    return state.surveys.where((survey) => survey.animalType == animalType).toList();
  }

  // รีเซ็ต State
  void reset() {
    state = const LivestockSurveyState();
  }

  // รีเฟรชข้อมูล
  Future<void> refresh() async {
    await loadSurveys();
    await loadStats();
  }
}

// Provider instances
final livestockSurveyProvider = StateNotifierProvider<LivestockSurveyNotifier, LivestockSurveyState>(
  (ref) => LivestockSurveyNotifier(),
);

// Provider สำหรับข้อมูลสำรวจรายการเดียว
final singleSurveyProvider = FutureProvider.family<LivestockSurveyDetailed?, String>((ref, id) async {
  final result = await LivestockSurveyService.getSurvey(id);
  return result['success'] ? result['survey'] : null;
});

// Provider สำหรับตรวจสอบการเชื่อมต่อ
final connectionStatusProvider = FutureProvider<bool>((ref) async {
  return await LivestockSurveyService.checkConnection();
});

// Provider สำหรับรายการประเภทสัตว์ที่ไม่ซ้ำ
final animalTypesProvider = Provider<List<String>>((ref) {
  final surveys = ref.watch(livestockSurveyProvider).surveys;
  final types = surveys.map((s) => s.animalType).toSet().toList();
  types.sort();
  return types;
});

// Provider สำหรับสถิติสรุป
final surveyStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(livestockSurveyProvider).stats;
});

// Provider สำหรับข้อมูลสำรวจที่กรองแล้ว
final filteredSurveysProvider = Provider.family<List<LivestockSurveyDetailed>, Map<String, String?>>((ref, filters) {
  final notifier = ref.read(livestockSurveyProvider.notifier);
  var surveys = ref.watch(livestockSurveyProvider).surveys;

  // กรองตามคำค้นหา
  final searchQuery = filters['search'];
  if (searchQuery != null && searchQuery.isNotEmpty) {
    surveys = notifier.searchSurveys(searchQuery);
  }

  // กรองตามประเภทสัตว์
  final animalType = filters['animalType'];
  if (animalType != null && animalType.isNotEmpty) {
    surveys = surveys.where((s) => s.animalType == animalType).toList();
  }

  return surveys;
});

// Helper functions
class SurveyHelpers {
  // คำนวณจำนวนสัตว์รวม
  static int getTotalAnimals(List<LivestockSurveyDetailed> surveys) {
    return surveys.fold(0, (sum, survey) => sum + survey.animalCount);
  }

  // คำนวณผลผลิตน้ำนมรวม
  static double getTotalMilkProduction(List<LivestockSurveyDetailed> surveys) {
    return surveys.fold(0.0, (sum, survey) => sum + survey.dailyMilkProductionKg);
  }

  // จัดกลุ่มตามประเภทสัตว์
  static Map<String, List<LivestockSurveyDetailed>> groupByAnimalType(List<LivestockSurveyDetailed> surveys) {
    final grouped = <String, List<LivestockSurveyDetailed>>{};
    
    for (final survey in surveys) {
      grouped.putIfAbsent(survey.animalType, () => []).add(survey);
    }
    
    return grouped;
  }

  // คำนวณค่าเฉลี่ยผลผลิตน้ำนม
  static double getAverageMilkProduction(List<LivestockSurveyDetailed> surveys) {
    final dairySurveys = surveys.where((s) => s.animalType == 'โคนม').toList();
    if (dairySurveys.isEmpty) return 0.0;
    
    final total = getTotalMilkProduction(dairySurveys);
    return total / dairySurveys.length;
  }
}
