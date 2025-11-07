import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Service สำหรับแชร์ไปยัง X (Twitter)
class TwitterService {
  static const String _apiKey = 'YOUR_TWITTER_API_KEY';
  static const String _apiSecret = 'YOUR_TWITTER_API_SECRET';
  static const String _bearerToken = 'YOUR_BEARER_TOKEN';
  
  /// แชร์ไปยัง X (Twitter) แบบ Web Intent
  Future<bool> shareToTwitter({
    required String text,
    required String url,
    List<String>? hashtags,
  }) async {
    try {
      // สร้าง tweet text
      final tweetText = _formatTweetText(text, hashtags);
      
      // Twitter Web Intent URL
      final intentUrl = Uri.https('twitter.com', '/intent/tweet', {
        'text': tweetText,
        'url': url,
      });
      
      return await launchUrl(
        intentUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error sharing to Twitter: $e');
      return false;
    }
  }
  
  /// Post tweet ผ่าน API (ต้องมี OAuth token)
  Future<bool> postTweet({
    required String accessToken,
    required String accessTokenSecret,
    required String text,
    String? mediaUrl,
  }) async {
    try {
      final endpoint = 'https://api.twitter.com/2/tweets';
      
      final body = {
        'text': text,
        if (mediaUrl != null) 'media': {'media_ids': []},
      };
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Posted to Twitter: ${data['data']['id']}');
        return true;
      } else {
        print('❌ Twitter API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error posting to Twitter: $e');
      return false;
    }
  }
  
  /// Format tweet text with hashtags
  String _formatTweetText(String text, List<String>? hashtags) {
    final buffer = StringBuffer(text);
    
    if (hashtags != null && hashtags.isNotEmpty) {
      buffer.write('\n\n');
      for (final tag in hashtags) {
        final formattedTag = tag.startsWith('#') ? tag : '#$tag';
        buffer.write('$formattedTag ');
      }
    }
    
    return buffer.toString();
  }
  
  /// สร้าง Twitter-optimized text (280 characters limit)
  String generateOptimizedTweet({
    required String title,
    required String price,
    String? description,
    required String url,
    List<String>? customHashtags,
  }) {
    final buffer = StringBuffer();
    
    // Title with emoji (keep it short)
    buffer.write('🐂 $title\n');
    
    // Price
    buffer.write('💰 $price\n');
    
    // Description (very short for Twitter)
    if (description != null && description.isNotEmpty) {
      final shortDesc = description.length > 60 
          ? '${description.substring(0, 60)}...'
          : description;
      buffer.write('$shortDesc\n');
    }
    
    buffer.write('\n');
    
    // Hashtags (Twitter best practices: 1-3 hashtags)
    final hashtags = <String>[];
    if (customHashtags != null && customHashtags.isNotEmpty) {
      hashtags.addAll(customHashtags.take(2));
    } else {
      hashtags.addAll(['#ปศุสัตว์', '#เกษตรกร']);
    }
    
    buffer.write(hashtags.join(' '));
    buffer.write('\n\n');
    
    // URL (will be auto-shortened by Twitter)
    buffer.write('➡️ $url');
    
    // ตรวจสอบความยาว (280 characters)
    final text = buffer.toString();
    if (text.length > 280) {
      // Trim description
      return generateOptimizedTweet(
        title: title,
        price: price,
        description: description != null && description.length > 30
            ? description.substring(0, 30)
            : null,
        url: url,
        customHashtags: customHashtags,
      );
    }
    
    return text;
  }
  
  /// สร้าง Twitter Thread (multiple tweets)
  List<String> generateThread({
    required String title,
    required String price,
    required String description,
    required String url,
    Map<String, String>? details,
  }) {
    final tweets = <String>[];
    
    // Tweet 1: Main info
    tweets.add(
      '🐂 $title\n\n'
      '💰 $price\n\n'
      '#ปศุสัตว์ #เกษตรกร'
    );
    
    // Tweet 2: Description
    if (description.isNotEmpty) {
      final chunks = _splitText(description, 250);
      for (final chunk in chunks) {
        tweets.add(chunk);
      }
    }
    
    // Tweet 3: Details
    if (details != null && details.isNotEmpty) {
      final buffer = StringBuffer('📋 รายละเอียด:\n\n');
      details.forEach((key, value) {
        buffer.write('• $key: $value\n');
      });
      tweets.add(buffer.toString());
    }
    
    // Final tweet: Call to action
    tweets.add(
      '👉 สนใจติดต่อได้ที่:\n'
      '$url\n\n'
      '#ขายปศุสัตว์ #ของดี'
    );
    
    return tweets;
  }
  
  /// Split text into chunks
  List<String> _splitText(String text, int maxLength) {
    final chunks = <String>[];
    var currentChunk = StringBuffer();
    
    final words = text.split(' ');
    for (final word in words) {
      if (currentChunk.length + word.length + 1 > maxLength) {
        chunks.add(currentChunk.toString().trim());
        currentChunk = StringBuffer();
      }
      currentChunk.write('$word ');
    }
    
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.toString().trim());
    }
    
    return chunks;
  }
  
  /// Generate Twitter Card metadata
  Map<String, String> generateTwitterCard({
    required String title,
    required String description,
    required String imageUrl,
    required String url,
  }) {
    return {
      'twitter:card': 'summary_large_image',
      'twitter:title': title,
      'twitter:description': description,
      'twitter:image': imageUrl,
      'twitter:url': url,
    };
  }
  
  /// ตรวจสอบ Twitter App ติดตั้งหรือไม่
  Future<bool> isTwitterAppInstalled() async {
    try {
      final twitterUrl = Uri.parse('twitter://');
      return await canLaunchUrl(twitterUrl);
    } catch (e) {
      return false;
    }
  }
  
  /// เปิด Twitter profile
  Future<bool> openProfile(String username) async {
    try {
      // ลองเปิดใน app ก่อน
      final appUrl = Uri.parse('twitter://user?screen_name=$username');
      final hasApp = await canLaunchUrl(appUrl);
      
      if (hasApp) {
        return await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      }
      
      // ถ้าไม่มี app ให้เปิด web
      final webUrl = Uri.parse('https://twitter.com/$username');
      return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('❌ Error opening Twitter profile: $e');
      return false;
    }
  }
  
  /// Get tweet engagement stats (requires API access)
  Future<Map<String, int>?> getTweetStats(String tweetId) async {
    try {
      final endpoint = 'https://api.twitter.com/2/tweets/$tweetId';
      final response = await http.get(
        Uri.parse('$endpoint?tweet.fields=public_metrics'),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final metrics = data['data']['public_metrics'];
        
        return {
          'retweets': metrics['retweet_count'] ?? 0,
          'likes': metrics['like_count'] ?? 0,
          'replies': metrics['reply_count'] ?? 0,
          'quotes': metrics['quote_count'] ?? 0,
        };
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting tweet stats: $e');
      return null;
    }
  }
}
