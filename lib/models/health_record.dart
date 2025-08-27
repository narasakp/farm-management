class HealthRecord {
  final String id;
  final String livestockId;
  final DateTime date;
  final String recordType; // 'vaccination', 'treatment', 'checkup'
  final String? disease;
  final String? vaccine;
  final String? medicine;
  final String? veterinarian;
  final double? cost;
  final String? notes;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.livestockId,
    required this.date,
    required this.recordType,
    this.disease,
    this.vaccine,
    this.medicine,
    this.veterinarian,
    this.cost,
    this.notes,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      date: DateTime.parse(json['date']),
      recordType: json['recordType'],
      disease: json['disease'],
      vaccine: json['vaccine'],
      medicine: json['medicine'],
      veterinarian: json['veterinarian'],
      cost: json['cost']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'date': date.toIso8601String(),
      'recordType': recordType,
      'disease': disease,
      'vaccine': vaccine,
      'medicine': medicine,
      'veterinarian': veterinarian,
      'cost': cost,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class VaccinationRecord {
  final String id;
  final String livestockId;
  final DateTime date;
  final String vaccineName;
  final String? batch;
  final String? manufacturer;
  final DateTime? expiryDate;
  final String? veterinarian;
  final double? cost;
  final DateTime? nextDueDate;
  final String? notes;
  final DateTime createdAt;

  VaccinationRecord({
    required this.id,
    required this.livestockId,
    required this.date,
    required this.vaccineName,
    this.batch,
    this.manufacturer,
    this.expiryDate,
    this.veterinarian,
    this.cost,
    this.nextDueDate,
    this.notes,
    required this.createdAt,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      date: DateTime.parse(json['date']),
      vaccineName: json['vaccineName'],
      batch: json['batch'],
      manufacturer: json['manufacturer'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      veterinarian: json['veterinarian'],
      cost: json['cost']?.toDouble(),
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'date': date.toIso8601String(),
      'vaccineName': vaccineName,
      'batch': batch,
      'manufacturer': manufacturer,
      'expiryDate': expiryDate?.toIso8601String(),
      'veterinarian': veterinarian,
      'cost': cost,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BreedingRecord {
  final String id;
  final String femaleId;
  final String? maleId;
  final DateTime breedingDate;
  final String breedingMethod; // 'natural', 'artificial'
  final DateTime? expectedBirthDate;
  final DateTime? actualBirthDate;
  final int? offspringCount;
  final List<String>? offspringIds;
  final String? notes;
  final DateTime createdAt;

  BreedingRecord({
    required this.id,
    required this.femaleId,
    this.maleId,
    required this.breedingDate,
    required this.breedingMethod,
    this.expectedBirthDate,
    this.actualBirthDate,
    this.offspringCount,
    this.offspringIds,
    this.notes,
    required this.createdAt,
  });

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'],
      femaleId: json['femaleId'],
      maleId: json['maleId'],
      breedingDate: DateTime.parse(json['breedingDate']),
      breedingMethod: json['breedingMethod'],
      expectedBirthDate: json['expectedBirthDate'] != null ? DateTime.parse(json['expectedBirthDate']) : null,
      actualBirthDate: json['actualBirthDate'] != null ? DateTime.parse(json['actualBirthDate']) : null,
      offspringCount: json['offspringCount'],
      offspringIds: json['offspringIds'] != null ? List<String>.from(json['offspringIds']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'femaleId': femaleId,
      'maleId': maleId,
      'breedingDate': breedingDate.toIso8601String(),
      'breedingMethod': breedingMethod,
      'expectedBirthDate': expectedBirthDate?.toIso8601String(),
      'actualBirthDate': actualBirthDate?.toIso8601String(),
      'offspringCount': offspringCount,
      'offspringIds': offspringIds,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
