import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class UnifiedFilterSection extends StatelessWidget {
  final bool isVisible;
  final List<FilterChipData> filters;
  final String? selectedCategory;
  final String? selectedLevel;
  final Function(String?)? onCategoryChanged;
  final Function(String?)? onLevelChanged;

  const UnifiedFilterSection({
    super.key,
    required this.isVisible,
    required this.filters,
    this.selectedCategory,
    this.selectedLevel,
    this.onCategoryChanged,
    this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? null : 0,
      curve: Curves.easeInOut,
      child: isVisible
          ? Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  if (filters.any((f) => f.type == FilterType.category)) ...[
                    Text(
                      'التصنيف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filters
                          .where((f) => f.type == FilterType.category)
                          .map((filter) => _buildFilterChip(
                                filter.label,
                                selectedCategory == filter.value,
                                () => onCategoryChanged?.call(
                                  selectedCategory == filter.value ? null : filter.value,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Level Filter
                  if (filters.any((f) => f.type == FilterType.level)) ...[
                    Text(
                      'المستوى',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filters
                          .where((f) => f.type == FilterType.level)
                          .map((filter) => _buildFilterChip(
                                filter.label,
                                selectedLevel == filter.value,
                                () => onLevelChanged?.call(
                                  selectedLevel == filter.value ? null : filter.value,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            )
          : Container(),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

enum FilterType {
  category,
  level,
  status,
  other,
}

class FilterChipData {
  final String label;
  final String value;
  final FilterType type;

  const FilterChipData({
    required this.label,
    required this.value,
    required this.type,
  });
}