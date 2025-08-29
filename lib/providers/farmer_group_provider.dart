import 'package:flutter/foundation.dart';
import '../models/farmer_group.dart';

class FarmerGroupProvider with ChangeNotifier {
  List<FarmerGroup> _groups = [];
  List<GroupMember> _members = [];
  List<GroupActivity> _activities = [];
  List<GroupFund> _funds = [];
  List<SavingsRecord> _savingsRecords = [];
  List<DividendRecord> _dividendRecords = [];
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<FarmerGroup> get groups => _groups;
  List<GroupMember> get members => _members;
  List<GroupActivity> get activities => _activities;
  List<GroupFund> get funds => _funds;
  List<SavingsRecord> get savingsRecords => _savingsRecords;
  List<DividendRecord> get dividendRecords => _dividendRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active groups
  List<FarmerGroup> get activeGroups => _groups.where((g) => g.isActive).toList();

  // Get members by group
  List<GroupMember> getMembersByGroup(String groupId) {
    return _members.where((m) => m.groupId == groupId && m.isActive).toList();
  }

  // Get activities by group
  List<GroupActivity> getActivitiesByGroup(String groupId) {
    return _activities.where((a) => a.groupId == groupId).toList();
  }

  // Get funds by group
  List<GroupFund> getFundsByGroup(String groupId) {
    return _funds.where((f) => f.groupId == groupId && f.isActive).toList();
  }

  // Get savings records by group
  List<SavingsRecord> getSavingsRecordsByGroup(String groupId) {
    return _savingsRecords.where((s) => s.groupId == groupId).toList();
  }

  // Get dividend records by group
  List<DividendRecord> getDividendRecordsByGroup(String groupId) {
    return _dividendRecords.where((d) => d.groupId == groupId).toList();
  }

  // Initialize with sample data
  Future<void> loadData() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Sample farmer groups
      _groups = [
        FarmerGroup(
          id: 'group_001',
          name: 'กลุ่มเกษตรกรบ้านสวนใหม่',
          description: 'กลุ่มเกษตรกรเลี้ยงโคเนื้อและปลูกข้าว',
          leaderFarmerId: 'farmer_001',
          registrationNumber: 'REG-2024-001',
          establishedDate: DateTime(2020, 3, 15),
          tambon: 'บ้านสวน',
          amphoe: 'เมือง',
          province: 'นครราชสีมา',
          memberCount: 25,
          totalFundAmount: 500000.0,
          isActive: true,
          notes: 'กลุ่มที่มีความเข้มแข็งและมีการบริหารจัดการที่ดี',
          createdAt: DateTime(2020, 3, 15),
        ),
        FarmerGroup(
          id: 'group_002',
          name: 'กลุ่มวิสาหกิจชุมชนไก่พื้นเมือง',
          description: 'กลุ่มเกษตรกรเลี้ยงไก่พื้นเมืองและแปรรูปผลิตภัณฑ์',
          leaderFarmerId: 'farmer_002',
          registrationNumber: 'REG-2024-002',
          establishedDate: DateTime(2021, 6, 10),
          tambon: 'หนองบัว',
          amphoe: 'ปากช่อง',
          province: 'นครราชสีมา',
          memberCount: 18,
          totalFundAmount: 300000.0,
          isActive: true,
          notes: 'เน้นการแปรรูปและการตลาด',
          createdAt: DateTime(2021, 6, 10),
        ),
        FarmerGroup(
          id: 'group_003',
          name: 'กลุ่มเกษตรกรปลูกผักปลอดสาร',
          description: 'กลุ่มเกษตรกรปลูกผักปลอดสารเคมี',
          leaderFarmerId: 'farmer_003',
          registrationNumber: 'REG-2024-003',
          establishedDate: DateTime(2022, 1, 20),
          tambon: 'คลองใหญ่',
          amphoe: 'โชคชัย',
          province: 'นครราชสีมา',
          memberCount: 12,
          totalFundAmount: 150000.0,
          isActive: true,
          createdAt: DateTime(2022, 1, 20),
        ),
      ];

