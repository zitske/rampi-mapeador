import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SupabaseService {
  static const String supabaseUrl =
      'https://zitske-group-rampi-supabase.o0p0en.easypanel.host';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q';

  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  // Autenticação
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'email': email,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  static Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  // Rampas
  static Future<List<Map<String, dynamic>>> fetchRampas() async {
    try {
      final response = await _client
          .from('rampas')
          .select()
          //.eq('approved', true)
          .order('id', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUserRampas({
    required String userId,
    String? status, // 'assessment', 'review', 'approved'
  }) async {
    try {
      var query = _client.from('rampas').select().eq('creator_id', userId);

      if (status != null) {
        if (status == 'assessment') {
          query = query
              .eq('assessment', true)
              .eq('review', false)
              .eq('approved', false);
        } else if (status == 'review') {
          query = query.eq('review', true).eq('approved', false);
        } else if (status == 'approved') {
          query = query.eq('approved', true);
        }
      }

      final response = await query.order('id', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> insertRampa({
    required String creatorId,
    required List<double> coordenadas,
    required String foto,
    required int inclinacao,
    required int condicao,
  }) async {
    try {
      final response = await _client.from('rampas').insert({
        'creator_id': creatorId,
        'latitude': coordenadas[0],
        'longitude': coordenadas[1],
        'foto': foto,
        'inclinacao': inclinacao,
        'condicao': condicao,
        'assessment': true,
        'review': false,
        'approved': false,
        'data_adicionado': DateTime.now().toIso8601String(),
      }).select();

      if (response.isNotEmpty) {
        return response[0]['id'].toString();
      }
      throw Exception('Failed to insert rampa');
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> uploadRampaImage({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final bucket = _client.storage.from('rampi-bucket');
      final filePath = '$userId/$fileName';

      await bucket.uploadBinary(
        filePath,
        imageBytes,
      );

      final publicUrl = bucket.getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Usuário perfil
  static Future<Map<String, dynamic>?> getUserProfile({
    required String userId,
  }) async {
    try {
      final response =
          await _client.from('usuarios').select().eq('id', userId).single();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required String name,
  }) async {
    try {
      await _client.from('usuarios').update({
        'name': name,
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
