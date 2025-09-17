import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class JobOffer {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String jobType;
  final String experience;
  final String companyLogo;
  final String description;
  final List<String> requirements;
  final List<String> benefits;
  final DateTime postedDate;
  final List<String> skills;
  final bool isUrgent;

  JobOffer({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.experience,
    required this.companyLogo,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.postedDate,
    required this.skills,
    required this.isUrgent,
  });
}

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<JobOffer> _allJobs = [];
  List<JobOffer> _filteredJobs = [];
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    // بيانات وهمية لفرص العمل
    _allJobs = [
      JobOffer(
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
      ),
      JobOffer(
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
      ),
      JobOffer(
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
      ),
      JobOffer(
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
      ),
      JobOffer(
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
      ),
      JobOffer(
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
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          'فرص العمل',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterJobs(),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن وظيفة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterJobs();
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
                      _buildFilterChip('الكل'),
                      const SizedBox(width: 8),
                      _buildFilterChip('دوام كامل'),
                      const SizedBox(width: 8),
                      _buildFilterChip('دوام جزئي'),
                      const SizedBox(width: 8),
                      _buildFilterChip('عاجل'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Container(
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

          // Jobs List
          Expanded(
            child: _filteredJobs.isEmpty
                ? Center(
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
                  )
                : isWideScreen
                    ? _buildDesktopLayout()
                    : _buildMobileLayout(),
          ),
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

  Widget _buildDesktopLayout() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  void _showJobDetails(JobOffer job) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTextStyles.body.copyWith(
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildJobCard(JobOffer job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showJobDetails(job),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo - Circle with first letter
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2B3990),
                        const Color(0xFF4A5EC1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      job.company.isNotEmpty ? job.company[0] : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Job Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Title
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Company Name
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Location Row
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Bottom Row - Tags and Salary
                      Row(
                        children: [
                          // Job Type Tag
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F4FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                job.jobType,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2196F3),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Experience Tag (only show if not beginner)
                          if (!job.experience.contains('1') && !job.experience.contains('مبتدئ'))
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  job.experience,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9C27B0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          const Spacer(),
                          // Salary
                          Flexible(
                            fit: FlexFit.loose,
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: job.salary.split(' ')[0],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '/شهر',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}