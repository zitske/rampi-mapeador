import 'package:flutter/material.dart';
import 'package:rampi_mapeador/Model/rampa_class.dart';
import 'package:rampi_mapeador/View/widgets/toggle.dart';
import 'package:rampi_mapeador/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WhiteCard extends StatelessWidget {
  WhiteCard(this.rampa, this.blocked);

  final Rampa rampa;
  final bool blocked;

  Future<String> _getEndereco() async {
    try {
      if (rampa.endereco != null && rampa.endereco!.isNotEmpty) {
        return rampa.endereco!;
      }

      final lat = rampa.coordenadas[0].toDouble();
      final lng = rampa.coordenadas[1].toDouble();

      print('Obtendo endereço para: lat=$lat, lng=$lng');

      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng'),
        headers: {'User-Agent': 'RampiMapeador/1.0'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final endereco = data['address'] ?? {};

        // Montando endereço com informações disponíveis
        final numero = endereco['house_number'] ?? '';
        final rua = endereco['road'] ?? endereco['street'] ?? '';
        final ruaComNumero = numero.isNotEmpty ? '$rua, $numero' : rua;
        final cidade =
            endereco['city'] ?? endereco['town'] ?? endereco['village'] ?? '';
        final bairro = endereco['suburb'] ?? endereco['neighbourhood'] ?? '';

        final enderecoCombinado = [ruaComNumero, bairro, cidade]
            .where((s) => s.isNotEmpty)
            .join(', ')
            .trim();

        print('Endereço obtido: $enderecoCombinado');
        rampa.endereco = enderecoCombinado.isNotEmpty
            ? enderecoCombinado
            : 'Endereço não disponível';
        return rampa.endereco!;
      } else {
        print('Erro na requisição: ${response.statusCode}');
        return 'Endereço não disponível';
      }
    } catch (e) {
      print('Erro ao obter endereço: $e');
      return 'Endereço não disponível';
    }
  }

  @override
  Widget build(BuildContext context) {
    var date = DateTime.fromMillisecondsSinceEpoch(rampa.dataAdicionado);
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return Dismissible(
      direction: blocked ? DismissDirection.none : DismissDirection.horizontal,
      key: UniqueKey(),
      onDismissed: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          print('start to end');
          try {
            await SupabaseService.client.from('rampas').update({
              'review': true,
              'approved': false,
              'assessment': false,
            }).eq('id', rampa.id);
            print('Rampa updated on Supabase');
          } catch (e) {
            print('Error updating rampa on Supabase: $e');
          }
        } else {
          try {
            await SupabaseService.client
                .from('rampas')
                .delete()
                .eq('id', rampa.id);
            print('Rampa deleted from Supabase');
          } catch (e) {
            print('Error deleting rampa from Supabase: $e');
          }
        }
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          Icons.send,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.0),
        margin: EdgeInsets.symmetric(vertical: 10.0),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        margin: EdgeInsets.symmetric(vertical: 10.0),
      ),
      child: Card(
        elevation: 4, // Adjust the elevation for the drop shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              15), // Adjust the border radius for rounded corners
        ),
        color: Colors.white,
        child: Container(
          //width: 200, // Adjust the width of the card as needed
          height: 130, // Adjust the height of the card as needed
          // Add your content here
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80.0,
                          width: 80.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(rampa.foto,
                                height: 80.0, width: 80.0, fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Endereço',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              FutureBuilder<String>(
                                future: _getEndereco(),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Carregando...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text("Adicionado em ${formattedDate}")
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Inclinação',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ToggleSwitch(
                    index: rampa.inclinacao,
                    selector: true,
                    id: rampa.id,
                    blocked: blocked,
                  ),
                  Spacer(),
                  Text(
                    'Condição',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ToggleSwitch(
                      index: rampa.condicao,
                      selector: false,
                      id: rampa.id,
                      blocked: blocked),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
