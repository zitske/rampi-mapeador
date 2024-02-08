import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rampi_mapeador/Model/rampa_class.dart';

class Database {
  Future<void> adicionar(Rampa rampa) async {
    try {
      await FirebaseFirestore.instance.collection('rampas').add({
        'coordenadas': rampa.coordenadas,
        'data_adicionado': rampa.dataAdicionado,
        'inclinacao': rampa.inclinacao,
        'condicao': rampa.condicao,
        'foto': rampa.foto,
      });
      print('Rampa added to Firebase');
    } catch (e) {
      print('Error adding rampa to Firebase: $e');
    }
  }

  Future<void> deletar() async {
    try {
      // Replace 'rampaId' with the actual ID of the rampa you want to delete
      await FirebaseFirestore.instance
          .collection('rampas')
          .doc('rampaId')
          .delete();
      print('Rampa deleted from Firebase');
    } catch (e) {
      print('Error deleting rampa from Firebase: $e');
    }
  }

  Future<void> editar(Rampa rampa) async {
    try {
      // Replace 'rampaId' with the actual ID of the rampa you want to edit
      await FirebaseFirestore.instance
          .collection('rampas')
          .doc('rampaId')
          .update({
        'coordenadas': rampa.coordenadas,
        'data_adicionado': rampa.dataAdicionado,
        'inclinacao': rampa.inclinacao,
        'condicao': rampa.condicao,
        'foto': rampa.foto,
      });
      print('Rampa edited on Firebase');
    } catch (e) {
      print('Error editing rampa on Firebase: $e');
    }
  }
}
