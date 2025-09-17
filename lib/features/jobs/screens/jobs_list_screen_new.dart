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
  String _selectedLevel = '';
  String _selectedLocation = '';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    _allJobs = [
      JobOffer(
        id: '1',
        title: 'مطور Flutter',
        company: 'شركة التقنية المتقدمة',
        location: 'الرياض',
        salary: '15k - 20k',
        jobType: 'دوام كامل',
        experience: 'متوسط',
        companyLogo: 'https://example.com/logo1.png',
        description: 'نبحث عن مطور Flutter ذو خبرة لتطوير تطبيقات الجوال.',
        requirements: ['خبرة 3 سنوات في Flutter', 'معرفة بـ Firebase', 'خبرة في State Management'],
        benefits: ['تأمين صحي', 'مكافآت سنوية', 'عمل مرن'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
        isUrgent: true,
      ),
      JobOffer(
        id: '2',
        title: 'مصمم UI/UX',
        company: 'استوديو الإبداع',
        location: 'جدة',
        salary: '10k - 15k',
        jobType: 'عن بُعد',
        experience: 'مبتدئ',
        companyLogo: 'https://example.com/logo2.png',
        description: 'فرصة رائعة لمصمم UI/UX مبتدئ للانضمام لفريقنا الإبداعي.',
        requirements: ['معرفة بـ Figma', 'حس إبداعي عالي', 'القدرة على العمل ضمن فريق'],
        benefits: ['عمل عن بُعد', 'تدريب مستمر', 'بيئة عمل ممتعة'],
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        skills: ['Figma', 'Adobe XD', 'Prototyping'],
        isUrgent: false,
      ),
      JobOffer(
        id: '3',
        title: 'مدير مشاريع تقنية',
        company: 'مجموعة الابتكار',
        location: 'الدمام',
        salary: '25k - 30k',
        jobType: 'دوام كامل',
        experience: 'خبير',
        companyLogo: 'https://example.com/logo3.png',
        description: 'نحتاج مدير مشاريع خبير لقيادة فريق التطوير.',
        requirements: ['خبرة 5 سنوات', 'شهادة PMP', 'مهارات قيادية'],
        benefits: ['راتب مجزي', 'سيارة شركة', 'تأمين شامل'],
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        skills: ['Agile', 'Scrum', 'Leadership', 'Communication'],
        isUrgent: true,
      ),
    ];
    _filterJobs();
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        bool matchesSearch = _searchController.text.isEmpty ||
            job.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            job.company.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesFilter = _selectedFilter == 'الكل' || job.jobType == _selectedFilter;
        bool matchesLevel = _selectedLevel.isEmpty || job.experience == _selectedLevel;
        bool matchesLocation = _selectedLocation.isEmpty || job.location == _selectedLocation;

        return matchesSearch && matchesFilter && matchesLevel && matchesLocation;
      }).toList();
    });
  }

  void _showJobDetails(JobOffer job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job.company,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(job.location, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.work_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(job.jobType, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 24),
              Text('وصف الوظيفة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(job.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 24),
              Text('المتطلبات', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...job.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(req, style: const TextStyle(height: 1.5))),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال طلبك بنجاح!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B3990),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'التقديم للوظيفة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('jobOpportunities') ?? 'فرص العمل',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterJobs(),
              decoration: InputDecoration(
                hintText: 'ابحث عن وظيفة...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Filters
          Container(
            height: 50,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip('الكل', 'الكل'),
                _buildFilterChip('دوام كامل', 'دوام كامل'),
                _buildFilterChip('عن بُعد', 'عن بُعد'),
                _buildFilterChip('دوام جزئي', 'دوام جزئي'),
              ],
            ),
          ),

          // Jobs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                return _buildJobCard(_filteredJobs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'الكل';
            _filterJobs();
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        showCheckmark: false,
      ),
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
                          Container(
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
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Experience Tag
                          if (job.experience != 'مبتدئ')
                            Container(
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
                              ),
                            ),
                          const Spacer(),
                          // Salary
                          RichText(
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