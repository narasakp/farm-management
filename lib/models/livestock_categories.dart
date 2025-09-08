// Extended livestock categories and specialized data models

class LivestockCategory {
  final String id;
  final String name;
  final String description;
  final List<String> applicableTypes;
  final Map<String, dynamic> defaultAttributes;

  LivestockCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.applicableTypes,
    required this.defaultAttributes,
  });
}

// Specialized data for different livestock types
class QuailData {
  final String livestockId;
  final QuailPurpose purpose;
  final int eggProductionPerDay;
  final double averageEggWeight;
  final QuailBreed breed;
  final int flockSize;
  final String housingType;
  final double feedConsumptionPerDay;
  final DateTime? lastEggCollection;

  QuailData({
    required this.livestockId,
    required this.purpose,
    this.eggProductionPerDay = 0,
    this.averageEggWeight = 0.0,
    required this.breed,
    this.flockSize = 1,
    required this.housingType,
    this.feedConsumptionPerDay = 0.0,
    this.lastEggCollection,
  });

  Map<String, dynamic> toJson() {
    return {
      'livestockId': livestockId,
      'purpose': purpose.toString(),
      'eggProductionPerDay': eggProductionPerDay,
      'averageEggWeight': averageEggWeight,
      'breed': breed.toString(),
      'flockSize': flockSize,
      'housingType': housingType,
      'feedConsumptionPerDay': feedConsumptionPerDay,
      'lastEggCollection': lastEggCollection?.toIso8601String(),
    };
  }

  factory QuailData.fromJson(Map<String, dynamic> json) {
    return QuailData(
      livestockId: json['livestockId'],
      purpose: QuailPurpose.values.firstWhere((e) => e.toString() == json['purpose']),
      eggProductionPerDay: json['eggProductionPerDay'] ?? 0,
      averageEggWeight: json['averageEggWeight']?.toDouble() ?? 0.0,
      breed: QuailBreed.values.firstWhere((e) => e.toString() == json['breed']),
      flockSize: json['flockSize'] ?? 1,
      housingType: json['housingType'],
      feedConsumptionPerDay: json['feedConsumptionPerDay']?.toDouble() ?? 0.0,
      lastEggCollection: json['lastEggCollection'] != null 
          ? DateTime.parse(json['lastEggCollection']) 
          : null,
    );
  }
}

enum QuailPurpose {
  egg,      // ไข่
  meat,     // เนื้อ
  breeding, // พันธุ์
  mixed,    // ผสม
}

enum QuailBreed {
  japanese,     // ญี่ปุ่น
  coturnix,     // คอเทอร์นิกซ์
  bobwhite,     // บ็อบไวท์
  pharaoh,      // ฟาโรห์
  tuxedo,       // ทักซิโด้
  local,        // พื้นเมือง
}

class PetData {
  final String livestockId;
  final PetType petType;
  final String breed;
  final PetSize size;
  final List<String> vaccinations;
  final DateTime? lastVetVisit;
  final String? microchipId;
  final bool isNeutered;
  final List<String> specialNeeds;
  final String? insurancePolicy;

  PetData({
    required this.livestockId,
    required this.petType,
    required this.breed,
    required this.size,
    required this.vaccinations,
    this.lastVetVisit,
    this.microchipId,
    this.isNeutered = false,
    required this.specialNeeds,
    this.insurancePolicy,
  });

  Map<String, dynamic> toJson() {
    return {
      'livestockId': livestockId,
      'petType': petType.toString(),
      'breed': breed,
      'size': size.toString(),
      'vaccinations': vaccinations,
      'lastVetVisit': lastVetVisit?.toIso8601String(),
      'microchipId': microchipId,
      'isNeutered': isNeutered,
      'specialNeeds': specialNeeds,
      'insurancePolicy': insurancePolicy,
    };
  }

  factory PetData.fromJson(Map<String, dynamic> json) {
    return PetData(
      livestockId: json['livestockId'],
      petType: PetType.values.firstWhere((e) => e.toString() == json['petType']),
      breed: json['breed'],
      size: PetSize.values.firstWhere((e) => e.toString() == json['size']),
      vaccinations: List<String>.from(json['vaccinations']),
      lastVetVisit: json['lastVetVisit'] != null 
          ? DateTime.parse(json['lastVetVisit']) 
          : null,
      microchipId: json['microchipId'],
      isNeutered: json['isNeutered'] ?? false,
      specialNeeds: List<String>.from(json['specialNeeds']),
      insurancePolicy: json['insurancePolicy'],
    );
  }
}

