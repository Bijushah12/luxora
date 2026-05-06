import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerSupportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CustomerSupportService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _contactMessages =>
      _firestore.collection('contact_messages');

  CollectionReference<Map<String, dynamic>> get _chatbotQueries =>
      _firestore.collection('chatbot_queries');

  Future<void> submitContactMessage({
    required String name,
    required String email,
    required String phone,
    required String topic,
    required String subject,
    required String message,
  }) async {
    final user = _auth.currentUser;

    await _contactMessages.add({
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'topic': topic.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
      'status': 'new',
      'source': 'about_us',
      'userId': user?.uid,
      'userEmail': user?.email,
      'userDisplayName': user?.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitChatExchange({
    required String question,
    required String answer,
    required String intent,
  }) async {
    final user = _auth.currentUser;

    await _chatbotQueries.add({
      'question': question.trim(),
      'answer': answer.trim(),
      'intent': intent.trim(),
      'status': 'resolved',
      'source': 'about_us_assistant',
      'userId': user?.uid,
      'userEmail': user?.email,
      'userDisplayName': user?.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
