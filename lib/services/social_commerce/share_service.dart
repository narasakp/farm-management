import 'package:share_plus/share_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/social_share.dart';
import '../../models/trading.dart';
import '../../models/livestock.dart';
import 'image_upload_service.dart';
import 'platforms/facebook_service.dart';
import 'platforms/tiktok_service.dart';
import 'platforms/twitter_service.dart';
import 'platforms/line_service.dart';

/// Service สำหรับการแชร์ไปยัง Social Media
class ShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();
  final FacebookService _facebookService = FacebookService();
  final TikTokService _tiktokService = TikTokService();
  final TwitterService _twitterService = TwitterService();
  final LineService _lineService = LineService();
  
  /// แชร์ไปยัง Social Media Platform
  Future<bool> shareToSocial({
    required MarketListing listing,
    required Livestock livestock,
    required String platform,
    String template = 'card',
    Map<String, dynamic>? customization,
    required String userId,
  }) async {
    try {
      // สร้าง Deep Link URL
      final shareUrl = _generateDeepLink(listing.id, platform);
      
      // สร้าง Content สำหรับแชร์
      final content = _generateShareContent(
        listing: listing,
        livestock: livestock,
        platform: platform,
        template: template,
        shareUrl: shareUrl,
      );
      
      // 🆕 Upload images to Firebase Storage
      print('📤 Uploading share images...');
      final imageUrls = await _imageUploadService.uploadShareImages(
        listingId: listing.id,
        listing: listing,
        livestock: livestock,
        template: template,
        customization: customization,
      );
      
      // 🆕 แชร์โดยใช้ platform-specific service
      bool shareSuccess = false;
      
      switch (platform) {
        case 'facebook':
          shareSuccess = await _facebookService.shareToFacebook(
            url: shareUrl,
            quote: content,
            hashtag: listing.shareTags?.first,
          );
          break;
        case 'tiktok':
          shareSuccess = await _tiktokService.shareContent(
            content: content,
            url: shareUrl,
            hashtags: listing.shareTags,
          );
          break;
        case 'x':
        case 'twitter':
          shareSuccess = await _twitterService.shareToTwitter(
            text: content,
            url: shareUrl,
            hashtags: listing.shareTags,
          );
          break;
        case 'line':
          shareSuccess = await _lineService.shareToLine(
            text: content,
            url: shareUrl,
          );
          break;
        default:
          // Fallback to generic share
          // Note: share_plus package required
          // final result = await Share.shareWithResult(
          //   content,
          //   subject: listing.shareTitle ?? 'ขายปศุสัตว์',
          // );
          // shareSuccess = result.status == ShareResultStatus.success;
      }
      
      // ถ้าแชร์สำเร็จ บันทึกลง database
      if (shareSuccess) {
        await _recordShareEvent(
          userId: userId,
          listingId: listing.id,
          platform: platform,
          template: template,
          shareUrl: shareUrl,
          content: content,
          customization: customization,
        );
        
        // Track Analytics
        await _analytics.logEvent(
          name: 'social_share',
          parameters: {
            'listing_id': listing.id,
            'platform': platform,
            'template': template,
            'livestock_type': livestock.type.name,
          },
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error sharing: $e');
      return false;
    }
  }
  
  /// สร้าง Deep Link URL
  String _generateDeepLink(String listingId, String source) {
    // Base URL (ต้องแก้ให้ตรงกับ domain จริง)
    const baseUrl = 'https://farm-app.com';
    return '$baseUrl/market/$listingId?source=$source&utm_campaign=social_share';
  }
  
  /// สร้าง Content สำหรับแชร์
  String _generateShareContent({
    required MarketListing listing,
    required Livestock livestock,
    required String platform,
    required String template,
    required String shareUrl,
  }) {
    final title = listing.shareTitle ?? 'ขาย${livestock.type.displayName}';
    final price = _formatPrice(listing.askingPrice);
    final description = listing.shareDescription ?? listing.description ?? '';
    
    // สร้าง hashtags
    final tags = _generateHashtags(livestock, listing);
    
    // Platform-specific formatting
    switch (platform) {
      case 'facebook':
        return _formatForFacebook(title, description, price, tags, shareUrl);
      case 'tiktok':
        return _formatForTikTok(title, description, price, tags, shareUrl);
      case 'x':
        return _formatForX(title, description, price, tags, shareUrl);
      case 'line':
        return _formatForLine(title, description, price, shareUrl);
      default:
        return _formatDefault(title, description, price, tags, shareUrl);
    }
  }
  
  /// Format สำหรับ Facebook
  String _formatForFacebook(
    String title,
    String description,
    String price,
    List<String> tags,
    String url,
  ) {
    return '''
🐂 $title

💰 ราคา: $price
📝 $description

${tags.join(' ')}

👉 ดูรายละเอียดและสั่งซื้อ: $url
''';
  }
  
  /// Format สำหรับ TikTok
  String _formatForTikTok(
    String title,
    String description,
    String price,
    List<String> tags,
    String url,
  ) {
    return '''
$title 🐂

💰 $price | $description

Link ในไบโอ 👆
หรือดูที่: $url

${tags.join(' ')}
''';
  }
  
  /// Format สำหรับ X (Twitter)
  String _formatForX(
    String title,
    String description,
    String price,
    List<String> tags,
    String url,
  ) {
    // Twitter มีข้อจำกัด 280 characters
    final shortDesc = description.length > 80 
        ? '${description.substring(0, 80)}...' 
        : description;
    
    return '''
🐂 $title

💰 $price
$shortDesc

${tags.take(3).join(' ')}

➡️ $url
''';
  }
  
  /// Format สำหรับ LINE
  String _formatForLine(
    String title,
    String description,
    String price,
    String url,
  ) {
    return '''
$title

ราคา: $price
$description

คลิกเพื่อดูรายละเอียด:
$url
''';
  }
  
  /// Format แบบ Default
  String _formatDefault(
    String title,
    String description,
    String price,
    List<String> tags,
    String url,
  ) {
    return '''
$title

ราคา: $price
$description

${tags.join(' ')}

$url
''';
  }
  
  /// สร้าง Hashtags อัตโนมัติ
  List<String> _generateHashtags(Livestock livestock, MarketListing listing) {
    final tags = <String>[];
    
    // จาก shareTags ถ้ามี
    if (listing.shareTags != null && listing.shareTags!.isNotEmpty) {
      tags.addAll(listing.shareTags!.map((t) => t.startsWith('#') ? t : '#$t'));
    }
    
    // เพิ่ม tags พื้นฐาน
    tags.addAll([
      '#${livestock.type.displayName.replaceAll(' ', '')}',
      '#ปศุสัตว์',
      '#เกษตรกร',
      '#ขายปศุสัตว์',
    ]);
    
    // เพิ่ม tag ตามประเภท
    if (livestock.type.name.contains('cattle')) {
      tags.add('#วัว');
    } else if (livestock.type.name.contains('buffalo')) {
      tags.add('#ควาย');
    } else if (livestock.type.name.contains('pig')) {
      tags.add('#หมู');
    }
    
    return tags.take(10).toList(); // จำกัดไม่เกิน 10 tags
  }
  
  /// Format ราคา
  String _formatPrice(double price) {
    if (price >= 1000) {
      return '฿${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
    return '฿${price.toStringAsFixed(0)}';
  }
  
  /// บันทึกการแชร์ลง Firestore
  Future<void> _recordShareEvent({
    required String userId,
    required String listingId,
    required String platform,
    required String template,
    required String shareUrl,
    required String content,
    Map<String, dynamic>? customization,
  }) async {
    final share = SocialShare(
      id: '', // Firestore จะ generate
      listingId: listingId,
      userId: userId,
      platform: platform,
      contentType: 'card',
      templateId: template,
      shareUrl: shareUrl,
      shareContent: content,
      customization: customization,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('social_shares').add(share.toFirestore());
    
    // อัปเดต socialStats ของ listing
    await _updateListingStats(listingId, platform);
  }
  
  /// อัปเดตสถิติของ listing
  Future<void> _updateListingStats(String listingId, String platform) async {
    final docRef = _firestore.collection('market_listings').doc(listingId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final data = snapshot.data() as Map<String, dynamic>;
      final socialStats = data['socialStats'] as Map<String, dynamic>?;
      
      int totalShares = (socialStats?['totalShares'] ?? 0) + 1;
      
      // อัปเดต platform stats
      final platformStats = socialStats?['platformStats'] as Map<String, dynamic>? ?? {};
      final currentStats = platformStats[platform] as Map<String, dynamic>? ?? {};
      platformStats[platform] = {
        'platform': platform,
        'shares': (currentStats['shares'] ?? 0) + 1,
        'views': currentStats['views'] ?? 0,
        'clicks': currentStats['clicks'] ?? 0,
        'purchases': currentStats['purchases'] ?? 0,
      };
      
      transaction.update(docRef, {
        'socialStats.totalShares': totalShares,
        'socialStats.platformStats': platformStats,
        'socialStats.lastShared': Timestamp.now(),
      });
    });
  }
  
  /// ดึงสถิติการแชร์ของ listing
  Future<SocialStats> getShareStats(String listingId) async {
    final snapshot = await _firestore
        .collection('social_shares')
        .where('listingId', isEqualTo: listingId)
        .get();
    
    if (snapshot.docs.isEmpty) {
      return SocialStats();
    }
    
    // รวมสถิติ
    int totalShares = snapshot.docs.length;
    int totalViews = 0;
    int totalClicks = 0;
    int totalPurchases = 0;
    final platformStats = <String, PlatformStats>{};
    
    for (final doc in snapshot.docs) {
      final share = SocialShare.fromFirestore(doc);
      totalViews += share.viewCount;
      totalClicks += share.clickCount;
      totalPurchases += share.conversionCount;
      
      // รวมตาม platform
      if (!platformStats.containsKey(share.platform)) {
        platformStats[share.platform] = PlatformStats(
          platform: share.platform,
          shares: 0,
          views: 0,
          clicks: 0,
          purchases: 0,
        );
      }
      
      final current = platformStats[share.platform]!;
      platformStats[share.platform] = PlatformStats(
        platform: share.platform,
        shares: current.shares + 1,
        views: current.views + share.viewCount,
        clicks: current.clicks + share.clickCount,
        purchases: current.purchases + share.conversionCount,
      );
    }
    
    final lastShare = snapshot.docs.isNotEmpty
        ? (snapshot.docs.first.data()['createdAt'] as Timestamp).toDate()
        : null;
    
    return SocialStats(
      totalShares: totalShares,
      totalViews: totalViews,
      totalClicks: totalClicks,
      totalPurchases: totalPurchases,
      platformStats: platformStats,
      lastShared: lastShare,
    );
  }
  
  /// ดึงประวัติการแชร์ทั้งหมดของ user
  Stream<List<SocialShare>> getUserShares(String userId) {
    return _firestore
        .collection('social_shares')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialShare.fromFirestore(doc))
            .toList());
  }
  
  /// ดึง Top Performers (listings ที่แชร์ได้ผลดี)
  Future<List<String>> getTopPerformers({
    int limit = 10,
    String sortBy = 'conversion', // conversion, clicks, views
  }) async {
    final snapshot = await _firestore
        .collection('social_shares')
        .orderBy('conversionCount', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data()['listingId'] as String)
        .toSet()
        .toList();
  }
}
