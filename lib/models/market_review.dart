import 'package:cloud_firestore/cloud_firestore.dart';

/// รีวิวตลาดนัด
class MarketReview {
  final String id;
  final String marketId;              // ตลาดที่รีวิว
  final String farmerId;              // ผู้รีวิว
  final String farmerName;
  final String bookingId;             // อ้างอิงจากการจองคิว
  
  final double rating;                // 1.0 - 5.0
  final String? comment;              // ความคิดเห็น
  final List<String>? imageUrls;      // รูปภาพ
  
  // Helpful count (optional - สำหรับอนาคต)
  final int helpfulCount;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  MarketReview({
    required this.id,
    required this.marketId,
    required this.farmerId,
    required this.farmerName,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.imageUrls,
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory MarketReview.fromJson(Map<String, dynamic> json) {
    return MarketReview(
      id: json['id'] as String,
      marketId: json['marketId'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      bookingId: json['bookingId'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marketId': marketId,
      farmerId': farmerId,
      'farmerName': farmerName,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'helpfulCount': helpfulCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MarketReview copyWith({
    String? id,
    String? marketId,
    String? farmerId,
    String? farmerName,
    String? bookingId,
    double? rating,
    String? comment,
    List<String>? imageUrls,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarketReview(
      id: id ?? this.id,
      marketId: marketId ?? this.marketId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
