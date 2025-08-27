class Livestock {
  final String id;
  final String farmId;
  final LivestockType type;
  final String breed;
  final String gender;
  final DateTime birthDate;
  final double? weight;
  final String? earTag;
  final String? rfidTag;
  final LivestockStatus status;
  final String? parentMaleId;
  final String? parentFemaleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Livestock({
    required this.id,
    required this.farmId,
    required this.type,
    required this.breed,
    required this.gender,
    required this.birthDate,
    this.weight,
    this.earTag,
    this.rfidTag,
    required this.status,
    this.parentMaleId,
    this.parentFemaleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Livestock.fromJson(Map<String, dynamic> json) {
    return Livestock(
      id: json['id'],
      farmId: json['farmId'],
      type: LivestockType.values.byName(json['type']),
      breed: json['breed'],
      gender: json['gender'],
      birthDate: DateTime.parse(json['birthDate']),
      weight: json['weight']?.toDouble(),
      earTag: json['earTag'],
      rfidTag: json['rfidTag'],
      status: LivestockStatus.values.byName(json['status']),
      parentMaleId: json['parentMaleId'],
      parentFemaleId: json['parentFemaleId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'type': type.name,
      'breed': breed,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'weight': weight,
      'earTag': earTag,
      'rfidTag': rfidTag,
      'status': status.name,
      'parentMaleId': parentMaleId,
      'parentFemaleId': parentFemaleId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get ageInMonths {
    final now = DateTime.now();
    return ((now.difference(birthDate).inDays) / 30.44).floor();
  }

  String get displayName {
    return '${type.displayName} ${earTag ?? id.substring(0, 8)}';
  }
}

enum LivestockType {
  cattle('โคเนื้อ'),
  dairyCow('โคนม'),
  buffalo('กระบือ'),
  pig('สุกร'),
  chicken('ไก่'),
  duck('เป็ด'),
  goat('แพะ'),
  sheep('แกะ'),
  quail('นกกระทา'),
  dog('สุนัข'),
  cat('แมว'),
  other('อื่นๆ');

  const LivestockType(this.displayName);
  final String displayName;
}

enum LivestockStatus {
  healthy('สุขภาพดี'),
  sick('ป่วย'),
  pregnant('ตั้งท้อง'),
  lactating('ให้นม'),
  sold('ขายแล้ว'),
  dead('ตาย'),
  missing('หาย');

  const LivestockStatus(this.displayName);
  final String displayName;
}

class HealthRecord {
  final String id;
  final String livestockId;
  final DateTime date;
  final String symptoms;
  final String? diagnosis;
  final String? treatment;
  final String? medication;
  final double? cost;
  final String? veterinarian;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.livestockId,
    required this.date,
    required this.symptoms,
    this.diagnosis,
    this.treatment,
    this.medication,
    this.cost,
    this.veterinarian,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      date: DateTime.parse(json['date']),
      symptoms: json['symptoms'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      medication: json['medication'],
      cost: json['cost']?.toDouble(),
      veterinarian: json['veterinarian'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'medication': medication,
      'cost': cost,
      'veterinarian': veterinarian,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