enum PetType {
  dog,      // สุนัข
  cat,      // แมว
  rabbit,   // กระต่าย
  hamster,  // หนูแฮมสเตอร์
  bird,     // นก
  fish,     // ปลา
}

enum PetSize {
  tiny,     // เล็กมาก
  small,    // เล็ก
  medium,   // กลาง
  large,    // ใหญ่
  giant,    // ใหญ่มาก
}

class AquacultureData {
  final String livestockId;
  final AquacultureType aquaType;
  final String species;
  final WaterType waterType;
  final double tankVolume;
  final int stockingDensity;
  final double waterTemperature;
  final double pH;
  final double dissolvedOxygen;
  final String feedType;
  final double feedingRate;
  final DateTime? lastWaterChange;

  AquacultureData({
    required this.livestockId,
    required this.aquaType,
    required this.species,
    required this.waterType,
    required this.tankVolume,
    required this.stockingDensity,
    this.waterTemperature = 0.0,
    this.pH = 7.0,
    this.dissolvedOxygen = 0.0,
    required this.feedType,
    this.feedingRate = 0.0,
    this.lastWaterChange,
  });

  Map<String, dynamic> toJson() {
    return {
      'livestockId': livestockId,
      'aquaType': aquaType.toString(),
      'species': species,
      'waterType': waterType.toString(),
      'tankVolume': tankVolume,
      'stockingDensity': stockingDensity,
      'waterTemperature': waterTemperature,
      'pH': pH,
      'dissolvedOxygen': dissolvedOxygen,
      'feedType': feedType,
      'feedingRate': feedingRate,
      'lastWaterChange': lastWaterChange?.toIso8601String(),
    };
  }

  factory AquacultureData.fromJson(Map<String, dynamic> json) {
    return AquacultureData(
      livestockId: json['livestockId'],
      aquaType: AquacultureType.values.firstWhere((e) => e.toString() == json['aquaType']),
      species: json['species'],
      waterType: WaterType.values.firstWhere((e) => e.toString() == json['waterType']),
      tankVolume: json['tankVolume'].toDouble(),
      stockingDensity: json['stockingDensity'],
      waterTemperature: json['waterTemperature']?.toDouble() ?? 0.0,
      pH: json['pH']?.toDouble() ?? 7.0,
      dissolvedOxygen: json['dissolvedOxygen']?.toDouble() ?? 0.0,
      feedType: json['feedType'],
      feedingRate: json['feedingRate']?.toDouble() ?? 0.0,
      lastWaterChange: json['lastWaterChange'] != null 
          ? DateTime.parse(json['lastWaterChange']) 
          : null,
    );
  }
}

enum AquacultureType {
  fish,     // ปลา
  shrimp,   // กุ้ง
  crab,     // ปู
  shellfish, // หอย
}

enum WaterType {
  freshwater,   // น้ำจืด
  saltwater,    // น้ำเค็ม
  brackish,     // น้ำกร่อย
}

class InsectData {
  final String livestockId;
  final InsectType insectType;
  final String species;
  final InsectStage currentStage;
  final int populationSize;
  final String housingType;
  final double temperature;
  final double humidity;
  final String feedType;
  final double feedConsumption;
  final DateTime? lastHarvest;
  final double harvestWeight;

  InsectData({
    required this.livestockId,
    required this.insectType,
    required this.species,
    required this.currentStage,
    required this.populationSize,
    required this.housingType,
    this.temperature = 0.0,
    this.humidity = 0.0,
    required this.feedType,
    this.feedConsumption = 0.0,
    this.lastHarvest,
    this.harvestWeight = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'livestockId': livestockId,
      'insectType': insectType.toString(),
      'species': species,
      'currentStage': currentStage.toString(),
      'populationSize': populationSize,
      'housingType': housingType,
      'temperature': temperature,
      'humidity': humidity,
      'feedType': feedType,
      'feedConsumption': feedConsumption,
      'lastHarvest': lastHarvest?.toIso8601String(),
      'harvestWeight': harvestWeight,
    };
  }

