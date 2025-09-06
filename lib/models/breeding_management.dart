import 'package:flutter/material.dart';

enum BreedingStatus {
  planned,
  mated,
  pregnant,
  delivered,
  failed,
  aborted,
}

extension BreedingStatusExtension on BreedingStatus {
  String get displayName {
    switch (this) {
      case BreedingStatus.planned:
        return 'วางแผน';
      case BreedingStatus.mated:
        return 'ผสมแล้ว';
      case BreedingStatus.pregnant:
        return 'ตั้งท้อง';
      case BreedingStatus.delivered:
        return 'คลอดแล้ว';
      case BreedingStatus.failed:
        return 'ผสมไม่สำเร็จ';
      case BreedingStatus.aborted:
        return 'แท้ง';
    }
  }

  Color get color {
    switch (this) {
      case BreedingStatus.planned:
        return Colors.blue;
      case BreedingStatus.mated:
        return Colors.orange;
      case BreedingStatus.pregnant:
        return Colors.purple;
      case BreedingStatus.delivered:
        return Colors.green;
      case BreedingStatus.failed:
        return Colors.red;
      case BreedingStatus.aborted:
        return Colors.grey;
    }
  }
}

enum PregnancyStage {
  early,    // 0-3 เดือน
  middle,   // 4-6 เดือน
  late,     // 7-9 เดือน
  overdue,  // เกินกำหนด
}

extension PregnancyStageExtension on PregnancyStage {
  String get displayName {
    switch (this) {
      case PregnancyStage.early:
        return 'ช่วงต้น (0-3 เดือน)';
      case PregnancyStage.middle:
        return 'ช่วงกลาง (4-6 เดือน)';
      case PregnancyStage.late:
        return 'ช่วงท้าย (7-9 เดือน)';
      case PregnancyStage.overdue:
        return 'เกินกำหนด';
    }
  }

  Color get color {
    switch (this) {
      case PregnancyStage.early:
        return Colors.lightBlue;
      case PregnancyStage.middle:
        return Colors.blue;
      case PregnancyStage.late:
        return Colors.deepPurple;
      case PregnancyStage.overdue:
        return Colors.red;
    }
  }
}

class BreedingRecord {
  final String id;
  final String motherId;
  final String motherName;
  final String fatherId;
  final String fatherName;
  final DateTime matingDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final BreedingStatus status;
  final PregnancyStage? pregnancyStage;
  final int? numberOfOffspring;
  final List<String> offspringIds;
  final String? veterinarian;
  final double? cost;
  final String? notes;
  final List<String> complications;
  final Map<String, dynamic> healthChecks;
  final DateTime createdAt;
  final DateTime updatedAt;

