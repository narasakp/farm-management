import 'package:flutter/foundation.dart';
import '../models/research_project.dart';
import '../models/research_data.dart';

class ResearchProvider with ChangeNotifier {
  List<ResearchProject> _projects = [];
  List<ResearchData> _researchData = [];
  bool _isLoading = false;

  List<ResearchProject> get projects => _projects;
  List<ResearchData> get researchData => _researchData;
  bool get isLoading => _isLoading;

  ResearchProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    
    _projects = [
      ResearchProject(
        id: '1',
        title: 'การศึกษาประสิทธิภาพการผลิตนมในโคนม',
        description: 'ศึกษาปัจจัยที่มีผลต่อการผลิตนมในโคนมพันธุ์ต่างๆ เพื่อเพิ่มประสิทธิภาพการผลิต',
        researcherName: 'ดร.สมชาย วิจัยดี',
        researcherEmail: 'somchai@research.ac.th',
        researcherPhone: '081-234-5678',
        status: ResearchStatus.ongoing,
        type: ResearchType.production,
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.add(const Duration(days: 180)),
        location: 'จังหวัดนครราชสีมา',
        objectives: [
          'ศึกษาปริมาณการผลิตนมในโคนมพันธุ์ต่างๆ',
          'วิเคราะห์ปัจจัยที่มีผลต่อคุณภาพนม',
          'เปรียบเทียบต้นทุนการผลิตระหว่างพันธุ์',
        ],
        methods: [
          'เก็บข้อมูลการผลิตนมรายวัน',
          'วิเคราะห์คุณภาพนมในห้องปฏิบัติการ',
          'สำรวจต้นทุนการเลี้ยง',
        ],
        findings: 'โคนมพันธุ์ฮอลสไตน์ให้ผลผลิตสูงสุด แต่ต้นทุนการเลี้ยงสูง',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ResearchProject(
        id: '2',
        title: 'การพัฒนาอาหารสัตว์จากวัสดุเหลือใช้ทางการเกษตร',
        description: 'พัฒนาสูตรอาหารสัตว์จากฟางข้าวและเศษใบอ้อย เพื่อลดต้นทุนการเลี้ยง',
        researcherName: 'ดร.สมหญิง นวัตกรรม',
        researcherEmail: 'somying@agri.ac.th',
        researcherPhone: '082-345-6789',
        status: ResearchStatus.dataCollection,
        type: ResearchType.nutrition,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 120)),
        location: 'จังหวัดสุพรรณบุรี',
        objectives: [
          'พัฒนาสูตรอาหารจากวัสดุเหลือใช้',
          'ทดสอบประสิทธิภาพการย่อยได้',
          'ประเมินผลกระทบต่อการเจริญเติบโต',
        ],
        methods: [
          'วิเคราะห์องค์ประกอบทางโภชนาการ',
          'ทดลองให้อาหารในสัตว์ทดลอง',
          'ติดตามน้ำหนักและสุขภาพ',
        ],
        attachments: [],
        createdAt: now.subtract(const Duration(days: 70)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ResearchProject(
        id: '3',
        title: 'การศึกษาโรคระบาดในสุกรและการป้องกัน',
        description: 'ศึกษาการแพร่ระบาดของโรคในสุกรและพัฒนาแนวทางการป้องกันที่เหมาะสม',
        researcherName: 'ดร.วิทยา สุขภาพดี',
        researcherEmail: 'wittaya@vet.ac.th',
        researcherPhone: '083-456-7890',
        status: ResearchStatus.analysis,
        type: ResearchType.livestockHealth,
        startDate: now.subtract(const Duration(days: 120)),
        endDate: now.add(const Duration(days: 60)),
        location: 'จังหวัดชลบุรี',
        objectives: [
          'ศึกษาสาเหตุการแพร่ระบาดของโรค',
          'พัฒนาวิธีการป้องกันที่มีประสิทธิภาพ',
          'ประเมินผลกระทบทางเศรษฐกิจ',
        ],
        methods: [
          'เก็บตัวอย่างเลือดและเนื้อเยื่อ',
          'วิเคราะห์ทางห้องปฏิบัติการ',
          'สำรวจข้อมูลจากเกษตรกร',
        ],
        findings: 'พบว่าการฉีดวัคซีนป้องกันมีประสิทธิภาพ 85%',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 130)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    _researchData = [
      ResearchData(
        id: '1',
        projectId: '1',
        dataType: 'production',
        title: 'ข้อมูลการผลิตนมรายวัน - ฟาร์ม A',
        description: 'บันทึกปริมาณการผลิตนมของโคนมฮอลสไตน์ 20 ตัว',
        data: {
          'farmId': 'FARM001',
          'totalCows': 20,
          'milkProduction': 450.5,
          'unit': 'ลิตร',
          'averagePerCow': 22.5,
          'fatContent': 3.8,
          'proteinContent': 3.2,
          'temperature': 28.5,
          'humidity': 75,
        },
        location: 'ฟาร์มโคนม บ้านสวนผึ้ง',
        latitude: 14.2971,
        longitude: 101.9943,
        collectionDate: now.subtract(const Duration(days: 1)),
        collectorName: 'นายสมศักดิ์ เกษตรกร',
        tags: ['milk', 'holstein', 'daily'],
        notes: 'อากาศร้อน ผลผลิตลดลงเล็กน้อย',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ResearchData(
        id: '2',
        projectId: '2',
        dataType: 'nutrition',
        title: 'ผลการทดลองอาหารสูตรใหม่ - สัปดาห์ที่ 4',
        description: 'ผลการให้อาหารสูตรใหม่จากฟางข้าวในสุกรทดลอง',
        data: {
          'feedFormula': 'ฟางข้าว 40% + ข้าวโพดบด 30% + กากถั่วเหลือง 20% + วิตามิน 10%',
          'testGroup': 15,
          'controlGroup': 15,
          'averageWeightGain': 0.85,
          'feedConversionRatio': 2.8,
          'cost': 12.50,
          'costReduction': 25.5,
        },
        location: 'ศูนย์วิจัยสัตว์ มหาวิทยาลัยเกษตรศาสตร์',
        latitude: 13.8462,
        longitude: 100.5717,
        collectionDate: now.subtract(const Duration(days: 3)),
        collectorName: 'ดร.สมหญิง นวัตกรรม',
        tags: ['nutrition', 'pig', 'alternative-feed'],
        notes: 'สัตว์มีสุขภาพดี ไม่พบอาการผิดปกติ',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    notifyListeners();
  }

  // Project management methods
  Future<void> addProject(ResearchProject project) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _projects.add(project);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProject(ResearchProject project) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _projects.removeWhere((p) => p.id == projectId);
    _researchData.removeWhere((d) => d.projectId == projectId);
    
    _isLoading = false;
    notifyListeners();
  }

  // Research data management methods
  Future<void> addResearchData(ResearchData data) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _researchData.add(data);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateResearchData(ResearchData data) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    final index = _researchData.indexWhere((d) => d.id == data.id);
    if (index != -1) {
      _researchData[index] = data;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteResearchData(String dataId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _researchData.removeWhere((d) => d.id == dataId);
    
    _isLoading = false;
    notifyListeners();
  }

  // Query methods
  List<ResearchProject> getProjectsByStatus(ResearchStatus status) {
    return _projects.where((p) => p.status == status).toList();
  }

  List<ResearchProject> getProjectsByType(ResearchType type) {
    return _projects.where((p) => p.type == type).toList();
  }

  List<ResearchData> getDataByProject(String projectId) {
    return _researchData.where((d) => d.projectId == projectId).toList();
  }

  List<ResearchData> getDataByType(String dataType) {
    return _researchData.where((d) => d.dataType == dataType).toList();
  }

  ResearchProject? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Statistics
  Map<ResearchStatus, int> getProjectStatusStats() {
    final stats = <ResearchStatus, int>{};
    for (final status in ResearchStatus.values) {
      stats[status] = _projects.where((p) => p.status == status).length;
    }
    return stats;
  }

  Map<ResearchType, int> getProjectTypeStats() {
    final stats = <ResearchType, int>{};
    for (final type in ResearchType.values) {
      stats[type] = _projects.where((p) => p.type == type).length;
    }
    return stats;
  }

  int get totalProjects => _projects.length;
  int get activeProjects => _projects.where((p) => 
    p.status == ResearchStatus.ongoing || 
    p.status == ResearchStatus.dataCollection ||
    p.status == ResearchStatus.analysis
  ).length;
  int get completedProjects => _projects.where((p) => 
    p.status == ResearchStatus.completed ||
    p.status == ResearchStatus.published
  ).length;
  int get totalDataPoints => _researchData.length;
}
