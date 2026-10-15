import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Kompresia
    );
  }

  Future<XFile?> takePhoto() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // Kompresia
    );
  }

  Future<String?> uploadRoundPhoto(
    XFile imageFile, 
    String groupId, 
    String sessionId, 
    String roundId, 
    String photoType
  ) async {
    try {
      final String extension = imageFile.name.contains('.')
          ? '.${imageFile.name.split('.').last}'
          : '.jpg';
      final String fileName = '${photoType}_${DateTime.now().millisecondsSinceEpoch}$extension';
      
      final Reference ref = _storage.ref().child('groups/$groupId/sessions/$sessionId/rounds/$roundId/$fileName');
      
      final bytes = await imageFile.readAsBytes();
      final metadata = SettableMetadata(
        contentType: imageFile.mimeType ?? 'image/jpeg',
      );
      
      final UploadTask uploadTask = ref.putData(bytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      return null;
    }
  }
}
