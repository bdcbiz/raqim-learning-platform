import 'package:flutter/material.dart';
import '../widgets/tracking/user_interactions_viewer.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/raqim_app_bar.dart';

class UserActivityScreen extends StatelessWidget {
  const UserActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: RaqimAppBar(
        title: 'نشاط المستخدم',
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: UserInteractionsViewer(),
      ),
    );
  }
}