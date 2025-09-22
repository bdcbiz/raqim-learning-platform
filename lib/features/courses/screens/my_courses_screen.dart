import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/courses_provider.dart';
import '../../certificates/providers/certificates_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  String _selectedFilter = 'all'; // all, in_progress, completed

  @override
  Widget build(BuildContext context) {
    final coursesProvider = Provider.of<CoursesProvider>(context);
    final certificatesProvider = Provider.of<CertificatesProvider>(context);
    
    // Get enrolled courses based on user progress
    final enrolledCourses = coursesProvider.courses.where((course) {
      return certificatesProvider.userProgress.any((p) => p.courseId == course.id);
    }).toList();

    // Apply filter
    final filteredCourses = enrolledCourses.where((course) {
      final progress = certificatesProvider.userProgress.firstWhere(
        (p) => p.courseId == course.id,
        orElse: () => certificatesProvider.userProgress.first,
      );
      
      if (_selectedFilter == 'in_progress') {
        return !progress.isCompleted && progress.overallProgress > 0;
      } else if (_selectedFilter == 'completed') {
        return progress.isCompleted;
      }
      return true; // all
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/images/raqimLogo.svg',
            height: 28,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          'دوراتي',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip(AppLocalizations.of(context)?.translate('all') ?? 'All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(AppLocalizations.of(context)?.translate('inProgress') ?? 'In Progress', 'in_progress'),
                const SizedBox(width: 8),
                _buildFilterChip(AppLocalizations.of(context)?.translate('completedStatus') ?? 'Completed', 'completed'),
              ],
            ),
          ),
          
          // Courses list
          Expanded(
            child: filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all'
                              ? AppLocalizations.of(context)?.translate('noCoursesEnrolled') ?? 'No courses enrolled yet'
                              : _selectedFilter == 'in_progress'
                                  ? AppLocalizations.of(context)?.translate('noCoursesInProgress') ?? 'No courses in progress'
                                  : AppLocalizations.of(context)?.translate('noCoursesCompleted') ?? 'No completed courses yet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_selectedFilter == 'all')
                          ElevatedButton.icon(
                            onPressed: () => context.go('/courses'),
                            icon: const Icon(Icons.search),
                            label: Text(AppLocalizations.of(context)?.translate('exploreCourses') ?? 'Explore Courses'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      final progress = certificatesProvider.userProgress.firstWhere(
                        (p) => p.courseId == course.id,
                        orElse: () => certificatesProvider.userProgress.first,
                      );
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            coursesProvider.selectCourse(course.id);
                            context.go('/course/${course.id}');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            children: [
                              // Course header with image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.network(
                                        course.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image, size: 50),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Progress overlay
                                  if (progress.isCompleted)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(context)?.translate('completed') ?? 'Completed',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              
                              // Course info and progress
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Course title
                                    Text(
                                      course.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Instructor
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          course.instructorName,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Progress bar
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)?.translate('progress') ?? 'Progress',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${progress.overallProgress.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                color: progress.isCompleted ? Colors.green : AppColors.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: progress.overallProgress / 100,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            progress.isCompleted ? Colors.green : AppColors.primaryColor,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Stats
                                    Row(
                                      children: [
                                        _buildStat(
                                          Icons.play_circle_outline,
                                          '${progress.completedLessons.length} ${AppLocalizations.of(context)?.translate('lessons') ?? 'Lessons'}',
                                        ),
                                        const SizedBox(width: 24),
                                        _buildStat(
                                          Icons.access_time,
                                          '${course.totalDuration.inHours} ${AppLocalizations.of(context)?.translate('hours') ?? 'Hours'}',
                                        ),
                                        const SizedBox(width: 24),
                                        if (progress.quizScores.isNotEmpty)
                                          _buildStat(
                                            Icons.assignment_turned_in,
                                            '${progress.quizScores.length} ${AppLocalizations.of(context)?.translate('quizzes') ?? 'Quizzes'}',
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Action buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              coursesProvider.selectCourse(course.id);
                                              context.go('/course/${course.id}/lesson');
                                            },
                                            icon: Icon(
                                              progress.isCompleted 
                                                  ? Icons.replay 
                                                  : Icons.play_arrow,
                                              size: 18,
                                            ),
                                            label: Text(
                                              progress.isCompleted 
                                                  ? AppLocalizations.of(context)?.translate('rewatch') ?? 'Rewatch' 
                                                  : AppLocalizations.of(context)?.translate('continueLeaming') ?? 'Continue Learning',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryColor,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                            ),
                                          ),
                                        ),
                                        if (progress.certificate != null) ...[
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: () => context.go('/certificates'),
                                            icon: const Icon(Icons.workspace_premium, size: 18),
                                            label: Text(AppLocalizations.of(context)?.translate('viewCertificate') ?? 'View Certificate'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}