  factory InsectData.fromJson(Map<String, dynamic> json) {
    return InsectData(
      livestockId: json['livestockId'],
      insectType: InsectType.values.firstWhere((e) => e.toString() == json['insectType']),
      species: json['species'],
      currentStage: InsectStage.values.firstWhere((e) => e.toString() == json['currentStage']),
      populationSize: json['populationSize'],
      housingType: json['housingType'],
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      feedType: json['feedType'],
      feedConsumption: json['feedConsumption']?.toDouble() ?? 0.0,
      lastHarvest: json['lastHarvest'] != null 
          ? DateTime.parse(json['lastHarvest']) 
          : null,
      harvestWeight: json['harvestWeight']?.toDouble() ?? 0.0,
    );
  }
}

enum InsectType {
  cricket,    // จิ้งหรีด
  silkworm,   // หนอนไหม
  bee,        // ผึ้ง
  mealworm,   // หนอนแป้ง
  blackfly,   // แมลงวันดำ
}

enum InsectStage {
  egg,        // ไข่
  larva,      // ตัวหนอน
  pupa,       // ดักแด้
  adult,      // ตัวเต็มวัย
}

// Extension methods for display names
extension QuailPurposeExtension on QuailPurpose {
  String get displayName {
    switch (this) {
      case QuailPurpose.egg:
        return 'ไข่';
      case QuailPurpose.meat:
        return 'เนื้อ';
      case QuailPurpose.breeding:
        return 'พันธุ์';
      case QuailPurpose.mixed:
        return 'ผสม';
    }
  }
}

extension QuailBreedExtension on QuailBreed {
  String get displayName {
    switch (this) {
      case QuailBreed.japanese:
        return 'ญี่ปุ่น';
      case QuailBreed.coturnix:
        return 'คอเทอร์นิกซ์';
      case QuailBreed.bobwhite:
        return 'บ็อบไวท์';
      case QuailBreed.pharaoh:
        return 'ฟาโรห์';
      case QuailBreed.tuxedo:
        return 'ทักซิโด้';
      case QuailBreed.local:
        return 'พื้นเมือง';
    }
  }
}

extension PetTypeExtension on PetType {
  String get displayName {
    switch (this) {
      case PetType.dog:
        return 'สุนัข';
      case PetType.cat:
        return 'แมว';
      case PetType.rabbit:
        return 'กระต่าย';
      case PetType.hamster:
        return 'หนูแฮมสเตอร์';
      case PetType.bird:
        return 'นก';
      case PetType.fish:
        return 'ปลา';
    }
  }
}

extension PetSizeExtension on PetSize {
  String get displayName {
    switch (this) {
      case PetSize.tiny:
        return 'เล็กมาก';
      case PetSize.small:
        return 'เล็ก';
      case PetSize.medium:
        return 'กลาง';
      case PetSize.large:
        return 'ใหญ่';
      case PetSize.giant:
        return 'ใหญ่มาก';
    }
  }
}

extension AquacultureTypeExtension on AquacultureType {
  String get displayName {
    switch (this) {
      case AquacultureType.fish:
        return 'ปลา';
      case AquacultureType.shrimp:
        return 'กุ้ง';
      case AquacultureType.crab:
        return 'ปู';
      case AquacultureType.shellfish:
        return 'หอย';
    }
  }
}

extension WaterTypeExtension on WaterType {
  String get displayName {
    switch (this) {
      case WaterType.freshwater:
        return 'น้ำจืด';
      case WaterType.saltwater:
        return 'น้ำเค็ม';
      case WaterType.brackish:
        return 'น้ำกร่อย';
    }
  }
}

extension InsectTypeExtension on InsectType {
  String get displayName {
    switch (this) {
      case InsectType.cricket:
        return 'จิ้งหรีด';
      case InsectType.silkworm:
        return 'หนอนไหม';
      case InsectType.bee:
        return 'ผึ้ง';
      case InsectType.mealworm:
        return 'หนอนแป้ง';
      case InsectType.blackfly:
        return 'แมลงวันดำ';
    }
  }
}

extension InsectStageExtension on InsectStage {
  String get displayName {
    switch (this) {
      case InsectStage.egg:
        return 'ไข่';
      case InsectStage.larva:
        return 'ตัวหนอน';
      case InsectStage.pupa:
        return 'ดักแด้';
      case InsectStage.adult:
        return 'ตัวเต็มวัย';
    }
  }
}
