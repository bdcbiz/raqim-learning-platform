import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/community_widget.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: !kIsWeb,
        leading: kIsWeb ? null : null,
        title: kIsWeb ? Text(
          'المجتمع',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ) : Row(
          children: [
            SvgPicture.asset(
              'assets/images/raqimLogo.svg',
              height: 32,
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'المجتمع',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: const CommunityWidget(),
    );
  }
}