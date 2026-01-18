import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rampi_mapeador/services/supabase_service.dart';

Future<void> adicionar() async {
  final ImagePicker picker = ImagePicker();
  //Pega a localização do usuário
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  //Pega a foto
  final XFile? photo =
      await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

  //Adiciona a rampa ao Supabase
  if (photo != null) {
    try {
      final user = SupabaseService.getCurrentUser();
      if (user != null) {
        final photoBytes = await photo.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload da foto
        final bucket = SupabaseService.client.storage.from('rampi-bucket');
        final filePath = '${user.id}/$fileName';

        await bucket.uploadBinary(filePath, photoBytes);
        final publicUrl = bucket.getPublicUrl(filePath);

        // Inserir rampa no banco
        await SupabaseService.insertRampa(
          coordenadas: [position.latitude, position.longitude],
          inclinacao: 0,
          condicao: 0,
          foto: publicUrl,
          creatorId: user.id,
        );
        print('Rampa added to Supabase');
      }
    } catch (e) {
      print('Error adding rampa to Supabase: $e');
    }
  }
}
