import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'app_language';
  static const String _notificationsKey = 'notifications_enabled';

  // Learning & Course Settings
  static const String _autoPlayNextKey = 'auto_play_next';
  static const String _videoSpeedKey = 'video_speed';
  static const String _autoSaveProgressKey = 'auto_save_progress';
  static const String _offlineDownloadsKey = 'offline_downloads';
  static const String _subtitleLanguageKey = 'subtitle_language';

  // Notification Settings
  static const String _courseRemindersKey = 'course_reminders';
  static const String _assignmentDeadlinesKey = 'assignment_deadlines';
  static const String _newCourseAlertsKey = 'new_course_alerts';
  static const String _achievementNotificationsKey = 'achievement_notifications';
  static const String _discussionRepliesKey = 'discussion_replies';

  // Accessibility & Display
  static const String _fontSizeKey = 'font_size';
  static const String _highContrastKey = 'high_contrast';
  static const String _reduceAnimationsKey = 'reduce_animations';
  static const String _screenReaderKey = 'screen_reader';

  // Privacy & Data
  static const String _profileVisibilityKey = 'profile_visibility';
  static const String _statisticsSharingKey = 'statistics_sharing';
  static const String _wifiOnlyKey = 'wifi_only';

  // Account & Security
  static const String _twoFactorAuthKey = 'two_factor_auth';
  static const String _emailPreferencesKey = 'email_preferences';

  // Regional Settings
  static const String _prayerTimesKey = 'prayer_times';
  static const String _hijriCalendarKey = 'hijri_calendar';
  static const String _regionalContentKey = 'regional_content';
  
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar', 'SA');
  bool _notificationsEnabled = true;

  // Learning & Course Settings
  bool _autoPlayNext = true;
  double _videoSpeed = 1.0;
  bool _autoSaveProgress = true;
  bool _offlineDownloads = false;
  String _subtitleLanguage = 'ar';

  // Notification Settings
  bool _courseReminders = true;
  bool _assignmentDeadlines = true;
  bool _newCourseAlerts = true;
  bool _achievementNotifications = true;
  bool _discussionReplies = true;

  // Accessibility & Display
  String _fontSize = 'medium';
  bool _highContrast = false;
  bool _reduceAnimations = false;
  bool _screenReader = false;

  // Privacy & Data
  String _profileVisibility = 'public';
  bool _statisticsSharing = true;
  bool _wifiOnly = false;

  // Account & Security
  bool _twoFactorAuth = false;
  bool _emailPreferences = true;

  // Regional Settings
  bool _prayerTimes = true;
  bool _hijriCalendar = true;
  String _regionalContent = 'global';
  
  AppSettingsProvider(this._prefs) {
    _loadSettings();
  }
  
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;

  // Learning & Course Settings Getters
  bool get autoPlayNext => _autoPlayNext;
  double get videoSpeed => _videoSpeed;
  bool get autoSaveProgress => _autoSaveProgress;
  bool get offlineDownloads => _offlineDownloads;
  String get subtitleLanguage => _subtitleLanguage;

  // Notification Settings Getters
  bool get courseReminders => _courseReminders;
  bool get assignmentDeadlines => _assignmentDeadlines;
  bool get newCourseAlerts => _newCourseAlerts;
  bool get achievementNotifications => _achievementNotifications;
  bool get discussionReplies => _discussionReplies;

  // Accessibility & Display Getters
  String get fontSize => _fontSize;
  bool get highContrast => _highContrast;
  bool get reduceAnimations => _reduceAnimations;
  bool get screenReader => _screenReader;

  // Privacy & Data Getters
  String get profileVisibility => _profileVisibility;
  bool get statisticsSharing => _statisticsSharing;
  bool get wifiOnly => _wifiOnly;

  // Account & Security Getters
  bool get twoFactorAuth => _twoFactorAuth;
  bool get emailPreferences => _emailPreferences;

  // Regional Settings Getters
  bool get prayerTimes => _prayerTimes;
  bool get hijriCalendar => _hijriCalendar;
  String get regionalContent => _regionalContent;
  
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

    _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;

    // Load Learning & Course Settings
    _autoPlayNext = _prefs.getBool(_autoPlayNextKey) ?? true;
    _videoSpeed = _prefs.getDouble(_videoSpeedKey) ?? 1.0;
    _autoSaveProgress = _prefs.getBool(_autoSaveProgressKey) ?? true;
    _offlineDownloads = _prefs.getBool(_offlineDownloadsKey) ?? false;
    _subtitleLanguage = _prefs.getString(_subtitleLanguageKey) ?? 'ar';

    // Load Notification Settings
    _courseReminders = _prefs.getBool(_courseRemindersKey) ?? true;
    _assignmentDeadlines = _prefs.getBool(_assignmentDeadlinesKey) ?? true;
    _newCourseAlerts = _prefs.getBool(_newCourseAlertsKey) ?? true;
    _achievementNotifications = _prefs.getBool(_achievementNotificationsKey) ?? true;
    _discussionReplies = _prefs.getBool(_discussionRepliesKey) ?? true;

    // Load Accessibility & Display Settings
    _fontSize = _prefs.getString(_fontSizeKey) ?? 'medium';
    _highContrast = _prefs.getBool(_highContrastKey) ?? false;
    _reduceAnimations = _prefs.getBool(_reduceAnimationsKey) ?? false;
    _screenReader = _prefs.getBool(_screenReaderKey) ?? false;

    // Load Privacy & Data Settings
    _profileVisibility = _prefs.getString(_profileVisibilityKey) ?? 'public';
    _statisticsSharing = _prefs.getBool(_statisticsSharingKey) ?? true;
    _wifiOnly = _prefs.getBool(_wifiOnlyKey) ?? false;

    // Load Account & Security Settings
    _twoFactorAuth = _prefs.getBool(_twoFactorAuthKey) ?? false;
    _emailPreferences = _prefs.getBool(_emailPreferencesKey) ?? true;

    // Load Regional Settings
    _prayerTimes = _prefs.getBool(_prayerTimesKey) ?? true;
    _hijriCalendar = _prefs.getBool(_hijriCalendarKey) ?? true;
    _regionalContent = _prefs.getString(_regionalContentKey) ?? 'global';

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

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _prefs.setBool(_notificationsKey, _notificationsEnabled);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  // Learning & Course Settings Methods
  Future<void> setAutoPlayNext(bool enabled) async {
    _autoPlayNext = enabled;
    await _prefs.setBool(_autoPlayNextKey, enabled);
    notifyListeners();
  }

  Future<void> setVideoSpeed(double speed) async {
    _videoSpeed = speed;
    await _prefs.setDouble(_videoSpeedKey, speed);
    notifyListeners();
  }

  Future<void> setAutoSaveProgress(bool enabled) async {
    _autoSaveProgress = enabled;
    await _prefs.setBool(_autoSaveProgressKey, enabled);
    notifyListeners();
  }

  Future<void> setOfflineDownloads(bool enabled) async {
    _offlineDownloads = enabled;
    await _prefs.setBool(_offlineDownloadsKey, enabled);
    notifyListeners();
  }

  Future<void> setSubtitleLanguage(String language) async {
    _subtitleLanguage = language;
    await _prefs.setString(_subtitleLanguageKey, language);
    notifyListeners();
  }

  // Notification Settings Methods
  Future<void> setCourseReminders(bool enabled) async {
    _courseReminders = enabled;
    await _prefs.setBool(_courseRemindersKey, enabled);
    notifyListeners();
  }

  Future<void> setAssignmentDeadlines(bool enabled) async {
    _assignmentDeadlines = enabled;
    await _prefs.setBool(_assignmentDeadlinesKey, enabled);
    notifyListeners();
  }

  Future<void> setNewCourseAlerts(bool enabled) async {
    _newCourseAlerts = enabled;
    await _prefs.setBool(_newCourseAlertsKey, enabled);
    notifyListeners();
  }

  Future<void> setAchievementNotifications(bool enabled) async {
    _achievementNotifications = enabled;
    await _prefs.setBool(_achievementNotificationsKey, enabled);
    notifyListeners();
  }

  Future<void> setDiscussionReplies(bool enabled) async {
    _discussionReplies = enabled;
    await _prefs.setBool(_discussionRepliesKey, enabled);
    notifyListeners();
  }

  // Accessibility & Display Methods
  Future<void> setFontSize(String size) async {
    _fontSize = size;
    await _prefs.setString(_fontSizeKey, size);
    notifyListeners();
  }

  Future<void> setHighContrast(bool enabled) async {
    _highContrast = enabled;
    await _prefs.setBool(_highContrastKey, enabled);
    notifyListeners();
  }

  Future<void> setReduceAnimations(bool enabled) async {
    _reduceAnimations = enabled;
    await _prefs.setBool(_reduceAnimationsKey, enabled);
    notifyListeners();
  }

  Future<void> setScreenReader(bool enabled) async {
    _screenReader = enabled;
    await _prefs.setBool(_screenReaderKey, enabled);
    notifyListeners();
  }

  // Privacy & Data Methods
  Future<void> setProfileVisibility(String visibility) async {
    _profileVisibility = visibility;
    await _prefs.setString(_profileVisibilityKey, visibility);
    notifyListeners();
  }

  Future<void> setStatisticsSharing(bool enabled) async {
    _statisticsSharing = enabled;
    await _prefs.setBool(_statisticsSharingKey, enabled);
    notifyListeners();
  }

  Future<void> setWifiOnly(bool enabled) async {
    _wifiOnly = enabled;
    await _prefs.setBool(_wifiOnlyKey, enabled);
    notifyListeners();
  }

  // Account & Security Methods
  Future<void> setTwoFactorAuth(bool enabled) async {
    _twoFactorAuth = enabled;
    await _prefs.setBool(_twoFactorAuthKey, enabled);
    notifyListeners();
  }

  Future<void> setEmailPreferences(bool enabled) async {
    _emailPreferences = enabled;
    await _prefs.setBool(_emailPreferencesKey, enabled);
    notifyListeners();
  }

  // Regional Settings Methods
  Future<void> setPrayerTimes(bool enabled) async {
    _prayerTimes = enabled;
    await _prefs.setBool(_prayerTimesKey, enabled);
    notifyListeners();
  }

  Future<void> setHijriCalendar(bool enabled) async {
    _hijriCalendar = enabled;
    await _prefs.setBool(_hijriCalendarKey, enabled);
    notifyListeners();
  }

  Future<void> setRegionalContent(String content) async {
    _regionalContent = content;
    await _prefs.setString(_regionalContentKey, content);
    notifyListeners();
  }
}