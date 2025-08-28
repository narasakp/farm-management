// Extended livestock types and breeds based on PRD requirements

enum LivestockBreed {
  // โคเนื้อ
  beefCattleLocal('โคเนื้อพื้นเมือง'),
  beefCattlePurebred('โคเนื้อพันธุ์แท้'),
  beefCattleCrossbred('โคเนื้อลูกผสม'),
  
  // โคนม
  dairyCattle('โคนม'),
  
  // กระบือ
  buffaloLocal('กระบือพื้นเมือง'),
  buffaloDairy('กระบือนม'),
  
  // สุกร
  pigLocal('สุกรพื้นเมือง'),
  pigBreeding('สุกรพันธุ์'),
  pigFattening('สุกรขุน'),
  
  // ไก่
  chickenLocal('ไก่พื้นเมือง'),
  chickenCrossbred('ไก่ลูกผสม'),
  chickenBroiler('ไก่เนื้อ (Broiler)'),
  chickenLayer('ไก่ไข่ (Layer)'),
  chickenParentStockBroiler('ไก่พ่อ-แม่พันธุ์ผลิตลูกไก่เนื้อ (PS)'),
  chickenParentStockLayer('ไก่พ่อ-แม่พันธุ์ผลิตลูกไก่ไข่ (PS)'),
  chickenGrandparentBroiler('ไก่ปู่-ย่าพันธุ์ผลิตลูกไก่เนื้อ (GP)'),
  chickenGrandparentLayer('ไก่ปู่-ย่าพันธุ์ผลิตลูกไก่ไข่ (GP)'),
  
  // เป็ด
  duckMuscovy('เป็ดเทศ'),
  duckMeat('เป็ดเนื้อ'),
  duckEgg('เป็ดไข่'),
  duckMeatFreeRange('เป็ดเนื้อไล่ทุ่ง'),
  duckEggFreeRange('เป็ดไข่ไล่ทุ่ง'),
  
  // แพะ
  goatMeat('แพะเนื้อ'),
  goatDairy('แพะนม'),
  
  // แกะ
  sheep('แกะ'),
  
  // นกกระทา
  quailMeat('นกกระทาพันธุ์เนื้อ'),
  quailEgg('นกกระทาพันธุ์ไข่'),
  
  // สัตว์เลี้ยงและอื่นๆ
  dog('สุนัข'),
  cat('แมว'),
  other('อื่นๆ');

  const LivestockBreed(this.displayName);
  final String displayName;
}

enum LivestockAgeGroup {
  // โคเนื้อ/กระบือ
  calfMale('เพศผู้'),
  calfFemaleYoung('เพศเมีย (แรกเกิด-โคสาว)'),
  calfFemalePregnant('เพศเมีย (ตั้งท้องแรกขึ้นไป)'),
  
  // โคนม
  dairyFemaleYoung('แรกเกิด-1ปี'),
  dairyFemaleHeifer('1ปี-ตั้งท้องแรก'),
  dairyFemaleLactating('กำลังรีดนม'),
  dairyFemaleDry('แห้งนม'),
  dairyMaleBull('พ่อพันธุ์'),
  
  // สุกร
  pigletMale('ลูกสุกรพันธุ์เพศผู้'),
  pigletFemale('ลูกสุกรพันธุ์เพศเมีย'),
  pigFatteningYoung('ลูกสุกรขุน'),
  pigFatteningAdult('สุกรขุน'),
  pigBreedingMale('พ่อพันธุ์'),
  pigBreedingFemale('แม่พันธุ์'),
  
  // แพะ/แกะ
  goatMale('เพศผู้'),
  goatFemaleYoung('เพศเมีย (แรกเกิด-แพะสาว)'),
  goatFemalePregnant('เพศเมีย (ตั้งท้องแรกขึ้นไป)'),
  
  sheepMale('เพศผู้'),
  sheepFemaleYoung('แรกเกิด-แกะสาว'),
  sheepFemalePregnant('ตั้งท้องแรกขึ้นไป'),
  
