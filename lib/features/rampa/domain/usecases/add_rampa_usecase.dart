// lib/features/rampa/domain/usecases/add_rampa_usecase.dart
import 'dart:typed_data';
import '../repositories/rampa_repository.dart';

class AddRampaParams {
  final String creatorId;
  final double latitude;
  final double longitude;
  final Uint8List imageBytes;
  final String fileName;
  final int inclinacao;
  final int condicao;

  const AddRampaParams({
    required this.creatorId,
    required this.latitude,
    required this.longitude,
    required this.imageBytes,
    required this.fileName,
    this.inclinacao = 0,
    this.condicao = 0,
  });
}

class AddRampaUseCase {
  final RampaRepository repository;

  AddRampaUseCase(this.repository);

  Future<String> call(AddRampaParams params) async {
    final fotoUrl = await repository.uploadImage(
      userId: params.creatorId,
      imageBytes: params.imageBytes,
      fileName: params.fileName,
    );
    final rampaId = await repository.addRampa(
      creatorId: params.creatorId,
      latitude: params.latitude,
      longitude: params.longitude,
      fotoUrl: fotoUrl,
      inclinacao: params.inclinacao,
      condicao: params.condicao,
    );
    return rampaId;
  }
}
