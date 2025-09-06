import 'package:flutter/material.dart';

enum FeedType {
  concentrate,
  roughage,
  supplement,
  mineral,
  medicine,
  other,
}

extension FeedTypeExtension on FeedType {
  String get displayName {
    switch (this) {
      case FeedType.concentrate:
        return 'อาหารข้น';
      case FeedType.roughage:
        return 'อาหารหยาบ';
      case FeedType.supplement:
        return 'อาหารเสริม';
      case FeedType.mineral:
        return 'เกลือแร่';
      case FeedType.medicine:
        return 'ยาสัตว์';
      case FeedType.other:
        return 'อื่นๆ';
    }
  }

  IconData get icon {
    switch (this) {
      case FeedType.concentrate:
        return Icons.grain;
      case FeedType.roughage:
        return Icons.grass;
      case FeedType.supplement:
        return Icons.medication;
      case FeedType.mineral:
        return Icons.science;
      case FeedType.medicine:
        return Icons.medical_services;
      case FeedType.other:
        return Icons.inventory;
    }
  }

  Color get color {
    switch (this) {
      case FeedType.concentrate:
        return Colors.brown;
      case FeedType.roughage:
        return Colors.green;
      case FeedType.supplement:
        return Colors.orange;
      case FeedType.mineral:
        return Colors.blue;
      case FeedType.medicine:
        return Colors.red;
      case FeedType.other:
        return Colors.grey;
    }
  }
}

enum FeedUnit {
  kg,
  gram,
  liter,
  ml,
  bag,
  bottle,
  tablet,
  capsule,
}

extension FeedUnitExtension on FeedUnit {
  String get displayName {
    switch (this) {
      case FeedUnit.kg:
        return 'กิโลกรัม';
      case FeedUnit.gram:
        return 'กรัม';
      case FeedUnit.liter:
        return 'ลิตร';
      case FeedUnit.ml:
        return 'มิลลิลิตร';
      case FeedUnit.bag:
        return 'ถุง';
      case FeedUnit.bottle:
        return 'ขวด';
      case FeedUnit.tablet:
        return 'เม็ด';
      case FeedUnit.capsule:
        return 'แคปซูล';
    }
  }

  String get shortName {
    switch (this) {
      case FeedUnit.kg:
        return 'กก.';
      case FeedUnit.gram:
        return 'ก.';
      case FeedUnit.liter:
        return 'ล.';
      case FeedUnit.ml:
        return 'มล.';
      case FeedUnit.bag:
        return 'ถุง';
      case FeedUnit.bottle:
        return 'ขวด';
      case FeedUnit.tablet:
        return 'เม็ด';
      case FeedUnit.capsule:
        return 'แคปซูล';
    }
  }
}

