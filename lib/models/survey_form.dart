import 'livestock.dart';

// แบบฟอร์มสำรวจดิจิทัลตาม PRD
class FarmSurvey {
  final String id;
  final String farmerId;
  final String surveyorId;
  final DateTime surveyDate;
  final FarmerInfo farmerInfo;
  final List<LivestockSurveyData> livestockData;
  final double? cropArea; // พื้นที่พืชอาหารสัตว์ (ไร่)
  final String? notes;
  final String? gpsLocation;
  final DateTime createdAt;

  FarmSurvey({
    required this.id,
    required this.farmerId,
    required this.surveyorId,
    required this.surveyDate,
    required this.farmerInfo,
    required this.livestockData,
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
      surveyDate: DateTime.parse(json['surveyDate']),
      farmerInfo: FarmerInfo.fromJson(json['farmerInfo']),
      livestockData: (json['livestockData'] as List)
          .map((e) => LivestockSurveyData.fromJson(e))
          .toList(),
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
      'surveyDate': surveyDate.toIso8601String(),
      'farmerInfo': farmerInfo.toJson(),
      'livestockData': livestockData.map((e) => e.toJson()).toList(),
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

  FarmerInfo({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.idCard,
    required this.phoneNumber,
    required this.address,
  });

  factory FarmerInfo.fromJson(Map<String, dynamic> json) {
    return FarmerInfo(
      title: json['title'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      idCard: json['idCard'],
      phoneNumber: json['phoneNumber'],
      address: FarmerAddress.fromJson(json['address']),
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
    if (postalCode != null) parts.add(postalCode!);
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
          'แรกเกิด-1ปี',
          '1ปี-ตั้งท้องแรก',
          'กำลังรีดนม',
          'แห้งนม',
          'พ่อพันธุ์'
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
      case LivestockType.pigBreeder:
      case LivestockType.pigFattening:
        return [
          'พ่อพันธุ์',
          'แม่พันธุ์',
          'ลูกสุกรขุน',
          'สุกรขุน',
          'ลูกสุกรพันธุ์ เพศเมีย',
          'ลูกสุกรพันธุ์ เพศผู้'
        ];
      default:
        return ['เพศผู้', 'เพศเมีย'];
    }
  }

  static bool requiresMilkProduction(LivestockType type) {
    return type == LivestockType.dairyCow || type == LivestockType.buffaloDairy || type == LivestockType.goatDairy;
  }
}
