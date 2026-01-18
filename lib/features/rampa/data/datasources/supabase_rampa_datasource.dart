// lib/features/rampa/data/datasources/supabase_rampa_datasource.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRampaDataSource {
  final SupabaseClient client;

  SupabaseRampaDataSource({required this.client});

  Future<List<Map<String, dynamic>>> fetchRampas() async {
    final response =
        await client.from('rampas').select().order('id', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<String> uploadImage({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final bucket = client.storage.from('rampi-bucket');
    final filePath = '$userId/$fileName';
    await bucket.uploadBinary(filePath, imageBytes);
    return bucket.getPublicUrl(filePath);
  }

  Future<Map<String, dynamic>> insertRampa({
    required String creatorId,
    required double latitude,
    required double longitude,
    required String foto,
    required int inclinacao,
    required int condicao,
  }) async {
    final response = await client.from('rampas').insert({
      'creator_id': creatorId,
      'latitude': latitude,
      'longitude': longitude,
      'foto': foto,
      'inclinacao': inclinacao,
      'condicao': condicao,
      'assessment': true,
      'review': false,
      'approved': false,
      'data_adicionado': DateTime.now().toIso8601String(),
    }).select();
    if (response.isNotEmpty) {
      return Map<String, dynamic>.from(response[0]);
    }
    throw Exception('Falha ao inserir rampa');
  }
}
