import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/admin_product.dart';
import '../services/admin_firestore_service.dart';
import '../services/admin_storage_service.dart';

class AdminProductsProvider extends ChangeNotifier {
  static const Duration _saveTimeout = Duration(seconds: 20);

  final AdminFirestoreService _firestoreService;
  final AdminStorageService _storageService;

  bool _isSaving = false;
  final Set<String> _deletingProductIds = {};
  String? _errorMessage;
  String? _successMessage;

  AdminProductsProvider({
    AdminFirestoreService? firestoreService,
    AdminStorageService? storageService,
  }) : _firestoreService = firestoreService ?? AdminFirestoreService(),
       _storageService = storageService ?? AdminStorageService();

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Stream<List<AdminProduct>> productsStream() =>
      _firestoreService.productsStream();

  bool isDeleting(String productId) => _deletingProductIds.contains(productId);

  Future<bool> saveProduct(
    AdminProduct product, {
    XFile? image,
    List<XFile> images = const [],
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final uploadedImages = <AdminImageUpload>[];

    try {
      var productToSave = product;
      String uploadWarning = '';
      final imagesToUpload = [
        ...?(image == null ? null : [image]),
        ...images,
      ];

      if (imagesToUpload.isNotEmpty) {
        try {
          uploadedImages.addAll(
            await _storageService
                .uploadProductImages(imagesToUpload)
                .timeout(_saveTimeout),
          );
          final galleryUrls = _mergeStrings([
            ...product.imageUrls,
            product.imageUrl,
            ...uploadedImages.map((upload) => upload.downloadUrl),
          ]);
          final galleryPaths = _mergeStrings([
            ...product.imagePaths,
            product.imagePath,
            ...uploadedImages.map((upload) => upload.storagePath),
          ]);

          productToSave = product.copyWith(
            imageUrl: galleryUrls.first,
            imagePath: galleryPaths.isEmpty ? '' : galleryPaths.first,
            imageUrls: galleryUrls,
            imagePaths: galleryPaths,
          );
        } catch (uploadError) {
          if (product.primaryImageUrl.trim().isEmpty) {
            rethrow;
          }
          try {
            for (final upload in uploadedImages) {
              await _storageService.deleteProductImage(upload.storagePath);
            }
          } catch (cleanupError) {
            debugPrint('Unable to clean partial product image: $cleanupError');
          }
          uploadedImages.clear();
          uploadWarning = ' Image upload failed, default image used.';
          debugPrint('Product image upload failed: $uploadError');
        }
      }

      if (productToSave.id.isEmpty) {
        await _firestoreService.addProduct(productToSave).timeout(_saveTimeout);
        _successMessage = 'Product added successfully.$uploadWarning';
      } else {
        await _firestoreService
            .updateProduct(productToSave)
            .timeout(_saveTimeout);
        _successMessage = 'Product updated successfully.$uploadWarning';
      }

      return true;
    } on TimeoutException {
      _errorMessage =
          'Product save timed out. Check Firebase rules/network, then try again.';
      return false;
    } catch (error) {
      if (uploadedImages.isNotEmpty) {
        try {
          for (final upload in uploadedImages) {
            await _storageService.deleteProductImage(upload.storagePath);
          }
        } catch (cleanupError) {
          debugPrint('Unable to clean uploaded product image: $cleanupError');
        }
      }
      _errorMessage = 'Unable to save product. $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(AdminProduct product) async {
    _deletingProductIds.add(product.id);
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteProduct(product.id);
      final paths = _mergeStrings([product.imagePath, ...product.imagePaths]);
      for (final path in paths) {
        await _storageService.deleteProductImage(path);
      }
      _successMessage = 'Product deleted successfully.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to delete product. $error';
      return false;
    } finally {
      _deletingProductIds.remove(product.id);
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  List<String> _mergeStrings(List<String> values) {
    final seen = <String>{};
    final merged = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) {
        continue;
      }
      seen.add(trimmed);
      merged.add(trimmed);
    }
    return merged;
  }
}
