import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

/// Local database service that persists user data
/// Uses SharedPreferences for simplicity and cross-platform compatibility
class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static const String _usersCollectionKey = 'local_db_users';
  static const String _currentUserKey = 'local_db_current_user';

  /// Save a new user to the database
  Future<bool> saveUser(UserModel user, String passwordHash) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      final usersJson = prefs.getString(_usersCollectionKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      // Check if user already exists
      if (users.containsKey(user.email.toLowerCase())) {
        print('User with email ${user.email} already exists');
        return false;
      }

      // Add new user with password hash
      users[user.email.toLowerCase()] = {
        'id': user.id,
        'email': user.email.toLowerCase(),
        'name': user.name,
        'passwordHash': passwordHash,
        'photoUrl': user.photoUrl,
        'emailVerified': user.emailVerified,
        'createdAt': user.createdAt.toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      };

      // Save updated users collection
      await prefs.setString(_usersCollectionKey, jsonEncode(users));

      print('User ${user.email} saved successfully to local database');
      return true;
    } catch (e) {
      print('Error saving user to local database: $e');
      return false;
    }
  }

  /// Get a user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersCollectionKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      return users[email.toLowerCase()];
    } catch (e) {
      print('Error getting user from local database: $e');
      return null;
    }
  }

  /// Update user data
  Future<bool> updateUser(String email, Map<String, dynamic> updates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersCollectionKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (!users.containsKey(email.toLowerCase())) {
        print('User with email $email not found');
        return false;
      }

      // Update user data
      final userData = users[email.toLowerCase()] as Map<String, dynamic>;
      userData.addAll(updates);
      userData['lastLoginAt'] = DateTime.now().toIso8601String();

      users[email.toLowerCase()] = userData;

      // Save updated users collection
      await prefs.setString(_usersCollectionKey, jsonEncode(users));

      print('User $email updated successfully');
      return true;
    } catch (e) {
      print('Error updating user in local database: $e');
      return false;
    }
  }

  /// Verify user credentials
  Future<Map<String, dynamic>?> verifyUser(String email, String passwordHash) async {
    try {
      final userData = await getUserByEmail(email);

      if (userData == null) {
        print('User not found: $email');
        return null;
      }

      if (userData['passwordHash'] != passwordHash) {
        print('Invalid password for user: $email');
        return null;
      }

      // Update last login
      await updateUser(email, {'lastLoginAt': DateTime.now().toIso8601String()});

      return userData;
    } catch (e) {
      print('Error verifying user: $e');
      return null;
    }
  }

  /// Get all registered users (for debugging)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersCollectionKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      return users.values.map((user) => user as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  /// Clear all user data (for testing)
  Future<void> clearAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersCollectionKey);
      await prefs.remove(_currentUserKey);
      print('All user data cleared from local database');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  /// Update user photo URL
  Future<void> updateUserPhoto(String email, String photoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersCollectionKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      final userKey = email.toLowerCase();
      if (users.containsKey(userKey)) {
        users[userKey]['photoUrl'] = photoUrl;
        await prefs.setString(_usersCollectionKey, jsonEncode(users));
        print('User photo updated for: $email');
      }
    } catch (e) {
      print('Error updating user photo: $e');
    }
  }

  /// Get total number of registered users
  Future<int> getUserCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersCollectionKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      return users.length;
    } catch (e) {
      print('Error getting user count: $e');
      return 0;
    }
  }
}