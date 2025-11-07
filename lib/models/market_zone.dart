import 'package:flutter/material.dart';

/// โซนจอดขายในตลาดนัด แบ่งตามประเภทสัตว์
class MarketZone {
  final String id;              // 'zone_a'
  final String name;            // 'โซน A (โค-กระบือ)'
  final String code;            // 'A'
  final String livestockType;   // 'โค', 'กระบือ', 'สุกร', 'เป็ด', 'ไก่', 'แพะ', 'แกะ'
  final int totalSlots;         // 20
  final double extraFee;        // 50 บาท (ค่าธรรมเนียมเพิ่ม)
  final String? description;
  final bool isActive;
  final int sortOrder;          // สำหรับเรียงลำดับการแสดงผล

  MarketZone({
    required this.id,
    required this.name,
    required this.code,
    required this.livestockType,
    required this.totalSlots,
    this.extraFee = 0,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
  });

  // From JSON
  factory MarketZone.fromJson(Map<String, dynamic> json) {
    return MarketZone(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      livestockType: json['livestockType'] as String,
      totalSlots: json['totalSlots'] as int,
      extraFee: (json['extraFee'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'livestockType': livestockType,
      'totalSlots': totalSlots,
      'extraFee': extraFee,
      'description': description,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  MarketZone copyWith({
    String? id,
    String? name,
    String? code,
    String? livestockType,
    int? totalSlots,
    double? extraFee,
    String? description,
    bool? isActive,
    int? sortOrder,
  }) {
    return MarketZone(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      livestockType: livestockType ?? this.livestockType,
      totalSlots: totalSlots ?? this.totalSlots,
      extraFee: extraFee ?? this.extraFee,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Get icon for livestock type
  IconData get icon {
    switch (livestockType.toLowerCase()) {
      case 'โค':
        return Icons.pets;
      case 'กระบือ':
        return Icons.pets;
      case 'สุกร':
        return Icons.agriculture;
      case 'เป็ด':
      case 'ไก่':
        return Icons.flutter_dash;
      case 'แพะ':
      case 'แกะ':
        return Icons.cruelty_free;
      default:
        return Icons.category;
    }
  }
}
