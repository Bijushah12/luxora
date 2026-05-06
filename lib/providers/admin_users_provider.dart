import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/admin_firestore_service.dart';

class AdminUsersProvider extends ChangeNotifier {
  final AdminFirestoreService _service;
  final Set<String> _updatingUserIds = {};
  String? _errorMessage;
  String? _successMessage;

  AdminUsersProvider({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Stream<List<AdminAppUser>> usersStream() => _service.usersStream();

  Stream<AdminUserActivity> userActivityStream(String userId) {
    return _service.userActivityStream(userId);
  }

  bool isUpdating(String userId) => _updatingUserIds.contains(userId);

  Future<bool> updateBlocked(AdminAppUser user, bool isBlocked) async {
    _updatingUserIds.add(user.id);
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.updateUserBlocked(user.id, isBlocked);
      _successMessage = isBlocked
          ? 'User blocked successfully.'
          : 'User unblocked successfully.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to update user access. $error';
      return false;
    } finally {
      _updatingUserIds.remove(user.id);
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
