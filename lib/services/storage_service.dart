import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'catan-leaderboard-1be8b.firebasestorage.app');
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<XFile?> takePhoto() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
      );
    } catch (e) {
      debugPrint('Error taking photo: $e');
      // Fallback to gallery if camera fails (common on web)
      return await pickImage();
    }
  }

  Future<String?> uploadRoundPhotoBytes({
    required Uint8List bytes,
    required String fileNameHint,
    required String groupId,
    required String sessionId,
    required String roundId,
    required String photoType,
  }) async {
    try {
      final String extension = fileNameHint.contains('.')
          ? '.${fileNameHint.split('.').last}'
          : '.jpg';
      final String fileName = '${photoType}_${DateTime.now().millisecondsSinceEpoch}$extension';
      
      final Reference ref = _storage.ref().child('groups/$groupId/sessions/$sessionId/rounds/$roundId/$fileName');
      
      debugPrint('Uploading photo to: ${ref.fullPath} (${bytes.length} bytes)');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      
      final UploadTask uploadTask = ref.putData(bytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e, stack) {
      debugPrint('Error uploading photo: $e\n$stack');
      rethrow;
    }
  }
}
