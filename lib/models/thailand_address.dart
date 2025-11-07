class Province {
  final int id;
  final String nameTh;
  final String nameEn;

  Province({
    required this.id,
    required this.nameTh,
    required this.nameEn,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] as int,
      nameTh: json['name_th'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}

class Amphoe {
  final int id;
  final String nameTh;
  final String nameEn;
  final int provinceId;

  Amphoe({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.provinceId,
  });

  factory Amphoe.fromJson(Map<String, dynamic> json) {
    return Amphoe(
      id: json['id'] as int,
      nameTh: json['name_th'] as String,
      nameEn: json['name_en'] as String,
      provinceId: json['province_id'] as int,
    );
  }
}

class Tambon {
  final int id;
  final String nameTh;
  final String nameEn;
  final int amphoeId;
  final int zipCode;

  Tambon({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.amphoeId,
    required this.zipCode,
  });

  factory Tambon.fromJson(Map<String, dynamic> json) {
    return Tambon(
      id: json['id'] as int,
      nameTh: json['name_th'] as String,
      nameEn: json['name_en'] as String,
      amphoeId: json['amphoe_id'] as int,
      zipCode: json['zip_code'] as int,
    );
  }
}
