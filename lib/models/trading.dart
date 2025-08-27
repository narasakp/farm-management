import 'livestock.dart';

// การซื้อขายปศุสัตว์และตลาดออนไลน์
class LivestockMarket {
  final String id;
  final String name;
  final String location;
  final String type; // 'physical', 'online'
  final List<String> operatingDays;
  final String? operatingHours;
  final String? contactInfo;
  final bool isActive;
  final DateTime createdAt;

  LivestockMarket({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.operatingDays,
    this.operatingHours,
    this.contactInfo,
    required this.isActive,
    required this.createdAt,
  });

  factory LivestockMarket.fromJson(Map<String, dynamic> json) {
    return LivestockMarket(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      operatingDays: List<String>.from(json['operatingDays']),
      operatingHours: json['operatingHours'],
      contactInfo: json['contactInfo'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type,
      'operatingDays': operatingDays,
      'operatingHours': operatingHours,
      'contactInfo': contactInfo,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TradingRecord {
  final String id;
  final String farmId;
  final String? buyerId;
  final String? sellerId;
  final String livestockId;
  final String transactionType; // 'buy', 'sell'
  final double price;
  final double? weight;
  final DateTime transactionDate;
  final String? marketId;
  final String? notes;
  final String status; // 'pending', 'completed', 'cancelled'
  final DateTime createdAt;

  TradingRecord({
    required this.id,
    required this.farmId,
    this.buyerId,
    this.sellerId,
    required this.livestockId,
    required this.transactionType,
    required this.price,
    this.weight,
    required this.transactionDate,
    this.marketId,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory TradingRecord.fromJson(Map<String, dynamic> json) {
    return TradingRecord(
      id: json['id'],
      farmId: json['farmId'],
      buyerId: json['buyerId'],
      sellerId: json['sellerId'],
      livestockId: json['livestockId'],
      transactionType: json['transactionType'],
      price: json['price'].toDouble(),
      weight: json['weight']?.toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      marketId: json['marketId'],
      notes: json['notes'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'livestockId': livestockId,
      'transactionType': transactionType,
      'price': price,
      'weight': weight,
      'transactionDate': transactionDate.toIso8601String(),
      'marketId': marketId,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MarketListing {
  final String id;
  final String farmId;
  final String livestockId;
  final double askingPrice;
  final double? minPrice;
  final String? description;
  final List<String>? images;
  final bool isNegotiable;
  final DateTime listedDate;
  final DateTime? expiryDate;
  final String status; // 'active', 'sold', 'expired', 'withdrawn'
  final int viewCount;
  final DateTime createdAt;

  MarketListing({
    required this.id,
    required this.farmId,
    required this.livestockId,
    required this.askingPrice,
    this.minPrice,
    this.description,
    this.images,
    required this.isNegotiable,
    required this.listedDate,
    this.expiryDate,
    required this.status,
    required this.viewCount,
    required this.createdAt,
  });

  factory MarketListing.fromJson(Map<String, dynamic> json) {
    return MarketListing(
      id: json['id'],
      farmId: json['farmId'],
      livestockId: json['livestockId'],
      askingPrice: json['askingPrice'].toDouble(),
      minPrice: json['minPrice']?.toDouble(),
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      isNegotiable: json['isNegotiable'],
      listedDate: DateTime.parse(json['listedDate']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      status: json['status'],
      viewCount: json['viewCount'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'livestockId': livestockId,
      'askingPrice': askingPrice,
      'minPrice': minPrice,
      'description': description,
      'images': images,
      'isNegotiable': isNegotiable,
      'listedDate': listedDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'status': status,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MarketBooking {
  final String id;
  final String farmId;
  final String marketId;
  final DateTime bookingDate;
  final String livestockType;
  final int quantity;
  final double? estimatedWeight;
  final String? notes;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? queueNumber;
  final DateTime createdAt;

  MarketBooking({
    required this.id,
    required this.farmId,
    required this.marketId,
    required this.bookingDate,
    required this.livestockType,
    required this.quantity,
    this.estimatedWeight,
    this.notes,
    required this.status,
    this.queueNumber,
    required this.createdAt,
  });

  factory MarketBooking.fromJson(Map<String, dynamic> json) {
    return MarketBooking(
      id: json['id'],
      farmId: json['farmId'],
      marketId: json['marketId'],
      bookingDate: DateTime.parse(json['bookingDate']),
      livestockType: json['livestockType'],
      quantity: json['quantity'],
      estimatedWeight: json['estimatedWeight']?.toDouble(),
      notes: json['notes'],
      status: json['status'],
      queueNumber: json['queueNumber'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'marketId': marketId,
      'bookingDate': bookingDate.toIso8601String(),
      'livestockType': livestockType,
      'quantity': quantity,
      'estimatedWeight': estimatedWeight,
      'notes': notes,
      'status': status,
      'queueNumber': queueNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PriceEstimation {
  final LivestockType type;
  final double weight;
  final String quality; // 'excellent', 'good', 'average', 'poor'
  final double estimatedPrice;
  final double pricePerKg;
  final String marketCondition;
  final DateTime estimationDate;

  PriceEstimation({
    required this.type,
    required this.weight,
    required this.quality,
    required this.estimatedPrice,
    required this.pricePerKg,
    required this.marketCondition,
    required this.estimationDate,
  });

  factory PriceEstimation.fromJson(Map<String, dynamic> json) {
    return PriceEstimation(
      type: LivestockType.values.byName(json['type']),
      weight: json['weight'].toDouble(),
      quality: json['quality'],
      estimatedPrice: json['estimatedPrice'].toDouble(),
      pricePerKg: json['pricePerKg'].toDouble(),
      marketCondition: json['marketCondition'],
      estimationDate: DateTime.parse(json['estimationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'weight': weight,
      'quality': quality,
      'estimatedPrice': estimatedPrice,
      'pricePerKg': pricePerKg,
      'marketCondition': marketCondition,
      'estimationDate': estimationDate.toIso8601String(),
    };
  }
}