  // ทั่วไป
  adult('โตเต็มวัย'),
  young('อ่อนวัย'),
  unknown('ไม่ระบุ');

  const LivestockAgeGroup(this.displayName);
  final String displayName;
}

class LivestockTypeHelper {
  static List<LivestockBreed> getBreedsForType(LivestockType type) {
    switch (type) {
      case LivestockType.cattle:
        return [
          LivestockBreed.beefCattleLocal,
          LivestockBreed.beefCattlePurebred,
          LivestockBreed.beefCattleCrossbred,
          LivestockBreed.dairyCattle,
        ];
      case LivestockType.buffalo:
        return [
          LivestockBreed.buffaloLocal,
          LivestockBreed.buffaloDairy,
        ];
      case LivestockType.pig:
        return [
          LivestockBreed.pigLocal,
          LivestockBreed.pigBreeding,
          LivestockBreed.pigFattening,
        ];
      case LivestockType.chicken:
        return [
          LivestockBreed.chickenLocal,
          LivestockBreed.chickenCrossbred,
          LivestockBreed.chickenBroiler,
          LivestockBreed.chickenLayer,
          LivestockBreed.chickenParentStockBroiler,
          LivestockBreed.chickenParentStockLayer,
          LivestockBreed.chickenGrandparentBroiler,
          LivestockBreed.chickenGrandparentLayer,
        ];
      case LivestockType.duck:
        return [
          LivestockBreed.duckMuscovy,
          LivestockBreed.duckMeat,
          LivestockBreed.duckEgg,
          LivestockBreed.duckMeatFreeRange,
          LivestockBreed.duckEggFreeRange,
        ];
      case LivestockType.goat:
        return [
          LivestockBreed.goatMeat,
          LivestockBreed.goatDairy,
        ];
      case LivestockType.sheep:
        return [LivestockBreed.sheep];
      default:
        return [LivestockBreed.other];
    }
  }

  static List<LivestockAgeGroup> getAgeGroupsForType(LivestockType type) {
    switch (type) {
      case LivestockType.cattle:
        return [
          LivestockAgeGroup.calfMale,
          LivestockAgeGroup.calfFemaleYoung,
          LivestockAgeGroup.calfFemalePregnant,
          LivestockAgeGroup.dairyFemaleYoung,
          LivestockAgeGroup.dairyFemaleHeifer,
          LivestockAgeGroup.dairyFemaleLactating,
          LivestockAgeGroup.dairyFemaleDry,
          LivestockAgeGroup.dairyMaleBull,
        ];
      case LivestockType.buffalo:
        return [
          LivestockAgeGroup.calfMale,
          LivestockAgeGroup.calfFemaleYoung,
          LivestockAgeGroup.calfFemalePregnant,
        ];
      case LivestockType.pig:
        return [
          LivestockAgeGroup.pigletMale,
          LivestockAgeGroup.pigletFemale,
          LivestockAgeGroup.pigFatteningYoung,
          LivestockAgeGroup.pigFatteningAdult,
          LivestockAgeGroup.pigBreedingMale,
          LivestockAgeGroup.pigBreedingFemale,
        ];
      case LivestockType.goat:
        return [
          LivestockAgeGroup.goatMale,
          LivestockAgeGroup.goatFemaleYoung,
          LivestockAgeGroup.goatFemalePregnant,
        ];
      case LivestockType.sheep:
        return [
          LivestockAgeGroup.sheepMale,
          LivestockAgeGroup.sheepFemaleYoung,
          LivestockAgeGroup.sheepFemalePregnant,
        ];
      default:
        return [
          LivestockAgeGroup.adult,
          LivestockAgeGroup.young,
          LivestockAgeGroup.unknown,
        ];
    }
  }

  static bool requiresMilkProduction(LivestockType type, LivestockBreed? breed) {
    return type == LivestockType.cattle && breed == LivestockBreed.dairyCattle ||
           type == LivestockType.buffalo && breed == LivestockBreed.buffaloDairy ||
           type == LivestockType.goat && breed == LivestockBreed.goatDairy;
  }
}
