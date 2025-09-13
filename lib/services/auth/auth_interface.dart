import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';

enum AuthenticationStatus {
  unknown,
  authenticated,
  unauthenticated,
  emailNotVerified,
}

class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;
  final AuthenticationStatus status;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.status = AuthenticationStatus.unknown,
  });
}

abstract class AuthServiceInterface extends ChangeNotifier {
  // Properties
  UserModel? get currentUser;
  AuthenticationStatus get status;
  bool get isAuthenticated;
  bool get isEmailVerified;
  Stream<dynamic>? get authStateChanges;

  // Core Authentication Methods
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthResult> signInWithGoogle();

  Future<void> signOut();

  // Email Verification
  Future<bool> sendEmailVerification();
  Future<bool> reloadUser();

  // Password Reset
  Future<bool> sendPasswordResetEmail(String email);

  // Profile Management
  Future<bool> updateUserProfile({String? displayName, String? photoURL});
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Account Management
  Future<bool> deleteAccount();

  // Initialization
  void initialize();

  // Debug methods
  Future<void> clearAllData();
}