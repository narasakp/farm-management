import 'package:url_launcher/url_launcher.dart';

/// Service สำหรับแชร์ไปยัง TikTok
class TikTokService {
  static const String _appId = 'YOUR_TIKTOK_APP_ID'; // แก้ให้ตรงกับ App ID จริง
  
  /// แชร์ไปยัง TikTok (เปิดแอป TikTok)
  Future<bool> shareToTikTok({
    required String videoUrl,
    String? caption,
    List<String>? hashtags,
  }) async {
    try {
      // TikTok sharing URL scheme
      // สำหรับ Android: snssdk1233://
      // สำหรับ iOS: tiktok://
      
      // ตรวจสอบว่าติดตั้ง TikTok หรือไม่
      final hasTikTok = await isTikTokAppInstalled();
      
      if (hasTikTok) {
        // เปิดแอป TikTok
        final tiktokUrl = Uri.parse('tiktok://');
        return await launchUrl(
          tiktokUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // เปิด TikTok Web
        final webUrl = Uri.parse('https://www.tiktok.com/upload');
        return await launchUrl(
          webUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('❌ Error sharing to TikTok: $e');
      return false;
    }
  }
  
  /// แชร์ content พร้อมข้อความ
  Future<bool> shareContent({
    required String content,
    required String url,
    List<String>? hashtags,
  }) async {
    try {
      // TikTok Web share
      final shareUrl = Uri.https('www.tiktok.com', '/share', {
        'text': _formatCaption(content, hashtags),
        'url': url,
      });
      
      return await launchUrl(
        shareUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error sharing content to TikTok: $e');
      return false;
    }
  }
  
  /// เปิดหน้า Upload ของ TikTok พร้อม pre-fill caption
  Future<bool> openUploadWithCaption({
    required String caption,
    List<String>? hashtags,
  }) async {
    try {
      final fullCaption = _formatCaption(caption, hashtags);
      
      // เปิด TikTok upload page
      final uploadUrl = Uri.parse('https://www.tiktok.com/upload');
      
      final launched = await launchUrl(
        uploadUrl,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        print('✅ Opened TikTok upload page');
        print('📝 Caption: $fullCaption');
      }
      
      return launched;
    } catch (e) {
      print('❌ Error opening TikTok upload: $e');
      return false;
    }
  }
  
  /// Format caption พร้อม hashtags
  String _formatCaption(String caption, List<String>? hashtags) {
    final buffer = StringBuffer(caption);
    
    if (hashtags != null && hashtags.isNotEmpty) {
      buffer.write('\n\n');
      for (final tag in hashtags) {
        final formattedTag = tag.startsWith('#') ? tag : '#$tag';
        buffer.write('$formattedTag ');
      }
    }
    
    return buffer.toString();
  }
  
  /// ตรวจสอบ TikTok App ติดตั้งหรือไม่
  Future<bool> isTikTokAppInstalled() async {
    try {
      // Try iOS scheme
      final iosUrl = Uri.parse('tiktok://');
      final hasIOS = await canLaunchUrl(iosUrl);
      if (hasIOS) return true;
      
      // Try Android scheme
      final androidUrl = Uri.parse('snssdk1233://');
      final hasAndroid = await canLaunchUrl(androidUrl);
      return hasAndroid;
    } catch (e) {
      return false;
    }
  }
  
  /// เปิด TikTok Profile
  Future<bool> openProfile(String username) async {
    try {
      final profileUrl = Uri.parse('https://www.tiktok.com/@$username');
      return await launchUrl(
        profileUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error opening TikTok profile: $e');
      return false;
    }
  }
  
  /// สร้าง TikTok-optimized caption
  String generateOptimizedCaption({
    required String title,
    required String price,
    String? description,
    List<String>? customHashtags,
  }) {
    final buffer = StringBuffer();
    
    // Title with emoji
    buffer.writeln('🐂 $title');
    buffer.writeln();
    
    // Price
    buffer.writeln('💰 $price');
    
    // Description (short)
    if (description != null && description.isNotEmpty) {
      final shortDesc = description.length > 100 
          ? '${description.substring(0, 100)}...'
          : description;
      buffer.writeln(shortDesc);
    }
    
    buffer.writeln();
    
    // Hashtags (TikTok best practices: 3-5 hashtags)
    final hashtags = <String>[
      '#ปศุสัตว์',
      '#เกษตรกร',
      '#ทำฟาร์ม',
    ];
    
    if (customHashtags != null) {
      hashtags.addAll(customHashtags.take(2));
    }
    
    buffer.write(hashtags.take(5).join(' '));
    
    return buffer.toString();
  }
  
  /// Get TikTok recommended hashtags (based on content)
  List<String> getRecommendedHashtags(String livestockType) {
    final baseHashtags = ['#ปศุสัตว์', '#เกษตรกร', '#ทำฟาร์ม'];
    
    // Add type-specific hashtags
    if (livestockType.contains('โค') || livestockType.contains('cattle')) {
      baseHashtags.addAll(['#วัว', '#โคเนื้อ', '#โคนม']);
    } else if (livestockType.contains('กระบือ') || livestockType.contains('buffalo')) {
      baseHashtags.addAll(['#ควาย', '#กระบือ']);
    } else if (livestockType.contains('สุกร') || livestockType.contains('pig')) {
      baseHashtags.addAll(['#หมู', '#สุกร', '#หมูไทย']);
    } else if (livestockType.contains('ไก่') || livestockType.contains('chicken')) {
      baseHashtags.addAll(['#ไก่', '#ไก่ไข่', '#ไก่เนื้อ']);
    }
    
    // Add trending hashtags (can be updated periodically)
    baseHashtags.addAll(['#FYP', '#ForYou', '#ของดี']);
    
    return baseHashtags;
  }
  
  /// Generate short URL for TikTok bio
  String generateBioLink(String fullUrl) {
    // In production, use a URL shortener service
    // For now, return the original URL
    return fullUrl;
  }
}
