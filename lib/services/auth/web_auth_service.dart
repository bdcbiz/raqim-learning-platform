import 'dart:async';
import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'auth_interface.dart';
import '../../data/models/user_model.dart';
import '../database/firestore_service.dart';
import '../tracking/interaction_tracker.dart';
import '../database/local_database_service.dart';

class WebAuthService extends AuthServiceInterface {
  static final WebAuthService _instance = WebAuthService._internal();
  factory WebAuthService() => _instance;
  WebAuthService._internal();

  static const String _usersKey = 'web_auth_users';
  static const String _currentUserKey = 'web_auth_current_user';
  static const String _sessionKey = 'web_auth_session';

  UserModel? _currentUser;
  AuthenticationStatus _status = AuthenticationStatus.unknown;
  StreamController<UserModel?>? _authStateController;
  final FirestoreService _firestoreService = FirestoreService();
  final InteractionTracker _tracker = InteractionTracker();
  final LocalDatabaseService _localDatabase = LocalDatabaseService();

  @override
  UserModel? get currentUser => _currentUser;

  @override
  AuthenticationStatus get status => _status;

  @override
  bool get isAuthenticated => _status == AuthenticationStatus.authenticated ||
      (_status == AuthenticationStatus.emailNotVerified && _currentUser != null);

  @override
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  @override
  Stream<UserModel?>? get authStateChanges => _authStateController?.stream;

  @override
  void initialize() {
    _authStateController = StreamController<UserModel?>.broadcast();
    _tracker.initialize(this);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      final sessionKey = prefs.getString(_sessionKey);

      print('DEBUG: Loading current user from storage');
      print('  - Has userJson: ${userJson != null}');
      print('  - Has sessionKey: ${sessionKey != null}');

      if (userJson != null && sessionKey != null && _isSessionValid(sessionKey)) {
        final userMap = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(userMap);
        _status = _currentUser!.emailVerified
            ? AuthenticationStatus.authenticated
            : AuthenticationStatus.emailNotVerified;

        print('  - User loaded: ${_currentUser!.email}');
        print('  - Email verified: ${_currentUser!.emailVerified}');
        print('  - Status: $_status');
      } else {
        _currentUser = null;
        _status = AuthenticationStatus.unauthenticated;
        print('  - No valid user session found');
      }
    } catch (e) {
      print('ERROR: Failed to load current user: $e');
      _currentUser = null;
      _status = AuthenticationStatus.unauthenticated;
    }

