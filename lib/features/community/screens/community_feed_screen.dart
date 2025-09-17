import 'package:flutter/material.dart';
import '../widgets/community_widget.dart';
import '../../../core/widgets/raqim_app_bar.dart';
import '../../../core/localization/app_localizations.dart';

/// Community Feed Screen that uses the refactored CommunityWidget
/// This screen now simply wraps the CommunityWidget in a Scaffold
class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using the refactored CommunityWidget which includes all functionality
    // The widget already includes header with title and sort options
    return Scaffold(
      appBar: RaqimAppBar(
        title: AppLocalizations.of(context)?.translate('communityTitle') ?? 'المجتمع',
      ),
      body: const CommunityWidget(),
    );
  }
}