import 'livestock.dart';

// แบบฟอร์มสำรวจดิจิทัลตาม PRD
class FarmSurvey {
  final String id;
  final String farmerId;
  final String surveyorId;
  final String? surveyorName; // ชื่อผู้สำรวจ (display_name หรือ username)
  final String? surveyorRole; // role ของผู้สำรวจ
  final DateTime surveyDate;
  final FarmerInfo farmerInfo;
  final List<LivestockSurveyData> livestockData;
  final double? farmArea; // ขนาดพื้นที่ฟาร์ม (ไร่)
  final double? cropArea; // พื้นที่ปลูกพืชอาหารสัตว์ (ไร่)
  final String? notes;
  final String? gpsLocation;
  final DateTime createdAt;

  FarmSurvey({
    required this.id,
    required this.farmerId,
    required this.surveyorId,
    this.surveyorName,
    this.surveyorRole,
    required this.surveyDate,
    required this.farmerInfo,
    required this.livestockData,
    this.farmArea,
    this.cropArea,
    this.notes,
    this.gpsLocation,
    required this.createdAt,
  });

  factory FarmSurvey.fromJson(Map<String, dynamic> json) {
    return FarmSurvey(
      id: json['id'],
      farmerId: json['farmerId'],
      surveyorId: json['surveyorId'],
      surveyorName: json['surveyorName'],
      surveyorRole: json['surveyorRole'],
      surveyDate: DateTime.parse(json['surveyDate']),
      farmerInfo: FarmerInfo.fromJson(json['farmerInfo']),
      livestockData: (json['livestockData'] as List)
          .map((e) => LivestockSurveyData.fromJson(e))
          .toList(),
      farmArea: json['farmArea']?.toDouble(),
      cropArea: json['cropArea']?.toDouble(),
      notes: json['notes'],
      gpsLocation: json['gpsLocation'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'surveyorId': surveyorId,
      'surveyorName': surveyorName,
      'surveyorRole': surveyorRole,
      'surveyDate': surveyDate.toIso8601String(),
      'farmerInfo': farmerInfo.toJson(),
      'livestockData': livestockData.map((e) => e.toJson()).toList(),
      'farmArea': farmArea,
      'cropArea': cropArea,
      'notes': notes,
      'gpsLocation': gpsLocation,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class FarmerInfo {
  final String title; // คำนำหน้า
  final String firstName;
  final String lastName;
  final String idCard; // เลขบัตรประจำตัว
  final String phoneNumber;
  final FarmerAddress address;
  final String? photoBase64; // รูปภาพเกษตรกร (Base64)

  FarmerInfo({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.idCard,
    required this.phoneNumber,
    required this.address,
    this.photoBase64,
  });

  String get fullName => '$title$firstName $lastName';

  factory FarmerInfo.fromJson(Map<String, dynamic> json) {
    return FarmerInfo(
      title: json['title'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      idCard: json['idCard'],
      phoneNumber: json['phoneNumber'],
      address: FarmerAddress.fromJson(json['address']),
      photoBase64: json['photoBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
      'idCard': idCard,
      'phoneNumber': phoneNumber,
      'address': address.toJson(),
      'photoBase64': photoBase64,
    };
  }
}

class FarmerAddress {
  final String houseNumber; // บ้านเลขที่
  final String? village; // บ้าน
  final String moo; // หมู่ที่
  final String tambon; // ตำบล
  final String amphoe; // อำเภอ
  final String province; // จังหวัด
  final String? postalCode;

  FarmerAddress({
    required this.houseNumber,
    this.village,
    required this.moo,
    required this.tambon,
    required this.amphoe,
    required this.province,
    this.postalCode,
  });

  factory FarmerAddress.fromJson(Map<String, dynamic> json) {
    return FarmerAddress(
      houseNumber: json['houseNumber'],
      village: json['village'],
      moo: json['moo'],
      tambon: json['tambon'],
      amphoe: json['amphoe'],
      province: json['province'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'houseNumber': houseNumber,
      'village': village,
      'moo': moo,
      'tambon': tambon,
      'amphoe': amphoe,
      'province': province,
      'postalCode': postalCode,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    parts.add('บ้านเลขที่ $houseNumber');
    if (village != null && village!.isNotEmpty) parts.add('บ้าน$village');
    parts.add('หมู่ที่ $moo');
    parts.add('ตำบล$tambon');
    parts.add('อำเภอ$amphoe');
    parts.add('จังหวัด$province');
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!); // รหัสไปรษณีย์ต่อท้ายจังหวัด
    }
    return parts.join(' ');
  }
  
  /// ที่อยู่ที่ mask ตาม role (ซ่อน บ้านเลขที่, บ้าน, หมู่ที่)
  /// ใช้สำหรับ OFFICER และ RESEARCHER
  String get maskedAddress {
    final parts = <String>[];
    parts.add('ตำบล$tambon');
    parts.add('อำเภอ$amphoe');
    parts.add('จังหวัด$province');
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    return parts.join(' ');
  }
}

class LivestockSurveyData {
  final LivestockType type;
  final String? breed;
  final LivestockGender? gender;
  final String? ageGroup; // แรกเกิด-1ปี, 1ปี-ตั้งท้องแรก, etc.
  final int count;
  final double? dailyMilkProduction; // สำหรับโคนม (กก./วัน)
  final String? notes;

  LivestockSurveyData({
    required this.type,
    this.breed,
    this.gender,
    this.ageGroup,
    required this.count,
    this.dailyMilkProduction,
    this.notes,
  });

  factory LivestockSurveyData.fromJson(Map<String, dynamic> json) {
    return LivestockSurveyData(
      type: LivestockType.values.byName(json['type']),
      breed: json['breed'],
      gender: json['gender'] != null ? LivestockGender.values.byName(json['gender']) : null,
      ageGroup: json['ageGroup'],
      count: json['count'],
      dailyMilkProduction: json['dailyMilkProduction']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'breed': breed,
      'gender': gender?.name,
      'ageGroup': ageGroup,
      'count': count,
      'dailyMilkProduction': dailyMilkProduction,
      'notes': notes,
    };
  }
}

// Survey Templates สำหรับแต่ละประเภทปศุสัตว์
class SurveyTemplate {
  static List<String> getAgeGroupsForType(LivestockType type) {
    switch (type) {
      case LivestockType.dairyCow:
        return [
          'เพศเมีย แรกเกิด-1ปี',
          'เพศเมีย 1ปี-ตั้งท้องแรก',
          'เพศเมีย โคกำลังรีดนม',
          'เพศเมีย โคแห้งนม',
          'เพศผู้'
        ];
      case LivestockType.beefCattleLocal:
      case LivestockType.beefCattlePurebred:
      case LivestockType.beefCattleCrossbred:
        return [
          'เพศผู้',
          'เพศเมีย (แรกเกิด-โคสาว)',
          'เพศเมีย (ตั้งท้องแรกขึ้นไป)'
        ];
      case LivestockType.buffaloLocal:
      case LivestockType.buffaloDairy:
        return [
          'เพศผู้',
          'เพศเมีย (แรกเกิด-กระบือสาว)',
          'เพศเมีย (ตั้งท้องแรกขึ้นไป)'
        ];
      case LivestockType.goatMeat:
      case LivestockType.goatDairy:
        return [
          'เพศผู้',
          'เพศเมีย (แรกเกิด-แพะสาว)',
          'เพศเมีย (ตั้งท้องแรกขึ้นไป)'
        ];
      case LivestockType.sheep:
        return [
          'เพศผู้',
          'เพศเมีย (แรกเกิด-แกะสาว)',
          'เพศเมีย (ตั้งท้องแรกขึ้นไป)'
        ];
      case LivestockType.pigLocal:
        return []; // ไม่ต้องมีกลุ่มอายุ/เพศ
      case LivestockType.pigBreeder:
        return [
          'พ่อพันธุ์',
          'แม่พันธุ์',
        ];
      case LivestockType.pigFattening:
        return [
          'ลูกสุกรขุน',
          'สุกรขุน',
        ];
      case LivestockType.pigBreederYoung:
        return [
          'เพศเมีย',
          'เพศผู้',
        ];
      case LivestockType.quailMeat:
      case LivestockType.quailEgg:
        return []; // ไม่ต้องมีกลุ่มอายุ/เพศ
      case LivestockType.duckMuscovy:
      case LivestockType.duckMeat:
      case LivestockType.duckEgg:
      case LivestockType.duckMeatField:
      case LivestockType.duckEggField:
        return []; // เป็ดทั้ง 5 ประเภทไม่ต้องมีกลุ่มอายุ/เพศ
      case LivestockType.chickenLocal:
      case LivestockType.chickenCrossbred:
      case LivestockType.chickenBroiler:
      case LivestockType.chickenLayer:
      case LivestockType.chickenBreederMeatPS:
      case LivestockType.chickenBreederLayerPS:
      case LivestockType.chickenBreederMeatGP:
      case LivestockType.chickenBreederLayerGP:
        return []; // ไก่ทั้ง 8 ประเภทไม่ต้องมีกลุ่มอายุ/เพศ
      default:
        return ['เพศผู้', 'เพศเมีย'];
    }
  }

  static bool requiresMilkProduction(LivestockType type) {
    return type == LivestockType.dairyCow || type == LivestockType.buffaloDairy || type == LivestockType.goatDairy;
  }
}
