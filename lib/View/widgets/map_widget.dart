import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rampi_mapeador/Model/rampa_class.dart';
import 'package:rampi_mapeador/services/supabase_service.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapController mapController = MapController();
  LatLng? currentLocation;
  LatLng? userLocation; // Localização real do usuário
  bool isLoading = true;
  List<Rampa> rampas = [];
  bool isSatelliteView = true; // Inicia com visão satélite
  Rampa? selectedRampa; // Rampa selecionada para exibir detalhes

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadRampas();
  }

  Future<void> _getCurrentLocation() async {
    // Define localização inicial padrão como UFSM
    setState(() {
      currentLocation = const LatLng(
          -29.7205, -53.7149); // UFSM - Universidade Federal de Santa Maria
      isLoading = false;
    });

    // Tenta obter localização real do usuário em background
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Erro ao obter localização do usuário: $e');
      // Mantém a localização da UFSM se não conseguir obter a do usuário
      userLocation = currentLocation;
    }
  }

  Future<void> _loadRampas() async {
    try {
      final data = await SupabaseService.fetchRampas();
      print('========== CARREGAMENTO DE RAMPAS ==========');
      print('Total de rampas retornadas: ${data.length}');

      setState(() {
        rampas = data.map((doc) {
          print('---');
          print('ID: ${doc['id']}');
          print(
              'Latitude (tipo: ${doc['latitude'].runtimeType}): ${doc['latitude']}');
          print(
              'Longitude (tipo: ${doc['longitude'].runtimeType}): ${doc['longitude']}');
          print('Condição: ${doc['condicao']}');
          print('Foto: ${doc['foto']}');

          final lat = doc['latitude'] is String
              ? double.parse(doc['latitude'])
              : (doc['latitude'] ?? 0).toDouble();
          final lng = doc['longitude'] is String
              ? double.parse(doc['longitude'])
              : (doc['longitude'] ?? 0).toDouble();

          print('Lat convertida: $lat, Lng convertida: $lng');

          // Conversão segura de tipos para campos que podem ser String ou int
          int parseIntValue(dynamic value, int defaultValue) {
            if (value == null) return defaultValue;
            if (value is int) return value;
            if (value is String) {
              try {
                return int.parse(value);
              } catch (e) {
                print('Erro ao converter string para int: $value');
                return defaultValue;
              }
            }
            return defaultValue;
          }

          final dataAdicionado = parseIntValue(doc['data_adicionado'], 0);
          final inclinacao = parseIntValue(doc['inclinacao'], 0);
          final condicao = parseIntValue(doc['condicao'], 0);

          print(
              'Valores convertidos: dataAdicionado=$dataAdicionado, inclinacao=$inclinacao, condicao=$condicao');

          return Rampa(
            coordenadas: [lat, lng],
            dataAdicionado: dataAdicionado,
            inclinacao: inclinacao,
            condicao: condicao,
            foto: doc['foto'] ?? '',
            id: doc['id'].toString(),
          );
        }).toList();
        print('========== FIM CARREGAMENTO ==========');
        print('Total de rampas no state: ${rampas.length}');
      });
    } catch (e) {
      print('Erro ao carregar rampas: $e');
      print(e.toString());
    }
  }

  Color _getColorByCondition(int condicao) {
    switch (condicao) {
      case 0:
        return Colors.red; // Ruim
      case 1:
        return Colors.orange; // Regular
      case 2:
        return Colors.green; // Bom
      default:
        return Colors.grey;
    }
  }

  Future<String> _getEndereco(Rampa rampa) async {
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
      ).timeout(const Duration(seconds: 5));

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

  void _showRampaDetails(Rampa rampa) {
    setState(() {
      selectedRampa = rampa;
    });
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildRampaCard(rampa),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildRampaCard(Rampa rampa) {
    final conditionLabels = ['Ruim', 'Regular', 'Bom'];
    final conditionColors = [Colors.red, Colors.orange, Colors.green];
    final inclinationLabels = ['Leve', 'Moderada', 'Acentuada'];

    return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Imagem da rampa - menor e clicável
                          if (rampa.foto.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _showExpandedImage(rampa);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: Image.network(
                                      rampa.foto,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                              Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Endereço
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Endereço',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Endereço
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Endereço',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<String>(
                                    future: _getEndereco(rampa),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? 'Carregando...',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Inclinação e Condição em uma linha
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Inclinação',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0191E2)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFF0191E2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                rampa.inclinacao == 0
                                                    ? Icons.trending_flat
                                                    : rampa.inclinacao == 1
                                                        ? Icons.trending_up
                                                        : Icons.show_chart,
                                                color: const Color(0xFF0191E2),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                rampa.inclinacao <
                                                        inclinationLabels.length
                                                    ? inclinationLabels[
                                                        rampa.inclinacao]
                                                    : 'Desconhecida',
                                                style: const TextStyle(
                                                  color: Color(0xFF0191E2),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Condição',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                conditionColors[rampa.condicao]
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: conditionColors[
                                                  rampa.condicao],
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                rampa.condicao == 0
                                                    ? Icons
                                                        .sentiment_very_dissatisfied
                                                    : rampa.condicao == 1
                                                        ? Icons
                                                            .sentiment_neutral
                                                        : Icons
                                                            .sentiment_very_satisfied,
                                                color: conditionColors[
                                                    rampa.condicao],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                conditionLabels[rampa.condicao],
                                                style: TextStyle(
                                                  color: conditionColors[
                                                      rampa.condicao],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Botão de fechar
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0191E2),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Fechar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _showExpandedImage(Rampa rampa) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  rampa.foto,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('MapWidget rebuild - rampas count: ${rampas.length}');
    if (isLoading || currentLocation == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentLocation!,
            initialZoom: 15.0,
            minZoom: 5.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: isSatelliteView
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.rampi_mapeador',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                // Marcadores das rampas aprovadas
                ...rampas.map((rampa) {
                  final lat = rampa.coordenadas[0] is double
                      ? rampa.coordenadas[0]
                      : (rampa.coordenadas[0] as num).toDouble();
                  final lng = rampa.coordenadas[1] is double
                      ? rampa.coordenadas[1]
                      : (rampa.coordenadas[1] as num).toDouble();

                  print('Criando marcador: ID=${rampa.id}, lat=$lat, lng=$lng');

                  final isSelected = selectedRampa?.id == rampa.id;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: isSelected ? 60 : 50,
                    height: isSelected ? 60 : 50,
                    child: GestureDetector(
                      onTap: () {
                        print('Marcador tocado: ${rampa.id}');
                        _showRampaDetails(rampa);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getColorByCondition(rampa.condicao),
                          boxShadow: [
                            BoxShadow(
                              color: _getColorByCondition(rampa.condicao)
                                  .withOpacity(0.5),
                              blurRadius: isSelected ? 15 : 8,
                              spreadRadius: isSelected ? 3 : 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.wheelchair_pickup,
                          color: Colors.white,
                          size: isSelected ? 32 : 28,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        isSatelliteView = !isSatelliteView;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        isSatelliteView ? Icons.map : Icons.satellite,
                        color: const Color(0xFF0191E2),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (userLocation != null) {
                        mapController.move(userLocation!, 16.0);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.my_location,
                        color: userLocation != null
                            ? const Color(0xFF0191E2)
                            : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
