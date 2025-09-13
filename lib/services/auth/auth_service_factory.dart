import 'package:flutter/foundation.dart';
import 'auth_interface.dart';
import 'web_auth_service.dart';

class AuthServiceFactory {
  static AuthServiceInterface createAuthService() {
    return WebAuthService();
  }
}