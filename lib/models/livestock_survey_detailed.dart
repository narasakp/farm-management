// Model สำหรับข้อมูลสำรวจปศุสัตว์แบบละเอียด
// รองรับแบบฟอร์มมาตรฐานและข้อมูลผลผลิต

class LivestockSurveyDetailed {
  final String id;
  final String prefix;
  final String firstName;
  final String lastName;
  final String idCardNumber;
  final String? phoneNumber;
  
  // ที่อยู่
  final String? addressNumber;
  final String? addressVillage;
  final String? addressMoo;
  final String? addressTambon;
  final String? addressAmphoe;
  final String? addressProvince;
  
  // ข้อมูลปศุสัตว์ทั่วไป
  final String animalType;
  final int animalCount;
  
  // โคนม - กลุ่มอายุ/เพศ ตามแบบฟอร์มมาตรฐาน
  final int dairyCowFemaleUnder1Year;      // เพศเมีย แรกเกิด-1ปี
  final int dairyCowFemale1To2Years;       // เพศเมีย 1ปี-ตั้งท้องแรก
  final int dairyCowPregnantFirstTime;     // เพศเมีย โดกำลังรีดนม
  final int dairyCowLactating;             // เพศเมีย โดแห้งนม
  final int dairyCowMale;                  // เพศผู้
  
  // ผลผลิตน้ำนม
  final double dailyMilkProductionKg;      // น้ำนมที่รีดได้ ณ วันที่สำรวจ (กิโลกรัม)
  
  // สุกร - กลุ่มอายุ/เพศ ตามแบบฟอร์มมาตรฐาน
  final int pigLocalTotal;                 // สุกรพื้นเมือง (ไม่แบ่งกลุ่ม)
  final int pigBreedingMale;               // สุกรพันธุ์ พ่อพันธุ์
  final int pigBreedingFemale;             // สุกรพันธุ์ แม่พันธุ์
  final int pigFatteningYoung;             // สุกรขุน ลูกสุกรขุน
  final int pigFatteningAdult;             // สุกรขุน สุกรขุน
  final int pigBreedingYoungMale;          // ลูกสุกรพันธุ์ เพศเมีย
  final int pigBreedingYoungFemale;        // ลูกสุกรพันธุ์ เพศผู้
  
  // ข้อมูลระบบ
  final DateTime surveyDate;
  final String? surveyorId;
  final String? notes;
  final DateTime createdAt;

  LivestockSurveyDetailed({
    required this.id,
    required this.prefix,
    required this.firstName,
    required this.lastName,
    required this.idCardNumber,
    this.phoneNumber,
    this.addressNumber,
    this.addressVillage,
    this.addressMoo,
    this.addressTambon,
    this.addressAmphoe,
    this.addressProvince,
    required this.animalType,
    required this.animalCount,
    this.dairyCowFemaleUnder1Year = 0,
    this.dairyCowFemale1To2Years = 0,
    this.dairyCowPregnantFirstTime = 0,
    this.dairyCowLactating = 0,
    this.dairyCowMale = 0,
    this.dailyMilkProductionKg = 0.0,
    this.pigLocalTotal = 0,
    this.pigBreedingMale = 0,
    this.pigBreedingFemale = 0,
    this.pigFatteningYoung = 0,
    this.pigFatteningAdult = 0,
    this.pigBreedingYoungMale = 0,
    this.pigBreedingYoungFemale = 0,
    required this.surveyDate,
    this.surveyorId,
    this.notes,
    required this.createdAt,
  });

  // Getters
  String get fullName => '$prefix$firstName $lastName';
  
  String get fullAddress {
    final parts = <String>[];
    if (addressNumber?.isNotEmpty == true) parts.add('บ้านเลขที่ $addressNumber');
    if (addressVillage?.isNotEmpty == true) parts.add('บ้าน$addressVillage');
    if (addressMoo?.isNotEmpty == true) parts.add('หมู่ที่ $addressMoo');
    if (addressTambon?.isNotEmpty == true) parts.add('ตำบล$addressTambon');
    if (addressAmphoe?.isNotEmpty == true) parts.add('อำเภอ$addressAmphoe');
    if (addressProvince?.isNotEmpty == true) parts.add('จังหวัด$addressProvince');
    return parts.join(' ');
  }
  
  int get totalDairyCows => 
    dairyCowFemaleUnder1Year + 
    dairyCowFemale1To2Years + 
    dairyCowPregnantFirstTime + 
    dairyCowLactating + 
    dairyCowMale;

