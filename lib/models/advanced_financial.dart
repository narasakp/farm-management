class ProfitLossAnalysis {
  final String id;
  final String farmId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final Map<String, double> revenueByCategory;
  final Map<String, double> expensesByCategory;
  final List<MonthlyFinancial> monthlyBreakdown;
  final DateTime createdAt;

  ProfitLossAnalysis({
    required this.id,
    required this.farmId,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.revenueByCategory,
    required this.expensesByCategory,
    required this.monthlyBreakdown,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'netProfit': netProfit,
      'profitMargin': profitMargin,
      'revenueByCategory': revenueByCategory,
      'expensesByCategory': expensesByCategory,
      'monthlyBreakdown': monthlyBreakdown.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProfitLossAnalysis.fromJson(Map<String, dynamic> json) {
    return ProfitLossAnalysis(
      id: json['id'],
      farmId: json['farmId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalRevenue: json['totalRevenue'].toDouble(),
      totalExpenses: json['totalExpenses'].toDouble(),
      netProfit: json['netProfit'].toDouble(),
      profitMargin: json['profitMargin'].toDouble(),
      revenueByCategory: Map<String, double>.from(json['revenueByCategory']),
      expensesByCategory: Map<String, double>.from(json['expensesByCategory']),
      monthlyBreakdown: (json['monthlyBreakdown'] as List)
          .map((m) => MonthlyFinancial.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MonthlyFinancial {
  final int year;
  final int month;
  final double revenue;
  final double expenses;
  final double profit;

  MonthlyFinancial({
    required this.year,
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'revenue': revenue,
      'expenses': expenses,
      'profit': profit,
    };
  }

  factory MonthlyFinancial.fromJson(Map<String, dynamic> json) {
    return MonthlyFinancial(
      year: json['year'],
      month: json['month'],
      revenue: json['revenue'].toDouble(),
      expenses: json['expenses'].toDouble(),
      profit: json['profit'].toDouble(),
    );
  }

  String get monthName {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return months[month - 1];
  }
}

class GroupSavings {
  final String id;
  final String groupId;
  final String memberId;
  final SavingsType type;
  final double amount;
  final DateTime date;
  final String description;
  final SavingsStatus status;
  final String? approvedBy;
  final DateTime? approvedDate;

  GroupSavings({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
    this.approvedBy,
    this.approvedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'memberId': memberId,
      'type': type.toString(),
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'status': status.toString(),
      'approvedBy': approvedBy,
      'approvedDate': approvedDate?.toIso8601String(),
    };
  }

  factory GroupSavings.fromJson(Map<String, dynamic> json) {
    return GroupSavings(
      id: json['id'],
      groupId: json['groupId'],
      memberId: json['memberId'],
      type: SavingsType.values.firstWhere((e) => e.toString() == json['type']),
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
      status: SavingsStatus.values.firstWhere((e) => e.toString() == json['status']),
      approvedBy: json['approvedBy'],
      approvedDate: json['approvedDate'] != null ? DateTime.parse(json['approvedDate']) : null,
    );
  }
}

enum SavingsType {
  deposit,    // ฝาก
  withdrawal, // ถอน
  interest,   // ดอกเบี้ย
  dividend,   // เงินปันผล
}

enum SavingsStatus {
  pending,   // รอดำเนินการ
  approved,  // อนุมัติ
  rejected,  // ปฏิเสธ
  completed, // เสร็จสิ้น
}

class DividendDistribution {
  final String id;
  final String groupId;
  final double totalAmount;
  final DateTime distributionDate;
  final List<MemberDividend> memberDividends;
  final DividendStatus status;
  final String calculationMethod;
  final Map<String, dynamic> calculationDetails;

  DividendDistribution({
    required this.id,
    required this.groupId,
    required this.totalAmount,
    required this.distributionDate,
    required this.memberDividends,
    required this.status,
    required this.calculationMethod,
    required this.calculationDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'totalAmount': totalAmount,
      'distributionDate': distributionDate.toIso8601String(),
      'memberDividends': memberDividends.map((m) => m.toJson()).toList(),
      'status': status.toString(),
      'calculationMethod': calculationMethod,
      'calculationDetails': calculationDetails,
    };
  }

  factory DividendDistribution.fromJson(Map<String, dynamic> json) {
    return DividendDistribution(
      id: json['id'],
      groupId: json['groupId'],
      totalAmount: json['totalAmount'].toDouble(),
      distributionDate: DateTime.parse(json['distributionDate']),
      memberDividends: (json['memberDividends'] as List)
          .map((m) => MemberDividend.fromJson(m))
          .toList(),
      status: DividendStatus.values.firstWhere((e) => e.toString() == json['status']),
      calculationMethod: json['calculationMethod'],
      calculationDetails: Map<String, dynamic>.from(json['calculationDetails']),
    );
  }
}

class MemberDividend {
  final String memberId;
  final String memberName;
  final double amount;
  final double sharePercentage;
  final Map<String, dynamic> calculationBase;

  MemberDividend({
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.sharePercentage,
    required this.calculationBase,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'sharePercentage': sharePercentage,
      'calculationBase': calculationBase,
    };
  }

  factory MemberDividend.fromJson(Map<String, dynamic> json) {
    return MemberDividend(
      memberId: json['memberId'],
      memberName: json['memberName'],
      amount: json['amount'].toDouble(),
      sharePercentage: json['sharePercentage'].toDouble(),
      calculationBase: Map<String, dynamic>.from(json['calculationBase']),
    );
  }
}

enum DividendStatus {
  calculated,   // คำนวณแล้ว
  approved,     // อนุมัติ
  distributed,  // จ่ายแล้ว
  cancelled,    // ยกเลิก
}

class FinancialForecast {
  final String id;
  final String farmId;
  final DateTime forecastDate;
  final int forecastMonths;
  final List<MonthlyForecast> monthlyForecasts;
  final ForecastModel model;
  final double confidenceLevel;
  final Map<String, dynamic> assumptions;

  FinancialForecast({
    required this.id,
    required this.farmId,
    required this.forecastDate,
    required this.forecastMonths,
    required this.monthlyForecasts,
    required this.model,
    required this.confidenceLevel,
    required this.assumptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'forecastDate': forecastDate.toIso8601String(),
      'forecastMonths': forecastMonths,
      'monthlyForecasts': monthlyForecasts.map((f) => f.toJson()).toList(),
      'model': model.toString(),
      'confidenceLevel': confidenceLevel,
      'assumptions': assumptions,
    };
  }

  factory FinancialForecast.fromJson(Map<String, dynamic> json) {
    return FinancialForecast(
      id: json['id'],
      farmId: json['farmId'],
      forecastDate: DateTime.parse(json['forecastDate']),
      forecastMonths: json['forecastMonths'],
      monthlyForecasts: (json['monthlyForecasts'] as List)
          .map((f) => MonthlyForecast.fromJson(f))
          .toList(),
      model: ForecastModel.values.firstWhere((e) => e.toString() == json['model']),
      confidenceLevel: json['confidenceLevel'].toDouble(),
      assumptions: Map<String, dynamic>.from(json['assumptions']),
    );
  }
}

class MonthlyForecast {
  final int year;
  final int month;
  final double predictedRevenue;
  final double predictedExpenses;
  final double predictedProfit;
  final double confidenceInterval;

  MonthlyForecast({
    required this.year,
    required this.month,
    required this.predictedRevenue,
    required this.predictedExpenses,
    required this.predictedProfit,
    required this.confidenceInterval,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'predictedRevenue': predictedRevenue,
      'predictedExpenses': predictedExpenses,
      'predictedProfit': predictedProfit,
      'confidenceInterval': confidenceInterval,
    };
  }

  factory MonthlyForecast.fromJson(Map<String, dynamic> json) {
    return MonthlyForecast(
      year: json['year'],
      month: json['month'],
      predictedRevenue: json['predictedRevenue'].toDouble(),
      predictedExpenses: json['predictedExpenses'].toDouble(),
      predictedProfit: json['predictedProfit'].toDouble(),
      confidenceInterval: json['confidenceInterval'].toDouble(),
    );
  }
}

enum ForecastModel {
  linear,        // เชิงเส้น
  seasonal,      // ตามฤดูกาล
  exponential,   // เลขชี้กำลัง
  arima,         // ARIMA
}

extension SavingsTypeExtension on SavingsType {
  String get displayName {
    switch (this) {
      case SavingsType.deposit:
        return 'ฝาก';
      case SavingsType.withdrawal:
        return 'ถอน';
      case SavingsType.interest:
        return 'ดอกเบี้ย';
      case SavingsType.dividend:
        return 'เงินปันผล';
    }
  }
}

extension SavingsStatusExtension on SavingsStatus {
  String get displayName {
    switch (this) {
      case SavingsStatus.pending:
        return 'รอดำเนินการ';
      case SavingsStatus.approved:
        return 'อนุมัติ';
      case SavingsStatus.rejected:
        return 'ปฏิเสธ';
      case SavingsStatus.completed:
        return 'เสร็จสิ้น';
    }
  }
}

extension DividendStatusExtension on DividendStatus {
  String get displayName {
    switch (this) {
      case DividendStatus.calculated:
        return 'คำนวณแล้ว';
      case DividendStatus.approved:
        return 'อนุมัติ';
      case DividendStatus.distributed:
        return 'จ่ายแล้ว';
      case DividendStatus.cancelled:
        return 'ยกเลิก';
    }
  }
}

extension ForecastModelExtension on ForecastModel {
  String get displayName {
    switch (this) {
      case ForecastModel.linear:
        return 'เชิงเส้น';
      case ForecastModel.seasonal:
        return 'ตามฤดูกาล';
      case ForecastModel.exponential:
        return 'เลขชี้กำลัง';
      case ForecastModel.arima:
        return 'ARIMA';
    }
  }
}
