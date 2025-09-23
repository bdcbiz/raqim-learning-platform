import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({super.key});

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _advertisements = [
    {
      'title': 'أدوات الذكاء الاصطناعي',
      'subtitle': 'اكتشف أفضل أدوات الذكاء الاصطناعي للإنتاجية والتطوير',
      'buttonText': 'استكشف الأدوات',
      'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'icon': Icons.auto_awesome,
      'action': 'ai_tools',
    },
    {
      'title': 'احصل على خصم 50%',
      'subtitle': 'على جميع دورات الذكاء الاصطناعي',
      'buttonText': 'ابدأ الآن',
      'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      'icon': Icons.discount,
      'code': 'AI50',
    },
    {
      'title': 'تعلم مع الخبراء',
      'subtitle': 'أفضل المدربين في مجال التقنية',
      'buttonText': 'اكتشف المزيد',
      'gradient': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      'icon': Icons.school,
    },
    {
      'title': 'شهادات معتمدة',
      'subtitle': 'احصل على شهادة معتمدة بعد إتمام الدورة',
      'buttonText': 'تصفح الدورات',
      'gradient': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'icon': Icons.verified,
    },
    {
      'title': 'مكتبة البرومبت',
      'subtitle': 'اكتشف أفضل البرومبت المجربة من المجتمع',
      'buttonText': 'استكشف المكتبة',
      'gradient': [const Color(0xFFBA5370), const Color(0xFFF4A6CD)],
      'icon': Icons.lightbulb,
      'action': 'prompt_library',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _advertisements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _advertisements.length,
            itemBuilder: (context, index) {
              final ad = _advertisements[index];
              return _buildAdvertisementCard(ad);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _advertisements.length,
            (index) => Container(
              width: _currentPage == index ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvertisementCard(Map<String, dynamic> ad) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: ad['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (ad['gradient'][0] as Color).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
          // Background Pattern
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ad['icon'],
                      color: Colors.white,
                      size: 28,
                    ),
                    if (ad['code'] != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ad['code'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ad['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  ad['subtitle'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle advertisement click
                      if (ad['action'] == 'ai_tools') {
                        context.go('/ai-tools');
                      } else if (ad['action'] == 'prompt_library') {
                        context.go('/community/prompts');
                      } else if (ad['code'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('كود الخصم ${ad['code']} تم نسخه'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ad['gradient'][0],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      ad['buttonText'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}