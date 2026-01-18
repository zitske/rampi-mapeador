class Rampa {
  List<dynamic> coordenadas;
  int dataAdicionado;
  int inclinacao;
  int condicao;
  String foto;
  String id;
  String? endereco; // Campo para armazenar o endereço

  Rampa({
    required this.coordenadas,
    required this.dataAdicionado,
    required this.inclinacao,
    required this.condicao,
    required this.foto,
    required this.id,
    this.endereco,
  });
}