  // JSON Serialization
  factory LivestockSurveyDetailed.fromJson(Map<String, dynamic> json) {
    return LivestockSurveyDetailed(
      id: json['id']?.toString() ?? '',
      prefix: json['prefix'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      idCardNumber: json['id_card_number'] ?? '',
      phoneNumber: json['phone_number'],
      addressNumber: json['address_number'],
      addressVillage: json['address_village'],
      addressMoo: json['address_moo'],
      addressTambon: json['address_tambon'],
      addressAmphoe: json['address_amphoe'],
      addressProvince: json['address_province'],
      animalType: json['animal_type'] ?? '',
      animalCount: json['animal_count'] ?? 0,
      dairyCowFemaleUnder1Year: json['dairy_cow_female_under_1_year'] ?? 0,
      dairyCowFemale1To2Years: json['dairy_cow_female_1_to_2_years'] ?? 0,
      dairyCowPregnantFirstTime: json['dairy_cow_pregnant_first_time'] ?? 0,
      dairyCowLactating: json['dairy_cow_lactating'] ?? 0,
      dairyCowMale: json['dairy_cow_male'] ?? 0,
      dailyMilkProductionKg: (json['daily_milk_production_kg'] ?? 0).toDouble(),
      pigLocalTotal: json['pig_local_total'] ?? 0,
      pigBreedingMale: json['pig_breeding_male'] ?? 0,
      pigBreedingFemale: json['pig_breeding_female'] ?? 0,
      pigFatteningYoung: json['pig_fattening_young'] ?? 0,
      pigFatteningAdult: json['pig_fattening_adult'] ?? 0,
      pigBreedingYoungMale: json['pig_breeding_young_male'] ?? 0,
      pigBreedingYoungFemale: json['pig_breeding_young_female'] ?? 0,
      surveyDate: DateTime.parse(json['survey_date'] ?? DateTime.now().toIso8601String()),
      surveyorId: json['surveyor_id']?.toString(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prefix': prefix,
      'first_name': firstName,
      'last_name': lastName,
      'id_card_number': idCardNumber,
      'phone_number': phoneNumber,
      'address_number': addressNumber,
      'address_village': addressVillage,
      'address_moo': addressMoo,
      'address_tambon': addressTambon,
      'address_amphoe': addressAmphoe,
      'address_province': addressProvince,
      'animal_type': animalType,
      'animal_count': animalCount,
      'dairy_cow_female_under_1_year': dairyCowFemaleUnder1Year,
      'dairy_cow_female_1_to_2_years': dairyCowFemale1To2Years,
      'dairy_cow_pregnant_first_time': dairyCowPregnantFirstTime,
      'dairy_cow_lactating': dairyCowLactating,
      'dairy_cow_male': dairyCowMale,
      'daily_milk_production_kg': dailyMilkProductionKg,
      'pig_local_total': pigLocalTotal,
      'pig_breeding_male': pigBreedingMale,
      'pig_breeding_female': pigBreedingFemale,
      'pig_fattening_young': pigFatteningYoung,
      'pig_fattening_adult': pigFatteningAdult,
      'pig_breeding_young_male': pigBreedingYoungMale,
      'pig_breeding_young_female': pigBreedingYoungFemale,
      'survey_date': surveyDate.toIso8601String(),
      'surveyor_id': surveyorId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // สำหรับส่งข้อมูลไป API
  Map<String, dynamic> toApiJson() {
    return {
      'prefix': prefix,
      'first_name': firstName,
      'last_name': lastName,
      'id_card_number': idCardNumber,
      'phone_number': phoneNumber,
      'address_number': addressNumber,
      'address_village': addressVillage,
      'address_moo': addressMoo,
      'address_tambon': addressTambon,
      'address_amphoe': addressAmphoe,
      'address_province': addressProvince,
      'animal_type': animalType,
      'animal_count': animalCount,
      'dairy_cow_female_under_1_year': dairyCowFemaleUnder1Year,
      'dairy_cow_female_1_to_2_years': dairyCowFemale1To2Years,
      'dairy_cow_pregnant_first_time': dairyCowPregnantFirstTime,
      'dairy_cow_lactating': dairyCowLactating,
      'dairy_cow_male': dairyCowMale,
      'daily_milk_production_kg': dailyMilkProductionKg,
      'pig_local_total': pigLocalTotal,
      'pig_breeding_male': pigBreedingMale,
      'pig_breeding_female': pigBreedingFemale,
      'pig_fattening_young': pigFatteningYoung,
      'pig_fattening_adult': pigFatteningAdult,
      'pig_breeding_young_male': pigBreedingYoungMale,
      'pig_breeding_young_female': pigBreedingYoungFemale,
      'survey_date': surveyDate.toIso8601String(),
      'surveyor_id': surveyorId,
      'notes': notes,
    };
  }

  LivestockSurveyDetailed copyWith({
    String? id,
    String? prefix,
    String? firstName,
    String? lastName,
    String? idCardNumber,
    String? phoneNumber,
    String? addressNumber,
    String? addressVillage,
    String? addressMoo,
    String? addressTambon,
    String? addressAmphoe,
    String? addressProvince,
    String? animalType,
    int? animalCount,
    int? dairyCowFemaleUnder1Year,
    int? dairyCowFemale1To2Years,
    int? dairyCowPregnantFirstTime,
    int? dairyCowLactating,
    int? dairyCowMale,
    double? dailyMilkProductionKg,
    DateTime? surveyDate,
    String? surveyorId,
    String? notes,
    DateTime? createdAt,
  }) {
    return LivestockSurveyDetailed(
      id: id ?? this.id,
      prefix: prefix ?? this.prefix,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressNumber: addressNumber ?? this.addressNumber,
      addressVillage: addressVillage ?? this.addressVillage,
      addressMoo: addressMoo ?? this.addressMoo,
      addressTambon: addressTambon ?? this.addressTambon,
      addressAmphoe: addressAmphoe ?? this.addressAmphoe,
      addressProvince: addressProvince ?? this.addressProvince,
      animalType: animalType ?? this.animalType,
      animalCount: animalCount ?? this.animalCount,
      dairyCowFemaleUnder1Year: dairyCowFemaleUnder1Year ?? this.dairyCowFemaleUnder1Year,
      dairyCowFemale1To2Years: dairyCowFemale1To2Years ?? this.dairyCowFemale1To2Years,
      dairyCowPregnantFirstTime: dairyCowPregnantFirstTime ?? this.dairyCowPregnantFirstTime,
      dairyCowLactating: dairyCowLactating ?? this.dairyCowLactating,
      dairyCowMale: dairyCowMale ?? this.dairyCowMale,
      dailyMilkProductionKg: dailyMilkProductionKg ?? this.dailyMilkProductionKg,
      surveyDate: surveyDate ?? this.surveyDate,
      surveyorId: surveyorId ?? this.surveyorId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ตัวช่วยสำหรับกลุ่มอายุโคนม
class DairyCowAgeGroups {
  static const String femaleUnder1Year = 'เพศเมีย แรกเกิด-1ปี';
  static const String female1To2Years = 'เพศเมีย 1ปี-ตั้งท้องแรก';
  static const String pregnantFirstTime = 'เพศเมีย โดกำลังรีดนม';
  static const String lactating = 'เพศเมีย โดแห้งนม';
  static const String male = 'เพศผู้';
  
  static List<String> get allGroups => [
    femaleUnder1Year,
    female1To2Years,
    pregnantFirstTime,
    lactating,
    male,
  ];
  
  static String getFieldName(String ageGroup) {
    switch (ageGroup) {
      case femaleUnder1Year:
        return 'dairy_cow_female_under_1_year';
      case female1To2Years:
        return 'dairy_cow_female_1_to_2_years';
      case pregnantFirstTime:
        return 'dairy_cow_pregnant_first_time';
      case lactating:
        return 'dairy_cow_lactating';
      case male:
        return 'dairy_cow_male';
      default:
        return '';
    }
  }
}

// ตัวช่วยสำหรับกลุ่มอายุ/เพศสุกร ตามแบบฟอร์มมาตรฐาน
class PigAgeGroups {
  // สุกรพื้นเมือง - ไม่มีกลุ่มอายุ/เพศ
  static const String localPigType = 'สุกรพื้นเมือง';
  
  // สุกรพันธุ์ - 2 กลุ่ม
  static const String breedingMale = 'พ่อพันธุ์';
  static const String breedingFemale = 'แม่พันธุ์';
  
  // สุกรขุน - 2 กลุ่ม  
  static const String fatteningYoung = 'ลูกสุกรขุน';
  static const String fatteningAdult = 'สุกรขุน';
  
  // ลูกสุกรพันธุ์ - 2 กลุ่ม
  static const String breedingYoungMale = 'เพศเมีย';
  static const String breedingYoungFemale = 'เพศผู้';
  
  static List<String> getGroupsForPigType(String pigType) {
    switch (pigType) {
      case 'สุกรพื้นเมือง':
        return []; // ไม่มีกลุ่มอายุ/เพศ
      case 'สุกรพันธุ์':
        return [breedingMale, breedingFemale];
      case 'สุกรขุน':
        return [fatteningYoung, fatteningAdult];
      case 'ลูกสุกรพันธุ์':
        return [breedingYoungMale, breedingYoungFemale];
      default:
        return [];
    }
  }
  
  static String getFieldName(String pigType, String ageGroup) {
    switch (pigType) {
      case 'สุกรพื้นเมือง':
        return 'pig_local_total';
      case 'สุกรพันธุ์':
        switch (ageGroup) {
          case breedingMale:
            return 'pig_breeding_male';
          case breedingFemale:
            return 'pig_breeding_female';
          default:
            return '';
        }
      case 'สุกรขุน':
        switch (ageGroup) {
          case fatteningYoung:
            return 'pig_fattening_young';
          case fatteningAdult:
            return 'pig_fattening_adult';
          default:
            return '';
        }
      case 'ลูกสุกรพันธุ์':
        switch (ageGroup) {
          case breedingYoungMale:
            return 'pig_breeding_young_male';
          case breedingYoungFemale:
            return 'pig_breeding_young_female';
          default:
            return '';
        }
      default:
        return '';
    }
  }
  
  static bool requiresAgeGroups(String pigType) {
    return pigType != 'สุกรพื้นเมือง';
  }
}
