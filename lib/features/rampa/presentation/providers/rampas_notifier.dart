// lib/features/rampa/presentation/providers/rampas_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/rampa.dart';
import '../../domain/repositories/rampa_repository.dart';

final rampaRepositoryProvider =
    Provider<RampaRepository>((ref) => throw UnimplementedError());

final rampasProvider =
    StateNotifierProvider<RampasNotifier, AsyncValue<List<Rampa>>>(
  (ref) => RampasNotifier(ref.watch(rampaRepositoryProvider)),
);

class RampasNotifier extends StateNotifier<AsyncValue<List<Rampa>>> {
  final RampaRepository repository;

  RampasNotifier(this.repository) : super(const AsyncValue.loading()) {
    fetchRampas();
  }

  Future<void> fetchRampas() async {
    state = const AsyncValue.loading();
    try {
      final rampas = await repository.fetchAllRampas();
      state = AsyncValue.data(rampas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
