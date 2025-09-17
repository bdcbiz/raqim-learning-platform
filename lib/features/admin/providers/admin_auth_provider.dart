import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _adminEmail;
  String? _adminName;
  String? _error;
  bool _isLoading = false;

  // Demo admin credentials
  static const String _demoEmail = 'admin@raqim.com';
  static const String _demoPassword = 'admin123';

  // Additional admin accounts
  static const Map<String, String> _adminAccounts = {
    'admin@raqim.com': 'admin123',
    'super@raqim.com': 'super123',
    'manager@raqim.com': 'manager123',
  };

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get adminEmail => _adminEmail;
  String? get adminName => _adminName;
  String? get error => _error;
  bool get isLoading => _isLoading;

  AdminAuthProvider() {
    _loadAdminSession();
  }

  // Load admin session from storage
  Future<void> _loadAdminSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('admin_authenticated') ?? false;
      _adminEmail = prefs.getString('admin_email');
      _adminName = prefs.getString('admin_name');

      if (_isAuthenticated && _adminEmail != null) {
        print('DEBUG AdminAuth: Loaded admin session: $_adminEmail');
      }

      notifyListeners();
    } catch (e) {
      print('ERROR AdminAuth: Failed to load session: $e');
    }
  }

  // Save admin session
  Future<void> _saveAdminSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('admin_authenticated', _isAuthenticated);

      if (_adminEmail != null) {
        await prefs.setString('admin_email', _adminEmail!);
      }

      if (_adminName != null) {
        await prefs.setString('admin_name', _adminName!);
      }

      print('DEBUG AdminAuth: Session saved');
    } catch (e) {
      print('ERROR AdminAuth: Failed to save session: $e');
    }
  }

  // Admin login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      // Check demo credentials
      if (_adminAccounts.containsKey(email.toLowerCase()) &&
          _adminAccounts[email.toLowerCase()] == password) {

        _isAuthenticated = true;
        _adminEmail = email.toLowerCase();
        _adminName = _getAdminNameFromEmail(email);
        _error = null;

        await _saveAdminSession();

        print('DEBUG AdminAuth: Login successful: $_adminEmail');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'بيانات الدخول غير صحيحة';
        print('DEBUG AdminAuth: Invalid credentials: $email');

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'خطأ في تسجيل الدخول: $e';
      print('ERROR AdminAuth: Login error: $e');

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_authenticated');
      await prefs.remove('admin_email');
      await prefs.remove('admin_name');

      _isAuthenticated = false;
      _adminEmail = null;
      _adminName = null;
      _error = null;

      print('DEBUG AdminAuth: Logout successful');
      notifyListeners();
    } catch (e) {
      print('ERROR AdminAuth: Logout error: $e');
    }
  }

  // Check if user has admin privileges
  bool isAdminEmail(String email) {
    return _adminAccounts.containsKey(email.toLowerCase());
  }

  // Get admin permissions level
  AdminRole getAdminRole(String email) {
    switch (email.toLowerCase()) {
      case 'super@raqim.com':
        return AdminRole.superAdmin;
      case 'admin@raqim.com':
        return AdminRole.admin;
      case 'manager@raqim.com':
        return AdminRole.manager;
      default:
        return AdminRole.none;
    }
  }

  // Check if admin has specific permission
  bool hasPermission(AdminPermission permission) {
    if (!_isAuthenticated || _adminEmail == null) return false;

    final role = getAdminRole(_adminEmail!);

    switch (role) {
      case AdminRole.superAdmin:
        return true; // Super admin has all permissions
      case AdminRole.admin:
        return permission != AdminPermission.systemSettings; // Admin has most permissions
      case AdminRole.manager:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.manageContent,
          AdminPermission.manageUsers,
        ].contains(permission); // Manager has limited permissions
      case AdminRole.none:
        return false;
    }
  }

  // Helper method to get admin name from email
  String _getAdminNameFromEmail(String email) {
    switch (email.toLowerCase()) {
      case 'admin@raqim.com':
        return 'مدير النظام';
      case 'super@raqim.com':
        return 'المدير العام';
      case 'manager@raqim.com':
        return 'مدير المحتوى';
      default:
        return 'مدير';
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Validate admin session (can be called periodically)
  Future<bool> validateSession() async {
    if (!_isAuthenticated || _adminEmail == null) return false;

    try {
      // In a real app, this would validate with the server
      // For demo, we just check if the account still exists
      return _adminAccounts.containsKey(_adminEmail!);
    } catch (e) {
      print('ERROR AdminAuth: Session validation failed: $e');
      await logout();
      return false;
    }
  }
}

// Admin roles enum
enum AdminRole {
  none,
  manager,
  admin,
  superAdmin,
}

// Admin permissions enum
enum AdminPermission {
  viewDashboard,
  manageUsers,
  manageCourses,
  manageContent,
  viewFinancials,
  manageFinancials,
  systemSettings,
}