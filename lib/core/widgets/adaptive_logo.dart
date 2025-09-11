import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class AdaptiveLogo extends StatelessWidget {
  final double height;
  final bool useWhiteVersion;
  
  const AdaptiveLogo({
    super.key,
    this.height = 40,
    this.useWhiteVersion = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine the color for the logo
    final Color logoColor = useWhiteVersion 
        ? Colors.white
        : isDarkMode 
            ? Colors.white 
            : AppColors.primaryColor;
    
    return SvgPicture.asset(
      'assets/images/raqimLogo.svg',
      height: height,
      colorFilter: ColorFilter.mode(
        logoColor,
        BlendMode.srcIn,
      ),
      placeholderBuilder: (context) => Container(
        height: height,
        width: height * 2,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(logoColor),
        ),
      ),
    );
  }
}