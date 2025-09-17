// Temporarily using local storage instead of Firestore due to Firebase configuration issues
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // Local storage keys
  static const String _usersKey = 'firestore_users';
  static const String _interactionsKey = 'firestore_interactions';

  Future<void> saveUserToDatabase(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      users[user.id] = {
        'email': user.email,
        'name': user.name,
        'photoUrl': user.photoUrl,
        'emailVerified': user.emailVerified,
        'createdAt': user.createdAt.toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
      };

      await prefs.setString(_usersKey, jsonEncode(users));
      print('User saved to local storage: ${user.email}');
    } catch (e) {
      print('Error saving user to local storage: $e');
    }
  }

  Future<void> updateUserLastLogin(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (users.containsKey(userId)) {
        users[userId]['lastLoginAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_usersKey, jsonEncode(users));
      }
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  Future<UserModel?> getUserFromDatabase(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (users.containsKey(userId)) {
        final data = users[userId];
        return UserModel(
          id: userId,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          photoUrl: data['photoUrl'],
          emailVerified: data['emailVerified'] ?? false,
          createdAt: DateTime.parse(data['createdAt']),
        );
      }
    } catch (e) {
      print('Error getting user from local storage: $e');
    }
    return null;
  }

  Future<void> trackInteraction({
    required String userId,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getString(_interactionsKey) ?? '[]';
      final interactions = List<Map<String, dynamic>>.from(jsonDecode(interactionsJson));

      interactions.add({
        'id': 'interaction_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'userEmail': details['userEmail'] ?? '',
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
        'deviceInfo': {
          'platform': defaultTargetPlatform.toString(),
          'isWeb': kIsWeb,
        },
      });

      // Keep only last 1000 interactions to avoid storage issues
      if (interactions.length > 1000) {
        interactions.removeRange(0, interactions.length - 1000);
      }

      await prefs.setString(_interactionsKey, jsonEncode(interactions));
      print('Interaction tracked: $action for user $userId');
    } catch (e) {
      print('Error tracking interaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserInteractions(String userId, {int limit = 50}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getString(_interactionsKey) ?? '[]';
      final allInteractions = List<Map<String, dynamic>>.from(jsonDecode(interactionsJson));

      // Filter by userId and sort by timestamp
      final userInteractions = allInteractions
          .where((interaction) => interaction['userId'] == userId)
          .toList()
          ..sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

      // Apply limit
      return userInteractions.take(limit).toList();
    } catch (e) {
      print('Error getting user interactions: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamUserInteractions(String userId) {
    // Create a stream that emits the current interactions and updates periodically
    return Stream.periodic(const Duration(seconds: 5), (i) async {
      return await getUserInteractions(userId);
    }).asyncMap((future) => future);
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getString(_interactionsKey) ?? '[]';
      final allInteractions = List<Map<String, dynamic>>.from(jsonDecode(interactionsJson));

      // Filter by userId
      final userInteractions = allInteractions
          .where((interaction) => interaction['userId'] == userId)
          .toList();

      final actionCounts = <String, int>{};

      for (final interaction in userInteractions) {
        final action = interaction['action'] as String;
        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
      }

      DateTime? lastInteractionTime;
      if (userInteractions.isNotEmpty) {
        // Sort to get the most recent
        userInteractions.sort((a, b) =>
          DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
        lastInteractionTime = DateTime.parse(userInteractions.first['timestamp']);
      }

      return {
        'totalInteractions': userInteractions.length,
        'actionCounts': actionCounts,
        'lastInteraction': lastInteractionTime?.toIso8601String(),
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
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (users.containsKey(userId)) {
        users[userId]['photoUrl'] = photoUrl;
        users[userId]['updatedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_usersKey, jsonEncode(users));
        print('User photo URL updated in local storage');
      }
    } catch (e) {
      print('Error updating user photo URL: $e');
      rethrow;
    }
  }
}