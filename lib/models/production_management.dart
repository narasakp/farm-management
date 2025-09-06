import 'package:flutter/material.dart';

enum ProductionType {
  milk,
  eggs,
  meat,
  wool,
  honey,
  other,
}

extension ProductionTypeExtension on ProductionType {
  String get displayName {
    switch (this) {
      case ProductionType.milk:
        return 'นม';
      case ProductionType.eggs:
        return 'ไข่';
      case ProductionType.meat:
        return 'เนื้อ';
      case ProductionType.wool:
        return 'ขนแกะ';
      case ProductionType.honey:
        return 'น้ำผึ้ง';
      case ProductionType.other:
        return 'อื่นๆ';
    }
  }

  String get unit {
    switch (this) {
      case ProductionType.milk:
        return 'ลิตร';
      case ProductionType.eggs:
        return 'ฟอง';
      case ProductionType.meat:
        return 'กิโลกรัม';
      case ProductionType.wool:
        return 'กิโลกรัม';
      case ProductionType.honey:
        return 'กิโลกรัม';
      case ProductionType.other:
        return 'หน่วย';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductionType.milk:
        return Icons.local_drink;
      case ProductionType.eggs:
        return Icons.egg;
      case ProductionType.meat:
        return Icons.restaurant;
      case ProductionType.wool:
        return Icons.texture;
      case ProductionType.honey:
        return Icons.water_drop;
      case ProductionType.other:
        return Icons.inventory;
    }
  }

  Color get color {
    switch (this) {
      case ProductionType.milk:
        return Colors.blue;
      case ProductionType.eggs:
        return Colors.orange;
      case ProductionType.meat:
        return Colors.red;
      case ProductionType.wool:
        return Colors.brown;
      case ProductionType.honey:
        return Colors.amber;
      case ProductionType.other:
        return Colors.grey;
    }
  }
}

enum ProductionQuality {
  excellent,
  good,
  average,
  poor,
}

extension ProductionQualityExtension on ProductionQuality {
  String get displayName {
    switch (this) {
      case ProductionQuality.excellent:
        return 'ดีเยี่ยม';
      case ProductionQuality.good:
        return 'ดี';
      case ProductionQuality.average:
        return 'ปานกลาง';
      case ProductionQuality.poor:
        return 'ต่ำ';
    }
  }

  Color get color {
    switch (this) {
      case ProductionQuality.excellent:
        return Colors.green;
      case ProductionQuality.good:
        return Colors.lightGreen;
      case ProductionQuality.average:
        return Colors.orange;
      case ProductionQuality.poor:
        return Colors.red;
    }
  }

  int get score {
    switch (this) {
      case ProductionQuality.excellent:
        return 4;
      case ProductionQuality.good:
        return 3;
      case ProductionQuality.average:
        return 2;
      case ProductionQuality.poor:
        return 1;
    }
  }
}

