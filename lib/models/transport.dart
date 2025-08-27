// ระบบการขนส่งและโลจิสติกส์
class TransportVehicle {
  final String id;
  final String ownerId;
  final String licensePlate;
  final String vehicleType; // 'truck', 'trailer', 'pickup'
  final double capacity; // ความจุ (กิโลกรัม)
  final int maxAnimals; // จำนวนสัตว์สูงสุด
  final String driverName;
  final String driverPhone;
  final String? driverLicense;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  TransportVehicle({
    required this.id,
    required this.ownerId,
    required this.licensePlate,
    required this.vehicleType,
    required this.capacity,
    required this.maxAnimals,
    required this.driverName,
    required this.driverPhone,
    this.driverLicense,
    required this.isActive,
    this.notes,
    required this.createdAt,
  });

  factory TransportVehicle.fromJson(Map<String, dynamic> json) {
    return TransportVehicle(
      id: json['id'],
      ownerId: json['ownerId'],
      licensePlate: json['licensePlate'],
      vehicleType: json['vehicleType'],
      capacity: json['capacity'].toDouble(),
      maxAnimals: json['maxAnimals'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      driverLicense: json['driverLicense'],
      isActive: json['isActive'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'licensePlate': licensePlate,
      'vehicleType': vehicleType,
      'capacity': capacity,
      'maxAnimals': maxAnimals,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverLicense': driverLicense,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TransportBooking {
  final String id;
  final String farmId;
  final String vehicleId;
  final DateTime bookingDate;
  final DateTime scheduledDate;
  final String pickupLocation;
  final String deliveryLocation;
  final String livestockType;
  final int animalCount;
  final double? estimatedWeight;
  final double distance; // ระยะทาง (กิโลเมตร)
  final double estimatedCost;
  final String status; // 'pending', 'confirmed', 'in_transit', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;

  TransportBooking({
    required this.id,
    required this.farmId,
    required this.vehicleId,
    required this.bookingDate,
    required this.scheduledDate,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.livestockType,
    required this.animalCount,
    this.estimatedWeight,
    required this.distance,
    required this.estimatedCost,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory TransportBooking.fromJson(Map<String, dynamic> json) {
    return TransportBooking(
      id: json['id'],
      farmId: json['farmId'],
      vehicleId: json['vehicleId'],
      bookingDate: DateTime.parse(json['bookingDate']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      pickupLocation: json['pickupLocation'],
      deliveryLocation: json['deliveryLocation'],
      livestockType: json['livestockType'],
      animalCount: json['animalCount'],
      estimatedWeight: json['estimatedWeight']?.toDouble(),
      distance: json['distance'].toDouble(),
      estimatedCost: json['estimatedCost'].toDouble(),
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'vehicleId': vehicleId,
      'bookingDate': bookingDate.toIso8601String(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'livestockType': livestockType,
      'animalCount': animalCount,
      'estimatedWeight': estimatedWeight,
      'distance': distance,
      'estimatedCost': estimatedCost,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TransportLog {
  final String id;
  final String bookingId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? pickupGPS;
  final String? deliveryGPS;
  final List<TransportCheckpoint> checkpoints;
  final double? actualDistance;
  final double? fuelCost;
  final String? issues;
  final String status; // 'started', 'in_progress', 'completed'
  final DateTime createdAt;

  TransportLog({
    required this.id,
    required this.bookingId,
    required this.startTime,
    this.endTime,
    this.pickupGPS,
    this.deliveryGPS,
    required this.checkpoints,
    this.actualDistance,
    this.fuelCost,
    this.issues,
    required this.status,
    required this.createdAt,
  });

  factory TransportLog.fromJson(Map<String, dynamic> json) {
    return TransportLog(
      id: json['id'],
      bookingId: json['bookingId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      pickupGPS: json['pickupGPS'],
      deliveryGPS: json['deliveryGPS'],
      checkpoints: (json['checkpoints'] as List)
          .map((e) => TransportCheckpoint.fromJson(e))
          .toList(),
      actualDistance: json['actualDistance']?.toDouble(),
      fuelCost: json['fuelCost']?.toDouble(),
      issues: json['issues'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'pickupGPS': pickupGPS,
      'deliveryGPS': deliveryGPS,
      'checkpoints': checkpoints.map((e) => e.toJson()).toList(),
      'actualDistance': actualDistance,
      'fuelCost': fuelCost,
      'issues': issues,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TransportCheckpoint {
  final String location;
  final String gpsCoordinates;
  final DateTime timestamp;
  final String? notes;

  TransportCheckpoint({
    required this.location,
    required this.gpsCoordinates,
    required this.timestamp,
    this.notes,
  });

  factory TransportCheckpoint.fromJson(Map<String, dynamic> json) {
    return TransportCheckpoint(
      location: json['location'],
      gpsCoordinates: json['gpsCoordinates'],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'gpsCoordinates': gpsCoordinates,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}

class TransportCostCalculator {
  static double calculateCost({
    required double distance,
    required double weight,
    required String livestockType,
    required String vehicleType,
  }) {
    // Base rate per km
    double baseRate = 15.0; // บาทต่อกิโลเมตร
    
    // Vehicle type multiplier
    double vehicleMultiplier = 1.0;
    switch (vehicleType) {
      case 'truck':
        vehicleMultiplier = 1.5;
        break;
      case 'trailer':
        vehicleMultiplier = 2.0;
        break;
      case 'pickup':
        vehicleMultiplier = 1.0;
        break;
    }
    
    // Livestock type multiplier (special handling)
    double livestockMultiplier = 1.0;
    if (livestockType.contains('โค') || livestockType.contains('กระบือ')) {
      livestockMultiplier = 1.3; // Large animals need special handling
    }
    
    // Weight factor
    double weightFactor = weight > 1000 ? 1.2 : 1.0;
    
    // Distance factor (longer distance gets discount)
    double distanceFactor = distance > 100 ? 0.9 : 1.0;
    
    double totalCost = distance * baseRate * vehicleMultiplier * 
                      livestockMultiplier * weightFactor * distanceFactor;
    
    // Minimum charge
    return totalCost < 500 ? 500 : totalCost;
  }
}
