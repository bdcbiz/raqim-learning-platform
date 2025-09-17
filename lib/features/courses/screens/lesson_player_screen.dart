import 'package:flutter/material.dart';
import '../../../core/widgets/raqim_app_bar.dart';

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
      appBar: RaqimAppBar(
        title: 'مشغل الدرس',
      ),
      body: const Center(
        child: Text('مشغل الفيديو سيكون هنا'),
      ),
    );
  }
}