// lib/features/rampa/domain/repositories/rampa_repository.dart
import 'dart:typed_data';
import '../entities/rampa.dart';

abstract class RampaRepository {
  Future<List<Rampa>> fetchAllRampas();
  Future<String> uploadImage({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  });
  Future<String> addRampa({
    required String creatorId,
    required double latitude,
    required double longitude,
    required String fotoUrl,
    required int inclinacao,
    required int condicao,
  });
}
