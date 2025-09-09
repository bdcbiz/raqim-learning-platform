import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/courses_provider.dart';
import '../../certificates/providers/certificates_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final coursesProvider = Provider.of<CoursesProvider>(context);
    final certificatesProvider = Provider.of<CertificatesProvider>(context);
    final course = coursesProvider.selectedCourse;

    if (course == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Find user progress for this course (may be null if not enrolled)
    final userProgress = certificatesProvider.userProgress.where(
      (p) => p.courseId == courseId,
    ).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                course.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Card
                  if (userProgress != null && userProgress.overallProgress > 0)
                    Card(
                      elevation: 2,
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.translate('courseProgress') ?? 'Course Progress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (userProgress.isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)?.translate('completed') ?? 'Completed',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: userProgress.overallProgress / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                userProgress.overallProgress >= 100 
                                    ? Colors.green 
                                    : AppTheme.primaryColor,
                              ),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${userProgress.overallProgress.toStringAsFixed(0)}% مكتمل',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            if (userProgress.certificate != null) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.go('/certificates');
                                },
                                icon: const Icon(Icons.workspace_premium, size: 18),
                                label: Text(AppLocalizations.of(context)?.translate('viewCertificate') ?? 'View Certificate'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: course.instructorPhotoUrl != null
                            ? NetworkImage(course.instructorPhotoUrl!)
                            : null,
                        child: course.instructorPhotoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(course.instructorName),
                      subtitle: Text(course.instructorBio),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)?.translate('educationalObjectives') ?? 'Educational Objectives',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...course.objectives.map((objective) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, 
                          color: Colors.green, 
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(objective)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)?.translate('requirements') ?? 'Requirements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...course.requirements.map((req) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_forward, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(req)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 8,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: userProgress != null 
            ? // User is enrolled - show continue learning button
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.translate('enrolledInCourse') ?? 'Enrolled in Course',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${AppLocalizations.of(context)?.translate('progress') ?? 'Progress'}: ${userProgress.overallProgress.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/course/${course.id}/lesson');
                      },
                      icon: Icon(
                        userProgress.isCompleted 
                            ? Icons.replay 
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        userProgress.isCompleted 
                            ? AppLocalizations.of(context)?.translate('rewatch') ?? 'Rewatch' 
                            : AppLocalizations.of(context)?.translate('continueLeaming') ?? 'Continue Learning',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              )
            : // User is not enrolled - show enroll/buy button
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.isFree ? AppLocalizations.of(context)?.translate('free') ?? 'Free' : '${course.price.toInt()} ${AppLocalizations.of(context)?.translate('sar') ?? 'SAR'}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: course.isFree ? Colors.green : null,
                        ),
                      ),
                      Text(
                        '${course.enrolledStudents} ${AppLocalizations.of(context)?.translate('studentsEnrolled') ?? 'Students Enrolled'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (course.isFree) {
                          // For free courses, enroll directly
                          coursesProvider.enrollInCourse(courseId);
                          // Add to user progress
                          certificatesProvider.loadUserProgress();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.translate('enrolledSuccessfully') ?? 'تم التسجيل في الدورة المجانية بنجاح!'),
                            ),
                          );
                        } else {
                          // For paid courses, navigate to payment
                          context.go('/payment', extra: {
                            'courseId': course.id,
                            'courseName': course.title,
                            'amount': course.price,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(course.isFree 
                          ? (AppLocalizations.of(context)?.translate('enrollNowFree') ?? 'سجل الآن مجاناً')
                          : (AppLocalizations.of(context)?.translate('buyNow') ?? 'اشترِ الآن')),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}