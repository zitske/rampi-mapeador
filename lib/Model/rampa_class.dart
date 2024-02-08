import 'dart:html';
import 'package:geolocator/geolocator.dart';

class Rampa {
  Position coordenadas;
  int dataAdicionado;
  num inclinacao;
  num condicao;
  String foto;
  String id;

  Rampa({
    required this.coordenadas,
    required this.dataAdicionado,
    required this.inclinacao,
    required this.condicao,
    required this.foto,
    required this.id,
  });
}
