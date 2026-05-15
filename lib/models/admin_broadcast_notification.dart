import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBroadcastNotification {
  final String id;
  final String title;
  final String message;
  final String audience;
  final String type;
  final bool isScheduled;
  final DateTime? scheduledAt;
  final DateTime? createdAt;

  const AdminBroadcastNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.type,
    required this.isScheduled,
    this.scheduledAt,
    this.createdAt,
  });

  factory AdminBroadcastNotification.empty() {
    return const AdminBroadcastNotification(
      id: '',
      title: '',
      message: '',
      audience: 'All customers',
      type: 'offer',
      isScheduled: false,
    );
  }

  factory AdminBroadcastNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return AdminBroadcastNotification(
      id: snapshot.id,
      title: _string(data['title']),
      message: _string(data['message']),
      audience: _string(data['audience']).trim().isEmpty
          ? 'All customers'
          : _string(data['audience']),
      type: _string(data['type']).trim().isEmpty
          ? 'offer'
          : _string(data['type']),
      isScheduled: data['isScheduled'] as bool? ?? false,
      scheduledAt: _toDateTime(data['scheduledAt']),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'message': message.trim(),
      'audience': audience,
      'type': type,
      'isScheduled': isScheduled,
      'scheduledAt': scheduledAt == null
          ? null
          : Timestamp.fromDate(scheduledAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

String _string(dynamic value) => value?.toString() ?? '';

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
