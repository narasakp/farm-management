/// Production record types
enum ProductionType {
  milk('milk', 'น้ำนม', 'ลิตร'),
  egg('egg', 'ไข่', 'ฟอง'),
  weight('weight', 'น้ำหนัก', 'กิโลกรัม');

  final String code;
  final String displayName;
  final String defaultUnit;

  const ProductionType(this.code, this.displayName, this.defaultUnit);

  static ProductionType fromCode(String code) {
    return ProductionType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => ProductionType.weight,
    );
  }
}

/// Production record model
class ProductionRecord {
  final int? id;
  final String livestockId;
  final int userId;
  final DateTime productionDate;
  final ProductionType productionType;
  final double quantity;
  final String unit;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductionRecord({
    this.id,
    required this.livestockId,
    required this.userId,
    required this.productionDate,
    required this.productionType,
    required this.quantity,
    required this.unit,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory ProductionRecord.fromJson(Map<String, dynamic> json) {
    return ProductionRecord(
      id: json['id'] as int?,
      livestockId: json['livestock_id'] as String,
      userId: json['user_id'] as int,
      productionDate: DateTime.parse(json['production_date'] as String),
      productionType: ProductionType.fromCode(json['production_type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'livestock_id': livestockId,
      'user_id': userId,
      'production_date': productionDate.toIso8601String().split('T')[0], // Date only
      'production_type': productionType.code,
      'quantity': quantity,
      'unit': unit,
      if (notes != null) 'notes': notes,
    };
  }

  /// Create a copy with updated fields
  ProductionRecord copyWith({
    int? id,
    String? livestockId,
    int? userId,
    DateTime? productionDate,
    ProductionType? productionType,
    double? quantity,
    String? unit,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductionRecord(
      id: id ?? this.id,
      livestockId: livestockId ?? this.livestockId,
      userId: userId ?? this.userId,
      productionDate: productionDate ?? this.productionDate,
      productionType: productionType ?? this.productionType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Production statistics
class ProductionStatistics {
  final ProductionType productionType;
  final int recordCount;
  final double totalQuantity;
  final double avgQuantity;
  final double minQuantity;
  final double maxQuantity;
  final String unit;

  ProductionStatistics({
    required this.productionType,
    required this.recordCount,
    required this.totalQuantity,
    required this.avgQuantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.unit,
  });

  factory ProductionStatistics.fromJson(Map<String, dynamic> json) {
    return ProductionStatistics(
      productionType: ProductionType.fromCode(json['production_type'] as String),
      recordCount: json['record_count'] as int,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      avgQuantity: (json['avg_quantity'] as num).toDouble(),
      minQuantity: (json['min_quantity'] as num).toDouble(),
      maxQuantity: (json['max_quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}
