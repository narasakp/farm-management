import 'package:cloud_firestore/cloud_firestore.dart';

/// Model สำหรับติดตามการคลิก Deep Link จาก Social Media
class DeepLinkClick {
  final String id;
  final String listingId; // ID ของประกาศขาย
  final String source; // facebook, tiktok, x, line, direct
  final String? campaign; // ชื่อแคมเปญ (optional)
  final String? referrer; // ผู้แนะนำ (สำหรับ affiliate)
  final String? userId; // ID ของผู้คลิก (ถ้า login แล้ว)
  final String? sessionId; // Session ID สำหรับติดตาม
  final DateTime clickTime; // เวลาที่คลิก
  final bool converted; // ซื้อแล้วหรือยัง
  final String? orderId; // Order ID ถ้าซื้อแล้ว
  final DateTime? conversionTime; // เวลาที่ซื้อ
  
  // Device & Location Info (optional)
  final String? deviceType; // mobile, desktop, tablet
  final String? platform; // ios, android, web
  final String? location; // ตำแหน่งที่คลิก (จาก IP)
  
  DeepLinkClick({
    required this.id,
    required this.listingId,
    required this.source,
    this.campaign,
    this.referrer,
    this.userId,
    this.sessionId,
    required this.clickTime,
    this.converted = false,
    this.orderId,
    this.conversionTime,
    this.deviceType,
    this.platform,
    this.location,
  });
  
  /// ระยะเวลาจากคลิกถึงซื้อ (วินาที)
  int? get timeToConversion {
    if (conversionTime == null) return null;
    return conversionTime!.difference(clickTime).inSeconds;
  }
  
  /// คำนวณระยะเวลาจากคลิกถึงปัจจุบัน
  Duration get timeSinceClick => DateTime.now().difference(clickTime);
  
  /// สร้าง instance จาก Firestore document
  factory DeepLinkClick.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeepLinkClick(
      id: doc.id,
      listingId: data['listingId'] ?? '',
      source: data['source'] ?? 'direct',
      campaign: data['campaign'],
      referrer: data['referrer'],
      userId: data['userId'],
      sessionId: data['sessionId'],
      clickTime: (data['clickTime'] as Timestamp).toDate(),
      converted: data['converted'] ?? false,
      orderId: data['orderId'],
      conversionTime: data['conversionTime'] != null
          ? (data['conversionTime'] as Timestamp).toDate()
          : null,
      deviceType: data['deviceType'],
      platform: data['platform'],
      location: data['location'],
    );
  }
  
  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'source': source,
      'campaign': campaign,
      'referrer': referrer,
      'userId': userId,
      'sessionId': sessionId,
      'clickTime': Timestamp.fromDate(clickTime),
      'converted': converted,
      'orderId': orderId,
      'conversionTime': conversionTime != null
          ? Timestamp.fromDate(conversionTime!)
          : null,
      'deviceType': deviceType,
      'platform': platform,
      'location': location,
    };
  }
  
  /// สร้าง copy พร้อมอัปเดตการ conversion
  DeepLinkClick markAsConverted({
    required String orderId,
    DateTime? conversionTime,
  }) {
    return DeepLinkClick(
      id: id,
      listingId: listingId,
      source: source,
      campaign: campaign,
      referrer: referrer,
      userId: userId,
      sessionId: sessionId,
      clickTime: clickTime,
      converted: true,
      orderId: orderId,
      conversionTime: conversionTime ?? DateTime.now(),
      deviceType: deviceType,
      platform: platform,
      location: location,
    );
  }
  
  /// สร้าง copy พร้อมอัปเดต userId (เมื่อ login)
  DeepLinkClick associateWithUser(String userId) {
    return DeepLinkClick(
      id: id,
      listingId: listingId,
      source: source,
      campaign: campaign,
      referrer: referrer,
      userId: userId,
      sessionId: sessionId,
      clickTime: clickTime,
      converted: converted,
      orderId: orderId,
      conversionTime: conversionTime,
      deviceType: deviceType,
      platform: platform,
      location: location,
    );
  }
}

/// สถิติการคลิกและ conversion แยกตาม source
class SourceStats {
  final String source;
  final int totalClicks;
  final int totalConversions;
  final double totalRevenue;
  final Duration avgTimeToConversion;
  
  SourceStats({
    required this.source,
    required this.totalClicks,
    required this.totalConversions,
    required this.totalRevenue,
    required this.avgTimeToConversion,
  });
  
  /// Conversion Rate
  double get conversionRate =>
      totalClicks > 0 ? (totalConversions / totalClicks) * 100 : 0;
  
  /// Revenue per Click
  double get revenuePerClick =>
      totalClicks > 0 ? totalRevenue / totalClicks : 0;
  
  /// Cost per Acquisition (สมมติ cost per click = 1 บาท)
  double get cpa {
    const costPerClick = 1.0; // ปรับได้ตาม platform
    final totalCost = totalClicks * costPerClick;
    return totalConversions > 0 ? totalCost / totalConversions : 0;
  }
  
  Map<String, dynamic> toJson() => {
    'source': source,
    'totalClicks': totalClicks,
    'totalConversions': totalConversions,
    'totalRevenue': totalRevenue,
    'conversionRate': conversionRate,
    'revenuePerClick': revenuePerClick,
    'avgTimeToConversion': avgTimeToConversion.inSeconds,
  };
}

/// Campaign Performance Stats
class CampaignStats {
  final String campaign;
  final Map<String, SourceStats> sourceStats;
  final DateTime startDate;
  final DateTime? endDate;
  
  CampaignStats({
    required this.campaign,
    required this.sourceStats,
    required this.startDate,
    this.endDate,
  });
  
  /// Total clicks across all sources
  int get totalClicks =>
      sourceStats.values.fold(0, (sum, stats) => sum + stats.totalClicks);
  
  /// Total conversions across all sources
  int get totalConversions =>
      sourceStats.values.fold(0, (sum, stats) => sum + stats.totalConversions);
  
  /// Total revenue across all sources
  double get totalRevenue =>
      sourceStats.values.fold(0.0, (sum, stats) => sum + stats.totalRevenue);
  
  /// Overall conversion rate
  double get overallConversionRate =>
      totalClicks > 0 ? (totalConversions / totalClicks) * 100 : 0;
  
  /// Best performing source
  String? get bestSource {
    if (sourceStats.isEmpty) return null;
    
    var best = sourceStats.entries.first;
    for (var entry in sourceStats.entries) {
      if (entry.value.conversionRate > best.value.conversionRate) {
        best = entry;
      }
    }
    return best.key;
  }
}
