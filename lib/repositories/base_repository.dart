import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

/// Base repository pattern for data access with offline support
abstract class BaseRepository<T> {
  /// Firestore collection reference
  CollectionReference get collection;
  
  /// Hive box name for local caching
  String get boxName;
  
  /// Convert Firestore document to model
  T fromFirestore(DocumentSnapshot doc);
  
  /// Convert model to Firestore data
  Map<String, dynamic> toFirestore(T item);
  
  /// Convert model to JSON for Hive storage
  Map<String, dynamic> toJson(T item);
  
  /// Convert JSON to model from Hive storage
  T fromJson(Map<String, dynamic> json);

  /// Get Hive box for local caching
  Future<Box<Map<String, dynamic>>> _getBox() async {
    return await Hive.openBox<Map<String, dynamic>>(boxName);
  }

  /// Get all items with offline support
  Future<List<T>> getAll() async {
    try {
      // Try to fetch from Firestore first
      final snapshot = await collection.get();
      final items = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      
      // Cache in Hive for offline access
      final box = await _getBox();
      await box.clear();
      for (int i = 0; i < items.length; i++) {
        await box.put(i.toString(), toJson(items[i]));
      }
      
      if (kDebugMode) {
        print('✅ Fetched ${items.length} items from Firestore and cached locally');
      }
      
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Firestore fetch failed, loading from cache: $e');
      }
      
      // Fallback to cached data
      return await _getFromCache();
    }
  }

  /// Get items from local cache
  Future<List<T>> _getFromCache() async {
    try {
      final box = await _getBox();
      final items = <T>[];
      
      for (var key in box.keys) {
        final json = box.get(key);
        if (json != null) {
          items.add(fromJson(json));
        }
      }
      
      if (kDebugMode) {
        print('📱 Loaded ${items.length} items from local cache');
      }
      
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cache load failed: $e');
      }
      return [];
    }
  }

  /// Add new item
  Future<String> add(T item) async {
    try {
      final docRef = await collection.add(toFirestore(item));
      
      // Update local cache
      final box = await _getBox();
      await box.put(docRef.id, toJson(item));
      
      if (kDebugMode) {
        print('✅ Added item with ID: ${docRef.id}');
      }
      
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Add item failed: $e');
      }
      rethrow;
    }
  }

  /// Update existing item
  Future<void> update(String id, T item) async {
    try {
      await collection.doc(id).update(toFirestore(item));
      
      // Update local cache
      final box = await _getBox();
      await box.put(id, toJson(item));
      
      if (kDebugMode) {
        print('✅ Updated item with ID: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update item failed: $e');
      }
      rethrow;
    }
  }

  /// Delete item
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
      
      // Remove from local cache
      final box = await _getBox();
      await box.delete(id);
      
      if (kDebugMode) {
        print('✅ Deleted item with ID: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Delete item failed: $e');
      }
      rethrow;
    }
  }

  /// Get item by ID
  Future<T?> getById(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (doc.exists) {
        final item = fromFirestore(doc);
        
        // Cache the item
        final box = await _getBox();
        await box.put(id, toJson(item));
        
        return item;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Firestore get failed, checking cache: $e');
      }
      
      // Try to get from cache
      final box = await _getBox();
      final json = box.get(id);
      return json != null ? fromJson(json) : null;
    }
  }
}
