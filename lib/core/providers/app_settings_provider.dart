import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'app_language';
  
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar', 'SA');
  
  AppSettingsProvider(this._prefs) {
    _loadSettings();
  }
  
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isArabic => _locale.languageCode == 'ar';
  
  void _loadSettings() {
    final themeString = _prefs.getString(_themeKey);
    if (themeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
    }
    
    final languageCode = _prefs.getString(_languageKey);
    if (languageCode != null) {
      _locale = languageCode == 'en' 
          ? const Locale('en', 'US') 
          : const Locale('ar', 'SA');
    }
    
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light;
    }
    
    await _prefs.setString(_themeKey, _themeMode.toString());
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }
  
  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('ar', 'SA');
    }
    
    await _prefs.setString(_languageKey, _locale.languageCode);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }
}