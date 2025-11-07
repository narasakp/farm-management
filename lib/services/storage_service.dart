import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

/// Service for managing file uploads to Firebase Storage
/// 
/// Handles livestock product images with automatic
/// path organization and metadata management
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  /// Upload product images to Firebase Storage
  /// 
  /// Returns list of download URLs for the uploaded images
  /// 
  /// Path structure: livestock_images/{listingId}/{index}_{filename}
  /// 
  /// Example:
  /// ```dart
  /// final urls = await storageService.uploadProductImages(
  ///   imageBytes,
  ///   imageNames,
  ///   'listing_12345',
  /// );
  /// ```
  Future<List<String>> uploadProductImages(
    List<Uint8List> imageBytes,
    List<String> imageNames,
    String listingId,
  ) async {
    List<String> downloadUrls = [];
    
    for (int i = 0; i < imageBytes.length; i++) {
      try {
        // Create unique filename with index
        final fileName = '${i}_${imageNames[i]}';
        final ref = _storage.ref().child('livestock_images/$listingId/$fileName');
        
        // Set metadata
        final metadata = SettableMetadata(
          contentType: _getContentType(imageNames[i]),
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
            'listingId': listingId,
            'originalName': imageNames[i],
            'index': i.toString(),
          },
        );
        
        // Upload file
        print('📤 Uploading ${imageNames[i]} (${_formatBytes(imageBytes[i].length)})...');
        final uploadTask = ref.putData(imageBytes[i], metadata);
        
        // Wait for completion
        final snapshot = await uploadTask;
        
        // Get download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        
        print('✅ Uploaded: $downloadUrl');
        
      } catch (e) {
        print('❌ Error uploading ${imageNames[i]}: $e');
        // Continue with other files even if one fails
      }
    }
    
    return downloadUrls;
  }
  
  /// Upload single listing image (for edit/update)
  Future<String> uploadListingImage(
    Uint8List imageBytes,
    String uniqueId,
    String fileName,
  ) async {
    try {
      final path = 'livestock_images/$uniqueId/$fileName';
      final ref = _storage.ref().child(path);
      
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalName': fileName,
        },
      );
      
      print('📤 Uploading $fileName (${_formatBytes(imageBytes.length)})...');
      final uploadTask = ref.putData(imageBytes, metadata);
      final snapshot = await uploadTask;
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Uploaded: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading listing image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  /// Upload single image
  Future<String?> uploadSingleImage(
    Uint8List imageBytes,
    String fileName,
    String path,
  ) async {
    try {
      final ref = _storage.ref().child(path);
      
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      final uploadTask = ref.putData(imageBytes, metadata);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
      
    } catch (e) {
      print('❌ Error uploading single image: $e');
      return null;
    }
  }
  
  /// Delete product images by URLs
  /// 
  /// Example:
  /// ```dart
  /// await storageService.deleteProductImages(listing.images);
  /// ```
  Future<void> deleteProductImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
        print('🗑️ Deleted: $url');
      } catch (e) {
        print('❌ Error deleting image: $e');
      }
    }
  }
  
  /// Delete entire listing folder
  Future<void> deleteListingFolder(String listingId) async {
    try {
      final ref = _storage.ref().child('livestock_images/$listingId');
      final listResult = await ref.listAll();
      
      // Delete all files in folder
      for (final item in listResult.items) {
        await item.delete();
      }
      
      print('🗑️ Deleted folder: livestock_images/$listingId');
    } catch (e) {
      print('❌ Error deleting folder: $e');
    }
  }
  
  /// Get content type from file extension
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'jfif':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'application/octet-stream';
    }
  }
  
  /// Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  /// Get file size from URL (requires metadata read)
  Future<int?> getFileSize(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      final metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      print('❌ Error getting file size: $e');
      return null;
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }
}
