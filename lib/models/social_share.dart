import 'package:cloud_firestore/cloud_firestore.dart';

/// Model สำหรับบันทึกการแชร์ไปยัง Social Media
class SocialShare {
  final String id;
  final String listingId; // ID ของประกาศขาย
  final String userId; // ID ของผู้แชร์
  final String platform; // facebook, tiktok, x, line
  final String contentType; // image, video, card
  final String templateId; // card, price, gallery, video
  final String shareUrl; // Deep link URL
  final String? shareContent; // Text content ที่แชร์
  final Map<String, dynamic>? customization; // การปรับแต่ง (สี, layout, etc)
  final DateTime createdAt;
  
  // Analytics
  final int viewCount; // จำนวนคนดู
  final int clickCount; // จำนวนคนคลิก
  final int conversionCount; // จำนวนคนซื้อ
  
  SocialShare({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.platform,
    required this.contentType,
    required this.templateId,
    required this.shareUrl,
    this.shareContent,
    this.customization,
    required this.createdAt,
    this.viewCount = 0,
    this.clickCount = 0,
    this.conversionCount = 0,
  });
  
  /// คำนวณ Conversion Rate
  double get conversionRate => 
      clickCount > 0 ? (conversionCount / clickCount) * 100 : 0;
  
  /// คำนวณ Click-Through Rate
  double get ctr =>
      viewCount > 0 ? (clickCount / viewCount) * 100 : 0;
  
  /// สร้าง instance จาก Firestore document
  factory SocialShare.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialShare(
      id: doc.id,
      listingId: data['listingId'] ?? '',
      userId: data['userId'] ?? '',
      platform: data['platform'] ?? '',
      contentType: data['contentType'] ?? 'image',
      templateId: data['templateId'] ?? 'card',
      shareUrl: data['shareUrl'] ?? '',
      shareContent: data['shareContent'],
      customization: data['customization'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      viewCount: data['viewCount'] ?? 0,
      clickCount: data['clickCount'] ?? 0,
      conversionCount: data['conversionCount'] ?? 0,
    );
  }
  
  /// สร้าง instance จาก JSON
  factory SocialShare.fromJson(Map<String, dynamic> json) {
    return SocialShare(
      id: json['id'] ?? '',
      listingId: json['listingId'] ?? '',
      userId: json['userId'] ?? '',
      platform: json['platform'] ?? '',
      contentType: json['contentType'] ?? 'image',
      templateId: json['templateId'] ?? json['template'] ?? 'card', // Support both
      shareUrl: json['shareUrl'] ?? '',
      shareContent: json['shareContent'],
      customization: json['customization'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      viewCount: json['viewCount'] ?? 0,
      clickCount: json['clickCount'] ?? 0,
      conversionCount: json['conversionCount'] ?? 0,
    );
  }
  
  /// แปลงเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'userId': userId,
      'platform': platform,
      'contentType': contentType,
      'templateId': templateId,
      'shareUrl': shareUrl,
      'shareContent': shareContent,
      'customization': customization,
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
      'clickCount': clickCount,
      'conversionCount': conversionCount,
    };
  }
  
  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'userId': userId,
      'platform': platform,
      'contentType': contentType,
      'templateId': templateId,
      'shareUrl': shareUrl,
      'shareContent': shareContent,
      'customization': customization,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewCount': viewCount,
      'clickCount': clickCount,
      'conversionCount': conversionCount,
    };
  }
  
  /// สร้าง copy พร้อมอัปเดตค่า
  SocialShare copyWith({
    String? id,
    String? listingId,
    String? userId,
    String? platform,
    String? contentType,
    String? templateId,
    String? shareUrl,
    String? shareContent,
    Map<String, dynamic>? customization,
    DateTime? createdAt,
    int? viewCount,
    int? clickCount,
    int? conversionCount,
  }) {
    return SocialShare(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      templateId: templateId ?? this.templateId,
      shareUrl: shareUrl ?? this.shareUrl,
      shareContent: shareContent ?? this.shareContent,
      customization: customization ?? this.customization,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      clickCount: clickCount ?? this.clickCount,
      conversionCount: conversionCount ?? this.conversionCount,
    );
  }
}

/// สถิติการแชร์แยกตาม Platform
class PlatformStats {
  final String platform;
  final int shares;
  final int views;
  final int clicks;
  final int purchases;
  
  PlatformStats({
    required this.platform,
    required this.shares,
    required this.views,
    required this.clicks,
    required this.purchases,
  });
  
  /// คำนวณ Conversion Rate
  double get conversionRate => clicks > 0 ? (purchases / clicks) * 100 : 0;
  
  /// คำนวณ Click-Through Rate
  double get ctr => views > 0 ? (clicks / views) * 100 : 0;
  
  /// คำนวณ Revenue per Share (ประมาณการ)
  double revenuePerShare(double avgOrderValue) => 
      shares > 0 ? (purchases * avgOrderValue) / shares : 0;
  
  Map<String, dynamic> toJson() => {
    'platform': platform,
    'shares': shares,
    'views': views,
    'clicks': clicks,
    'purchases': purchases,
    'conversionRate': conversionRate,
    'ctr': ctr,
  };
  
  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      platform: json['platform'] ?? '',
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      clicks: json['clicks'] ?? 0,
      purchases: json['purchases'] ?? 0,
    );
  }
}

/// สถิติรวมของ Social Commerce
class SocialStats {
  final int totalShares;
  final int totalViews;
  final int totalClicks;
  final int totalPurchases;
  final Map<String, PlatformStats> platformStats;
  final DateTime? lastShared;
  
  SocialStats({
    this.totalShares = 0,
    this.totalViews = 0,
    this.totalClicks = 0,
    this.totalPurchases = 0,
    this.platformStats = const {},
    this.lastShared,
  });
  
  /// คำนวณ Overall Conversion Rate
  double get overallConversionRate => 
      totalClicks > 0 ? (totalPurchases / totalClicks) * 100 : 0;
  
  /// คำนวณ Overall CTR
  double get overallCtr =>
      totalViews > 0 ? (totalClicks / totalViews) * 100 : 0;
  
  /// Platform ที่ดีที่สุด (conversion rate สูงสุด)
  String? get bestPlatform {
    if (platformStats.isEmpty) return null;
    
    var best = platformStats.entries.first;
    for (var entry in platformStats.entries) {
      if (entry.value.conversionRate > best.value.conversionRate) {
        best = entry;
      }
    }
    return best.key;
  }
  
  Map<String, dynamic> toJson() => {
    'totalShares': totalShares,
    'totalViews': totalViews,
    'totalClicks': totalClicks,
    'totalPurchases': totalPurchases,
    'platformStats': platformStats.map((k, v) => MapEntry(k, v.toJson())),
    'lastShared': lastShared?.toIso8601String(),
  };
  
  factory SocialStats.fromJson(Map<String, dynamic> json) {
    return SocialStats(
      totalShares: json['totalShares'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      totalClicks: json['totalClicks'] ?? 0,
      totalPurchases: json['totalPurchases'] ?? 0,
      platformStats: (json['platformStats'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, PlatformStats.fromJson(v as Map<String, dynamic>)),
      ) ?? {},
      lastShared: json['lastShared'] != null 
          ? DateTime.parse(json['lastShared']) 
          : null,
    );
  }
}
