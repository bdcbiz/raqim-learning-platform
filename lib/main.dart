import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Temporarily commenting out Firebase imports to avoid web compatibility issues
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'firebase_options.dart';
import 'core/utils/logger.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/app_settings_provider.dart';
import 'core/localization/app_localizations.dart';
import 'features/auth/providers/auth_provider.dart' as app_auth;
import 'features/courses/providers/courses_provider.dart';
import 'features/certificates/providers/certificates_provider.dart';
import 'features/community/providers/community_provider.dart';
import 'features/news/providers/news_provider.dart';
import 'features/payment/providers/payment_provider.dart';
import 'features/payment/screens/payment_methods_screen.dart';
import 'features/payment/screens/credit_card_payment_screen.dart';
import 'features/payment/screens/payment_success_screen.dart';
import 'features/payment/screens/payment_history_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/auth/screens/email_verification_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/courses/screens/courses_list_screen.dart';
import 'screens/simple_course_detail_screen.dart';
import 'features/courses/screens/my_courses_screen.dart';
import 'features/courses/screens/lesson_player_screen.dart';
import 'features/certificates/screens/certificates_screen.dart';
import 'features/community/screens/create_post_screen.dart';
import 'features/community/screens/prompt_library_screen.dart';
import 'features/news/screens/news_details_screen.dart';
import 'services/auth/auth_service_factory.dart';
import 'services/analytics/analytics_service_factory.dart';
import 'providers/course_provider.dart';
import 'screens/courses_screen.dart';
import 'services/progress_service.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/admin_login_screen.dart';
import 'features/admin/screens/courses_management_screen.dart';
import 'features/admin/screens/users_management_screen.dart';
import 'features/admin/screens/content_management_screen.dart';
import 'features/admin/screens/financial_management_screen.dart';
import 'features/admin/providers/admin_auth_provider.dart';
import 'features/courses/screens/course_content_screen.dart';
import 'features/ai_tools/screens/ai_tools_screen.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Temporarily commenting out Firebase initialization due to web compatibility issues
  // TODO: Restore Firebase once compatibility issues are resolved
  /*
  // Initialize Firebase with proper configuration (skip for web due to compatibility issues)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');

      // Connect to Firebase emulators for local development
      if (kDebugMode || DefaultFirebaseOptions.currentPlatform.projectId == 'demo-project') {
        debugPrint('Connecting to Firebase emulators...');

        // Connect Firestore to emulator
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8070);

        // Connect Auth to emulator
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

        // Connect Storage to emulator
        await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);

        debugPrint('Successfully connected to Firebase emulators');
      }
    } catch (e) {
      // Handle Firebase initialization errors gracefully
      debugPrint('Firebase initialization failed: $e');
    }
  } else {
    debugPrint('Skipping Firebase initialization for web platform due to compatibility issues');
  }
  */
  debugPrint('Firebase initialization temporarily disabled - using mock data for now');

  final prefs = await SharedPreferences.getInstance();
  // ApiService.init() is not needed when using mock data
  // await ApiService.init();

  // Initialize platform-specific auth service
  final authService = AuthServiceFactory.createAuthService();
  authService.initialize();

  // Initialize analytics service
  final analyticsService = AnalyticsServiceFactory.instance;
  await analyticsService.initialize();
  await analyticsService.logAppLaunch('cold_start');

  runApp(RaqimApp(prefs: prefs));
}

class RaqimApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const RaqimApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider(prefs)),
        ChangeNotifierProvider.value(value: AuthServiceFactory.createAuthService()),
        ChangeNotifierProvider(create: (_) => SyncService()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => CertificatesProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ProgressService()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Directionality(
            textDirection: settingsProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              themeMode: ThemeMode.light,
              locale: settingsProvider.locale,
              supportedLocales: const [
                Locale('ar', 'SA'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: _router(context),
            ),
          );
        },
      ),
    );
  }

  GoRouter _router(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authService = AuthServiceFactory.createAuthService();
        final isAuthenticated = authService.isAuthenticated;
        final isEmailVerified = authService.isEmailVerified;
        final currentUser = authService.currentUser;

        // Debug logging
        Logger.debug('Route redirect check');
        Logger.debug('Path: ${state.matchedLocation}');
        Logger.debug('isAuthenticated: $isAuthenticated');
        Logger.debug('isEmailVerified: $isEmailVerified');
        Logger.debug('currentUser: ${currentUser?.email}');
        Logger.debug('authStatus: ${authService.status}');

        // Allow admin access for demo purposes - check first
        if (state.matchedLocation.startsWith('/admin')) {
          Logger.debug('Allowing admin access for demo');
          return null;
        }

        final isLoginPage = state.matchedLocation == '/login';
        final isRegisterPage = state.matchedLocation == '/register';
        final isEmailVerificationPage = state.matchedLocation == '/email-verification';
        final isForgotPasswordPage = state.matchedLocation.startsWith('/forgot-password');

        // Allow auth pages and email verification
        if (isLoginPage || isRegisterPage || isEmailVerificationPage || isForgotPasswordPage) {
          // If fully authenticated, redirect to home
          if (isAuthenticated && isEmailVerified && (isLoginPage || isRegisterPage)) {
            Logger.debug('Redirecting authenticated user to home');
            return '/';
          }
          return null;
        }

        // Check if user has current session but email not verified
        if (currentUser != null && !isEmailVerified) {
          Logger.debug('User logged in but email not verified, allowing access');
          // For demo purposes, we'll allow access even without email verification
          // In production, you might want to redirect to email verification
          return null;
        }

        // If not authenticated at all, redirect to login
        if (currentUser == null) {
          Logger.debug('No user session, redirecting to login');
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
          routes: [
            GoRoute(
              path: 'courses',
              builder: (context, state) => const CoursesScreen(),
            ),
            GoRoute(
              path: 'my-courses',
              builder: (context, state) => const MyCoursesScreen(),
            ),
            GoRoute(
              path: 'certificates',
              builder: (context, state) => const CertificatesScreen(),
            ),
            GoRoute(
              path: 'course/:courseId',
              builder: (context, state) {
                final courseId = state.pathParameters['courseId']!;
                return SimpleCourseDetailScreen(courseId: courseId);
              },
              routes: [
                GoRoute(
                  path: 'lesson',
                  builder: (context, state) {
                    final courseId = state.pathParameters['courseId']!;
                    return LessonPlayerScreen(
                      courseId: courseId,
                      lessonId: 'l1', // Default to first lesson
                    );
                  },
                ),
                GoRoute(
                  path: 'content',
                  builder: (context, state) {
                    final courseId = state.pathParameters['courseId']!;
                    return CourseContentScreen(courseId: courseId);
                  },
                ),
                GoRoute(
                  path: 'lesson/:lessonId',
                  builder: (context, state) {
                    final courseId = state.pathParameters['courseId']!;
                    final lessonId = state.pathParameters['lessonId']!;
                    return LessonPlayerScreen(
                      courseId: courseId,
                      lessonId: lessonId,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'community/create',
              builder: (context, state) => const CreatePostScreen(),
            ),
            GoRoute(
              path: 'community/prompts',
              builder: (context, state) => const PromptLibraryScreen(),
            ),
            GoRoute(
              path: 'news/details/:newsId',
              builder: (context, state) {
                final newsId = state.pathParameters['newsId']!;
                return NewsDetailsScreen(newsId: newsId);
              },
            ),
            GoRoute(
              path: 'payment',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return PaymentMethodsScreen(
                  courseId: extra['courseId'],
                  courseName: extra['courseName'],
                  amount: extra['amount'],
                );
              },
            ),
            GoRoute(
              path: 'payment/credit-card',
              builder: (context, state) {
                final paymentData = state.extra as Map<String, dynamic>;
                return CreditCardPaymentScreen(paymentData: paymentData);
              },
            ),
            GoRoute(
              path: 'payment/success',
              builder: (context, state) {
                final paymentData = state.extra as Map<String, dynamic>;
                return PaymentSuccessScreen(paymentData: paymentData);
              },
            ),
            GoRoute(
              path: 'payment/history',
              builder: (context, state) => const PaymentHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesListScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/email-verification',
          builder: (context, state) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
          routes: [
            GoRoute(
              path: 'verify',
              builder: (context, state) {
                final email = state.extra as String? ?? '';
                return OtpVerificationScreen(email: email);
              },
            ),
            GoRoute(
              path: 'reset',
              builder: (context, state) {
                final email = state.extra as String? ?? '';
                return ResetPasswordScreen(email: email);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/ai-tools',
          builder: (context, state) => const AIToolsScreen(),
        ),
        // Admin routes
        GoRoute(
          path: '/admin-login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'courses',
              builder: (context, state) => const CoursesManagementScreen(),
            ),
            GoRoute(
              path: 'users',
              builder: (context, state) => const UsersManagementScreen(),
            ),
            GoRoute(
              path: 'content',
              builder: (context, state) => const ContentManagementScreen(),
            ),
            GoRoute(
              path: 'finance',
              builder: (context, state) => const FinancialManagementScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'الصفحة غير موجودة',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}