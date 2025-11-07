import 'package:cloud_firestore/cloud_firestore.dart';
import 'market_schedule.dart';
import 'market_zone.dart';

/// ตลาดนัด - สถานที่ขายสัตว์
class Market {
  final String id;
  final String name;                        // 'ตลาดนัดเทศบาลเมือง'
  final String description;
  final String location;                    // 'เขตเมือง, จังหวัดขอนแก่น'
  final GeoPoint? coordinates;              // lat, lng สำหรับ Google Maps
  
  // ตารางเปิด-ปิด (key: 'monday', 'tuesday', 'wednesday', ...)
  final Map<String, MarketSchedule> schedules;
  
  // โซนจอดขาย
  final List<MarketZone> zones;
  
  // ค่าธรรมเนียม
  final double baseFee;                     // 100 บาท (ค่าพื้นฐาน)
  final Map<String, double>? zoneFees;      // {'zone_a': 50, 'zone_b': 30} (deprecated - ใช้ในโซนแทน)
  
  // รีวิวและคะแนน
  final double rating;                      // 0.0 - 5.0
  final int reviewCount;
  
  // อื่น ๆ
  final bool isActive;                      // เปิด/ปิดการจอง
  final String? imageUrl;                   // รูปภาพตลาด
  final String? rules;                      // ระเบียบการใช้งาน
  final List<String>? facilities;           // ['ที่จอดรถ', 'น้ำดื่ม', 'ห้องน้ำ']
  
  // Contact
  final String? phone;
  final String? email;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;                   // admin user ID

  Market({
    required this.id,
    required this.name,
    this.description = '',
    required this.location,
    this.coordinates,
    required this.schedules,
    required this.zones,
    this.baseFee = 100,
    this.zoneFees,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    this.imageUrl,
    this.rules,
    this.facilities,
    this.phone,
    this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // From JSON
  factory Market.fromJson(Map<String, dynamic> json) {
    // Parse schedules
    Map<String, MarketSchedule> schedules = {};
    if (json['schedules'] != null) {
      (json['schedules'] as Map<String, dynamic>).forEach((key, value) {
        schedules[key] = MarketSchedule.fromJson(value as Map<String, dynamic>);
      });
    }

    // Parse zones
    List<MarketZone> zones = [];
    if (json['zones'] != null) {
      zones = (json['zones'] as List<dynamic>)
          .map((e) => MarketZone.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse zoneFees
    Map<String, double>? zoneFees;
    if (json['zoneFees'] != null) {
      zoneFees = (json['zoneFees'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    return Market(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String,
      coordinates: json['coordinates'] as GeoPoint?,
      schedules: schedules,
      zones: zones,
      baseFee: (json['baseFee'] as num?)?.toDouble() ?? 100,
      zoneFees: zoneFees,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      rules: json['rules'] as String?,
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: json['createdBy'] as String? ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'coordinates': coordinates,
      'schedules': schedules.map((key, value) => MapEntry(key, value.toJson())),
      'zones': zones.map((e) => e.toJson()).toList(),
      'baseFee': baseFee,
      'zoneFees': zoneFees,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'rules': rules,
      'facilities': facilities,
      'phone': phone,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  Market copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    GeoPoint? coordinates,
    Map<String, MarketSchedule>? schedules,
    List<MarketZone>? zones,
    double? baseFee,
    Map<String, double>? zoneFees,
    double? rating,
    int? reviewCount,
    bool? isActive,
    String? imageUrl,
    String? rules,
    List<String>? facilities,
    String? phone,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Market(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      schedules: schedules ?? this.schedules,
      zones: zones ?? this.zones,
      baseFee: baseFee ?? this.baseFee,
      zoneFees: zoneFees ?? this.zoneFees,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      rules: rules ?? this.rules,
      facilities: facilities ?? this.facilities,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Get available slots for a specific zone
  int getAvailableSlots(String zoneId) {
    // TODO: Query bookings และคำนวณคิวว่าง
    final zone = zones.firstWhere((z) => z.id == zoneId);
    return zone.totalSlots; // Mock: คืนค่าทั้งหมดก่อน
  }

  /// Check if market is open on a specific day
  bool isOpenOn(String dayOfWeek) {
    return schedules[dayOfWeek.toLowerCase()]?.isOpen ?? false;
  }
}
