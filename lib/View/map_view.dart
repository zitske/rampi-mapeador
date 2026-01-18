import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rampi_mapeador/Model/rampa_class.dart';
import 'package:rampi_mapeador/services/supabase_service.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController mapController = MapController();
  LatLng? currentLocation;
  LatLng? userLocation; // Localização real do usuário
  bool isLoading = true;
  List<Rampa> rampas = [];
  bool isSatelliteView = true; // Inicia com visão satélite

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadRampas();
  }

  Future<void> _getCurrentLocation() async {
    // Define localização inicial padrão como UFSM
    setState(() {
      currentLocation = LatLng(
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
      setState(() {
        rampas = data.map((doc) {
          return Rampa(
            coordenadas: [doc['latitude'], doc['longitude']],
            dataAdicionado: doc['data_adicionado'],
            inclinacao: doc['inclinacao'],
            condicao: doc['condicao'],
            foto: doc['foto'],
            id: doc['id'].toString(),
          );
        }).toList();
      });
    } catch (e) {
      print('Erro ao carregar rampas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || currentLocation == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0191E2),
          title: Text('Mapa de Rampas'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0191E2),
        title: Text('Mapa de Rampas'),
      ),
      body: FlutterMap(
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
                return Marker(
                  point: LatLng(
                    rampa.coordenadas[0].toDouble(),
                    rampa.coordenadas[1].toDouble(),
                  ),
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    onTap: () {
                      _showRampaDetails(rampa);
                    },
                    child: Icon(
                      Icons.wheelchair_pickup,
                      color: _getColorByCondition(rampa.condicao),
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'mapView',
            onPressed: () {
              setState(() {
                isSatelliteView = !isSatelliteView;
              });
            },
            child: Icon(isSatelliteView ? Icons.map : Icons.satellite),
            tooltip: isSatelliteView ? 'Mapa' : 'Satélite',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'mapLocation',
            onPressed: () {
              if (userLocation != null) {
                mapController.move(userLocation!, 16.0);
              }
            },
            backgroundColor: userLocation != null ? null : Colors.grey,
            child: Icon(Icons.my_location),
            tooltip: 'Ir para Minha Localização',
          ),
        ],
      ),
    );
  }

  Color _getColorByCondition(int condicao) {
    switch (condicao) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showRampaDetails(Rampa rampa) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhes da Rampa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  rampa.foto,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text('Latitude: ${rampa.coordenadas[0]}'),
              Text('Longitude: ${rampa.coordenadas[1]}'),
              Text('Inclinação: ${rampa.inclinacao}°'),
              Text('Condição: ${_getConditionText(rampa.condicao)}'),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  mapController.move(
                    LatLng(
                      rampa.coordenadas[0].toDouble(),
                      rampa.coordenadas[1].toDouble(),
                    ),
                    18.0,
                  );
                  Navigator.pop(context);
                },
                icon: Icon(Icons.location_on),
                label: Text('Ir para localização'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getConditionText(int condicao) {
    switch (condicao) {
      case 1:
        return 'Boa';
      case 2:
        return 'Regular';
      case 3:
        return 'Ruim';
      default:
        return 'Não avaliada';
    }
  }
}
