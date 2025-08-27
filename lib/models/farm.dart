class Farm {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String tambon;
  final String amphoe;
  final String province;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final double? areaSize;
  final String? farmType;
  final String? registrationNumber;
  final DateTime? registrationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Farm({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.tambon,
    required this.amphoe,
    required this.province,
    required this.postalCode,
    this.latitude,
    this.longitude,
    this.areaSize,
    this.farmType,
    this.registrationNumber,
    this.registrationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'],
      address: json['address'],
      tambon: json['tambon'],
      amphoe: json['amphoe'],
      province: json['province'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      areaSize: json['areaSize']?.toDouble(),
      farmType: json['farmType'],
      registrationNumber: json['registrationNumber'],
      registrationDate: json['registrationDate'] != null 
          ? DateTime.parse(json['registrationDate']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'tambon': tambon,
      'amphoe': amphoe,
      'province': province,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'areaSize': areaSize,
      'farmType': farmType,
      'registrationNumber': registrationNumber,
      'registrationDate': registrationDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullAddress {
    return '$address ต.$tambon อ.$amphoe จ.$province $postalCode';
  }
}

class Farmer {
  final String id;
  final String prefix;
  final String firstName;
  final String lastName;
  final String idCard;
  final String phoneNumber;
  final String? email;
  final String address;
  final String tambon;
  final String amphoe;
  final String province;
  final DateTime? birthDate;
  final String? occupation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Farmer({
    required this.id,
    required this.prefix,
    required this.firstName,
    required this.lastName,
    required this.idCard,
    required this.phoneNumber,
    this.email,
    required this.address,
    required this.tambon,
    required this.amphoe,
    required this.province,
    this.birthDate,
    this.occupation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      prefix: json['prefix'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      idCard: json['idCard'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      tambon: json['tambon'],
      amphoe: json['amphoe'],
      province: json['province'],
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate']) 
          : null,
      occupation: json['occupation'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prefix': prefix,
      'firstName': firstName,
      'lastName': lastName,
      'idCard': idCard,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'tambon': tambon,
      'amphoe': amphoe,
      'province': province,
      'birthDate': birthDate?.toIso8601String(),
      'occupation': occupation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName {
    return '$prefix$firstName $lastName';
  }

  String get fullAddress {
    return '$address ต.$tambon อ.$amphoe จ.$province';
  }
}
