import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';

class LessonPlayerScreen extends StatelessWidget {
  final String courseId;
  final String lessonId;

  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/images/raqimLogo.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'مشغل الدرس',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('مشغل الفيديو سيكون هنا'),
      ),
    );
  }
}