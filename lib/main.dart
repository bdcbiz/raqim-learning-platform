import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/app_settings_provider.dart';
import 'core/localization/app_localizations.dart';
import 'features/auth/providers/auth_provider.dart';
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
import 'features/courses/screens/course_details_screen.dart';
import 'screens/simple_course_detail_screen.dart';
import 'features/courses/screens/my_courses_screen.dart';
import 'features/courses/screens/lesson_player_screen.dart';
import 'features/certificates/screens/certificates_screen.dart';
import 'features/community/screens/community_feed_screen.dart';
import 'features/community/screens/post_details_screen.dart';
import 'features/community/screens/create_post_screen.dart';
import 'features/news/screens/news_feed_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'services/api_service.dart';
import 'services/auth/auth_service_factory.dart';
import 'services/analytics/analytics_service_factory.dart';
import 'services/analytics/firebase_analytics_service.dart';
import 'providers/course_provider.dart';
import 'screens/courses_screen.dart';
import 'services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper configuration
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // Handle Firebase initialization errors gracefully
    debugPrint('Firebase initialization failed: $e');
  }

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
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider.value(value: AuthServiceFactory.createAuthService()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => CertificatesProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ProgressService()),
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
        print('DEBUG: Route redirect check');
        print('  - Path: ${state.matchedLocation}');
        print('  - isAuthenticated: $isAuthenticated');
        print('  - isEmailVerified: $isEmailVerified');
        print('  - currentUser: ${currentUser?.email}');
        print('  - authStatus: ${authService.status}');

        final isLoginPage = state.matchedLocation == '/login';
        final isRegisterPage = state.matchedLocation == '/register';
        final isEmailVerificationPage = state.matchedLocation == '/email-verification';
        final isForgotPasswordPage = state.matchedLocation.startsWith('/forgot-password');

        // Allow auth pages and email verification
        if (isLoginPage || isRegisterPage || isEmailVerificationPage || isForgotPasswordPage) {
          // If fully authenticated, redirect to home
          if (isAuthenticated && isEmailVerified && (isLoginPage || isRegisterPage)) {
            print('DEBUG: Redirecting authenticated user to home');
            return '/';
          }
          return null;
        }

        // Check if user has current session but email not verified
        if (currentUser != null && !isEmailVerified) {
          print('DEBUG: User logged in but email not verified, allowing access');
          // For demo purposes, we'll allow access even without email verification
          // In production, you might want to redirect to email verification
          return null;
        }

        // If not authenticated at all, redirect to login
        if (currentUser == null) {
          print('DEBUG: No user session, redirecting to login');
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
              path: 'community/post/:postId',
              builder: (context, state) {
                final postId = state.pathParameters['postId']!;
                return PostDetailsScreen(postId: postId);
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