class GPSLocation {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final DateTime timestamp;
  final String? address;
  final String? province;
  final String? district;
  final String? subDistrict;

  GPSLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.timestamp,
    this.address,
    this.province,
    this.district,
    this.subDistrict,
  });

  GPSLocation copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    DateTime? timestamp,
    String? address,
    String? province,
    String? district,
    String? subDistrict,
  }) {
    return GPSLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
      province: province ?? this.province,
      district: district ?? this.district,
      subDistrict: subDistrict ?? this.subDistrict,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
      'province': province,
      'district': district,
      'subDistrict': subDistrict,
    };
  }

  factory GPSLocation.fromJson(Map<String, dynamic> json) {
    return GPSLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      address: json['address'],
      province: json['province'],
      district: json['district'],
      subDistrict: json['subDistrict'],
    );
  }

  // Calculate distance between two GPS points (in kilometers)
  double distanceTo(GPSLocation other) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double lat1Rad = latitude * (3.14159265359 / 180);
    double lat2Rad = other.latitude * (3.14159265359 / 180);
    double deltaLatRad = (other.latitude - latitude) * (3.14159265359 / 180);
    double deltaLngRad = (other.longitude - longitude) * (3.14159265359 / 180);

    double a = (deltaLatRad / 2).sin() * (deltaLatRad / 2).sin() +
        lat1Rad.cos() * lat2Rad.cos() *
        (deltaLngRad / 2).sin() * (deltaLngRad / 2).sin();
    double c = 2 * (a.sqrt()).asin();

    return earthRadius * c;
  }

  // Get formatted coordinates string
  String get coordinatesString => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  // Get full address string
  String get fullAddress {
    List<String> addressParts = [];
    if (address != null && address!.isNotEmpty) addressParts.add(address!);
    if (subDistrict != null && subDistrict!.isNotEmpty) addressParts.add('ต.$subDistrict');
    if (district != null && district!.isNotEmpty) addressParts.add('อ.$district');
    if (province != null && province!.isNotEmpty) addressParts.add('จ.$province');
    
    return addressParts.isNotEmpty ? addressParts.join(', ') : coordinatesString;
  }

  @override
  String toString() {
    return 'GPSLocation(lat: $latitude, lng: $longitude, address: ${fullAddress})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GPSLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ timestamp.hashCode;
  }
}

class LocationTrack {
  final String id;
  final String entityId; // Farm ID, Transport ID, etc.
  final String entityType; // 'farm', 'transport', 'survey', etc.
  final List<GPSLocation> locations;
  final DateTime startTime;
  final DateTime? endTime;
  final String? description;
  final Map<String, dynamic>? metadata;

  LocationTrack({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.locations,
    required this.startTime,
    this.endTime,
    this.description,
    this.metadata,
  });

  LocationTrack copyWith({
    String? id,
    String? entityId,
    String? entityType,
    List<GPSLocation>? locations,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return LocationTrack(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      locations: locations ?? this.locations,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  // Add new location to track
  LocationTrack addLocation(GPSLocation location) {
    return copyWith(
      locations: [...locations, location],
      endTime: location.timestamp,
    );
  }

  // Get total distance traveled
  double get totalDistance {
    if (locations.length < 2) return 0.0;
    
    double total = 0.0;
    for (int i = 1; i < locations.length; i++) {
      total += locations[i - 1].distanceTo(locations[i]);
    }
    return total;
  }

  // Get duration of track
  Duration get duration {
    if (endTime == null) return DateTime.now().difference(startTime);
    return endTime!.difference(startTime);
  }

  // Get average speed (km/h)
  double get averageSpeed {
    final durationHours = duration.inMilliseconds / (1000 * 60 * 60);
    if (durationHours == 0) return 0.0;
    return totalDistance / durationHours;
  }

  // Get current location (last location in track)
  GPSLocation? get currentLocation {
    return locations.isNotEmpty ? locations.last : null;
  }

  // Get starting location
  GPSLocation? get startLocation {
    return locations.isNotEmpty ? locations.first : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityId': entityId,
      'entityType': entityType,
      'locations': locations.map((l) => l.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'description': description,
      'metadata': metadata,
    };
  }

  factory LocationTrack.fromJson(Map<String, dynamic> json) {
    return LocationTrack(
      id: json['id'],
      entityId: json['entityId'],
      entityType: json['entityType'],
      locations: (json['locations'] as List)
          .map((l) => GPSLocation.fromJson(l))
          .toList(),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      description: json['description'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }
}

// Predefined locations for Thailand provinces
class ThailandLocations {
  static const Map<String, GPSLocation> provinces = {
    'กรุงเทพมหานคร': GPSLocation(
      latitude: 13.7563,
      longitude: 100.5018,
      timestamp: null,
      province: 'กรุงเทพมหานคร',
    ),
    'นครราชสีมา': GPSLocation(
      latitude: 14.9799,
      longitude: 102.0977,
      timestamp: null,
      province: 'นครราชสีมา',
    ),
    'เชียงใหม่': GPSLocation(
      latitude: 18.7883,
      longitude: 98.9853,
      timestamp: null,
      province: 'เชียงใหม่',
    ),
    'ขอนแก่น': GPSLocation(
      latitude: 16.4322,
      longitude: 102.8236,
      timestamp: null,
      province: 'ขอนแก่น',
    ),
    'สุราษฎร์ธานี': GPSLocation(
      latitude: 9.1382,
      longitude: 99.3215,
      timestamp: null,
      province: 'สุราษฎร์ธานี',
    ),
    'ชลบุรี': GPSLocation(
      latitude: 13.3611,
      longitude: 100.9847,
      timestamp: null,
      province: 'ชลบุรี',
    ),
    'สุพรรณบุรี': GPSLocation(
      latitude: 14.4745,
      longitude: 100.1218,
      timestamp: null,
      province: 'สุพรรณบุรี',
    ),
  };

  static GPSLocation? getProvinceLocation(String provinceName) {
    return provinces[provinceName];
  }

  static List<String> get provinceNames => provinces.keys.toList();
}