class FeedItem {
  final String id;
  final String name;
  final FeedType type;
  final String? brand;
  final String? description;
  final FeedUnit unit;
  final double currentStock;
  final double minimumStock;
  final double maximumStock;
  final double costPerUnit;
  final String? supplier;
  final String? supplierContact;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? storageLocation;
  final Map<String, dynamic> nutritionalInfo;
  final List<String> suitableFor; // livestock types
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedItem({
    required this.id,
    required this.name,
    required this.type,
    this.brand,
    this.description,
    required this.unit,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.costPerUnit,
    this.supplier,
    this.supplierContact,
    this.expiryDate,
    this.batchNumber,
    this.storageLocation,
    this.nutritionalInfo = const {},
    this.suitableFor = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => currentStock <= minimumStock;
  bool get isOverStock => currentStock >= maximumStock;
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  double get stockValue => currentStock * costPerUnit;
  double get stockPercentage => maximumStock > 0 ? (currentStock / maximumStock) * 100 : 0;

  FeedItem copyWith({
    String? id,
    String? name,
    FeedType? type,
    String? brand,
    String? description,
    FeedUnit? unit,
    double? currentStock,
    double? minimumStock,
    double? maximumStock,
    double? costPerUnit,
    String? supplier,
    String? supplierContact,
    DateTime? expiryDate,
    String? batchNumber,
    String? storageLocation,
    Map<String, dynamic>? nutritionalInfo,
    List<String>? suitableFor,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplier: supplier ?? this.supplier,
      supplierContact: supplierContact ?? this.supplierContact,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      storageLocation: storageLocation ?? this.storageLocation,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      suitableFor: suitableFor ?? this.suitableFor,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'brand': brand,
      'description': description,
      'unit': unit.name,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'costPerUnit': costPerUnit,
      'supplier': supplier,
      'supplierContact': supplierContact,
      'expiryDate': expiryDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'storageLocation': storageLocation,
      'nutritionalInfo': nutritionalInfo,
      'suitableFor': suitableFor,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'],
      name: json['name'],
      type: FeedType.values.firstWhere((e) => e.name == json['type']),
      brand: json['brand'],
      description: json['description'],
      unit: FeedUnit.values.firstWhere((e) => e.name == json['unit']),
      currentStock: json['currentStock'].toDouble(),
      minimumStock: json['minimumStock'].toDouble(),
      maximumStock: json['maximumStock'].toDouble(),
      costPerUnit: json['costPerUnit'].toDouble(),
      supplier: json['supplier'],
      supplierContact: json['supplierContact'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      batchNumber: json['batchNumber'],
      storageLocation: json['storageLocation'],
      nutritionalInfo: Map<String, dynamic>.from(json['nutritionalInfo'] ?? {}),
      suitableFor: List<String>.from(json['suitableFor'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class FeedingRecord {
  final String id;
  final String livestockId;
  final String livestockName;
  final String feedItemId;
  final String feedItemName;
  final double quantity;
  final FeedUnit unit;
  final DateTime feedingTime;
  final String? fedBy;
  final String? notes;
  final double? cost;
  final DateTime createdAt;

  FeedingRecord({
    required this.id,
    required this.livestockId,
    required this.livestockName,
    required this.feedItemId,
    required this.feedItemName,
    required this.quantity,
    required this.unit,
    required this.feedingTime,
    this.fedBy,
    this.notes,
    this.cost,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'livestockName': livestockName,
      'feedItemId': feedItemId,
      'feedItemName': feedItemName,
      'quantity': quantity,
      'unit': unit.name,
      'feedingTime': feedingTime.toIso8601String(),
      'fedBy': fedBy,
      'notes': notes,
      'cost': cost,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeedingRecord.fromJson(Map<String, dynamic> json) {
    return FeedingRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      livestockName: json['livestockName'],
      feedItemId: json['feedItemId'],
      feedItemName: json['feedItemName'],
      quantity: json['quantity'].toDouble(),
      unit: FeedUnit.values.firstWhere((e) => e.name == json['unit']),
      feedingTime: DateTime.parse(json['feedingTime']),
      fedBy: json['fedBy'],
      notes: json['notes'],
      cost: json['cost']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class FeedSchedule {
  final String id;
  final String livestockId;
  final String livestockName;
  final String feedItemId;
  final String feedItemName;
  final double quantity;
  final FeedUnit unit;
  final List<int> feedingTimes; // Hours of the day (0-23)
  final List<int> daysOfWeek; // 1=Monday, 7=Sunday
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedSchedule({
    required this.id,
    required this.livestockId,
    required this.livestockName,
    required this.feedItemId,
    required this.feedItemName,
    required this.quantity,
    required this.unit,
    required this.feedingTimes,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool shouldFeedNow() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentWeekday = now.weekday;
    
    return isActive &&
           feedingTimes.contains(currentHour) &&
           daysOfWeek.contains(currentWeekday) &&
           now.isAfter(startDate) &&
           (endDate == null || now.isBefore(endDate!));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'livestockName': livestockName,
      'feedItemId': feedItemId,
      'feedItemName': feedItemName,
      'quantity': quantity,
      'unit': unit.name,
      'feedingTimes': feedingTimes,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FeedSchedule.fromJson(Map<String, dynamic> json) {
    return FeedSchedule(
      id: json['id'],
      livestockId: json['livestockId'],
      livestockName: json['livestockName'],
      feedItemId: json['feedItemId'],
      feedItemName: json['feedItemName'],
      quantity: json['quantity'].toDouble(),
      unit: FeedUnit.values.firstWhere((e) => e.name == json['unit']),
      feedingTimes: List<int>.from(json['feedingTimes']),
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class FeedInventoryTransaction {
  final String id;
  final String feedItemId;
  final String feedItemName;
  final String type; // 'in', 'out', 'adjustment'
  final double quantity;
  final FeedUnit unit;
  final double? costPerUnit;
  final double? totalCost;
  final String? reason;
  final String? reference; // PO number, feeding record ID, etc.
  final String? performedBy;
  final DateTime transactionDate;
  final DateTime createdAt;

  FeedInventoryTransaction({
    required this.id,
    required this.feedItemId,
    required this.feedItemName,
    required this.type,
    required this.quantity,
    required this.unit,
    this.costPerUnit,
    this.totalCost,
    this.reason,
    this.reference,
    this.performedBy,
    required this.transactionDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feedItemId': feedItemId,
      'feedItemName': feedItemName,
      'type': type,
      'quantity': quantity,
      'unit': unit.name,
      'costPerUnit': costPerUnit,
      'totalCost': totalCost,
      'reason': reason,
      'reference': reference,
      'performedBy': performedBy,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeedInventoryTransaction.fromJson(Map<String, dynamic> json) {
    return FeedInventoryTransaction(
      id: json['id'],
      feedItemId: json['feedItemId'],
      feedItemName: json['feedItemName'],
      type: json['type'],
      quantity: json['quantity'].toDouble(),
      unit: FeedUnit.values.firstWhere((e) => e.name == json['unit']),
      costPerUnit: json['costPerUnit']?.toDouble(),
      totalCost: json['totalCost']?.toDouble(),
      reason: json['reason'],
      reference: json['reference'],
      performedBy: json['performedBy'],
      transactionDate: DateTime.parse(json['transactionDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class FeedSummary {
  final int totalFeedItems;
  final int lowStockItems;
  final int expiringSoonItems;
  final int expiredItems;
  final double totalInventoryValue;
  final double monthlyFeedCost;
  final Map<FeedType, int> itemsByType;
  final Map<FeedType, double> valueByType;
  final List<FeedItem> criticalItems;
  final List<FeedingRecord> recentFeedings;
  final List<FeedSchedule> upcomingFeedings;

  FeedSummary({
    required this.totalFeedItems,
    required this.lowStockItems,
    required this.expiringSoonItems,
    required this.expiredItems,
    required this.totalInventoryValue,
    required this.monthlyFeedCost,
    required this.itemsByType,
    required this.valueByType,
    required this.criticalItems,
    required this.recentFeedings,
    required this.upcomingFeedings,
  });
}
