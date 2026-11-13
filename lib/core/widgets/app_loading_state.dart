import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_spacing.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.label,
  });

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: label ?? 'Loading',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.controlActive,
                strokeWidth: 2,
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                label!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
