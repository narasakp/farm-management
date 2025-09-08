import 'package:flutter/foundation.dart';
import '../models/advanced_financial.dart';

class AdvancedFinancialProvider with ChangeNotifier {
  List<ProfitLossAnalysis> _profitLossAnalyses = [];
  List<GroupSavings> _groupSavings = [];
  List<DividendDistribution> _dividendDistributions = [];
  List<FinancialForecast> _forecasts = [];
  bool _isLoading = false;
  String? _error;

  List<ProfitLossAnalysis> get profitLossAnalyses => _profitLossAnalyses;
  List<GroupSavings> get groupSavings => _groupSavings;
  List<DividendDistribution> get dividendDistributions => _dividendDistributions;
  List<FinancialForecast> get forecasts => _forecasts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdvancedFinancialProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    
    // Sample Profit/Loss Analysis
    _profitLossAnalyses = [
      ProfitLossAnalysis(
        id: '1',
        farmId: 'FARM001',
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year, 12, 31),
        totalRevenue: 2850000.0,
        totalExpenses: 2100000.0,
        netProfit: 750000.0,
        profitMargin: 26.32,
        revenueByCategory: {
          'ขายโคนม': 1800000.0,
          'ขายโคเนื้อ': 650000.0,
          'ขายปุ๋ย': 250000.0,
          'บริการผสมเทียม': 150000.0,
        },
        expensesByCategory: {
          'อาหารสัตว์': 850000.0,
          'ค่าแรงงาน': 480000.0,
          'ยาและวัคซีน': 320000.0,
          'เชื้อเพลิง': 280000.0,
          'ค่าไฟฟ้า': 170000.0,
        },
        monthlyBreakdown: _generateMonthlyBreakdown(now.year),
        createdAt: now,
      ),
      ProfitLossAnalysis(
        id: '2',
        farmId: 'FARM002',
        startDate: DateTime(now.year - 1, 1, 1),
        endDate: DateTime(now.year - 1, 12, 31),
        totalRevenue: 1950000.0,
        totalExpenses: 1680000.0,
        netProfit: 270000.0,
        profitMargin: 13.85,
        revenueByCategory: {
          'ขายสุกร': 1200000.0,
          'ขายไก่': 450000.0,
          'ขายไข่': 300000.0,
        },
        expensesByCategory: {
          'อาหารสัตว์': 720000.0,
          'ค่าแรงงาน': 360000.0,
          'ยาและวัคซีน': 280000.0,
          'เชื้อเพลิง': 200000.0,
          'ค่าไฟฟ้า': 120000.0,
        },
        monthlyBreakdown: _generateMonthlyBreakdown(now.year - 1),
        createdAt: now.subtract(const Duration(days: 365)),
      ),
    ];

    // Sample Group Savings
    _groupSavings = [
      GroupSavings(
        id: '1',
        groupId: 'GROUP001',
        memberId: 'MEMBER001',
        type: SavingsType.deposit,
        amount: 50000.0,
        date: now.subtract(const Duration(days: 30)),
        description: 'ฝากเงินออมประจำเดือน',
        status: SavingsStatus.completed,
        approvedBy: 'ADMIN001',
        approvedDate: now.subtract(const Duration(days: 29)),
      ),
      GroupSavings(
        id: '2',
        groupId: 'GROUP001',
        memberId: 'MEMBER002',
        type: SavingsType.withdrawal,
        amount: 25000.0,
        date: now.subtract(const Duration(days: 15)),
        description: 'ถอนเงินเพื่อซื้ออาหารสัตว์',
        status: SavingsStatus.pending,
      ),
      GroupSavings(
        id: '3',
        groupId: 'GROUP001',
        memberId: 'MEMBER003',
        type: SavingsType.interest,
        amount: 2500.0,
        date: now.subtract(const Duration(days: 7)),
        description: 'ดอกเบี้ยประจำเดือน 5%',
        status: SavingsStatus.completed,
        approvedBy: 'ADMIN001',
        approvedDate: now.subtract(const Duration(days: 6)),
      ),
    ];

    // Sample Dividend Distribution
    _dividendDistributions = [
      DividendDistribution(
        id: '1',
        groupId: 'GROUP001',
        totalAmount: 500000.0,
        distributionDate: DateTime(now.year, 12, 31),
        status: DividendStatus.calculated,
        calculationMethod: 'ตามสัดส่วนการลงทุน',
        calculationDetails: {
          'totalInvestment': 2000000.0,
          'profitRate': 25.0,
          'distributionRate': 80.0,
        },
        memberDividends: [
          MemberDividend(
            memberId: 'MEMBER001',
            memberName: 'นายสมชาย เกษตรกร',
            amount: 200000.0,
            sharePercentage: 40.0,
            calculationBase: {
              'investment': 800000.0,
              'shares': 40,
            },
          ),
          MemberDividend(
            memberId: 'MEMBER002',
            memberName: 'นางสมหญิง ปศุสัตว์',
            amount: 150000.0,
            sharePercentage: 30.0,
            calculationBase: {
              'investment': 600000.0,
              'shares': 30,
            },
          ),
          MemberDividend(
            memberId: 'MEMBER003',
            memberName: 'นายสมศักดิ์ โคนม',
            amount: 150000.0,
            sharePercentage: 30.0,
            calculationBase: {
              'investment': 600000.0,
              'shares': 30,
            },
          ),
        ],
      ),
    ];

    // Sample Financial Forecast
    _forecasts = [
      FinancialForecast(
        id: '1',
        farmId: 'FARM001',
        forecastDate: now,
        forecastMonths: 12,
        model: ForecastModel.seasonal,
        confidenceLevel: 85.0,
        assumptions: {
          'milkPriceGrowth': 3.5,
          'feedCostIncrease': 2.8,
          'seasonalVariation': true,
          'marketDemand': 'stable',
        },
        monthlyForecasts: _generateMonthlyForecasts(now),
      ),
    ];

    notifyListeners();
  }

  List<MonthlyFinancial> _generateMonthlyBreakdown(int year) {
    final List<MonthlyFinancial> breakdown = [];
    for (int month = 1; month <= 12; month++) {
      // Simulate seasonal variation
      double seasonalFactor = 1.0;
      if (month >= 4 && month <= 6) seasonalFactor = 1.2; // High season
      if (month >= 10 && month <= 12) seasonalFactor = 0.8; // Low season

      final revenue = (200000 + (month * 5000)) * seasonalFactor;
      final expenses = (150000 + (month * 3000)) * seasonalFactor;
      
      breakdown.add(MonthlyFinancial(
        year: year,
        month: month,
        revenue: revenue,
        expenses: expenses,
        profit: revenue - expenses,
      ));
    }
    return breakdown;
  }

  List<MonthlyForecast> _generateMonthlyForecasts(DateTime startDate) {
    final List<MonthlyForecast> forecasts = [];
    for (int i = 1; i <= 12; i++) {
      final forecastDate = DateTime(startDate.year, startDate.month + i, 1);
      
      // Simple forecast with growth trend and seasonal variation
      double growthFactor = 1 + (i * 0.02); // 2% monthly growth
      double seasonalFactor = 1.0;
      
      final month = forecastDate.month;
      if (month >= 4 && month <= 6) seasonalFactor = 1.15;
      if (month >= 10 && month <= 12) seasonalFactor = 0.85;

      final baseRevenue = 250000.0;
      final baseExpenses = 180000.0;
      
      final predictedRevenue = baseRevenue * growthFactor * seasonalFactor;
      final predictedExpenses = baseExpenses * growthFactor * 0.98; // Slight efficiency gain
      
      forecasts.add(MonthlyForecast(
        year: forecastDate.year,
        month: forecastDate.month,
        predictedRevenue: predictedRevenue,
        predictedExpenses: predictedExpenses,
        predictedProfit: predictedRevenue - predictedExpenses,
        confidenceInterval: 15.0, // ±15%
      ));
    }
    return forecasts;
  }

  // Profit/Loss Analysis methods
  Future<void> generateProfitLossAnalysis(String farmId, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // In real implementation, this would calculate from actual financial records
      final analysis = ProfitLossAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmId: farmId,
        startDate: startDate,
        endDate: endDate,
        totalRevenue: 1500000.0,
        totalExpenses: 1200000.0,
        netProfit: 300000.0,
        profitMargin: 20.0,
        revenueByCategory: {
          'ขายปศุสัตว์': 1000000.0,
          'ขายผลผลิต': 500000.0,
        },
        expensesByCategory: {
          'อาหารสัตว์': 600000.0,
          'ค่าแรงงาน': 400000.0,
          'อื่นๆ': 200000.0,
        },
        monthlyBreakdown: [],
        createdAt: DateTime.now(),
      );

      _profitLossAnalyses.add(analysis);
    } catch (e) {
      _error = 'ไม่สามารถสร้างรายงานกำไรขาดทุนได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Group Savings methods
  Future<void> addGroupSavings(GroupSavings savings) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _groupSavings.add(savings);
    } catch (e) {
      _error = 'ไม่สามารถเพิ่มรายการออมได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveGroupSavings(String savingsId, String approvedBy) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _groupSavings.indexWhere((s) => s.id == savingsId);
      if (index != -1) {
        final savings = _groupSavings[index];
        _groupSavings[index] = GroupSavings(
          id: savings.id,
          groupId: savings.groupId,
          memberId: savings.memberId,
          type: savings.type,
          amount: savings.amount,
          date: savings.date,
          description: savings.description,
          status: SavingsStatus.approved,
          approvedBy: approvedBy,
          approvedDate: DateTime.now(),
        );
      }
    } catch (e) {
      _error = 'ไม่สามารถอนุมัติรายการออมได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dividend Distribution methods
  Future<void> calculateDividends(String groupId, double totalAmount, String method) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple calculation - in real implementation would be more complex
      final distribution = DividendDistribution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        totalAmount: totalAmount,
        distributionDate: DateTime.now(),
        status: DividendStatus.calculated,
        calculationMethod: method,
        calculationDetails: {
          'totalMembers': 3,
          'equalShare': totalAmount / 3,
        },
        memberDividends: [
          MemberDividend(
            memberId: 'MEMBER001',
            memberName: 'สมาชิก 1',
            amount: totalAmount / 3,
            sharePercentage: 33.33,
            calculationBase: {'shares': 1},
          ),
          MemberDividend(
            memberId: 'MEMBER002',
            memberName: 'สมาชิก 2',
            amount: totalAmount / 3,
            sharePercentage: 33.33,
            calculationBase: {'shares': 1},
          ),
          MemberDividend(
            memberId: 'MEMBER003',
            memberName: 'สมาชิก 3',
            amount: totalAmount / 3,
            sharePercentage: 33.33,
            calculationBase: {'shares': 1},
          ),
        ],
      );

      _dividendDistributions.add(distribution);
    } catch (e) {
      _error = 'ไม่สามารถคำนวณเงินปันผลได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Financial Forecast methods
  Future<void> generateForecast(String farmId, int months, ForecastModel model) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final forecast = FinancialForecast(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmId: farmId,
        forecastDate: DateTime.now(),
        forecastMonths: months,
        model: model,
        confidenceLevel: 80.0,
        assumptions: {
          'growthRate': 2.0,
          'seasonalVariation': true,
        },
        monthlyForecasts: _generateMonthlyForecasts(DateTime.now()),
      );

      _forecasts.add(forecast);
    } catch (e) {
      _error = 'ไม่สามารถสร้างการพยากรณ์ได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Query methods
  List<GroupSavings> getSavingsByGroup(String groupId) {
    return _groupSavings.where((s) => s.groupId == groupId).toList();
  }

  List<GroupSavings> getSavingsByMember(String memberId) {
    return _groupSavings.where((s) => s.memberId == memberId).toList();
  }

  List<GroupSavings> getPendingSavings() {
    return _groupSavings.where((s) => s.status == SavingsStatus.pending).toList();
  }

  ProfitLossAnalysis? getLatestProfitLoss(String farmId) {
    final analyses = _profitLossAnalyses.where((a) => a.farmId == farmId).toList();
    if (analyses.isEmpty) return null;
    analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return analyses.first;
  }

  FinancialForecast? getLatestForecast(String farmId) {
    final forecasts = _forecasts.where((f) => f.farmId == farmId).toList();
    if (forecasts.isEmpty) return null;
    forecasts.sort((a, b) => b.forecastDate.compareTo(a.forecastDate));
    return forecasts.first;
  }

  // Statistics
  double getTotalGroupSavings(String groupId) {
    return _groupSavings
        .where((s) => s.groupId == groupId && s.type == SavingsType.deposit && s.status == SavingsStatus.completed)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  double getTotalGroupWithdrawals(String groupId) {
    return _groupSavings
        .where((s) => s.groupId == groupId && s.type == SavingsType.withdrawal && s.status == SavingsStatus.completed)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  double getGroupBalance(String groupId) {
    return getTotalGroupSavings(groupId) - getTotalGroupWithdrawals(groupId);
  }

  int get totalProfitLossAnalyses => _profitLossAnalyses.length;
  int get totalGroupSavingsRecords => _groupSavings.length;
  int get totalDividendDistributions => _dividendDistributions.length;
  int get totalForecasts => _forecasts.length;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
