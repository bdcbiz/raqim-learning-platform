import 'package:flutter/material.dart';
import '../widgets/tracking/user_interactions_viewer.dart';
import '../core/theme/app_theme.dart';

class UserActivityScreen extends StatelessWidget {
  const UserActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('نشاط المستخدم'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        titleTextStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: UserInteractionsViewer(),
      ),
    );
  }
}