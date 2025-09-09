import 'package:flutter/material.dart';

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
        title: const Text('مشغل الدرس'),
      ),
      body: const Center(
        child: Text('مشغل الفيديو سيكون هنا'),
      ),
    );
  }
}