  BreedingRecord({
    required this.id,
    required this.motherId,
    required this.motherName,
    required this.fatherId,
    required this.fatherName,
    required this.matingDate,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.status,
    this.pregnancyStage,
    this.numberOfOffspring,
    this.offspringIds = const [],
    this.veterinarian,
    this.cost,
    this.notes,
    this.complications = const [],
    this.healthChecks = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  int get gestationDays {
    if (expectedDeliveryDate == null) return 0;
    return expectedDeliveryDate!.difference(matingDate).inDays;
  }

  int get daysPregnant {
    if (status != BreedingStatus.pregnant) return 0;
    return DateTime.now().difference(matingDate).inDays;
  }

  int get daysUntilDelivery {
    if (expectedDeliveryDate == null) return 0;
    return expectedDeliveryDate!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue {
    if (expectedDeliveryDate == null || status != BreedingStatus.pregnant) return false;
    return DateTime.now().isAfter(expectedDeliveryDate!);
  }

  PregnancyStage get currentPregnancyStage {
    if (status != BreedingStatus.pregnant) return PregnancyStage.early;
    
    final days = daysPregnant;
    if (isOverdue) return PregnancyStage.overdue;
    if (days >= 210) return PregnancyStage.late;    // 7+ months
    if (days >= 120) return PregnancyStage.middle;  // 4+ months
    return PregnancyStage.early;                    // 0-3 months
  }

  BreedingRecord copyWith({
    String? id,
    String? motherId,
    String? motherName,
    String? fatherId,
    String? fatherName,
    DateTime? matingDate,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    BreedingStatus? status,
    PregnancyStage? pregnancyStage,
    int? numberOfOffspring,
    List<String>? offspringIds,
    String? veterinarian,
    double? cost,
    String? notes,
    List<String>? complications,
    Map<String, dynamic>? healthChecks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreedingRecord(
      id: id ?? this.id,
      motherId: motherId ?? this.motherId,
      motherName: motherName ?? this.motherName,
      fatherId: fatherId ?? this.fatherId,
      fatherName: fatherName ?? this.fatherName,
      matingDate: matingDate ?? this.matingDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      status: status ?? this.status,
      pregnancyStage: pregnancyStage ?? this.pregnancyStage,
      numberOfOffspring: numberOfOffspring ?? this.numberOfOffspring,
      offspringIds: offspringIds ?? this.offspringIds,
      veterinarian: veterinarian ?? this.veterinarian,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      complications: complications ?? this.complications,
      healthChecks: healthChecks ?? this.healthChecks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motherId': motherId,
      'motherName': motherName,
      'fatherId': fatherId,
      'fatherName': fatherName,
      'matingDate': matingDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'status': status.name,
      'pregnancyStage': pregnancyStage?.name,
      'numberOfOffspring': numberOfOffspring,
      'offspringIds': offspringIds,
      'veterinarian': veterinarian,
      'cost': cost,
      'notes': notes,
      'complications': complications,
      'healthChecks': healthChecks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'],
      motherId: json['motherId'],
      motherName: json['motherName'],
      fatherId: json['fatherId'],
      fatherName: json['fatherName'],
      matingDate: DateTime.parse(json['matingDate']),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null 
          ? DateTime.parse(json['expectedDeliveryDate']) 
          : null,
      actualDeliveryDate: json['actualDeliveryDate'] != null 
          ? DateTime.parse(json['actualDeliveryDate']) 
          : null,
      status: BreedingStatus.values.firstWhere((e) => e.name == json['status']),
      pregnancyStage: json['pregnancyStage'] != null 
          ? PregnancyStage.values.firstWhere((e) => e.name == json['pregnancyStage'])
          : null,
      numberOfOffspring: json['numberOfOffspring'],
      offspringIds: List<String>.from(json['offspringIds'] ?? []),
      veterinarian: json['veterinarian'],
      cost: json['cost']?.toDouble(),
      notes: json['notes'],
      complications: List<String>.from(json['complications'] ?? []),
      healthChecks: Map<String, dynamic>.from(json['healthChecks'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class BreedingSummary {
  final int totalBreedings;
  final int activePregnancies;
  final int successfulDeliveries;
  final int failedBreedings;
  final int expectedDeliveriesThisMonth;
  final int overdueDeliveries;
  final double totalBreedingCost;
  final double averageOffspringPerDelivery;
  final List<BreedingRecord> recentBreedings;
  final List<BreedingRecord> upcomingDeliveries;

  BreedingSummary({
    required this.totalBreedings,
    required this.activePregnancies,
    required this.successfulDeliveries,
    required this.failedBreedings,
    required this.expectedDeliveriesThisMonth,
    required this.overdueDeliveries,
    required this.totalBreedingCost,
    required this.averageOffspringPerDelivery,
    required this.recentBreedings,
    required this.upcomingDeliveries,
  });
}

class OffspringRecord {
  final String id;
  final String breedingRecordId;
  final String name;
  final String gender;
  final DateTime birthDate;
  final double? birthWeight;
  final String? healthStatus;
  final String? notes;
  final DateTime createdAt;

  OffspringRecord({
    required this.id,
    required this.breedingRecordId,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.birthWeight,
    this.healthStatus,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'breedingRecordId': breedingRecordId,
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'birthWeight': birthWeight,
      'healthStatus': healthStatus,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OffspringRecord.fromJson(Map<String, dynamic> json) {
    return OffspringRecord(
      id: json['id'],
      breedingRecordId: json['breedingRecordId'],
      name: json['name'],
      gender: json['gender'],
      birthDate: DateTime.parse(json['birthDate']),
      birthWeight: json['birthWeight']?.toDouble(),
      healthStatus: json['healthStatus'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