      // Sample group members
      _members = [
        GroupMember(
          id: 'member_001',
          groupId: 'group_001',
          farmerId: 'farmer_001',
          joinDate: DateTime(2020, 3, 15),
          membershipType: 'leader',
          contributionAmount: 50000.0,
          isActive: true,
          role: 'ประธานกลุ่ม',
          createdAt: DateTime(2020, 3, 15),
        ),
        GroupMember(
          id: 'member_002',
          groupId: 'group_001',
          farmerId: 'farmer_004',
          joinDate: DateTime(2020, 4, 1),
          membershipType: 'committee',
          contributionAmount: 30000.0,
          isActive: true,
          role: 'เหรัญญิก',
          createdAt: DateTime(2020, 4, 1),
        ),
        GroupMember(
          id: 'member_003',
          groupId: 'group_001',
          farmerId: 'farmer_005',
          joinDate: DateTime(2020, 5, 15),
          membershipType: 'regular',
          contributionAmount: 20000.0,
          isActive: true,
          createdAt: DateTime(2020, 5, 15),
        ),
      ];

      // Sample group activities
      _activities = [
        GroupActivity(
          id: 'activity_001',
          groupId: 'group_001',
          title: 'อบรมเทคนิคการเลี้ยงโคเนื้อ',
          description: 'อบรมเทคนิคการเลี้ยงโคเนื้อแบบครบวงจร',
          activityType: 'training',
          scheduledDate: DateTime(2024, 9, 15),
          location: 'ศูนย์การเรียนรู้กลุ่ม',
          participantIds: ['member_001', 'member_002', 'member_003'],
          budget: 15000.0,
          status: 'planned',
          createdAt: DateTime.now(),
        ),
        GroupActivity(
          id: 'activity_002',
          groupId: 'group_001',
          title: 'ประชุมประจำเดือน',
          description: 'ประชุมรายงานผลการดำเนินงานประจำเดือน',
          activityType: 'meeting',
          scheduledDate: DateTime(2024, 9, 5),
          location: 'บ้านประธานกลุ่ม',
          participantIds: ['member_001', 'member_002'],
          status: 'completed',
          outcomes: 'มีมติอนุมัติโครงการใหม่ 2 โครงการ',
          createdAt: DateTime.now(),
        ),
      ];

      // Sample group funds
      _funds = [
        GroupFund(
          id: 'fund_001',
          groupId: 'group_001',
          fundName: 'กองทุนสวัสดิการสมาชิก',
          fundType: 'savings',
          totalAmount: 300000.0,
          availableAmount: 250000.0,
          interestRate: 2.5,
          description: 'กองทุนสำหรับสวัสดิการสมาชิกและเงินกู้ฉุกเฉิน',
          isActive: true,
          createdAt: DateTime(2020, 6, 1),
        ),
        GroupFund(
          id: 'fund_002',
          groupId: 'group_001',
          fundName: 'กองทุนพัฒนาการผลิต',
          fundType: 'investment',
          totalAmount: 200000.0,
          availableAmount: 180000.0,
          interestRate: 3.0,
          description: 'กองทุนสำหรับลงทุนพัฒนาการผลิตและเทคโนโลยี',
          isActive: true,
          createdAt: DateTime(2020, 8, 1),
        ),
      ];

      // Sample savings records
      _savingsRecords = [
        SavingsRecord(
          id: 'savings_001',
          groupId: 'group_001',
          memberId: 'member_001',
          fundId: 'fund_001',
          amount: 5000.0,
          transactionType: 'deposit',
          transactionDate: DateTime(2024, 8, 1),
          notes: 'ฝากเงินประจำเดือน',
          approvedBy: 'member_002',
          createdAt: DateTime(2024, 8, 1),
        ),
        SavingsRecord(
          id: 'savings_002',
          groupId: 'group_001',
          memberId: 'member_003',
          fundId: 'fund_001',
          amount: 2000.0,
          transactionType: 'withdrawal',
          transactionDate: DateTime(2024, 8, 15),
          notes: 'ถอนเงินฉุกเฉิน',
          approvedBy: 'member_001',
          createdAt: DateTime(2024, 8, 15),
        ),
      ];

