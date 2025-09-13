abstract class AnalyticsServiceInterface {
  // Initialize analytics
  Future<void> initialize();

  // Set user properties
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String? value);

  // Screen tracking
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  });

  // Custom events
  Future<void> logEvent(String name, Map<String, Object>? parameters);

  // Predefined events for education app
  Future<void> logLogin(String loginMethod);
  Future<void> logSignUp(String signUpMethod);
  Future<void> logSearch(String searchTerm);
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
    String? itemName,
  });
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  });

  // Course-specific events
  Future<void> logCourseView(String courseId, String courseName);
  Future<void> logCourseEnroll(String courseId, String courseName);
  Future<void> logLessonStart(String courseId, String lessonId);
  Future<void> logLessonComplete(String courseId, String lessonId);
  Future<void> logCourseComplete(String courseId, String courseName);

  // Purchase events
  Future<void> logPurchase({
    required String currency,
    required double value,
    required String transactionId,
    String? affiliation,
    String? coupon,
    String? shipping,
    String? tax,
    List<Map<String, Object>>? items,
  });

  // Engagement events
  Future<void> logVideoPlay(String videoId, String videoTitle);
  Future<void> logVideoPause(String videoId, int watchTime);
  Future<void> logVideoComplete(String videoId, int totalTime);
  Future<void> logQuizStart(String quizId);
  Future<void> logQuizComplete(String quizId, int score, int totalQuestions);

  // Community events
  Future<void> logPostCreate(String postId, String category);
  Future<void> logPostView(String postId);
  Future<void> logPostLike(String postId);
  Future<void> logPostShare(String postId);

  // Error tracking
  Future<void> logError(String errorMessage, {
    String? stackTrace,
    bool? fatal,
  });

  // Custom dimensions for educational analytics
  Future<void> logLearningProgress({
    required String courseId,
    required int completedLessons,
    required int totalLessons,
    required double progressPercentage,
  });

  Future<void> logCertificateEarned(String certificateId, String courseId);

  // Performance tracking
  Future<void> logPageLoadTime(String pageName, int loadTimeMs);
  Future<void> logAppLaunch(String launchMode);
  Future<void> logAppBackground();
  Future<void> logAppForeground();
}