class ProductionRecord {
  final String id;
  final String livestockId;
  final String livestockName;
  final ProductionType type;
  final double quantity;
  final ProductionQuality quality;
  final DateTime date;
  final DateTime? timeCollected;
  final double? pricePerUnit;
  final double? totalValue;
  final String? collectedBy;
  final String? storageLocation;
  final String? notes;
  final Map<String, dynamic> qualityMetrics;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductionRecord({
    required this.id,
    required this.livestockId,
    required this.livestockName,
    required this.type,
    required this.quantity,
    required this.quality,
    required this.date,
    this.timeCollected,
    this.pricePerUnit,
    this.totalValue,
    this.collectedBy,
    this.storageLocation,
    this.notes,
    this.qualityMetrics = const {},
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get calculatedTotalValue {
    if (totalValue != null) return totalValue!;
    if (pricePerUnit != null) return quantity * pricePerUnit!;
    return 0.0;
  }

  ProductionRecord copyWith({
    String? id,
    String? livestockId,
    String? livestockName,
    ProductionType? type,
    double? quantity,
    ProductionQuality? quality,
    DateTime? date,
    DateTime? timeCollected,
    double? pricePerUnit,
    double? totalValue,
    String? collectedBy,
    String? storageLocation,
    String? notes,
    Map<String, dynamic>? qualityMetrics,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductionRecord(
      id: id ?? this.id,
      livestockId: livestockId ?? this.livestockId,
      livestockName: livestockName ?? this.livestockName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      quality: quality ?? this.quality,
      date: date ?? this.date,
      timeCollected: timeCollected ?? this.timeCollected,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalValue: totalValue ?? this.totalValue,
      collectedBy: collectedBy ?? this.collectedBy,
      storageLocation: storageLocation ?? this.storageLocation,
      notes: notes ?? this.notes,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'livestockName': livestockName,
      'type': type.name,
      'quantity': quantity,
      'quality': quality.name,
      'date': date.toIso8601String(),
      'timeCollected': timeCollected?.toIso8601String(),
      'pricePerUnit': pricePerUnit,
      'totalValue': totalValue,
      'collectedBy': collectedBy,
      'storageLocation': storageLocation,
      'notes': notes,
      'qualityMetrics': qualityMetrics,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProductionRecord.fromJson(Map<String, dynamic> json) {
    return ProductionRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      livestockName: json['livestockName'],
      type: ProductionType.values.firstWhere((e) => e.name == json['type']),
      quantity: json['quantity'].toDouble(),
      quality: ProductionQuality.values.firstWhere((e) => e.name == json['quality']),
      date: DateTime.parse(json['date']),
      timeCollected: json['timeCollected'] != null 
          ? DateTime.parse(json['timeCollected']) 
          : null,
      pricePerUnit: json['pricePerUnit']?.toDouble(),
      totalValue: json['totalValue']?.toDouble(),
      collectedBy: json['collectedBy'],
      storageLocation: json['storageLocation'],
      notes: json['notes'],
      qualityMetrics: Map<String, dynamic>.from(json['qualityMetrics'] ?? {}),
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ProductionSummary {
  final int totalRecords;
  final double totalQuantity;
  final double totalValue;
  final double averageQuality;
  final Map<ProductionType, double> quantityByType;
  final Map<ProductionType, double> valueByType;
  final Map<ProductionQuality, int> recordsByQuality;
  final List<ProductionRecord> recentRecords;
  final Map<String, double> dailyProduction;
  final Map<String, double> monthlyProduction;
  final double averageDailyProduction;
  final ProductionType mostProductiveType;
  final String topProducingLivestock;

  ProductionSummary({
    required this.totalRecords,
    required this.totalQuantity,
    required this.totalValue,
    required this.averageQuality,
    required this.quantityByType,
    required this.valueByType,
    required this.recordsByQuality,
    required this.recentRecords,
    required this.dailyProduction,
    required this.monthlyProduction,
    required this.averageDailyProduction,
    required this.mostProductiveType,
    required this.topProducingLivestock,
  });
}

class ProductionTarget {
  final String id;
  final ProductionType type;
  final double dailyTarget;
  final double weeklyTarget;
  final double monthlyTarget;
  final double yearlyTarget;
  final ProductionQuality minimumQuality;
  final String? livestockId;
  final String? livestockName;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductionTarget({
    required this.id,
    required this.type,
    required this.dailyTarget,
    required this.weeklyTarget,
    required this.monthlyTarget,
    required this.yearlyTarget,
    required this.minimumQuality,
    this.livestockId,
    this.livestockName,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'dailyTarget': dailyTarget,
      'weeklyTarget': weeklyTarget,
      'monthlyTarget': monthlyTarget,
      'yearlyTarget': yearlyTarget,
      'minimumQuality': minimumQuality.name,
      'livestockId': livestockId,
      'livestockName': livestockName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProductionTarget.fromJson(Map<String, dynamic> json) {
    return ProductionTarget(
      id: json['id'],
      type: ProductionType.values.firstWhere((e) => e.name == json['type']),
      dailyTarget: json['dailyTarget'].toDouble(),
      weeklyTarget: json['weeklyTarget'].toDouble(),
      monthlyTarget: json['monthlyTarget'].toDouble(),
      yearlyTarget: json['yearlyTarget'].toDouble(),
      minimumQuality: ProductionQuality.values.firstWhere((e) => e.name == json['minimumQuality']),
      livestockId: json['livestockId'],
      livestockName: json['livestockName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ProductionAnalytics {
  final double productionTrend; // Percentage change from previous period
  final double qualityTrend;
  final double valueTrend;
  final Map<String, double> seasonalPatterns;
  final List<String> insights;
  final List<String> recommendations;
  final Map<String, double> performanceMetrics;

  ProductionAnalytics({
    required this.productionTrend,
    required this.qualityTrend,
    required this.valueTrend,
    required this.seasonalPatterns,
    required this.insights,
    required this.recommendations,
    required this.performanceMetrics,
  });
}