    notifyListeners();
    _authStateController?.add(_currentUser);
  }

  bool _isSessionValid(String sessionKey) {
    // Simple session validation - in a real app, you'd verify with your backend
    final parts = sessionKey.split('_');
    if (parts.length != 2) return false;

    final timestamp = int.tryParse(parts[1]);
    if (timestamp == null) return false;

    final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    // Session expires after 24 hours
    return now.difference(sessionTime).inHours < 24;
  }

  String _generateSessionKey(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${userId}_$timestamp';
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> _getStoredUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    print('DEBUG: _getStoredUser called with email: ${email.toLowerCase()}');
    print('DEBUG: Stored users JSON: $usersJson');

    if (usersJson != null) {
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      print('DEBUG: All stored users: ${users.keys.toList()}');
      final foundUser = users[email.toLowerCase()];
      print('DEBUG: Found user for ${email.toLowerCase()}: ${foundUser != null}');
      return foundUser;
    }

    print('DEBUG: No users stored yet');
    return null;
  }

  Future<void> _saveUser(String email, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = Map<String, dynamic>.from(jsonDecode(usersJson));

    print('DEBUG: Saving user with email: ${email.toLowerCase()}');
    print('DEBUG: Current stored users before save: ${users.keys.toList()}');

    users[email.toLowerCase()] = userData;
    final newUsersJson = jsonEncode(users);
    await prefs.setString(_usersKey, newUsersJson);

    print('DEBUG: User saved successfully');
    print('DEBUG: All stored users after save: ${users.keys.toList()}');
  }

  Future<void> _saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    await prefs.setString(_sessionKey, _generateSessionKey(user.id));
  }

  // Debug method to clear all stored data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
    await prefs.remove(_sessionKey);
    _currentUser = null;
    _status = AuthenticationStatus.unauthenticated;
    notifyListeners();
    _authStateController?.add(null);
  }

  @override
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Debug: print what we're looking for
      print('DEBUG: Registering user with email: ${email.toLowerCase()}');

      // Check if user already exists
      final existingUser = await _getStoredUser(email);
      print('DEBUG: Existing user found: ${existingUser != null}');

      if (existingUser != null) {
        print('DEBUG: User already exists, returning error');
        return AuthResult(
          success: false,
          errorMessage: 'المستخدم موجود بالفعل',
        );
      }

      // Validate email format
      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          errorMessage: 'البريد الإلكتروني غير صحيح',
        );
      }

      // Validate password strength
      if (password.length < 6) {
        return AuthResult(
          success: false,
          errorMessage: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
        );
      }

      // Create new user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final hashedPassword = _hashPassword(password);

      _currentUser = UserModel(
        id: userId,
        email: email.toLowerCase(),
        name: name,
        photoUrl: null,
        createdAt: DateTime.now(),
        emailVerified: false,
      );

      // Save to local persistent database
      final savedToLocal = await _localDatabase.saveUser(_currentUser!, hashedPassword);
      if (!savedToLocal) {
        return AuthResult(
          success: false,
          errorMessage: 'فشل في حفظ بيانات المستخدم',
        );
      }

      // Also save to session storage for immediate use
      final userData = {
        'id': userId,
        'email': email.toLowerCase(),
        'name': name,
        'passwordHash': hashedPassword,
        'emailVerified': false,
        'createdAt': DateTime.now().toIso8601String(),
        'photoUrl': null,
      };
      await _saveUser(email, userData);

      _status = AuthenticationStatus.emailNotVerified;
      await _saveCurrentUser(_currentUser!);

      // Save user to Firestore (make it non-blocking)
      try {
        _firestoreService.saveUserToDatabase(_currentUser!).catchError((e) {
          print('Firestore save failed (non-critical): $e');
        });
      } catch (e) {
        print('Firestore not available (continuing without it): $e');
      }

      // Track registration (make it non-blocking)
      try {
        _tracker.trackRegistration('email').catchError((e) {
          print('Tracking failed (non-critical): $e');
        });
      } catch (e) {
        print('Tracking not available (continuing without it): $e');
      }

      notifyListeners();
      _authStateController?.add(_currentUser);

      return AuthResult(
        success: true,
        user: _currentUser,
        status: AuthenticationStatus.emailNotVerified,
      );

    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Debug: print what we're looking for
      print('DEBUG: Signing in user with email: ${email.toLowerCase()}');

      // First try to get from local persistent database
      final hashedPassword = _hashPassword(password);
      final localUserData = await _localDatabase.verifyUser(email, hashedPassword);

      if (localUserData != null) {
        print('DEBUG: User found in local database');
        // User found in local database, use that data
        _currentUser = UserModel(
          id: localUserData['id'] as String,
          email: localUserData['email'] as String,
          name: localUserData['name'] as String,
          photoUrl: localUserData['photoUrl'] as String?,
          createdAt: DateTime.parse(localUserData['createdAt'] as String),
          emailVerified: localUserData['emailVerified'] as bool? ?? false,
        );

        // Update session storage
        await _saveUser(email, localUserData);
      } else {
        // Fallback to session storage
        final userData = await _getStoredUser(email);
        print('DEBUG: Found user data in session: ${userData != null}');

        if (userData == null) {
          print('DEBUG: User not found, returning error');
          return AuthResult(
            success: false,
            errorMessage: 'المستخدم غير موجود',
          );
        }

        final storedPasswordHash = userData['passwordHash'] as String;
        final inputPasswordHash = _hashPassword(password);

        if (storedPasswordHash != inputPasswordHash) {
          return AuthResult(
            success: false,
            errorMessage: 'كلمة المرور غير صحيحة',
          );
        }

        _currentUser = UserModel(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
          photoUrl: userData['photoUrl'] as String?,
          createdAt: DateTime.parse(userData['createdAt'] as String),
          emailVerified: userData['emailVerified'] as bool? ?? false,
        );
      }

      _status = _currentUser!.emailVerified
          ? AuthenticationStatus.authenticated
          : AuthenticationStatus.emailNotVerified;

      await _saveCurrentUser(_currentUser!);

      // Update last login in Firestore (make it non-blocking)
      try {
        _firestoreService.updateUserLastLogin(_currentUser!.id).catchError((e) {
          print('Firestore update failed (non-critical): $e');
        });
      } catch (e) {
        print('Firestore not available (continuing without it): $e');
      }

      // Track login (make it non-blocking)
      try {
        _tracker.trackLogin('email').catchError((e) {
          print('Tracking failed (non-critical): $e');
        });
      } catch (e) {
        print('Tracking not available (continuing without it): $e');
      }

      notifyListeners();
      _authStateController?.add(_currentUser);

      return AuthResult(
        success: true,
        user: _currentUser,
        status: _status,
      );

    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    // For web demo purposes, simulate Google sign-in
    // In a real implementation, you'd integrate with Google Sign-In for web

    return AuthResult(
      success: false,
      errorMessage: 'تسجيل الدخول بواسطة Google غير متاح في الإصدار التجريبي للويب',
    );
  }

  @override
  Future<bool> sendEmailVerification() async {
    // Simulate email verification for web
    if (_currentUser != null) {
      // In a real app, you'd send an actual verification email
      print('Simulated email verification sent to ${_currentUser!.email}');

      // For demo purposes, automatically verify after 2 seconds (faster)
      Future.delayed(const Duration(seconds: 2), () async {
        await _verifyEmail();
      });

      return true;
    }
    return false;
  }

  // Force immediate verification for demo purposes
  Future<bool> forceEmailVerification() async {
    if (_currentUser != null) {
      print('DEBUG: Force email verification for ${_currentUser!.email}');
      await _verifyEmail();
      // Ensure status is immediately set to authenticated
      _status = AuthenticationStatus.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _verifyEmail() async {
    if (_currentUser != null) {
      // Update in local database
      await _localDatabase.updateUser(_currentUser!.email, {'emailVerified': true});

      // Update in session storage
      final userData = await _getStoredUser(_currentUser!.email);
      if (userData != null) {
        userData['emailVerified'] = true;
        await _saveUser(_currentUser!.email, userData);
      }

      _currentUser = _currentUser!.copyWith(emailVerified: true);
      _status = AuthenticationStatus.authenticated;

      await _saveCurrentUser(_currentUser!);
      notifyListeners();
      _authStateController?.add(_currentUser);

      print('DEBUG: Email verified successfully for ${_currentUser!.email}');
    }
  }

  @override
  Future<bool> reloadUser() async {
    if (_currentUser != null) {
      final userData = await _getStoredUser(_currentUser!.email);
      if (userData != null) {
        _currentUser = UserModel(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
          photoUrl: userData['photoUrl'] as String?,
          createdAt: DateTime.parse(userData['createdAt'] as String),
          emailVerified: userData['emailVerified'] as bool? ?? false,
        );

        _status = _currentUser!.emailVerified
            ? AuthenticationStatus.authenticated
            : AuthenticationStatus.emailNotVerified;

        await _saveCurrentUser(_currentUser!);
        notifyListeners();
        _authStateController?.add(_currentUser);

        return _currentUser!.emailVerified;
      }
    }
    return false;
  }

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    final userData = await _getStoredUser(email);
    if (userData != null) {
      // In a real app, you'd send an actual password reset email
      print('Simulated password reset email sent to $email');
      return true;
    }
    return false;
  }

  @override
  Future<bool> updateUserProfile({String? displayName, String? photoURL}) async {
    if (_currentUser != null) {
      try {
        final userData = await _getStoredUser(_currentUser!.email);
        if (userData != null) {
          if (displayName != null) {
            userData['name'] = displayName;
          }
          if (photoURL != null) {
            userData['photoUrl'] = photoURL;
          }

          await _saveUser(_currentUser!.email, userData);

          _currentUser = _currentUser!.copyWith(
            name: displayName ?? _currentUser!.name,
            photoUrl: photoURL ?? _currentUser!.photoUrl,
          );

          await _saveCurrentUser(_currentUser!);
          notifyListeners();
          _authStateController?.add(_currentUser);

          return true;
        }
      } catch (e) {
        print('Error updating user profile: $e');
      }
    }
    return false;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser != null) {
      try {
        final userData = await _getStoredUser(_currentUser!.email);
        if (userData != null) {
          final storedPasswordHash = userData['passwordHash'] as String;
          final currentPasswordHash = _hashPassword(currentPassword);

          if (storedPasswordHash != currentPasswordHash) {
            return false;
          }

          if (newPassword.length < 6) {
            return false;
          }

          userData['passwordHash'] = _hashPassword(newPassword);
          await _saveUser(_currentUser!.email, userData);

          return true;
        }
      } catch (e) {
        print('Error changing password: $e');
      }
    }
    return false;
  }

  @override
  Future<bool> deleteAccount() async {
    if (_currentUser != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString(_usersKey) ?? '{}';
        final users = Map<String, dynamic>.from(jsonDecode(usersJson));

        users.remove(_currentUser!.email.toLowerCase());
        await prefs.setString(_usersKey, jsonEncode(users));

        await signOut();
        return true;
      } catch (e) {
        print('Error deleting account: $e');
      }
    }
    return false;
  }

  @override
  Future<void> signOut() async {
    try {
      // Track logout before clearing user (make it non-blocking)
      if (_currentUser != null) {
        try {
          _tracker.trackLogout().catchError((e) {
            print('Tracking logout failed (non-critical): $e');
          });
        } catch (e) {
          print('Tracking not available: $e');
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.remove(_sessionKey);

      _currentUser = null;
      _status = AuthenticationStatus.unauthenticated;

      notifyListeners();
      _authStateController?.add(_currentUser);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  void dispose() {
    _authStateController?.close();
    super.dispose();
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    if (_currentUser == null) return;

    print('DEBUG: WebAuthService.updateProfilePhoto called with photoUrl: ${photoUrl.substring(0, Math.min(100, photoUrl.length))}');

    // Update current user with new photo
    _currentUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: _currentUser!.name,
      photoUrl: photoUrl,
      emailVerified: _currentUser!.emailVerified,
      createdAt: _currentUser!.createdAt,
    );

    print('DEBUG: Updated _currentUser.photoUrl to: ${_currentUser!.photoUrl?.substring(0, Math.min(100, _currentUser!.photoUrl?.length ?? 0))}');

    // Save to session storage (this is the critical part)
    await _saveCurrentUser(_currentUser!);

    // IMPORTANT: Also update the stored user data in _usersKey
    final userData = await _getStoredUser(_currentUser!.email);
    if (userData != null) {
      userData['photoUrl'] = photoUrl;
      await _saveUser(_currentUser!.email, userData);
      print('DEBUG: Updated stored user data with new photoUrl');
    }

    // Update in local database
    await _localDatabase.updateUserPhoto(_currentUser!.email, photoUrl);
    print('DEBUG: Updated local database with new photoUrl');

    // Update Firestore (non-blocking)
    try {
      _firestoreService.updateUserPhotoUrl(_currentUser!.id, photoUrl).catchError((e) {
        print('Firestore photo update failed (non-critical): $e');
      });
    } catch (e) {
      print('Firestore not available: $e');
    }

    // Force UI update
    notifyListeners();
    _authStateController?.add(_currentUser);

    print('DEBUG: WebAuthService.updateProfilePhoto completed - notified listeners');
  }
}