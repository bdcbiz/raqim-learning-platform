import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _interactionsCollection => _firestore.collection('interactions');

  Future<void> saveUserToDatabase(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'photoUrl': user.photoUrl,
        'emailVerified': user.emailVerified,
        'createdAt': user.createdAt.toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
      });

      print('User saved to Firestore: ${user.email}');
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }

  Future<void> updateUserLastLogin(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  Future<UserModel?> getUserFromDatabase(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel(
          id: doc.id,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          photoUrl: data['photoUrl'],
          emailVerified: data['emailVerified'] ?? false,
          createdAt: DateTime.parse(data['createdAt']),
        );
      }
    } catch (e) {
      print('Error getting user from Firestore: $e');
    }
    return null;
  }

  Future<void> trackInteraction({
    required String userId,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    try {
      await _interactionsCollection.add({
        'userId': userId,
        'userEmail': details['userEmail'] ?? '',
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': kIsWeb ? 'web' : 'mobile',
        'deviceInfo': {
          'platform': defaultTargetPlatform.toString(),
          'isWeb': kIsWeb,
        },
      });

      print('Interaction tracked: $action for user $userId');
    } catch (e) {
      print('Error tracking interaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserInteractions(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _interactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user interactions: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamUserInteractions(String userId) {
    return _interactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final querySnapshot = await _interactionsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final interactions = querySnapshot.docs;
      final actionCounts = <String, int>{};

      for (final doc in interactions) {
        final action = (doc.data() as Map<String, dynamic>)['action'] as String;
        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
      }

      return {
        'totalInteractions': interactions.length,
        'actionCounts': actionCounts,
        'lastInteraction': interactions.isNotEmpty
            ? (interactions.first.data() as Map<String, dynamic>)['timestamp']
            : null,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'totalInteractions': 0,
        'actionCounts': {},
        'lastInteraction': null,
      };
    }
  }

  /// Update user photo URL
  Future<void> updateUserPhotoUrl(String userId, String photoUrl) async {
    try {
      await _usersCollection.doc(userId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User photo URL updated in Firestore');
    } catch (e) {
      print('Error updating user photo URL: $e');
      throw e;
    }
  }
}