import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rampi_mapeador/features/rampa/presentation/providers/rampas_notifier.dart';
import 'package:rampi_mapeador/features/rampa/domain/entities/rampa.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController _mapController = MapController();
  LatLng? currentLocation;
  bool isSatelliteView = true;

  @override
  void initState() {
    super.initState();
    currentLocation = const LatLng(-29.7205, -53.7149);
  }

  @override
  Widget build(BuildContext context) {
    final rampasAsync = ref.watch(rampasProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0191E2),
        title: const Text('Mapa de Rampas'),
      ),
      body: rampasAsync.when(
        data: (rampas) => FlutterMap(
          mapController: _mapController,
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
              markers:
                  rampas.map((rampa) => _buildMarkerForRampa(rampa)).toList(),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar rampas: $e')),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'mapViewToggle',
            onPressed: () => setState(() => isSatelliteView = !isSatelliteView),
            child: Icon(isSatelliteView ? Icons.map : Icons.satellite),
          ),
        ],
      ),
    );
  }

  Marker _buildMarkerForRampa(Rampa rampa) {
    return Marker(
      point: LatLng(rampa.latitude, rampa.longitude),
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _showRampaDetails(rampa),
        child: Icon(Icons.wheelchair_pickup,
            color: _getColorByCondition(rampa.condicao), size: 40),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalhes da Rampa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(rampa.foto,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              Text('Latitude: ${rampa.latitude}'),
              Text('Longitude: ${rampa.longitude}'),
              Text('Inclinação: ${rampa.inclinacao}°'),
              Text('Condição: ${_getConditionText(rampa.condicao)}'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _mapController.move(
                      LatLng(rampa.latitude, rampa.longitude), 18.0);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Ir para localização'),
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
