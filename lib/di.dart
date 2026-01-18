// lib/di.dart
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/rampa/data/datasources/supabase_rampa_datasource.dart';
import 'features/rampa/data/repositories/rampa_repository_impl.dart';
import 'features/rampa/domain/repositories/rampa_repository.dart';
import 'features/rampa/domain/usecases/add_rampa_usecase.dart';
import 'features/rampa/presentation/providers/rampas_notifier.dart';
import 'features/rampa/presentation/controllers/add_rampa_controller.dart';

final supabaseRampaDataSourceProvider = riverpod.Provider((ref) {
  return SupabaseRampaDataSource(client: Supabase.instance.client);
});

final rampaRepositoryImplProvider = riverpod.Provider<RampaRepository>((ref) {
  final ds = ref.read(supabaseRampaDataSourceProvider);
  return RampaRepositoryImpl(remoteDataSource: ds);
});

final rampaRepositoryProvider = riverpod.Provider<RampaRepository>(
    (ref) => ref.read(rampaRepositoryImplProvider));

final addRampaUseCaseProvider = riverpod.Provider(
    (ref) => AddRampaUseCase(ref.read(rampaRepositoryProvider)));

// Overrides to connect to providers defined in files
final rampaRepositoryProviderOverride = riverpod.Provider<RampaRepository>(
    (ref) => ref.read(rampaRepositoryImplProvider));
final addRampaUseCaseProviderOverride = riverpod.Provider<AddRampaUseCase>(
    (ref) => ref.read(addRampaUseCaseProvider));
