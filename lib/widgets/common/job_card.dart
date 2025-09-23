import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobOffer job;
  final VoidCallback onTap;
  final bool showDetailedInfo;
  final VoidCallback? onClose;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.showDetailedInfo = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 8 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with company logo and info
                Row(
                  children: [
                    // Company logo
                    Container(
                      width: isMobile ? 40 : 60,
                      height: isMobile ? 40 : 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
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
                                size: isMobile ? 20 : 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (!isMobile) SizedBox(width: 16),
                    if (isMobile) SizedBox(width: 8),

                    // Company info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.company,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isMobile) SizedBox(height: 4),
                          if (isMobile) SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: isMobile ? 12 : 14,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                job.location,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: isMobile ? 11 : 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Urgent badge
                    if (job.isUrgent)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'عاجل',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                if (!isMobile) SizedBox(height: 16),
                if (isMobile) SizedBox(height: 8),

                // Job title
                Text(
                  job.title,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: isMobile ? 2 : null,
                  overflow: isMobile ? TextOverflow.ellipsis : null,
                ),

                if (!isMobile) SizedBox(height: 12),
                if (isMobile) SizedBox(height: 6),

                // Job details - responsive layout
                if (isMobile)
                  // Mobile: Stack details vertically to prevent overflow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: _buildJobDetail(Icons.work_outline, job.jobType)),
                          const SizedBox(width: 8),
                          Flexible(child: _buildJobDetail(Icons.trending_up, job.experience)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        job.salary,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                else
                  // Desktop: Keep horizontal layout
                  Row(
                    children: [
                      _buildJobDetail(Icons.work_outline, job.jobType),
                      const SizedBox(width: 16),
                      _buildJobDetail(Icons.trending_up, job.experience),
                      const Spacer(),
                      Text(
                        job.salary,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                // Skills
                if (job.skills.isNotEmpty) ...[
                  if (!isMobile) SizedBox(height: 16),
                  if (isMobile) SizedBox(height: 8),
                  Wrap(
                    spacing: isMobile ? 4 : 8,
                    runSpacing: isMobile ? 4 : 8,
                    children: job.skills.take(isMobile ? 2 : 3).map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: isMobile ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Job Description (only shown when showDetailedInfo is true)
                if (showDetailedInfo && job.description.isNotEmpty) ...[
                  if (!isMobile) SizedBox(height: 16),
                  if (isMobile) SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'وصف الوظيفة',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.description,
                          style: AppTextStyles.body.copyWith(
                            fontSize: isMobile ? 12 : 14,
                            height: 1.5,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: isMobile ? 3 : 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],

                if (!isMobile) SizedBox(height: 8),
                if (isMobile) SizedBox(height: 8),

                // Action button
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: Size(double.infinity, isMobile ? 44 : 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'تقدم الآن',
                    style: AppTextStyles.button.copyWith(
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondaryText),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}