import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Service for uploading images to Cloudinary
/// 
/// Free tier: 25 GB storage, 25 GB bandwidth/month
class CloudinaryService {
  // TODO: Replace with your Cloudinary credentials
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiSecret = 'YOUR_API_SECRET';
  static const String uploadPreset = 'livestock_images'; // Create this in Cloudinary Dashboard
  
  /// Upload single image to Cloudinary
  /// 
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      
      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );
      
      // Add upload preset (unsigned upload)
      request.fields['upload_preset'] = uploadPreset;
      
      // Add folder
      request.fields['folder'] = 'livestock_images';
      
      // Send request
      print('📤 Uploading $fileName to Cloudinary...');
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        final secureUrl = jsonData['secure_url'] as String;
        
        print('✅ Uploaded: $secureUrl');
        return secureUrl;
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        return null;
      }
      
    } catch (e) {
      print('❌ Error uploading to Cloudinary: $e');
      return null;
    }
  }
  
  /// Upload multiple images
  /// 
  /// Returns list of secure URLs
  Future<List<String>> uploadImages(
    List<Uint8List> imageBytesList,
    List<String> fileNames,
  ) async {
    List<String> urls = [];
    
    for (int i = 0; i < imageBytesList.length; i++) {
      final url = await uploadImage(imageBytesList[i], fileNames[i]);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }
  
  /// Delete image from Cloudinary
  /// 
  /// Requires public_id extracted from URL
  Future<bool> deleteImage(String publicId) async {
    try {
      // Generate signature for authenticated request
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(publicId, timestamp);
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');
      
      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );
      
      if (response.statusCode == 200) {
        print('🗑️ Deleted: $publicId');
        return true;
      } else {
        print('❌ Delete failed: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error deleting from Cloudinary: $e');
      return false;
    }
  }
  
  /// Generate SHA1 signature for authenticated requests
  String _generateSignature(String publicId, int timestamp) {
    // Note: This is a simplified version
    // In production, you should use crypto package for proper SHA1
    return 'placeholder_signature'; // TODO: Implement proper signature
  }
  
  /// Extract public_id from Cloudinary URL
  /// 
  /// Example: https://res.cloudinary.com/xxx/image/upload/v123/livestock_images/cow.jpg
  /// Returns: livestock_images/cow
  String? extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find 'upload' segment
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex + 2 >= pathSegments.length) {
        return null;
      }
      
      // Skip version (v123456)
      final startIndex = uploadIndex + 2;
      
      // Get remaining path without extension
      final publicIdParts = pathSegments.sublist(startIndex);
      final publicId = publicIdParts.join('/').replaceAll(RegExp(r'\.[^.]+$'), '');
      
      return publicId;
      
    } catch (e) {
      print('❌ Error extracting public_id: $e');
      return null;
    }
  }
}
