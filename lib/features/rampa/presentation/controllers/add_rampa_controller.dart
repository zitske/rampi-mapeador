// lib/features/rampa/presentation/controllers/add_rampa_controller.dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/add_rampa_usecase.dart';
import '../providers/rampas_notifier.dart';

final addRampaUseCaseProvider =
    Provider<AddRampaUseCase>((ref) => throw UnimplementedError());

final addRampaControllerProvider =
    StateNotifierProvider<AddRampaController, AsyncValue<void>>(
  (ref) => AddRampaController(
      ref.read(addRampaUseCaseProvider), ref.read(rampasProvider.notifier)),
);

class AddRampaController extends StateNotifier<AsyncValue<void>> {
  final AddRampaUseCase _useCase;
  final RampasNotifier _rampasNotifier;

  AddRampaController(this._useCase, this._rampasNotifier)
      : super(const AsyncValue.data(null));

  Future<void> addRampaFlow({required String userId}) async {
    state = const AsyncValue.loading();
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final picker = ImagePicker();
      final XFile? photo =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (photo == null) {
        state = AsyncValue.data(null);
        return;
      }
      final bytes = await photo.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final params = AddRampaParams(
        creatorId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        imageBytes: bytes,
        fileName: fileName,
      );

      await _useCase.call(params);

      await _rampasNotifier.fetchRampas();

      state = AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
