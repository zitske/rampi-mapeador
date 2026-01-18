// lib/features/rampa/domain/entities/rampa.dart
class Rampa {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime dataAdicionado;
  final int inclinacao;
  final int condicao;
  final String foto;
  final String? endereco;

  const Rampa({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.dataAdicionado,
    required this.inclinacao,
    required this.condicao,
    required this.foto,
    this.endereco,
  });
}
