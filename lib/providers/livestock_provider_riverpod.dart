import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/livestock.dart';
import '../repositories/livestock_repository.dart';

/// Livestock repository provider
final livestockRepositoryProvider = Provider<LivestockRepository>((ref) {
  return LivestockRepository();
});

/// Livestock list provider with async loading
final livestockListProvider = FutureProvider<List<Livestock>>((ref) async {
  final repository = ref.read(livestockRepositoryProvider);
  return await repository.getAll();
});

/// Livestock by farm ID provider
final livestockByFarmProvider = FutureProvider.family<List<Livestock>, String>((ref, farmId) async {
  final repository = ref.read(livestockRepositoryProvider);
  return await repository.getByFarmId(farmId);
});

/// Livestock by type provider
final livestockByTypeProvider = FutureProvider.family<List<Livestock>, String>((ref, type) async {
  final repository = ref.read(livestockRepositoryProvider);
  return await repository.getByType(type);
});

/// Livestock notifier for state management
class LivestockNotifier extends StateNotifier<AsyncValue<List<Livestock>>> {
  final LivestockRepository _repository;

  LivestockNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLivestock();
  }

  /// Load all livestock
  Future<void> loadLivestock() async {
    state = const AsyncValue.loading();
    try {
      final livestock = await _repository.getAll();
      state = AsyncValue.data(livestock);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add new livestock
  Future<void> addLivestock(Livestock livestock) async {
    try {
      await _repository.add(livestock);
      await loadLivestock(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update livestock
  Future<void> updateLivestock(String id, Livestock livestock) async {
    try {
      await _repository.update(id, livestock);
      await loadLivestock(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete livestock
  Future<void> deleteLivestock(String id) async {
    try {
      await _repository.delete(id);
      await loadLivestock(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Livestock state notifier provider
final livestockNotifierProvider = StateNotifierProvider<LivestockNotifier, AsyncValue<List<Livestock>>>((ref) {
  final repository = ref.read(livestockRepositoryProvider);
  return LivestockNotifier(repository);
});
