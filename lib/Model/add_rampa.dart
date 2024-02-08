import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future<void> adicionar() async {
  final ImagePicker picker = ImagePicker();
  //Pega a localização do usuário
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  //Pega a foto
  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
  //Faz o upload da foto para o Firebase
  Future<String> uploadPhoto(XFile photo) async {
    try {
      // Create a reference to the Firebase Cloud Storage bucket
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('photos/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the photo to Firebase Cloud Storage
      final firebase_storage.UploadTask uploadTask =
          ref.putData(await photo.readAsBytes());

      // Wait for the upload to complete
      final firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded photo
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading photo to Firebase Cloud Storage: $e');
      return '';
    }
  }

  //Adiciona a rampa ao Firebase
  if (photo != null) {
    String photoId = await uploadPhoto(photo);
    try {
      await FirebaseFirestore.instance.collection('rampas').add({
        'coordenadas': position,
        'data_adicionado': DateTime.now().millisecondsSinceEpoch,
        'inclinacao': 0,
        'condicao': 0,
        'foto': photoId,
      });
      print('Rampa added to Firebase');
    } catch (e) {
      print('Error adding rampa to Firebase: $e');
    }
  }
}
