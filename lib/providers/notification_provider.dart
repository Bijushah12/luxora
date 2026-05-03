import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _storageKey = 'luxora_notifications';

  final List<AppNotification> _notifications = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<AppNotification> get notifications {
    final sorted = List<AppNotification>.from(_notifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  int get unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  Future<void> loadNotifications() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _notifications
          ..clear()
          ..addAll(
            decoded.map(
              (item) => AppNotification.fromMap(item as Map<String, dynamic>),
            ),
          );
      } else {
        _notifications.addAll(_initialNotifications());
        await _saveNotifications();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);

    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearRead() async {
    _notifications.removeWhere((notification) => notification.isRead);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  List<AppNotification> _initialNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'welcome-${now.microsecondsSinceEpoch}',
        type: 'account',
        title: 'Welcome to Luxora',
        subtitle: 'Your account is ready for luxury watch shopping.',
        createdAt: now,
        isRead: false,
      ),
      AppNotification(
        id: 'offer-${now.microsecondsSinceEpoch}',
        type: 'offer',
        title: 'Member offer unlocked',
        subtitle: 'Explore curated offers on premium collections.',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
    ];
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _notifications.map((notification) => notification.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}
