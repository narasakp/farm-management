import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Service สำหรับแชร์ไปยัง LINE
class LineService {
  static const String _channelId = 'YOUR_LINE_CHANNEL_ID';
  static const String _channelSecret = 'YOUR_LINE_CHANNEL_SECRET';
  static const String _channelAccessToken = 'YOUR_CHANNEL_ACCESS_TOKEN';
  
  /// แชร์ไปยัง LINE (แบบ URL scheme)
  Future<bool> shareToLine({
    required String text,
    String? url,
  }) async {
    try {
      // สร้าง message
      final message = url != null ? '$text\n$url' : text;
      
      // LINE URL scheme
      final lineUrl = Uri.https('line.me', '/R/msg/text/', {
        'text': message,
      });
      
      // ลองเปิด LINE app ก่อน
      final appUrl = Uri.parse('line://msg/text/$message');
      final hasApp = await canLaunchUrl(appUrl);
      
      if (hasApp) {
        return await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      }
      
      // ถ้าไม่มี app ให้เปิด LINE web
      return await launchUrl(lineUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('❌ Error sharing to LINE: $e');
      return false;
    }
  }
  
  /// แชร์ไปยัง LINE Timeline
  Future<bool> shareToTimeline({
    required String text,
    String? imageUrl,
    String? linkUrl,
  }) async {
    try {
      // LINE Timeline sharing
      // Note: ต้องใช้ LINE Login SDK
      
      print('⚠️ LINE Timeline sharing requires LINE Login SDK');
      
      // For now, ใช้ general share
      return await shareToLine(text: text, url: linkUrl);
    } catch (e) {
      print('❌ Error sharing to LINE Timeline: $e');
      return false;
    }
  }
  
  /// ส่งข้อความผ่าน LINE Messaging API
  Future<bool> sendMessage({
    required String userId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final endpoint = 'https://api.line.me/v2/bot/message/push';
      
      final messages = <Map<String, dynamic>>[];
      
      // Text message
      messages.add({
        'type': 'text',
        'text': text,
      });
      
      // Image message
      if (imageUrl != null) {
        messages.add({
          'type': 'image',
          'originalContentUrl': imageUrl,
          'previewImageUrl': imageUrl,
        });
      }
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_channelAccessToken',
        },
        body: jsonEncode({
          'to': userId,
          'messages': messages,
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ Sent LINE message to user: $userId');
        return true;
      } else {
        print('❌ LINE API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending LINE message: $e');
      return false;
    }
  }
  
  /// ส่งข้อความแบบ Flex Message (rich message)
  Future<bool> sendFlexMessage({
    required String userId,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required String actionUrl,
  }) async {
    try {
      final endpoint = 'https://api.line.me/v2/bot/message/push';
      
      // สร้าง Flex Message
      final flexMessage = {
        'type': 'flex',
        'altText': title,
        'contents': {
          'type': 'bubble',
          'hero': {
            'type': 'image',
            'url': imageUrl,
            'size': 'full',
            'aspectRatio': '20:13',
            'aspectMode': 'cover',
          },
          'body': {
            'type': 'box',
            'layout': 'vertical',
            'contents': [
              {
                'type': 'text',
                'text': title,
                'weight': 'bold',
                'size': 'xl',
              },
              {
                'type': 'box',
                'layout': 'vertical',
                'margin': 'lg',
                'spacing': 'sm',
                'contents': [
                  {
                    'type': 'box',
                    'layout': 'baseline',
                    'spacing': 'sm',
                    'contents': [
                      {
                        'type': 'text',
                        'text': 'ราคา',
                        'color': '#aaaaaa',
                        'size': 'sm',
                        'flex': 1,
                      },
                      {
                        'type': 'text',
                        'text': '฿${price.toStringAsFixed(0)}',
                        'wrap': true,
                        'color': '#666666',
                        'size': 'sm',
                        'flex': 5,
                      },
                    ],
                  },
                ],
              },
              {
                'type': 'text',
                'text': description,
                'wrap': true,
                'color': '#666666',
                'size': 'sm',
                'margin': 'md',
              },
            ],
          },
          'footer': {
            'type': 'box',
            'layout': 'vertical',
            'spacing': 'sm',
            'contents': [
              {
                'type': 'button',
                'style': 'primary',
                'height': 'sm',
                'action': {
                  'type': 'uri',
                  'label': 'ดูรายละเอียด',
                  'uri': actionUrl,
                },
              },
            ],
            'flex': 0,
          },
        },
      };
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_channelAccessToken',
        },
        body: jsonEncode({
          'to': userId,
          'messages': [flexMessage],
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ Sent LINE Flex Message to user: $userId');
        return true;
      } else {
        print('❌ LINE API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending LINE Flex Message: $e');
      return false;
    }
  }
  
  /// สร้าง LINE-optimized message
  String generateOptimizedMessage({
    required String title,
    required String price,
    String? description,
    required String url,
  }) {
    final buffer = StringBuffer();
    
    // Title with emoji
    buffer.writeln('🐂 $title');
    buffer.writeln();
    
    // Price
    buffer.writeln('💰 ราคา: $price');
    
    // Description
    if (description != null && description.isNotEmpty) {
      buffer.writeln();
      final shortDesc = description.length > 150 
          ? '${description.substring(0, 150)}...'
          : description;
      buffer.writeln(shortDesc);
    }
    
    buffer.writeln();
    buffer.writeln('👉 คลิกเพื่อดูรายละเอียด:');
    buffer.write(url);
    
    return buffer.toString();
  }
  
  /// ตรวจสอบ LINE App ติดตั้งหรือไม่
  Future<bool> isLineAppInstalled() async {
    try {
      final lineUrl = Uri.parse('line://');
      return await canLaunchUrl(lineUrl);
    } catch (e) {
      return false;
    }
  }
  
  /// เปิด LINE Add Friend QR
  Future<bool> addFriend(String lineId) async {
    try {
      final addUrl = Uri.parse('https://line.me/R/ti/p/$lineId');
      return await launchUrl(
        addUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error adding LINE friend: $e');
      return false;
    }
  }
  
  /// เปิด LINE Official Account
  Future<bool> openOfficialAccount(String accountId) async {
    try {
      // LINE OA URL format: https://line.me/R/ti/p/@accountId
      final oaUrl = Uri.parse('https://line.me/R/ti/p/@$accountId');
      return await launchUrl(
        oaUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('❌ Error opening LINE OA: $e');
      return false;
    }
  }
  
  /// Broadcast message to multiple users
  Future<bool> broadcastMessage({
    required List<String> userIds,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final endpoint = 'https://api.line.me/v2/bot/message/multicast';
      
      final messages = <Map<String, dynamic>>[];
      
      messages.add({
        'type': 'text',
        'text': text,
      });
      
      if (imageUrl != null) {
        messages.add({
          'type': 'image',
          'originalContentUrl': imageUrl,
          'previewImageUrl': imageUrl,
        });
      }
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_channelAccessToken',
        },
        body: jsonEncode({
          'to': userIds,
          'messages': messages,
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ Broadcast message to ${userIds.length} users');
        return true;
      } else {
        print('❌ LINE API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error broadcasting message: $e');
      return false;
    }
  }
  
  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final endpoint = 'https://api.line.me/v2/bot/profile/$userId';
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $_channelAccessToken',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }
}
