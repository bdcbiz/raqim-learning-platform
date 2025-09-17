import 'package:flutter/material.dart';
import '../../../core/widgets/raqim_app_bar.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RaqimAppBar(
        title: 'إنشاء منشور جديد',
      ),
      body: const Center(
        child: Text('نموذج إنشاء المنشور سيكون هنا'),
      ),
    );
  }
}