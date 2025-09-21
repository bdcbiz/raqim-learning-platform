import 'package:flutter/material.dart';
import '../widgets/community_widget.dart';
import '../../../widgets/common/raqim_app_bar.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Community Feed Screen that uses the refactored CommunityWidget
/// This screen now simply wraps the CommunityWidget in a Scaffold
class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: const RaqimAppBar(
        title: 'المجتمع',
      ),
      body: const CommunityWidget(),
    );
  }
}