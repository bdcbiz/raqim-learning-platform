import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء منشور جديد'),
      ),
      body: const Center(
        child: Text('نموذج إنشاء المنشور سيكون هنا'),
      ),
    );
  }
}