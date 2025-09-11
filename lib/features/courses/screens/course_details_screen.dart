import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/courses_provider.dart';
import '../../certificates/providers/certificates_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/modern_button.dart';
import '../../../widgets/common/modern_card.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final coursesProvider = Provider.of<CoursesProvider>(context);
    final certificatesProvider = Provider.of<CertificatesProvider>(context);
    final course = coursesProvider.selectedCourse;

    if (course == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Find user progress for this course (may be null if not enrolled)
    final userProgress = certificatesProvider.userProgress.where(
      (p) => p.courseId == courseId,
    ).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with Course Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: course.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.inputBackground,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.inputBackground,
                      child: const Icon(Icons.error, size: 64),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Course Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title and Basic Info
                  Text(
                    course.title,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 8),
                  
                  // Instructor Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.inputBackground,
                        backgroundImage: course.instructorPhotoUrl != null
                            ? NetworkImage(course.instructorPhotoUrl!)
                            : null,
                        child: course.instructorPhotoUrl == null
                            ? Icon(Icons.person, color: AppColors.secondaryText)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.instructorName,
                              style: AppTextStyles.cardTitle,
                            ),
                            if (course.instructorBio.isNotEmpty)
                              Text(
                                course.instructorBio,
                                style: AppTextStyles.small,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Course Stats
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.star,
                        '${course.rating}',
                        '(${course.totalRatings})',
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.people,
                        '${course.enrolledStudents}',
                        'طالب',
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.schedule,
                        '${course.duration ?? 8}',
                        'ساعات',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Progress Card (if enrolled)
                  if (userProgress != null && userProgress.overallProgress > 0)
                    ModernCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.translate('courseProgress') ?? 'تقدم الكورس',
                                style: AppTextStyles.cardTitle,
                              ),
                              if (userProgress.isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)?.translate('completed') ?? 'مكتمل',
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: userProgress.overallProgress / 100,
                              backgroundColor: AppColors.inputBackground,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                userProgress.overallProgress >= 100 
                                    ? AppColors.success 
                                    : AppColors.primaryColor,
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${userProgress.overallProgress.toStringAsFixed(0)}% مكتمل',
                            style: AppTextStyles.small,
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'وصف الكورس',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    margin: EdgeInsets.zero,
                    child: Text(
                      course.description,
                      style: AppTextStyles.body,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Learning Objectives
                  Text(
                    AppLocalizations.of(context)?.translate('educationalObjectives') ?? 'أهداف التعلم',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: course.objectives.asMap().entries.map((entry) {
                        final index = entry.key;
                        final objective = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: index < course.objectives.length - 1 ? 12 : 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  objective,
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Requirements
                  Text(
                    AppLocalizations.of(context)?.translate('requirements') ?? 'المتطلبات',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: course.requirements.asMap().entries.map((entry) {
                        final index = entry.key;
                        final requirement = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: index < course.requirements.length - 1 ? 12 : 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  requirement,
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom CTA Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 12,
              color: AppColors.shadowColor,
            ),
          ],
        ),
        child: SafeArea(
          child: userProgress != null 
              ? ModernButton(
                  text: userProgress.isCompleted 
                      ? AppLocalizations.of(context)?.translate('rewatch') ?? 'إعادة المشاهدة'
                      : AppLocalizations.of(context)?.translate('continueLeaming') ?? 'متابعة التعلم',
                  icon: userProgress.isCompleted ? Icons.replay : Icons.play_arrow,
                  onPressed: () {
                    context.go('/course/${course.id}/lesson');
                  },
                  width: double.infinity,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course.isFree 
                              ? AppLocalizations.of(context)?.translate('free') ?? 'مجاني'
                              : '${course.price.toInt()} ر.س',
                          style: AppTextStyles.h2.copyWith(
                            color: course.isFree ? AppColors.success : AppColors.primaryColor,
                          ),
                        ),
                        Text(
                          '${course.enrolledStudents} طالب مسجل',
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ModernButton(
                      text: course.isFree 
                          ? AppLocalizations.of(context)?.translate('enrollNowFree') ?? 'سجل الآن مجاناً'
                          : AppLocalizations.of(context)?.translate('buyNow') ?? 'اشترِ الآن',
                      onPressed: () async {
                        try {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(width: 16),
                                  Text('جاري المعالجة...'),
                                ],
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          
                          // Try to enroll - backend will handle free vs paid logic
                          final response = await coursesProvider.enrollInCourse(courseId);
                          
                          if (response != null && response['success'] == true) {
                            // Successfully enrolled in free course
                            certificatesProvider.loadUserProgress();
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)?.translate('enrolledSuccessfully') ?? 'تم التسجيل في الدورة بنجاح!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            throw Exception(response?['error'] ?? 'فشل التسجيل في الدورة');
                          }
                        } catch (e) {
                          // Check for different error types
                          if (e.toString().contains('402') || e.toString().contains('paid course')) {
                            // This is a paid course - redirect to payment
                            if (context.mounted) {
                              context.go('/payment', extra: {
                                'courseId': course.id,
                                'courseName': course.title,
                                'amount': course.price,
                              });
                            }
                          } else if (e.toString().contains('401') || e.toString().contains('Not authorized')) {
                            // User not logged in
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('يجب تسجيل الدخول أولاً'),
                                  backgroundColor: Colors.red,
                                  action: SnackBarAction(
                                    label: 'تسجيل الدخول',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      context.go('/login');
                                    },
                                  ),
                                ),
                              );
                            }
                          } else if (e.toString().contains('Already enrolled')) {
                            // Already enrolled
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('أنت مسجل بالفعل في هذه الدورة'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          } else {
                            // Other errors
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('حدث خطأ: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.secondaryText,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.small,
        ),
      ],
    );
  }
}