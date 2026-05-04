import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/admin_product.dart';
import '../services/admin_firestore_service.dart';
import '../services/admin_storage_service.dart';

class AdminProductsProvider extends ChangeNotifier {
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

  Future<bool> saveProduct(AdminProduct product, {XFile? image}) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    AdminImageUpload? uploadedImage;

    try {
      var productToSave = product;
      if (image != null) {
        uploadedImage = await _storageService.uploadProductImage(image);
        productToSave = product.copyWith(
          imageUrl: uploadedImage.downloadUrl,
          imagePath: uploadedImage.storagePath,
        );
      }

      if (productToSave.id.isEmpty) {
        await _firestoreService.addProduct(productToSave);
        _successMessage = 'Product added successfully.';
      } else {
        await _firestoreService.updateProduct(productToSave);
        _successMessage = 'Product updated successfully.';
      }

      if (uploadedImage != null &&
          product.imagePath.isNotEmpty &&
          product.imagePath != uploadedImage.storagePath) {
        try {
          await _storageService.deleteProductImage(product.imagePath);
        } catch (error) {
          debugPrint('Unable to clean old product image: $error');
        }
      }

      return true;
    } catch (error) {
      if (uploadedImage != null) {
        try {
          await _storageService.deleteProductImage(uploadedImage.storagePath);
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
      if (product.imagePath.isNotEmpty) {
        await _storageService.deleteProductImage(product.imagePath);
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
}
