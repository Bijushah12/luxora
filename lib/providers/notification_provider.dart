import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _storageKey = 'luxora_notifications';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<User?>? _authSubscription;

  final List<AppNotification> _notifications = [];
  bool _isLoaded = false;
  bool _disposed = false;

  NotificationProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(_loadForUser);
    _loadForUser(_auth.currentUser);
  }

  bool get isLoaded => _isLoaded;

  List<AppNotification> get notifications {
    final sorted = List<AppNotification>.from(_notifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  int get unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  Future<void> loadNotifications() async {
    if (_isLoaded) return;
    await _loadForUser(_auth.currentUser);
  }

  Future<void> _loadForUser(User? user) async {
    _isLoaded = false;
    _safeNotify();
    _notifications.clear();

    if (user == null) {
      await _loadLocalNotifications();
      _isLoaded = true;
      _safeNotify();
      return;
    }

    try {
      final doc = await _notificationsRef.doc(user.uid).get();
      final rawNotifications = doc.data()?['items'];

      if (rawNotifications is Iterable) {
        _notifications.addAll(
          rawNotifications
              .whereType<Map>()
              .map((item) => AppNotification.fromMap(_stringMap(item)))
              .where((notification) => notification.id.trim().isNotEmpty),
        );
      }

      if (_notifications.isEmpty) {
        _notifications.addAll(_initialNotifications());
        await _saveNotifications();
      }
    } catch (error) {
      debugPrint('Error loading cloud notifications: $error');
      await _loadLocalNotifications();
    }

    _isLoaded = true;
    _safeNotify();
  }

  Future<void> _loadLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _notifications
          ..clear()
          ..addAll(
            decoded.map(
              (item) => AppNotification.fromMap(_stringMap(item as Map)),
            ),
          );
      } else {
        _notifications.addAll(_initialNotifications());
        await _saveNotifications();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);

    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    await _saveNotifications();
    _safeNotify();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _saveNotifications();
    _safeNotify();
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }

    await _saveNotifications();
    _safeNotify();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await _saveNotifications();
    _safeNotify();
  }

  Future<void> clearRead() async {
    _notifications.removeWhere((notification) => notification.isRead);
    await _saveNotifications();
    _safeNotify();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    _safeNotify();
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

    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _notificationsRef.doc(user.uid).set({
        'userId': user.uid,
        'items': _notifications
            .map((notification) => notification.toMap())
            .toList(),
        'totalNotifications': _notifications.length,
        'unreadCount': unreadCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      debugPrint('Error saving cloud notifications: $error');
    }
  }

  Map<String, dynamic> _stringMap(Map<dynamic, dynamic> value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
