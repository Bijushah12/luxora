import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AdminImageUpload {
  final String downloadUrl;
  final String storagePath;

  const AdminImageUpload({
    required this.downloadUrl,
    required this.storagePath,
  });
}

class AdminStorageService {
  final FirebaseStorage _storage;

  AdminStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<AdminImageUpload> uploadProductImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final extension = _extensionFor(image.name);
    final safeName = image.name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final storagePath =
        'product_images/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final reference = _storage.ref(storagePath);

    final task = await reference.putData(
      bytes,
      SettableMetadata(contentType: _contentTypeFor(extension)),
    );

    return AdminImageUpload(
      downloadUrl: await task.ref.getDownloadURL(),
      storagePath: storagePath,
    );
  }

  Future<void> deleteProductImage(String storagePath) async {
    final path = storagePath.trim();
    if (path.isEmpty) {
      return;
    }

    try {
      await _referenceFor(path).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found' && error.code != 'not-found') {
        rethrow;
      }
    }
  }

  Reference _referenceFor(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') ||
        pathOrUrl.startsWith('https://') ||
        pathOrUrl.startsWith('gs://')) {
      return _storage.refFromURL(pathOrUrl);
    }
    return _storage.ref(pathOrUrl);
  }

  static String _extensionFor(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) {
      return 'jpg';
    }
    return parts.last.toLowerCase();
  }

  static String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
