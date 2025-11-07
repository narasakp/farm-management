import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../models/trading.dart';
import '../../models/livestock.dart';
import 'template_generator.dart';

/// Service สำหรับ upload รูปภาพไปยัง Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TemplateGenerator _templateGenerator = TemplateGenerator();
  
  /// Upload template image และคืน URL
  Future<Map<String, String>> uploadShareImages({
    required String listingId,
    required MarketListing listing,
    required Livestock livestock,
    required String template,
    String? livestockImageUrl,
    Map<String, dynamic>? customization,
  }) async {
    try {
      print('🔄 Uploading share images for listing: $listingId');
      
      final urls = <String, String>{};
      
      // สร้างรูปภาพจาก template
      final image = await _templateGenerator.generateImage(
        template: template,
        listing: listing,
        livestock: livestock,
        imageUrl: livestockImageUrl,
        customization: customization,
      );
      
      if (image == null) {
        throw Exception('Failed to generate image');
      }
      
      // แปลงเป็น bytes
      final bytes = await _templateGenerator.exportAsBytes(image);
      if (bytes == null) {
        throw Exception('Failed to export image');
      }
      
      // Upload สำหรับแต่ละ platform (ขนาดต่างกัน)
      final platforms = {
        'facebook': _resizeForFacebook,
        'tiktok': _resizeForTikTok,
        'twitter': _resizeForTwitter,
        'line': _resizeForLine,
      };
      
      for (final entry in platforms.entries) {
        final platform = entry.key;
        final resizeFunc = entry.value;
        
        // Resize สำหรับแต่ละ platform
        final resizedBytes = await resizeFunc(Uint8List.fromList(bytes));
        
        // Upload
        final url = await _uploadToStorage(
          bytes: resizedBytes,
          listingId: listingId,
          platform: platform,
          template: template,
        );
        
        if (url != null) {
          urls[platform] = url;
          print('✅ Uploaded $platform: $url');
        }
      }
      
      return urls;
    } catch (e) {
      print('❌ Error uploading images: $e');
      rethrow;
    }
  }
  
  /// Upload ไฟล์ไปยัง Firebase Storage
  Future<String?> _uploadToStorage({
    required Uint8List bytes,
    required String listingId,
    required String platform,
    required String template,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'share_images/$listingId/${platform}_${template}_$timestamp.png';
      
      // Upload
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/png',
          customMetadata: {
            'listingId': listingId,
            'platform': platform,
            'template': template,
          },
        ),
      );
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading to storage: $e');
      return null;
    }
  }
  
  /// Resize สำหรับ Facebook (1200x630)
  Future<Uint8List> _resizeForFacebook(Uint8List bytes) async {
    // Facebook recommended: 1200x630 (1.91:1)
    return bytes; // For now, return original
    // TODO: Implement actual resize with image package
  }
  
  /// Resize สำหรับ TikTok (1080x1920)
  Future<Uint8List> _resizeForTikTok(Uint8List bytes) async {
    // TikTok: 1080x1920 (9:16)
    return bytes;
  }
  
  /// Resize สำหรับ Twitter (1200x675)
  Future<Uint8List> _resizeForTwitter(Uint8List bytes) async {
    // Twitter: 1200x675 (16:9)
    return bytes;
  }
  
  /// Resize สำหรับ LINE (1040x1040)
  Future<Uint8List> _resizeForLine(Uint8List bytes) async {
    // LINE: Square or 16:9
    return bytes;
  }
  
  /// Delete share images
  Future<void> deleteShareImages(String listingId) async {
    try {
      final ref = _storage.ref().child('share_images/$listingId');
      final listResult = await ref.listAll();
      
      for (final item in listResult.items) {
        await item.delete();
      }
      
      print('✅ Deleted share images for listing: $listingId');
    } catch (e) {
      print('❌ Error deleting images: $e');
    }
  }
  
  /// Get all share images for a listing
  Future<List<String>> getShareImages(String listingId) async {
    try {
      final ref = _storage.ref().child('share_images/$listingId');
      final listResult = await ref.listAll();
      
      final urls = <String>[];
      for (final item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('❌ Error getting images: $e');
      return [];
    }
  }
  
  /// Upload livestock image (from camera/gallery)
  Future<String?> uploadLivestockImage({
    required String listingId,
    required Uint8List imageBytes,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'livestock_images/$listingId/image_$timestamp.jpg';
      
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'listingId': listingId,
            'type': 'livestock',
          },
        ),
      );
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Uploaded livestock image: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading livestock image: $e');
      return null;
    }
  }
  
  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats(String listingId) async {
    try {
      final ref = _storage.ref().child('share_images/$listingId');
      final listResult = await ref.listAll();
      
      int totalSize = 0;
      int fileCount = listResult.items.length;
      
      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }
      
      return {
        'fileCount': fileCount,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('❌ Error getting storage stats: $e');
      return {'fileCount': 0, 'totalSize': 0, 'totalSizeMB': '0.00'};
    }
  }
}
