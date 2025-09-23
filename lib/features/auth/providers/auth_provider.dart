import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../services/api/api_service.dart';
import '../../../services/cache_service.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ApiService _apiService = ApiService.instance;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._prefs) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await CacheService.init();
    await _apiService.initialize();
    await _loadUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadUser() async {
    // Try to load from cache first
    final cachedUser = CacheService.getCachedUser();
    if (cachedUser != null) {
      _currentUser = cachedUser;
      notifyListeners();
      
      // Refresh from server in background if needed
      if (CacheService.shouldRefreshCache()) {
        await _refreshUserFromServer();
      }
    } else {
      // Fallback to SharedPreferences for backward compatibility
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
        
        // Cache the user for next time
        if (_currentUser != null) {
          await CacheService.cacheUserData(_currentUser!);
        }
        notifyListeners();
      }
    }
  }

  Future<void> _refreshUserFromServer() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response['data'] != null) {
        final userData = response['data'];
        _currentUser = UserModel(
          id: userData['id'].toString(),
          email: userData['email'],
          name: userData['name'],
          photoUrl: userData['avatar'],
          bio: userData['bio'],
          createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
        );

        // Update cache
        await CacheService.cacheUserData(_currentUser!);
        await CacheService.updateLastSync();
        await _saveUser();

        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user from server: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response['data'] != null && response['data']['user'] != null) {
        final userData = response['data']['user'];
        _currentUser = UserModel(
          id: userData['id'].toString(),
          email: userData['email'],
          name: userData['name'],
          photoUrl: userData['avatar'],
          bio: userData['bio'],
          createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
        );

        await _saveUser();

        // Cache the user data
        await CacheService.cacheUserData(_currentUser!);
        await CacheService.updateLastSync();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'استجابة غير صحيحة من الخادم';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'فشل تسجيل الدخول: ${e.toString()}';
      }
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
      final response = await _apiService.post('/auth/register', body: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response['data'] != null && response['data']['user'] != null) {
        final userData = response['data']['user'];
        _currentUser = UserModel(
          id: userData['id'].toString(),
          email: userData['email'],
          name: userData['name'],
          photoUrl: userData['avatar'],
          bio: userData['bio'],
          createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
        );

        await _saveUser();

        // Cache the user data
        await CacheService.cacheUserData(_currentUser!);
        await CacheService.updateLastSync();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'استجابة غير صحيحة من الخادم';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is ValidationException) {
        if (e.getFieldError('email')?.contains('taken') == true) {
          _error = 'المستخدم موجود بالفعل';
        } else {
          _error = e.message;
        }
      } else if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'فشل إنشاء الحساب';
      }
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
      
      // Cache the user data
      await CacheService.cacheUserData(_currentUser!);
      await CacheService.updateLastSync();
      
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
    try {
      // Try to logout from API (but don't fail if server is down)
      await _apiService.post('/auth/logout');
    } catch (e) {
      print('API logout failed (continuing with local logout): $e');
    }

    // Clear local data regardless of API result
    await _prefs.clear();

    // Clear all cached data
    await CacheService.clearAllCache();

    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _saveUser();
    
    // Update cache
    await CacheService.cacheUserData(_currentUser!);
    
    notifyListeners();
  }

  Future<void> updateProfileImage(String imagePath) async {
    print('DEBUG: updateProfileImage called with path: ${imagePath.substring(0, 100)}...');
    if (_currentUser != null) {
      // Update the current user model with new image
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        photoUrl: imagePath,
        bio: _currentUser!.bio,
        createdAt: _currentUser!.createdAt,
      );

      print('DEBUG: User photoUrl updated to: ${_currentUser!.photoUrl?.substring(0, 100)}...');

      // Save to SharedPreferences
      await _saveUser();

      // Update cache
      await CacheService.cacheUserData(_currentUser!);

      // Force immediate UI update
      notifyListeners();

      print('DEBUG: Notified listeners about photo update');

      // Try to upload to server in background
      if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
        // This is a local file, should upload to server
        // TODO: Implement actual upload
        // try {
        //   final response = await ApiService.uploadAvatar(imagePath);
        //   if (response['url'] != null) {
        //     _currentUser = UserModel(
        //       id: _currentUser!.id,
        //       email: _currentUser!.email,
        //       name: _currentUser!.name,
        //       photoUrl: response['url'],
        //       bio: _currentUser!.bio,
        //       createdAt: _currentUser!.createdAt,
        //     );
        //     await _saveUser();
        //     await CacheService.cacheUserData(_currentUser!);
        //     notifyListeners();
        //   }
        // } catch (e) {
        //   print('Failed to upload avatar: $e');
        // }
      }
    }
  }

  Future<void> updateUserName(String name) async {
    if (_currentUser != null && name.trim().isNotEmpty) {
      // Update the current user model with new name
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: name.trim(),
        photoUrl: _currentUser!.photoUrl,
        bio: _currentUser!.bio,
        createdAt: _currentUser!.createdAt,
      );

      // Save to SharedPreferences
      await _saveUser();
      // Update cache
      await CacheService.cacheUserData(_currentUser!);

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