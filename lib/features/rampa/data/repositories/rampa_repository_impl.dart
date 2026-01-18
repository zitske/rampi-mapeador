// lib/features/rampa/data/repositories/rampa_repository_impl.dart
import 'dart:typed_data';
import '../../domain/entities/rampa.dart';
import '../../domain/repositories/rampa_repository.dart';
import '../datasources/supabase_rampa_datasource.dart';
import '../models/rampa_model.dart';

class RampaRepositoryImpl implements RampaRepository {
  final SupabaseRampaDataSource remoteDataSource;

  RampaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadImage({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) =>
      remoteDataSource.uploadImage(
        userId: userId,
        imageBytes: imageBytes,
        fileName: fileName,
      );

  @override
  Future<String> addRampa({
    required String creatorId,
    required double latitude,
    required double longitude,
    required String fotoUrl,
    required int inclinacao,
    required int condicao,
  }) async {
    final inserted = await remoteDataSource.insertRampa(
      creatorId: creatorId,
      latitude: latitude,
      longitude: longitude,
      foto: fotoUrl,
      inclinacao: inclinacao,
      condicao: condicao,
    );
    return inserted['id'].toString();
  }

  @override
  Future<List<Rampa>> fetchAllRampas() async {
    final data = await remoteDataSource.fetchRampas();
    return data.map((m) => RampaModel.fromMap(m)).toList();
  }
}
