import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Service สำหรับแชร์ไปยัง Facebook
class FacebookService {
  static const String _appId = 'YOUR_FACEBOOK_APP_ID'; // แก้ให้ตรงกับ App ID จริง
  static const String _graphApiUrl = 'https://graph.facebook.com/v18.0';
  
  /// แชร์ไปยัง Facebook (แบบ Web Share)
  Future<bool> shareToFacebook({
    required String url,
    String? quote,
    String? hashtag,
  }) async {
    try {
      // สร้าง Facebook share URL
      final shareUrl = Uri.https('www.facebook.com', '/sharer/sharer.php', {
        'u': url,
        if (quote != null) 'quote': quote,
        if (hashtag != null) 'hashtag': hashtag,
      });
      
      // เปิด URL
      final launched = await launchUrl(
        shareUrl,
        mode: LaunchMode.externalApplication,
      );
      
      return launched;
    } catch (e) {
      print('❌ Error sharing to Facebook: $e');
      return false;
    }
  }
  
  /// แชร์ไปยัง Facebook Feed (ต้องใช้ Access Token)
  Future<bool> shareToFeed({
    required String accessToken,
    required String message,
    required String link,
    String? picture,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_graphApiUrl/me/feed'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'link': link,
          if (picture != null) 'picture': picture,
          'access_token': accessToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Posted to Facebook: ${data['id']}');
        return true;
      } else {
        print('❌ Facebook API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error posting to Facebook: $e');
      return false;
    }
  }
  
  /// แชร์ไปยัง Facebook Story
  Future<bool> shareToStory({
    required String stickerAssetUrl,
    String? backgroundAssetUrl,
  }) async {
    try {
      // Facebook Stories sharing ใช้ URL scheme
      final params = {
        'sticker_asset': stickerAssetUrl,
        if (backgroundAssetUrl != null) 'background_asset': backgroundAssetUrl,
        'app_id': _appId,
      };
      
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final storyUrl = Uri.parse('https://www.facebook.com/dialog/share_to_story?$queryString');
      
      return await launchUrl(
        storyUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error sharing to Facebook Story: $e');
      return false;
    }
  }
  
  /// แชร์ไปยัง Facebook Marketplace
  Future<bool> shareToMarketplace({
    required String title,
    required String description,
    required double price,
    required String currency,
    required String imageUrl,
    required String location,
  }) async {
    try {
      // Facebook Marketplace API endpoint
      // Note: ต้องมี special permissions
      print('⚠️ Facebook Marketplace sharing requires special permissions');
      
      // สำหรับตอนนี้ให้เปิด Marketplace URL
      final marketplaceUrl = Uri.parse('https://www.facebook.com/marketplace/create');
      
      return await launchUrl(
        marketplaceUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error sharing to Marketplace: $e');
      return false;
    }
  }
  
  /// แชร์ไปยัง Facebook Group
  Future<bool> shareToGroup({
    required String groupId,
    required String message,
    required String link,
  }) async {
    try {
      final shareUrl = Uri.https('www.facebook.com', '/groups/$groupId', {
        'message': message,
        'link': link,
      });
      
      return await launchUrl(
        shareUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error sharing to Facebook Group: $e');
      return false;
    }
  }
  
  /// ตรวจสอบ Facebook App ติดตั้งหรือไม่
  Future<bool> isFacebookAppInstalled() async {
    try {
      final fbUrl = Uri.parse('fb://');
      return await canLaunchUrl(fbUrl);
    } catch (e) {
      return false;
    }
  }
  
  /// Get Facebook share count (จำนวนครั้งที่ share)
  Future<int> getShareCount(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$_graphApiUrl/?id=${Uri.encodeComponent(url)}&fields=engagement'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['engagement']?['share_count'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      print('❌ Error getting share count: $e');
      return 0;
    }
  }
  
  /// Generate Facebook Open Graph tags
  Map<String, String> generateOGTags({
    required String title,
    required String description,
    required String url,
    required String imageUrl,
    String type = 'website',
  }) {
    return {
      'og:title': title,
      'og:description': description,
      'og:url': url,
      'og:image': imageUrl,
      'og:type': type,
      'og:site_name': 'Farm Management App',
      'fb:app_id': _appId,
    };
  }
}
