import 'package:cloud_firestore/cloud_firestore.dart';
import 'livestock.dart';
import 'social_share.dart';

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
  final List<String> images; // Required field
  final bool isNegotiable;
  final DateTime listedDate;
  final DateTime? expiryDate;
  final String status; // 'active', 'sold', 'expired', 'withdrawn'
  final int viewCount;
  final DateTime createdAt;
  
  // 🆕 Social Commerce Fields
  final String? shareTitle; // หัวข้อสำหรับแชร์ (catchy title)
  final String? shareDescription; // คำอธิบายสั้นๆ สำหรับแชร์
  final List<String>? shareTags; // Hashtags สำหรับ social media
  final SocialStats? socialStats; // สถิติการแชร์และยอดขาย

  MarketListing({
    required this.id,
    required this.farmId,
    required this.livestockId,
    required this.askingPrice,
    this.minPrice,
    this.description,
    required this.images,
    required this.isNegotiable,
    required this.listedDate,
    this.expiryDate,
    required this.status,
    required this.viewCount,
    required this.createdAt,
    // Social Commerce
    this.shareTitle,
    this.shareDescription,
    this.shareTags,
    this.socialStats,
  });

  factory MarketListing.fromJson(Map<String, dynamic> json) {
    return MarketListing(
      id: json['id'],
      farmId: json['farmId'],
      livestockId: json['livestockId'],
      askingPrice: json['askingPrice'].toDouble(),
      minPrice: json['minPrice']?.toDouble(),
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      isNegotiable: json['isNegotiable'],
      listedDate: DateTime.parse(json['listedDate']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      status: json['status'],
      viewCount: json['viewCount'],
      createdAt: DateTime.parse(json['createdAt']),
      // Social Commerce
      shareTitle: json['shareTitle'],
      shareDescription: json['shareDescription'],
      shareTags: json['shareTags'] != null ? List<String>.from(json['shareTags']) : null,
      socialStats: json['socialStats'] != null 
          ? SocialStats.fromJson(json['socialStats'] as Map<String, dynamic>)
          : null,
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
      // Social Commerce
      'shareTitle': shareTitle,
      'shareDescription': shareDescription,
      'shareTags': shareTags,
      'socialStats': socialStats?.toJson(),
    };
  }
  
  /// สร้าง instance จาก Firestore document
  factory MarketListing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketListing(
      id: doc.id,
      farmId: data['farmId'] ?? '',
      livestockId: data['livestockId'] ?? '',
      askingPrice: (data['askingPrice'] as num?)?.toDouble() ?? 0.0,
      minPrice: (data['minPrice'] as num?)?.toDouble(),
      description: data['description'],
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      isNegotiable: data['isNegotiable'] ?? false,
      listedDate: (data['listedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'active',
      viewCount: data['viewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shareTitle: data['shareTitle'],
      shareDescription: data['shareDescription'],
      shareTags: data['shareTags'] != null ? List<String>.from(data['shareTags']) : null,
      socialStats: data['socialStats'] != null 
          ? SocialStats.fromJson(data['socialStats'] as Map<String, dynamic>)
          : null,
    );
  }
  
  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'farmId': farmId,
      'livestockId': livestockId,
      'askingPrice': askingPrice,
      'minPrice': minPrice,
      'description': description,
      'images': images,
      'isNegotiable': isNegotiable,
      'listedDate': Timestamp.fromDate(listedDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'status': status,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'shareTitle': shareTitle,
      'shareDescription': shareDescription,
      'shareTags': shareTags,
      'socialStats': socialStats?.toJson(),
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
  
  /// สร้าง instance จาก Firestore document
  factory MarketBooking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketBooking(
      id: doc.id,
      farmId: data['farmId'] ?? '',
      marketId: data['marketId'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      livestockType: data['livestockType'] ?? '',
      quantity: data['quantity'] ?? 0,
      estimatedWeight: (data['estimatedWeight'] as num?)?.toDouble(),
      notes: data['notes'],
      status: data['status'] ?? 'pending',
      queueNumber: data['queueNumber'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'farmId': farmId,
      'marketId': marketId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'livestockType': livestockType,
      'quantity': quantity,
      'estimatedWeight': estimatedWeight,
      'notes': notes,
      'status': status,
      'queueNumber': queueNumber,
      'createdAt': Timestamp.fromDate(createdAt),
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
