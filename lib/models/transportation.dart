class TransportVehicle {
  final String id;
  final String ownerId;
  final String vehicleType; // 'truck', 'trailer', 'pickup'
  final String licensePlate;
  final String? brand;
  final String? model;
  final int? year;
  final double maxCapacityWeight; // กิโลกรัม
  final int maxCapacityAnimals; // จำนวนตัว
  final List<String> suitableAnimalTypes; // ['cattle', 'pig', 'chicken']
  final String driverName;
  final String driverPhone;
  final String? driverLicense;
  final bool isActive;
  final double pricePerKm;
  final double? pricePerAnimal;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransportVehicle({
    required this.id,
    required this.ownerId,
    required this.vehicleType,
    required this.licensePlate,
    this.brand,
    this.model,
    this.year,
    required this.maxCapacityWeight,
    required this.maxCapacityAnimals,
    required this.suitableAnimalTypes,
    required this.driverName,
    required this.driverPhone,
    this.driverLicense,
    required this.isActive,
    required this.pricePerKm,
    this.pricePerAnimal,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportVehicle.fromJson(Map<String, dynamic> json) {
    return TransportVehicle(
      id: json['id'],
      ownerId: json['ownerId'],
      vehicleType: json['vehicleType'],
      licensePlate: json['licensePlate'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      maxCapacityWeight: json['maxCapacityWeight'].toDouble(),
      maxCapacityAnimals: json['maxCapacityAnimals'],
      suitableAnimalTypes: List<String>.from(json['suitableAnimalTypes']),
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      driverLicense: json['driverLicense'],
      isActive: json['isActive'],
      pricePerKm: json['pricePerKm'].toDouble(),
      pricePerAnimal: json['pricePerAnimal']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'year': year,
      'maxCapacityWeight': maxCapacityWeight,
      'maxCapacityAnimals': maxCapacityAnimals,
      'suitableAnimalTypes': suitableAnimalTypes,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverLicense': driverLicense,
      'isActive': isActive,
      'pricePerKm': pricePerKm,
      'pricePerAnimal': pricePerAnimal,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TransportBooking {
  final String id;
  final String farmId;
  final String vehicleId;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime scheduledDate;
  final DateTime? scheduledTime;
  final List<TransportItem> items;
  final double totalWeight;
  final int totalAnimals;
  final double estimatedDistance;
  final double estimatedCost;
  final double? actualCost;
  final String status; // 'pending', 'confirmed', 'in_transit', 'delivered', 'cancelled'
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransportBooking({
    required this.id,
    required this.farmId,
    required this.vehicleId,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.scheduledDate,
    this.scheduledTime,
    required this.items,
    required this.totalWeight,
    required this.totalAnimals,
    required this.estimatedDistance,
    required this.estimatedCost,
    this.actualCost,
    required this.status,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportBooking.fromJson(Map<String, dynamic> json) {
    return TransportBooking(
      id: json['id'],
      farmId: json['farmId'],
      vehicleId: json['vehicleId'],
      pickupLocation: json['pickupLocation'],
      deliveryLocation: json['deliveryLocation'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime']) 
          : null,
      items: (json['items'] as List)
          .map((item) => TransportItem.fromJson(item))
          .toList(),
      totalWeight: json['totalWeight'].toDouble(),
      totalAnimals: json['totalAnimals'],
      estimatedDistance: json['estimatedDistance'].toDouble(),
      estimatedCost: json['estimatedCost'].toDouble(),
      actualCost: json['actualCost']?.toDouble(),
      status: json['status'],
      specialInstructions: json['specialInstructions'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'vehicleId': vehicleId,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalWeight': totalWeight,
      'totalAnimals': totalAnimals,
      'estimatedDistance': estimatedDistance,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'status': status,
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TransportItem {
  final String livestockId;
  final String animalType;
  final int quantity;
  final double? weight;
  final String? notes;

  TransportItem({
    required this.livestockId,
    required this.animalType,
    required this.quantity,
    this.weight,
    this.notes,
  });

  factory TransportItem.fromJson(Map<String, dynamic> json) {
    return TransportItem(
      livestockId: json['livestockId'],
      animalType: json['animalType'],
      quantity: json['quantity'],
      weight: json['weight']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'livestockId': livestockId,
      'animalType': animalType,
      'quantity': quantity,
      'weight': weight,
      'notes': notes,
    };
  }
}

class TransportLog {
  final String id;
  final String bookingId;
  final DateTime timestamp;
  final String status;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final List<String>? photos;

  TransportLog({
    required this.id,
    required this.bookingId,
    required this.timestamp,
    required this.status,
    this.location,
    this.latitude,
    this.longitude,
    this.notes,
    this.photos,
  });

  factory TransportLog.fromJson(Map<String, dynamic> json) {
    return TransportLog(
      id: json['id'],
      bookingId: json['bookingId'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      notes: json['notes'],
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'photos': photos,
    };
  }
}
