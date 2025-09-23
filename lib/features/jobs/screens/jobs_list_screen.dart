import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/job_card.dart';
import '../../../models/job_model.dart' as JobModels;


class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<JobModels.JobOffer> _allJobs = [];
  List<JobModels.JobOffer> _filteredJobs = [];
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    // بيانات وهمية لفرص العمل
    _allJobs = [
      JobModels.JobOffer(
        id: '1',
        title: 'مطور Flutter Senior',
        company: 'شركة التقنية المتقدمة',
        location: 'الرياض، السعودية',
        salary: '15,000 - 25,000 ر.س',
        jobType: 'دوام كامل',
        experience: '3-5 سنوات',
        companyLogo: 'https://picsum.photos/100/100?random=1',
        description: 'نبحث عن مطور Flutter خبير للانضمام إلى فريقنا التقني المتميز.',
        requirements: ['خبرة 3+ سنوات في Flutter', 'معرفة بـ Dart', 'خبرة في REST APIs'],
        benefits: ['تأمين صحي', 'مكافآت سنوية', 'بيئة عمل مرنة'],
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        skills: ['Flutter', 'Dart', 'Firebase', 'REST API'],
        isUrgent: true,
        contactEmail: 'hr@techcompany.com',
      ),
      JobModels.JobOffer(
        id: '2',
        title: 'مهندس ذكاء اصطناعي',
        company: 'مؤسسة الذكاء التقني',
        location: 'جدة، السعودية',
        salary: '18,000 - 30,000 ر.س',
        jobType: 'دوام كامل',
        experience: '2-4 سنوات',
        companyLogo: 'https://picsum.photos/100/100?random=2',
        description: 'فرصة مميزة للعمل في مجال الذكاء الاصطناعي وتطوير النماذج.',
        requirements: ['خبرة في Python', 'معرفة بـ TensorFlow/PyTorch', 'فهم الخوارزميات'],
        benefits: ['راتب مجزي', 'تدريب مستمر', 'مشاريع متنوعة'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        skills: ['Python', 'TensorFlow', 'Machine Learning', 'Deep Learning'],
        isUrgent: false,
        contactEmail: 'ai-jobs@smarttech.com',
      ),
      JobModels.JobOffer(
        id: '3',
        title: 'مطور React Native',
        company: 'ستارت اب التقنية',
        location: 'الدمام، السعودية',
        salary: '12,000 - 20,000 ر.س',
        jobType: 'دوام جزئي',
        experience: '1-3 سنوات',
        companyLogo: 'https://picsum.photos/100/100?random=3',
        description: 'انضم لفريق ناشئ ومتحمس لتطوير تطبيقات الموبايل.',
        requirements: ['خبرة في React Native', 'JavaScript/TypeScript', 'Git'],
        benefits: ['مرونة في العمل', 'بيئة إبداعية', 'نمو مهني'],
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        skills: ['React Native', 'JavaScript', 'TypeScript', 'Redux'],
        isUrgent: false,
        contactEmail: 'careers@techstartup.com',
      ),
      JobModels.JobOffer(
        id: '4',
        title: 'محلل بيانات',
        company: 'شركة البيانات الذكية',
        location: 'الرياض، السعودية',
        salary: '10,000 - 18,000 ر.س',
        jobType: 'دوام كامل',
        experience: '2-4 سنوات',
        companyLogo: 'https://picsum.photos/100/100?random=4',
        description: 'فرصة للعمل مع أحدث تقنيات تحليل البيانات والذكاء الاصطناعي.',
        requirements: ['خبرة في SQL', 'Python/R', 'تحليل البيانات'],
        benefits: ['تأمين شامل', 'بدلات', 'تطوير مهني'],
        postedDate: DateTime.now().subtract(const Duration(days: 4)),
        skills: ['SQL', 'Python', 'Power BI', 'Excel'],
        isUrgent: true,
        contactEmail: 'data-jobs@smartdata.com',
      ),
      JobModels.JobOffer(
        id: '5',
        title: 'مطور Backend',
        company: 'تقنيات المستقبل',
        location: 'المدينة المنورة، السعودية',
        salary: '14,000 - 22,000 ر.س',
        jobType: 'دوام كامل',
        experience: '3-6 سنوات',
        companyLogo: 'https://picsum.photos/100/100?random=5',
        description: 'نبحث عن مطور backend محترف للعمل على مشاريع تقنية متطورة.',
        requirements: ['Node.js أو Python', 'قواعد البيانات', 'Cloud Services'],
        benefits: ['راتب تنافسي', 'عمل عن بعد', 'تدريب تقني'],
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        skills: ['Node.js', 'MongoDB', 'AWS', 'Docker'],
        isUrgent: false,
        contactEmail: 'backend@futuretech.com',
      ),
      JobModels.JobOffer(
        id: '6',
        title: 'مصمم UI/UX',
        company: 'وكالة الإبداع الرقمي',
        location: 'الخبر، السعودية',
        salary: '8,000 - 15,000 ر.س',
        jobType: 'دوام كامل',
        experience: '1-3 سنوات',
        companyLogo: 'https://picsum.photos/100/100?random=6',
        description: 'انضم لفريق التصميم وساهم في إنشاء تجارب مستخدم مميزة.',
        requirements: ['خبرة في Figma/Adobe XD', 'فهم UX', 'مهارات تصميم'],
        benefits: ['بيئة إبداعية', 'مشاريع متنوعة', 'نمو مهني'],
        postedDate: DateTime.now().subtract(const Duration(days: 6)),
        skills: ['Figma', 'Adobe XD', 'Photoshop', 'UI Design'],
        isUrgent: false,
        contactEmail: 'design@creativedigital.com',
      ),
    ];

    _filteredJobs = List.from(_allJobs);
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final matchesSearch = _searchController.text.isEmpty ||
            job.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            job.company.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            job.location.toLowerCase().contains(_searchController.text.toLowerCase());

        final matchesFilter = _selectedFilter == 'الكل' ||
            (_selectedFilter == 'دوام كامل' && job.jobType == 'دوام كامل') ||
            (_selectedFilter == 'دوام جزئي' && job.jobType == 'دوام جزئي') ||
            (_selectedFilter == 'عاجل' && job.isUrgent);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'الوظائف',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          // Search and Filter Section - Pinned
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchFilterDelegate(
              searchController: _searchController,
              selectedFilter: _selectedFilter,
              onSearchChanged: _filterJobs,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
                _filterJobs();
              },
              buildFilterChip: _buildFilterChip,
            ),
          ),

          // Results Count
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Text(
                'تم العثور على ${_filteredJobs.length} وظيفة',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Jobs List
          _filteredJobs.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد وظائف متاحة',
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جرب تغيير معايير البحث',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : isWideScreen
                  ? _buildDesktopSliverLayout()
                  : _buildMobileSliverLayout(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        _filterJobs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSliverLayout() {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final job = _filteredJobs[index];
            return JobCard(
              job: job,
              onTap: () => _showJobDetails(job),
            );
          },
          childCount: _filteredJobs.length,
        ),
      ),
    );
  }

  Widget _buildMobileSliverLayout() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final job = _filteredJobs[index];
            return JobCard(
              job: job,
              onTap: () => _showJobDetails(job),
            );
          },
          childCount: _filteredJobs.length,
        ),
      ),
    );
  }


  void _showJobDetails(JobModels.JobOffer job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.inputBackground,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                job.companyLogo,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.business,
                                      color: AppColors.primaryColor,
                                      size: 30,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: AppTextStyles.h2.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.company,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      job.location,
                                      style: AppTextStyles.small.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Job Details
                      _buildDetailSection('الوصف', job.description),
                      _buildDetailSection('المتطلبات', job.requirements.join('\n• ')),
                      _buildDetailSection('المزايا', job.benefits.join('\n• ')),

                      const SizedBox(height: 24),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إرسال طلب التقديم بنجاح!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'تقدم الآن',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.inputBackground,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForSection(title),
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              height: 1.6,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSection(String title) {
    switch (title) {
      case 'الوصف':
        return Icons.description_outlined;
      case 'المتطلبات':
        return Icons.checklist_outlined;
      case 'المزايا':
        return Icons.star_outline;
      default:
        return Icons.info_outline;
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _SearchFilterDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String selectedFilter;
  final VoidCallback onSearchChanged;
  final Function(String) onFilterChanged;
  final Widget Function(String) buildFilterChip;

  _SearchFilterDelegate({
    required this.searchController,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.buildFilterChip,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.white,
      elevation: shrinkOffset > 0 ? 4 : 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              onChanged: (value) => onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'ابحث عن وظيفة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => onFilterChanged('الكل'),
                    child: buildFilterChip('الكل'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onFilterChanged('دوام كامل'),
                    child: buildFilterChip('دوام كامل'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onFilterChanged('دوام جزئي'),
                    child: buildFilterChip('دوام جزئي'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onFilterChanged('عاجل'),
                    child: buildFilterChip('عاجل'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 140;

  @override
  double get minExtent => 140;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}