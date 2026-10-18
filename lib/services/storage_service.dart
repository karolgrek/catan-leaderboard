import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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

  Uint8List compressImageBytes(Uint8List rawBytes, {int maxDimension = 1440, int quality = 75}) {
    try {
      final img.Image? decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        debugPrint('Could not decode image, using raw bytes');
        return rawBytes;
      }

      img.Image resized = decoded;
      if (decoded.width > maxDimension || decoded.height > maxDimension) {
        if (decoded.width > decoded.height) {
          resized = img.copyResize(decoded, width: maxDimension);
        } else {
          resized = img.copyResize(decoded, height: maxDimension);
        }
      }

      final Uint8List compressed = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      debugPrint('Image compressed: ${rawBytes.length} bytes -> ${compressed.length} bytes (-${((1 - compressed.length / rawBytes.length) * 100).toStringAsFixed(1)}%)');
      return compressed;
    } catch (e) {
      debugPrint('Compression error, fallback to raw: $e');
      return rawBytes;
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
      
      debugPrint('Original photo size: ${bytes.length} bytes');
      final Uint8List uploadBytes = compressImageBytes(bytes);
      debugPrint('Uploading photo to: ${ref.fullPath} (${uploadBytes.length} bytes)');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      
      final UploadTask uploadTask = ref.putData(uploadBytes, metadata);
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
