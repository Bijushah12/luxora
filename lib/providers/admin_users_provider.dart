import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/admin_firestore_service.dart';

class AdminUsersProvider extends ChangeNotifier {
  final AdminFirestoreService _service;

  AdminUsersProvider({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  Stream<List<AdminAppUser>> usersStream() => _service.usersStream();

  Stream<AdminUserActivity> userActivityStream(String userId) {
    return _service.userActivityStream(userId);
  }
}
