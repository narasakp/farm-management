import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livestock.dart';
import 'base_repository.dart';

/// Repository for livestock data management
class LivestockRepository extends BaseRepository<Livestock> {
  @override
  CollectionReference get collection => 
      FirebaseFirestore.instance.collection('livestock');

  @override
  String get boxName => 'livestock_cache';

  @override
  Livestock fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Livestock(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
      healthStatus: data['healthStatus'] ?? 'healthy',
      farmId: data['farmId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toFirestore(Livestock item) {
    return {
      'name': item.name,
      'type': item.type,
      'breed': item.breed,
      'age': item.age,
      'weight': item.weight,
      'healthStatus': item.healthStatus,
      'farmId': item.farmId,
      'createdAt': Timestamp.fromDate(item.createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  @override
  Map<String, dynamic> toJson(Livestock item) {
    return {
      'id': item.id,
      'name': item.name,
      'type': item.type,
      'breed': item.breed,
      'age': item.age,
      'weight': item.weight,
      'healthStatus': item.healthStatus,
      'farmId': item.farmId,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
    };
  }

  @override
  Livestock fromJson(Map<String, dynamic> json) {
    return Livestock(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age'] ?? 0,
      weight: (json['weight'] ?? 0.0).toDouble(),
      healthStatus: json['healthStatus'] ?? 'healthy',
      farmId: json['farmId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Get livestock by farm ID
  Future<List<Livestock>> getByFarmId(String farmId) async {
    try {
      final snapshot = await collection
          .where('farmId', isEqualTo: farmId)
          .get();
      
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      // Fallback to cache and filter
      final allLivestock = await getAll();
      return allLivestock.where((livestock) => livestock.farmId == farmId).toList();
    }
  }

  /// Get livestock by type
  Future<List<Livestock>> getByType(String type) async {
    try {
      final snapshot = await collection
          .where('type', isEqualTo: type)
          .get();
      
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      // Fallback to cache and filter
      final allLivestock = await getAll();
      return allLivestock.where((livestock) => livestock.type == type).toList();
    }
  }
}