      // Sample dividend records
      _dividendRecords = [
        DividendRecord(
          id: 'dividend_001',
          groupId: 'group_001',
          memberId: 'member_001',
          amount: 8000.0,
          dividendPeriod: 'Annual-2023',
          distributionDate: DateTime(2024, 1, 15),
          profitShare: 15.5,
          calculationMethod: 'ตามสัดส่วนการลงทุน',
          notes: 'เงินปันผลประจำปี 2023',
          createdAt: DateTime(2024, 1, 15),
        ),
      ];

      _error = null;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Create new farmer group
  Future<void> createGroup(FarmerGroup group) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _groups.add(group);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการสร้างกลุ่ม: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Update farmer group
  Future<void> updateGroup(FarmerGroup updatedGroup) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
      if (index != -1) {
        _groups[index] = updatedGroup;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการอัปเดตกลุ่ม: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Add member to group
  Future<void> addMember(GroupMember member) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _members.add(member);
      
      // Update group member count
      final groupIndex = _groups.indexWhere((g) => g.id == member.groupId);
      if (groupIndex != -1) {
        final group = _groups[groupIndex];
        _groups[groupIndex] = FarmerGroup(
          id: group.id,
          name: group.name,
          description: group.description,
          leaderFarmerId: group.leaderFarmerId,
          registrationNumber: group.registrationNumber,
          establishedDate: group.establishedDate,
          tambon: group.tambon,
          amphoe: group.amphoe,
          province: group.province,
          memberCount: group.memberCount + 1,
          totalFundAmount: group.totalFundAmount,
          isActive: group.isActive,
          notes: group.notes,
          createdAt: group.createdAt,
        );
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มสมาชิก: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Create activity
  Future<void> createActivity(GroupActivity activity) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _activities.add(activity);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการสร้างกิจกรรม: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Create fund
  Future<void> createFund(GroupFund fund) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _funds.add(fund);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการสร้างกองทุน: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Add savings record
  Future<void> addSavingsRecord(SavingsRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _savingsRecords.add(record);
      
      // Update fund available amount
      final fundIndex = _funds.indexWhere((f) => f.id == record.fundId);
      if (fundIndex != -1) {
        final fund = _funds[fundIndex];
        final newAvailableAmount = record.transactionType == 'deposit'
            ? fund.availableAmount + record.amount
            : fund.availableAmount - record.amount;
            
        _funds[fundIndex] = GroupFund(
          id: fund.id,
          groupId: fund.groupId,
          fundName: fund.fundName,
          fundType: fund.fundType,
          totalAmount: fund.totalAmount,
          availableAmount: newAvailableAmount,
          interestRate: fund.interestRate,
          description: fund.description,
          isActive: fund.isActive,
          createdAt: fund.createdAt,
        );
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการบันทึกการออม: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Add dividend record
  Future<void> addDividendRecord(DividendRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _dividendRecords.add(record);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการบันทึกเงินปันผล: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get group statistics
  Map<String, dynamic> getGroupStatistics(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    final members = getMembersByGroup(groupId);
    final activities = getActivitiesByGroup(groupId);
    final funds = getFundsByGroup(groupId);
    final savings = getSavingsRecordsByGroup(groupId);
    
    final totalSavings = savings
        .where((s) => s.transactionType == 'deposit')
        .fold(0.0, (sum, s) => sum + s.amount);
    
    final totalWithdrawals = savings
        .where((s) => s.transactionType == 'withdrawal')
        .fold(0.0, (sum, s) => sum + s.amount);
    
    return {
      'groupName': group.name,
      'memberCount': members.length,
      'activeActivities': activities.where((a) => a.status != 'completed').length,
      'totalFunds': funds.fold(0.0, (sum, f) => sum + f.totalAmount),
      'availableFunds': funds.fold(0.0, (sum, f) => sum + f.availableAmount),
      'totalSavings': totalSavings,
      'totalWithdrawals': totalWithdrawals,
      'netSavings': totalSavings - totalWithdrawals,
    };
  }
}
