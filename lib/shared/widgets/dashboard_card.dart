import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.x4,
  });

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.isMinimal ? AppColors.surfaceRaised : AppColors.surface,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: theme.cardBorder,
        boxShadow: theme.cardShadow,
      ),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}
