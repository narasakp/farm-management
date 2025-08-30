class FarmRecord {
  final String id;
  final String name;
  final String location;
  final String ownerName;
  final String phoneNumber;
  final double area; // ขนาดพื้นที่ (ไร่)
  final String farmType; // ประเภทฟาร์ม
  final int livestockCount;
  final DateTime establishedDate;
  final String status; // 'active', 'inactive', 'maintenance'
  final String? description;

  FarmRecord({
    required this.id,
    required this.name,
    required this.location,
    required this.ownerName,
    required this.phoneNumber,
    required this.area,
    required this.farmType,
    required this.livestockCount,
    required this.establishedDate,
    required this.status,
    this.description,
  });

  factory FarmRecord.fromJson(Map<String, dynamic> json) {
    return FarmRecord(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      ownerName: json['ownerName'],
      phoneNumber: json['phoneNumber'],
      area: json['area'].toDouble(),
      farmType: json['farmType'],
      livestockCount: json['livestockCount'],
      establishedDate: DateTime.parse(json['establishedDate']),
      status: json['status'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'area': area,
      'farmType': farmType,
      'livestockCount': livestockCount,
      'establishedDate': establishedDate.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}
