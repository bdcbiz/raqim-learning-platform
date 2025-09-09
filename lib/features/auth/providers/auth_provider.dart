import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._prefs) {
    _loadUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _loadUser() {
    final userId = _prefs.getString('userId');
    if (userId != null) {
      _currentUser = UserModel(
        id: userId,
        email: _prefs.getString('userEmail') ?? '',
        name: _prefs.getString('userName') ?? '',
        photoUrl: _prefs.getString('userPhotoUrl'),
        bio: _prefs.getString('userBio'),
        createdAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@')[0],
        createdAt: DateTime.now(),
      );
      
      await _saveUser();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل تسجيل الدخول: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
      
      await _saveUser();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل إنشاء الحساب: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: 'user@gmail.com',
        name: 'مستخدم جوجل',
        photoUrl: 'https://picsum.photos/150',
        createdAt: DateTime.now(),
      );
      
      await _saveUser();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل تسجيل الدخول بواسطة جوجل: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.clear();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _saveUser();
    notifyListeners();
  }

  Future<void> updateProfileImage(String imagePath) async {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        photoUrl: imagePath,
        bio: _currentUser!.bio,
        createdAt: _currentUser!.createdAt,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      await _prefs.setString('userId', _currentUser!.id);
      await _prefs.setString('userEmail', _currentUser!.email);
      await _prefs.setString('userName', _currentUser!.name);
      if (_currentUser!.photoUrl != null) {
        await _prefs.setString('userPhotoUrl', _currentUser!.photoUrl!);
      }
      if (_currentUser!.bio != null) {
        await _prefs.setString('userBio', _currentUser!.bio!);
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}