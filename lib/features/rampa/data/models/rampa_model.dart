// lib/features/rampa/data/models/rampa_model.dart
import '../../domain/entities/rampa.dart';

class RampaModel extends Rampa {
  const RampaModel({
    required String id,
    required double latitude,
    required double longitude,
    required DateTime dataAdicionado,
    required int inclinacao,
    required int condicao,
    required String foto,
    String? endereco,
  }) : super(
          id: id,
          latitude: latitude,
          longitude: longitude,
          dataAdicionado: dataAdicionado,
          inclinacao: inclinacao,
          condicao: condicao,
          foto: foto,
          endereco: endereco,
        );

  factory RampaModel.fromMap(Map<String, dynamic> map) {
    final dateValue = map['data_adicionado'];
    DateTime parsedDate;
    if (dateValue is String) {
      parsedDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else if (dateValue is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      parsedDate = DateTime.now();
    }

    return RampaModel(
      id: map['id'].toString(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      dataAdicionado: parsedDate,
      inclinacao: map['inclinacao'] ?? 0,
      condicao: map['condicao'] ?? 0,
      foto: map['foto'] ?? '',
      endereco: map['endereco'],
    );
  }
}
