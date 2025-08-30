enum LivestockType {
  // โคเนื้อ
  beefCattleLocal('โคเนื้อพื้นเมือง'),
  beefCattlePurebred('โคเนื้อพันธุ์แท้'),
  beefCattleCrossbred('โคเนื้อลูกผสม'),
  
  // โคนม
  dairyCow('โคนม'),
  
  // กระบือ
  buffaloLocal('กระบือพื้นเมือง'),
  buffaloDairy('กระบือนม'),
  
  // สุกร
  pigLocal('สุกรพื้นเมือง'),
  pigBreeder('สุกรพันธุ์'),
  pigFattening('สุกรขุน'),
  
  // ไก่
  chickenLocal('ไก่พื้นเมือง'),
  chickenCrossbred('ไก่ลูกผสม'),
  chickenBroiler('ไก่เนื้อ'),
  chickenLayer('ไก่ไข่'),
  chickenBreederPS('ไก่พ่อแม่พันธุ์'),
  chickenBreederGP('ไก่ปู่ย่าพันธุ์'),
  
  // เป็ด
  duckMeat('เป็ดเนื้อ'),
  duckEgg('เป็ดไข่'),
  duckField('เป็ดไล่ทุ่ง'),
  
  // แพะ
  goatMeat('แพะเนื้อ'),
  goatDairy('แพะนม'),
  
  // แกะ
  sheep('แกะ'),
  
  // นกกระทา
  quailMeat('นกกระทาเนื้อ'),
  quailEgg('นกกระทาไข่'),
  
  // สัตว์เลี้ยง
  dog('สุนัข'),
  cat('แมว'),
  
  // อื่นๆ
  other('อื่นๆ');

  const LivestockType(this.displayName);
  final String displayName;
}

enum LivestockGender {
  male('เพศผู้'),
  female('เพศเมีย'),
  unknown('ไม่ระบุ');

  const LivestockGender(this.displayName);
  final String displayName;
}

enum LivestockStatus {
  healthy('สุขภาพดี'),
  sick('ป่วย'),
  pregnant('ตั้งท้อง'),
  lactating('ให้นม'),
  dry('แห้งนม'),
  breeding('ผสมพันธุ์'),
  fattening('ขุน'),
  sold('ขายแล้ว'),
  dead('ตาย');

  const LivestockStatus(this.displayName);
  final String displayName;
}

class Livestock {
  final String id;
  final String farmId;
  final String? name;
  final String? earTag;
  final LivestockType type;
  final String? breed;
  final LivestockGender gender;
  final DateTime? birthDate;
  final double? weight;
  final LivestockStatus status;
  final String? motherEarTag;
  final String? fatherEarTag;
  final DateTime? acquiredDate;
  final double? acquiredPrice;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Compatibility properties for new screens
  String get tagNumber => earTag ?? id;
  String get healthStatus {
    switch (status) {
      case LivestockStatus.healthy:
        return 'healthy';
      case LivestockStatus.sick:
        return 'sick';
      case LivestockStatus.pregnant:
        return 'pregnant';
      case LivestockStatus.sold:
        return 'sold';
      default:
        return 'healthy';
    }
  }

  Livestock({
    required this.id,
    required this.farmId,
    this.name,
    this.earTag,
    required this.type,
    this.breed,
    required this.gender,
    this.birthDate,
    this.weight,
    required this.status,
    this.motherEarTag,
    this.fatherEarTag,
    this.acquiredDate,
    this.acquiredPrice,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  int? get ageInMonths {
    if (birthDate == null) return null;
    final now = DateTime.now();
    return (now.difference(birthDate!).inDays / 30).round();
  }

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (earTag != null && earTag!.isNotEmpty) return 'หมายเลข: $earTag';
    return '${type.displayName} #${id.substring(0, 6)}';
  }

  factory Livestock.fromJson(Map<String, dynamic> json) {
    return Livestock(
      id: json['id'],
      farmId: json['farmId'],
      name: json['name'],
      earTag: json['earTag'],
      type: LivestockType.values.byName(json['type']),
      breed: json['breed'],
      gender: LivestockGender.values.byName(json['gender']),
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      weight: json['weight']?.toDouble(),
      status: LivestockStatus.values.byName(json['status']),
      motherEarTag: json['motherEarTag'],
      fatherEarTag: json['fatherEarTag'],
      acquiredDate: json['acquiredDate'] != null ? DateTime.parse(json['acquiredDate']) : null,
      acquiredPrice: json['acquiredPrice']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'earTag': earTag,
      'type': type.name,
      'breed': breed,
      'gender': gender.name,
      'birthDate': birthDate?.toIso8601String(),
      'weight': weight,
      'status': status.name,
      'motherEarTag': motherEarTag,
      'fatherEarTag': fatherEarTag,
      'acquiredDate': acquiredDate?.toIso8601String(),
      'acquiredPrice': acquiredPrice,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Livestock copyWith({
    String? id,
    String? farmId,
    String? name,
    String? earTag,
    LivestockType? type,
    String? breed,
    LivestockGender? gender,
    DateTime? birthDate,
    double? weight,
    LivestockStatus? status,
    String? motherEarTag,
    String? fatherEarTag,
    DateTime? acquiredDate,
    double? acquiredPrice,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Livestock(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      earTag: earTag ?? this.earTag,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      motherEarTag: motherEarTag ?? this.motherEarTag,
      fatherEarTag: fatherEarTag ?? this.fatherEarTag,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      acquiredPrice: acquiredPrice ?? this.acquiredPrice,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

