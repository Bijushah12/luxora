import 'package:flutter/material.dart';

import '../models/admin_broadcast_notification.dart';
import '../services/admin_firestore_service.dart';

class AdminNotificationsProvider extends ChangeNotifier {
  final AdminFirestoreService _service;

  bool _isSaving = false;
  final Set<String> _deletingNotificationIds = {};
  String? _errorMessage;
  String? _successMessage;

  AdminNotificationsProvider({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Stream<List<AdminBroadcastNotification>> notificationsStream() {
    return _service.adminNotificationsStream();
  }

  bool isDeleting(String notificationId) {
    return _deletingNotificationIds.contains(notificationId);
  }

  Future<bool> save(AdminBroadcastNotification notification) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.saveAdminNotification(notification);
      _successMessage = notification.id.isEmpty
          ? 'Notification draft created.'
          : 'Notification updated.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to save notification. $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> send(AdminBroadcastNotification notification) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.sendAdminNotification(notification);
      _successMessage = 'Notification queued for push delivery.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to queue notification. $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String notificationId) async {
    _deletingNotificationIds.add(notificationId);
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.deleteAdminNotification(notificationId);
      _successMessage = 'Notification deleted.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to delete notification. $error';
      return false;
    } finally {
      _deletingNotificationIds.remove(notificationId);
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
