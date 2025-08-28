class BreedingRecord {
  final String id;
  final String livestockId;
  final String? maleParentId;
  final String? femaleParentId;
  final DateTime breedingDate;
  final String breedingMethod; // 'natural', 'artificial_insemination'
  final DateTime? expectedBirthDate;
  final DateTime? actualBirthDate;
  final int? numberOfOffspring;
  final List<String>? offspringIds;
  final String? veterinarian;
  final double? cost;
  final String? notes;
  final String status; // 'bred', 'confirmed_pregnant', 'born', 'failed'
  final DateTime createdAt;
  final DateTime updatedAt;

  BreedingRecord({
    required this.id,
    required this.livestockId,
    this.maleParentId,
    this.femaleParentId,
    required this.breedingDate,
    required this.breedingMethod,
    this.expectedBirthDate,
    this.actualBirthDate,
    this.numberOfOffspring,
    this.offspringIds,
    this.veterinarian,
    this.cost,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      maleParentId: json['maleParentId'],
      femaleParentId: json['femaleParentId'],
      breedingDate: DateTime.parse(json['breedingDate']),
      breedingMethod: json['breedingMethod'],
      expectedBirthDate: json['expectedBirthDate'] != null 
          ? DateTime.parse(json['expectedBirthDate']) 
          : null,
      actualBirthDate: json['actualBirthDate'] != null 
          ? DateTime.parse(json['actualBirthDate']) 
          : null,
      numberOfOffspring: json['numberOfOffspring'],
      offspringIds: json['offspringIds'] != null 
          ? List<String>.from(json['offspringIds']) 
          : null,
      veterinarian: json['veterinarian'],
      cost: json['cost']?.toDouble(),
      notes: json['notes'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'maleParentId': maleParentId,
      'femaleParentId': femaleParentId,
      'breedingDate': breedingDate.toIso8601String(),
      'breedingMethod': breedingMethod,
      'expectedBirthDate': expectedBirthDate?.toIso8601String(),
      'actualBirthDate': actualBirthDate?.toIso8601String(),
      'numberOfOffspring': numberOfOffspring,
      'offspringIds': offspringIds,
      'veterinarian': veterinarian,
      'cost': cost,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BreedingRecord copyWith({
    String? id,
    String? livestockId,
    String? maleParentId,
    String? femaleParentId,
    DateTime? breedingDate,
    String? breedingMethod,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    int? numberOfOffspring,
    List<String>? offspringIds,
    String? veterinarian,
    double? cost,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreedingRecord(
      id: id ?? this.id,
      livestockId: livestockId ?? this.livestockId,
      maleParentId: maleParentId ?? this.maleParentId,
      femaleParentId: femaleParentId ?? this.femaleParentId,
      breedingDate: breedingDate ?? this.breedingDate,
      breedingMethod: breedingMethod ?? this.breedingMethod,
      expectedBirthDate: expectedBirthDate ?? this.expectedBirthDate,
      actualBirthDate: actualBirthDate ?? this.actualBirthDate,
      numberOfOffspring: numberOfOffspring ?? this.numberOfOffspring,
      offspringIds: offspringIds ?? this.offspringIds,
      veterinarian: veterinarian ?? this.veterinarian,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VaccinationRecord {
  final String id;
  final String livestockId;
  final String vaccineName;
  final String vaccineType; // 'preventive', 'treatment'
  final DateTime vaccinationDate;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final double? dosage;
  final String? administeredBy;
  final double? cost;
  final String? sideEffects;
  final String? notes;
  final DateTime createdAt;

  VaccinationRecord({
    required this.id,
    required this.livestockId,
    required this.vaccineName,
    required this.vaccineType,
    required this.vaccinationDate,
    this.nextDueDate,
    this.batchNumber,
    this.dosage,
    this.administeredBy,
    this.cost,
    this.sideEffects,
    this.notes,
    required this.createdAt,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      vaccineName: json['vaccineName'],
      vaccineType: json['vaccineType'],
      vaccinationDate: DateTime.parse(json['vaccinationDate']),
      nextDueDate: json['nextDueDate'] != null 
          ? DateTime.parse(json['nextDueDate']) 
          : null,
      batchNumber: json['batchNumber'],
      dosage: json['dosage']?.toDouble(),
      administeredBy: json['administeredBy'],
      cost: json['cost']?.toDouble(),
      sideEffects: json['sideEffects'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'vaccineName': vaccineName,
      'vaccineType': vaccineType,
      'vaccinationDate': vaccinationDate.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'dosage': dosage,
      'administeredBy': administeredBy,
      'cost': cost,
      'sideEffects': sideEffects,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class FeedRecord {
  final String id;
  final String livestockId;
  final String feedType;
  final String feedName;
  final double quantity; // กิโลกรัม
  final double costPerUnit;
  final double totalCost;
  final DateTime feedingDate;
  final String? supplier;
  final String? notes;
  final DateTime createdAt;

  FeedRecord({
    required this.id,
    required this.livestockId,
    required this.feedType,
    required this.feedName,
    required this.quantity,
    required this.costPerUnit,
    required this.totalCost,
    required this.feedingDate,
    this.supplier,
    this.notes,
    required this.createdAt,
  });

  factory FeedRecord.fromJson(Map<String, dynamic> json) {
    return FeedRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      feedType: json['feedType'],
      feedName: json['feedName'],
      quantity: json['quantity'].toDouble(),
      costPerUnit: json['costPerUnit'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      feedingDate: DateTime.parse(json['feedingDate']),
      supplier: json['supplier'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'feedType': feedType,
      'feedName': feedName,
      'quantity': quantity,
      'costPerUnit': costPerUnit,
      'totalCost': totalCost,
      'feedingDate': feedingDate.toIso8601String(),
      'supplier': supplier,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MilkProductionRecord {
  final String id;
  final String livestockId;
  final DateTime productionDate;
  final double morningYield; // กิโลกรัม
  final double eveningYield; // กิโลกรัม
  final double totalDailyYield;
  final double? fatContent; // เปอร์เซ็นต์
  final double? proteinContent; // เปอร์เซ็นต์
  final String quality; // 'excellent', 'good', 'fair', 'poor'
  final double? pricePerKg;
  final double? totalRevenue;
  final String? buyer;
  final String? notes;
  final DateTime createdAt;

  MilkProductionRecord({
    required this.id,
    required this.livestockId,
    required this.productionDate,
    required this.morningYield,
    required this.eveningYield,
    required this.totalDailyYield,
    this.fatContent,
    this.proteinContent,
    required this.quality,
    this.pricePerKg,
    this.totalRevenue,
    this.buyer,
    this.notes,
    required this.createdAt,
  });

  factory MilkProductionRecord.fromJson(Map<String, dynamic> json) {
    return MilkProductionRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      productionDate: DateTime.parse(json['productionDate']),
      morningYield: json['morningYield'].toDouble(),
      eveningYield: json['eveningYield'].toDouble(),
      totalDailyYield: json['totalDailyYield'].toDouble(),
      fatContent: json['fatContent']?.toDouble(),
      proteinContent: json['proteinContent']?.toDouble(),
      quality: json['quality'],
      pricePerKg: json['pricePerKg']?.toDouble(),
      totalRevenue: json['totalRevenue']?.toDouble(),
      buyer: json['buyer'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'productionDate': productionDate.toIso8601String(),
      'morningYield': morningYield,
      'eveningYield': eveningYield,
      'totalDailyYield': totalDailyYield,
      'fatContent': fatContent,
      'proteinContent': proteinContent,
      'quality': quality,
      'pricePerKg': pricePerKg,
      'totalRevenue': totalRevenue,
      'buyer': buyer,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
