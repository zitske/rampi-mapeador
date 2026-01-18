// Legacy mutable model kept for backwards compatibility with existing Views/widgets.
// Prefer using the new immutable domain entity in `features/rampa/domain/entities/rampa.dart`.

import 'package:rampi_mapeador/features/rampa/domain/entities/rampa.dart'
    as domain;

class Rampa {
  List<dynamic> coordenadas;
  int dataAdicionado; // epoch ms
  int inclinacao;
  int condicao;
  String foto;
  String id;
  String?
      endereco; // Campo para armazenar o endereço (mutável para compatibilidade)

  Rampa({
    required this.coordenadas,
    required this.dataAdicionado,
    required this.inclinacao,
    required this.condicao,
    required this.foto,
    required this.id,
    this.endereco,
  });

  factory Rampa.fromMap(Map<String, dynamic> map) => Rampa(
        coordenadas: [map['latitude'], map['longitude']],
        dataAdicionado: map['data_adicionado'] is String
            ? DateTime.tryParse(map['data_adicionado'])
                    ?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch
            : (map['data_adicionado'] is int
                ? map['data_adicionado']
                : DateTime.now().millisecondsSinceEpoch),
        inclinacao: map['inclinacao'] ?? 0,
        condicao: map['condicao'] ?? 0,
        foto: map['foto'] ?? '',
        id: map['id'].toString(),
        endereco: map['endereco'],
      );

  factory Rampa.fromDomain(domain.Rampa domainRampa) => Rampa(
        coordenadas: [domainRampa.latitude, domainRampa.longitude],
        dataAdicionado: domainRampa.dataAdicionado.millisecondsSinceEpoch,
        inclinacao: domainRampa.inclinacao,
        condicao: domainRampa.condicao,
        foto: domainRampa.foto,
        id: domainRampa.id,
        endereco: domainRampa.endereco,
      );
}
